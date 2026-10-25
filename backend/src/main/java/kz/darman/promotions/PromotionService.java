package kz.darman.promotions;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import kz.darman.common.ApiException;
import kz.darman.common.Lang;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class PromotionService {
    public record BannerDto(UUID id, String title, String subtitle, Integer discountPercent, String code) {}

    public record PromoCheck(String code, boolean valid, int discountPercent, BigDecimal discountAmount, String reason) {}

    private final PromotionRepository repo;

    public PromotionService(PromotionRepository repo) {
        this.repo = repo;
    }

    public List<BannerDto> banners(String lang) {
        Instant now = Instant.now();
        return repo.findByKindAndActiveTrueOrderBySortOrderAsc("BANNER").stream().filter(p -> p.isLive(now))
                .map(p -> new BannerDto(p.getId(), Lang.pick(lang, p.getTitleRu(), p.getTitleKk(), p.getTitleEn()),
                        Lang.pick(lang, p.getSubtitleRu(), p.getSubtitleKk(), p.getSubtitleEn()), p.getDiscountPercent(), p.getCode()))
                .toList();
    }

    /** Validates a promo code against an order subtotal. Never throws for unknown codes; reports a reason instead. */
    public PromoCheck check(String code, BigDecimal subtotal) {
        if (code == null || code.isBlank()) return new PromoCheck(null, false, 0, BigDecimal.ZERO, "EMPTY");
        Promotion p = repo.findByCodeIgnoreCase(code.trim()).filter(x -> "PROMO_CODE".equals(x.getKind())).orElse(null);
        if (p == null || !p.isLive(Instant.now())) return new PromoCheck(code.trim(), false, 0, BigDecimal.ZERO, "UNKNOWN_OR_EXPIRED");
        if (p.getMinOrderAmount() != null && subtotal.compareTo(p.getMinOrderAmount()) < 0) {
            return new PromoCheck(p.getCode(), false, 0, BigDecimal.ZERO, "MIN_ORDER_NOT_REACHED");
        }
        int pct = p.getDiscountPercent() == null ? 0 : p.getDiscountPercent();
        BigDecimal amount = subtotal.multiply(BigDecimal.valueOf(pct)).divide(BigDecimal.valueOf(100), 0, RoundingMode.DOWN);
        return new PromoCheck(p.getCode(), true, pct, amount, null);
    }

    public PromoCheck require(String code, BigDecimal subtotal) {
        PromoCheck c = check(code, subtotal);
        if (!c.valid()) throw ApiException.unprocessable("PROMO_INVALID", "Promo code cannot be applied: " + c.reason());
        return c;
    }
}
