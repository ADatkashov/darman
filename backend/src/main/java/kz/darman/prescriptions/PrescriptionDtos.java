package kz.darman.prescriptions;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public final class PrescriptionDtos {
    private PrescriptionDtos() {}

    public record FileDto(UUID id, String originalName, String mimeType, long sizeBytes) {}

    public record EventDto(String type, String fromStatus, String toStatus, String comment, Instant createdAt) {}

    public record PrescriptionDto(UUID id, String status, String note, String rejectionReason, Instant submittedAt,
                                  Instant reviewedAt, Instant expiresAt, Instant createdAt, List<FileDto> files,
                                  List<EventDto> events, boolean usableForOrder, boolean demoReview) {}

    /** Reviewer view: includes the patient's display name only; phone and address are intentionally omitted. */
    public record ReviewItemDto(PrescriptionDto prescription, UUID userId, String userFullName) {}

    public record ApproveRequest(String comment, Integer validDays) {}

    public record RejectRequest(@jakarta.validation.constraints.NotBlank @jakarta.validation.constraints.Size(max = 500) String reason) {}
}
