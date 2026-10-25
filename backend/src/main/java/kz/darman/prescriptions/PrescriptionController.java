package kz.darman.prescriptions;

import java.util.List;
import java.util.UUID;
import kz.darman.config.AuthUser;
import kz.darman.prescriptions.PrescriptionDtos.PrescriptionDto;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/prescriptions")
public class PrescriptionController {
    private final PrescriptionService service;

    public PrescriptionController(PrescriptionService service) {
        this.service = service;
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public PrescriptionDto create(@AuthenticationPrincipal AuthUser user,
                                  @RequestPart(value = "files", required = false) List<MultipartFile> files,
                                  @RequestParam(value = "note", required = false) String note) {
        return service.create(user.id(), files, note);
    }

    @PostMapping(value = "/{id}/files", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public PrescriptionDto addFiles(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id,
                                    @RequestPart("files") List<MultipartFile> files) {
        return service.addFiles(user.id(), id, files);
    }

    @DeleteMapping("/{id}/files/{fileId}")
    public PrescriptionDto removeFile(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id, @PathVariable UUID fileId) {
        return service.removeFile(user.id(), id, fileId);
    }

    @PostMapping("/{id}/submit")
    public PrescriptionDto submit(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id) {
        return service.submit(user.id(), id);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteDraft(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id) {
        service.deleteDraft(user.id(), id);
    }

    @GetMapping
    public List<PrescriptionDto> list(@AuthenticationPrincipal AuthUser user) {
        return service.list(user.id());
    }

    @GetMapping("/{id}")
    public PrescriptionDto get(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id) {
        return service.get(user, id);
    }

    /** Authorized download only: owner or staff with PRESCRIPTION_REVIEW. Never cacheable, never public. */
    @GetMapping("/{id}/files/{fileId}")
    public ResponseEntity<InputStreamResource> download(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id,
                                                        @PathVariable UUID fileId) {
        PrescriptionService.Download d = service.download(user, id, fileId);
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(d.mimeType()))
                .contentLength(d.size())
                .cacheControl(CacheControl.noStore())
                .header(HttpHeaders.CONTENT_DISPOSITION, ContentDisposition.inline().filename("prescription-file").build().toString())
                .header("X-Content-Type-Options", "nosniff")
                .body(new InputStreamResource(d.stream()));
    }
}
