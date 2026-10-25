package kz.darman.prescriptions;

import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;
import java.time.Duration;
import java.time.Instant;
import java.util.HexFormat;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import kz.darman.audit.AuditService;
import kz.darman.common.ApiException;
import kz.darman.common.PageResponse;
import kz.darman.config.AppProperties;
import kz.darman.config.AuthUser;
import kz.darman.notifications.NotificationService;
import kz.darman.prescriptions.PrescriptionDtos.*;
import kz.darman.prescriptions.PrescriptionRepositories.*;
import kz.darman.storage.FileStorage;
import kz.darman.users.User;
import kz.darman.users.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.PageRequest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
public class PrescriptionService {
    private static final Logger log = LoggerFactory.getLogger(PrescriptionService.class);
    private static final int DEFAULT_VALID_DAYS = 30;
    public static final String REVIEW_PERMISSION = "PRESCRIPTION_REVIEW";

    public record Download(InputStream stream, String mimeType, String fileName, long size) {}

    private final PrescriptionRepository prescriptions;
    private final FileRepository files;
    private final EventRepository events;
    private final FileStorage storage;
    private final AppProperties props;
    private final AuditService audit;
    private final NotificationService notifications;
    private final UserRepository users;
    private final JdbcTemplate jdbc;

    public PrescriptionService(PrescriptionRepository prescriptions, FileRepository files, EventRepository events, FileStorage storage,
                               AppProperties props, AuditService audit, NotificationService notifications, UserRepository users,
                               JdbcTemplate jdbc) {
        this.prescriptions = prescriptions;
        this.files = files;
        this.events = events;
        this.storage = storage;
        this.props = props;
        this.audit = audit;
        this.notifications = notifications;
        this.users = users;
        this.jdbc = jdbc;
    }

    // ───────────── customer ─────────────

    @Transactional
    public PrescriptionDto create(UUID userId, List<MultipartFile> uploads, String note) {
        Prescription p = new Prescription();
        p.setUserId(userId);
        p.setNote(note == null || note.isBlank() ? null : note.trim().substring(0, Math.min(note.trim().length(), 500)));
        prescriptions.save(p);
        event(p, userId, "CREATED", null, PrescriptionStatus.DRAFT, null);
        if (uploads != null && !uploads.isEmpty()) attach(p, uploads);
        return dto(p, true);
    }

    @Transactional
    public PrescriptionDto addFiles(UUID userId, UUID id, List<MultipartFile> uploads) {
        Prescription p = ownedDraft(userId, id);
        attach(p, uploads);
        return dto(p, true);
    }

    @Transactional
    public PrescriptionDto removeFile(UUID userId, UUID id, UUID fileId) {
        Prescription p = ownedDraft(userId, id);
        PrescriptionFile f = files.findById(fileId).filter(x -> x.getPrescriptionId().equals(id)).orElseThrow(() -> ApiException.notFound("File"));
        try {
            storage.delete(f.getStorageKey());
        } catch (IOException e) {
            log.warn("Could not delete stored file {}: {}", f.getStorageKey(), e.getMessage());
        }
        files.delete(f);
        return dto(p, true);
    }

    @Transactional
    public PrescriptionDto submit(UUID userId, UUID id) {
        Prescription p = ownedDraft(userId, id);
        if (files.countByPrescriptionId(id) == 0) {
            throw ApiException.unprocessable("PRESCRIPTION_FILES_REQUIRED", "Attach at least one photo or PDF before submitting");
        }
        p.setStatus(PrescriptionStatus.SUBMITTED);
        p.setSubmittedAt(Instant.now());
        event(p, userId, "SUBMITTED", PrescriptionStatus.DRAFT, PrescriptionStatus.SUBMITTED, null);
        audit.record("PRESCRIPTION_SUBMITTED", "Prescription", id, null);
        return dto(p, true);
    }

    @Transactional
    public void deleteDraft(UUID userId, UUID id) {
        Prescription p = ownedDraft(userId, id);
        for (PrescriptionFile f : files.findByPrescriptionIdOrderByCreatedAtAsc(id)) {
            try {
                storage.delete(f.getStorageKey());
            } catch (IOException e) {
                log.warn("Could not delete stored file {}: {}", f.getStorageKey(), e.getMessage());
            }
        }
        prescriptions.delete(p);
    }

