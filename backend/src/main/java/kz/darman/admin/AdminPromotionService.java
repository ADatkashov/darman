package kz.darman.admin;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import kz.darman.audit.AuditService;
import kz.darman.common.ApiException;
import kz.darman.promotions.Promotion;
import kz.darman.promotions.PromotionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminPromotionService {
    public record PromotionRequest(@NotBlank @Pattern(regexp = "BANNER|PROMO_CODE") String kind, @Size(max = 40) @Pattern(regexp = "[A-Za-z0-9_-]*") String code,
                                   @NotBlank String titleRu, @NotBlank String titleKk, @NotBlank String titleEn, String subtitleRu, String subtitleKk,
                                   String subtitleEn, @Min(1) @Max(90) Integer discountPercent, @DecimalMin("0") BigDecimal minOrderAmount,
                                   Instant startsAt, Instant endsAt, Integer sortOrder, Boolean active) {}

    public record PromotionDto(UUID id, String kind, String code, String titleRu, String titleKk, String titleEn, String subtitleRu, String subtitleKk,
                               String subtitleEn, Integer discountPercent, BigDecimal minOrderAmount, Instant startsAt, Instant endsAt, int sortOrder,
                               boolean active) {}

    private final PromotionRepository repo;
    private final AuditService audit;

    public AdminPromotionService(PromotionRepository repo, AuditService audit) {
        this.repo = repo;
        this.audit = audit;
    }

    @Transactional(readOnly = true)
    public List<PromotionDto> list() {
        return repo.findAll().stream().map(AdminPromotionService::dto).toList();
    }

    @Transactional
    public PromotionDto save(UUID id, PromotionRequest r) {
        if ("PROMO_CODE".equals(r.kind()) && (r.code() == null || r.code().isBlank() || r.discountPercent() == null)) {
            throw ApiException.badRequest("PROMO_FIELDS_REQUIRED", "A promo code needs a code and a discount percent");
        }
        if (r.startsAt() != null && r.endsAt() != null && !r.endsAt().isAfter(r.startsAt())) {
            throw ApiException.badRequest("INVALID_PERIOD", "endsAt must be after startsAt");
        }
        Promotion p = id == null ? new Promotion() : repo.findById(id).orElseThrow(() -> ApiException.notFound("Promotion"));
        p.setKind(r.kind());
        p.setCode(r.code() == null || r.code().isBlank() ? null : r.code().trim().toUpperCase());
        p.setTitleRu(r.titleRu());
        p.setTitleKk(r.titleKk());
        p.setTitleEn(r.titleEn());
        p.setSubtitleRu(r.subtitleRu());
        p.setSubtitleKk(r.subtitleKk());
        p.setSubtitleEn(r.subtitleEn());
        p.setDiscountPercent(r.discountPercent());
        p.setMinOrderAmount(r.minOrderAmount());
        p.setStartsAt(r.startsAt());
        p.setEndsAt(r.endsAt());
        if (r.sortOrder() != null) p.setSortOrder(r.sortOrder());
        if (r.active() != null) p.setActive(r.active());
        p = repo.save(p);
        audit.record(id == null ? "PROMOTION_CREATED" : "PROMOTION_UPDATED", "Promotion", p.getId(), null);
        return dto(p);
    }

    @Transactional
    public void delete(UUID id) {
        Promotion p = repo.findById(id).orElseThrow(() -> ApiException.notFound("Promotion"));
        p.setActive(false);
        audit.record("PROMOTION_DEACTIVATED", "Promotion", id, null);
    }

    private static PromotionDto dto(Promotion p) {
        return new PromotionDto(p.getId(), p.getKind(), p.getCode(), p.getTitleRu(), p.getTitleKk(), p.getTitleEn(), p.getSubtitleRu(), p.getSubtitleKk(),
                p.getSubtitleEn(), p.getDiscountPercent(), p.getMinOrderAmount(), p.getStartsAt(), p.getEndsAt(), p.getSortOrder(), p.isActive());
    }
}