    @Transactional(readOnly = true)
    public List<PrescriptionDto> list(UUID userId) {
        return prescriptions.findByUserIdOrderByCreatedAtDesc(userId).stream().map(p -> dto(p, false)).toList();
    }

    @Transactional
    public PrescriptionDto get(AuthUser user, UUID id) {
        Prescription p = accessible(user, id);
        if (!p.getUserId().equals(user.id())) audit.record("PRESCRIPTION_VIEWED_BY_STAFF", "Prescription", id, null);
        return dto(p, true);
    }

    @Transactional
    public Download download(AuthUser user, UUID id, UUID fileId) {
        Prescription p = accessible(user, id);
        PrescriptionFile f = files.findById(fileId).filter(x -> x.getPrescriptionId().equals(id)).orElseThrow(() -> ApiException.notFound("File"));
        audit.record("PRESCRIPTION_FILE_ACCESSED", "PrescriptionFile", fileId, "prescription=" + id + (p.getUserId().equals(user.id()) ? " owner" : " staff"));
        try {
            return new Download(storage.open(f.getStorageKey()), f.getMimeType(), f.getOriginalName(), f.getSizeBytes());
        } catch (IOException e) {
            throw ApiException.notFound("File");
        }
    }

    /** Used by checkout: returns the prescription only if it is approved, unexpired, owned by the user and not yet used. */
    @Transactional(readOnly = true)
    public Prescription requireUsable(UUID userId, UUID id) {
        Prescription p = prescriptions.findById(id).filter(x -> x.getUserId().equals(userId))
                .orElseThrow(() -> ApiException.unprocessable("PRESCRIPTION_REQUIRED", "A valid approved prescription is required"));
        if (p.effectiveStatus() != PrescriptionStatus.APPROVED) {
            throw ApiException.unprocessable("PRESCRIPTION_NOT_APPROVED", "The prescription is not approved (status " + p.effectiveStatus() + ")");
        }
        if (isUsed(id)) throw ApiException.unprocessable("PRESCRIPTION_ALREADY_USED", "This prescription has already been used for an order");
        return p;
    }

    // ───────────── review (pharmacist) ─────────────

    @Transactional
    public PageResponse<ReviewItemDto> reviewQueue(List<PrescriptionStatus> statuses, int page, int size) {
        var result = statuses == null || statuses.isEmpty()
                ? prescriptions.findAllByOrderByCreatedAtDesc(PageRequest.of(page, size))
                : prescriptions.findByStatusInOrderBySubmittedAtAsc(statuses, PageRequest.of(page, size));
        audit.record("PRESCRIPTION_QUEUE_VIEWED", "Prescription", null, null);
        return PageResponse.of(result, p -> new ReviewItemDto(dto(p, false), p.getUserId(),
                users.findById(p.getUserId()).map(User::getFullName).orElse(null)));
    }

    @Transactional
    public PrescriptionDto startReview(AuthUser reviewer, UUID id) {
        Prescription p = load(id);
        assertNotOwn(reviewer, p);
        requireStatus(p, PrescriptionStatus.SUBMITTED);
        p.setStatus(PrescriptionStatus.UNDER_REVIEW);
        p.setReviewedBy(reviewer.id());
        event(p, reviewer.id(), "REVIEW_STARTED", PrescriptionStatus.SUBMITTED, PrescriptionStatus.UNDER_REVIEW, null);
        audit.record("PRESCRIPTION_REVIEW_STARTED", "Prescription", id, null);
        notifications.notify(p.getUserId(), "PRESCRIPTIONS", "PRESCRIPTION", "RX_UNDER_REVIEW", "Prescription is under review", id);
        return dto(p, true);
    }

    @Transactional
    public PrescriptionDto approve(AuthUser reviewer, UUID id, ApproveRequest req) {
        Prescription p = load(id);
        assertNotOwn(reviewer, p);
        requireStatus(p, PrescriptionStatus.UNDER_REVIEW);
        int days = req != null && req.validDays() != null ? Math.min(Math.max(req.validDays(), 1), 90) : DEFAULT_VALID_DAYS;
        p.setStatus(PrescriptionStatus.APPROVED);
        p.setReviewedBy(reviewer.id());
        p.setReviewedAt(Instant.now());
        p.setExpiresAt(Instant.now().plus(Duration.ofDays(days)));
        p.setRejectionReason(null);
        event(p, reviewer.id(), "APPROVED", PrescriptionStatus.UNDER_REVIEW, PrescriptionStatus.APPROVED, req == null ? null : req.comment());
        audit.record("PRESCRIPTION_APPROVED", "Prescription", id, null);
        notifications.notify(p.getUserId(), "PRESCRIPTIONS", "PRESCRIPTION", "RX_APPROVED", "Prescription approved", id);
        return dto(p, true);
    }

    @Transactional
    public PrescriptionDto reject(AuthUser reviewer, UUID id, RejectRequest req) {
        Prescription p = load(id);
        assertNotOwn(reviewer, p);
        requireStatus(p, PrescriptionStatus.UNDER_REVIEW);
        p.setStatus(PrescriptionStatus.REJECTED);
        p.setReviewedBy(reviewer.id());
        p.setReviewedAt(Instant.now());
        p.setRejectionReason(req.reason().trim());
        event(p, reviewer.id(), "REJECTED", PrescriptionStatus.UNDER_REVIEW, PrescriptionStatus.REJECTED, req.reason());
        audit.record("PRESCRIPTION_REJECTED", "Prescription", id, null);
        notifications.notify(p.getUserId(), "PRESCRIPTIONS", "PRESCRIPTION", "RX_REJECTED", "Prescription rejected", id);
        return dto(p, true);
    }

    /** Demo-only automatic review, enabled by darman.demo.auto-review-prescriptions. Clearly labeled in the event log. */
    @Transactional
    public void demoAutoReview(UUID prescriptionId, UUID systemActor, boolean approve) {
        Prescription p = load(prescriptionId);
        PrescriptionStatus from = p.getStatus();
        if (from == PrescriptionStatus.SUBMITTED) {
            p.setStatus(PrescriptionStatus.UNDER_REVIEW);
            event(p, systemActor, "REVIEW_STARTED", from, PrescriptionStatus.UNDER_REVIEW, "DEMO: automated demo step, not a pharmacist review");
        } else if (from == PrescriptionStatus.UNDER_REVIEW && approve) {
            p.setStatus(PrescriptionStatus.APPROVED);
            p.setReviewedAt(Instant.now());
            p.setExpiresAt(Instant.now().plus(Duration.ofDays(DEFAULT_VALID_DAYS)));
            event(p, systemActor, "APPROVED", from, PrescriptionStatus.APPROVED, "DEMO: approved automatically — NOT a verification by a licensed pharmacist");
        }
    }

    @Scheduled(fixedDelayString = "PT15M", initialDelayString = "PT1M")
    @Transactional
    public void expireApproved() {
        for (Prescription p : prescriptions.findExpired(Instant.now())) {
            p.setStatus(PrescriptionStatus.EXPIRED);
            event(p, null, "EXPIRED", PrescriptionStatus.APPROVED, PrescriptionStatus.EXPIRED, null);
        }
    }

    // ───────────── helpers ─────────────

    private void attach(Prescription p, List<MultipartFile> uploads) {
        long existing = files.countByPrescriptionId(p.getId());
        if (existing + uploads.size() > props.storage().maxFilesPerPrescription()) {
            throw ApiException.unprocessable("TOO_MANY_FILES", "At most " + props.storage().maxFilesPerPrescription() + " files per prescription");
        }
        for (MultipartFile up : uploads) {
            if (up.isEmpty()) throw ApiException.badRequest("EMPTY_FILE", "Empty file");
            if (up.getSize() > props.storage().maxFileBytes()) {
                throw new ApiException(org.springframework.http.HttpStatus.PAYLOAD_TOO_LARGE, "FILE_TOO_LARGE", "File exceeds the size limit");
            }
            try {
                byte[] bytes = up.getBytes();
                FileSniffer.Detected type = FileSniffer.detect(bytes);
                if (type == null) throw ApiException.unprocessable("UNSUPPORTED_FILE_TYPE", "Only JPEG, PNG and PDF files are accepted");
                String key = "rx/%s/%s/%s.%s".formatted(p.getUserId(), p.getId(), UUID.randomUUID(), type.ext());
                storage.put(key, new java.io.ByteArrayInputStream(bytes), bytes.length);
                PrescriptionFile f = new PrescriptionFile();
                f.setPrescriptionId(p.getId());
                f.setStorageKey(key);
                f.setOriginalName(safeName(up.getOriginalFilename(), type.ext()));
                f.setMimeType(type.mime());
                f.setSizeBytes(bytes.length);
                f.setSha256(HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes)));
                files.save(f);
            } catch (IOException | java.security.NoSuchAlgorithmException e) {
                throw new ApiException(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR, "STORAGE_ERROR", "Could not store the file");
            }
        }
        audit.record("PRESCRIPTION_FILES_ADDED", "Prescription", p.getId(), "count=" + uploads.size());
    }

    private static String safeName(String name, String ext) {
        String base = name == null ? "prescription." + ext : name.replaceAll("[^\\p{L}\\p{N}._ -]", "_");
        return base.length() > 120 ? base.substring(base.length() - 120) : base;
    }

    private Prescription load(UUID id) {
        return prescriptions.findById(id).orElseThrow(() -> ApiException.notFound("Prescription"));
    }

    private Prescription ownedDraft(UUID userId, UUID id) {
        Prescription p = load(id);
        if (!p.getUserId().equals(userId)) throw ApiException.notFound("Prescription");
        if (p.getStatus() != PrescriptionStatus.DRAFT) {
            throw ApiException.conflict("PRESCRIPTION_NOT_EDITABLE", "Only a draft prescription can be changed");
        }
        return p;
    }

    /** Owner, or staff holding PRESCRIPTION_REVIEW. Anyone else gets 404 so existence is not leaked. */
    private Prescription accessible(AuthUser user, UUID id) {
        Prescription p = load(id);
        boolean owner = p.getUserId().equals(user.id());
        if (!owner && !user.has(REVIEW_PERMISSION)) {
            audit.recordIndependent("PRESCRIPTION_ACCESS_DENIED", "Prescription", id, null);
            throw ApiException.notFound("Prescription");
        }
        return p;
    }

    private void assertNotOwn(AuthUser reviewer, Prescription p) {
        if (p.getUserId().equals(reviewer.id())) {
            throw ApiException.forbidden("Staff cannot review their own prescription");
        }
    }

    private void requireStatus(Prescription p, PrescriptionStatus expected) {
        if (p.getStatus() != expected) {
            throw ApiException.conflict("INVALID_PRESCRIPTION_STATE", "Prescription is " + p.getStatus() + ", expected " + expected);
        }
    }

    private void event(Prescription p, UUID actor, String type, PrescriptionStatus from, PrescriptionStatus to, String comment) {
        PrescriptionReviewEvent e = new PrescriptionReviewEvent();
        e.setPrescriptionId(p.getId());
        e.setActorId(actor);
        e.setEventType(type);
        e.setFromStatus(from == null ? null : from.name());
        e.setToStatus(to == null ? null : to.name());
        e.setComment(comment == null || comment.isBlank() ? null : comment.trim());
        events.save(e);
    }

    private boolean isUsed(UUID id) {
        Integer n = jdbc.queryForObject("select count(*) from orders where prescription_id = ?", Integer.class, id);
        return n != null && n > 0;
    }

    private PrescriptionDto dto(Prescription p, boolean detailed) {
        List<FileDto> fs = files.findByPrescriptionIdOrderByCreatedAtAsc(p.getId()).stream()
                .map(f -> new FileDto(f.getId(), f.getOriginalName(), f.getMimeType(), f.getSizeBytes())).toList();
        List<EventDto> es = detailed ? events.findByPrescriptionIdOrderByCreatedAtAsc(p.getId()).stream()
                .map(e -> new EventDto(e.getEventType(), e.getFromStatus(), e.getToStatus(), e.getComment(), e.getCreatedAt())).toList() : List.of();
        PrescriptionStatus eff = p.effectiveStatus();
        boolean usable = eff == PrescriptionStatus.APPROVED && !isUsed(p.getId());
        boolean demo = es.stream().anyMatch(e -> e.comment() != null && e.comment().startsWith("DEMO:"));
        return new PrescriptionDto(p.getId(), eff.name(), p.getNote(), p.getRejectionReason(), p.getSubmittedAt(), p.getReviewedAt(),
                p.getExpiresAt(), p.getCreatedAt(), fs, es, usable, demo);
    }
}
