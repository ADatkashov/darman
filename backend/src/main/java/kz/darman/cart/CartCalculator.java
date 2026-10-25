package kz.darman.cart;

import java.math.BigDecimal;
import java.util.*;
import kz.darman.cart.CartDtos.*;
import kz.darman.pricing.OfferView;
import kz.darman.pricing.PricingService;
import org.springframework.stereotype.Component;

/** Pure cart computation shared by the server cart and the stateless validation endpoint. */
@Component
public class CartCalculator {
    public record Raw(UUID itemId, UUID offerId, int quantity, BigDecimal expectedPrice) {}

    private final PricingService pricing;

    public CartCalculator(PricingService pricing) {
        this.pricing = pricing;
    }

    public CartDto compute(List<Raw> raws, Map<UUID, OfferView> views) {
        List<CartLine> lines = new ArrayList<>();
        Set<UUID> branches = new LinkedHashSet<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        boolean rx = false;
        boolean blocked = false;
        List<String> issues = new ArrayList<>();
        OfferView first = null;
        for (Raw r : raws) {
            OfferView v = views.get(r.offerId());
            if (v == null) {
                lines.add(new CartLine(r.itemId(), r.offerId(), null, null, null, null, null, false, null, null, null,
                        BigDecimal.ZERO, r.expectedPrice(), r.quantity(), 0, BigDecimal.ZERO, "UNAVAILABLE"));
                blocked = true;
                issues.add("UNAVAILABLE:" + r.offerId());
                continue;
            }
            if (first == null) first = v;
            branches.add(v.branchId());
            String status = "OK";
            if (!v.purchasable()) status = "UNAVAILABLE";
            else if (v.stock() <= 0) status = "OUT_OF_STOCK";
            else if (v.stock() < r.quantity()) status = "LOW_STOCK_ADJUSTMENT_NEEDED";
            else if (r.expectedPrice() != null && r.expectedPrice().compareTo(v.price()) != 0) status = "PRICE_CHANGED";
            if (!status.equals("OK") && !status.equals("PRICE_CHANGED")) blocked = true;
            if (!status.equals("OK")) issues.add(status + ":" + v.offerId());
            BigDecimal lineTotal = v.price().multiply(BigDecimal.valueOf(r.quantity()));
            subtotal = subtotal.add(lineTotal);
            rx |= v.rxRequired();
            lines.add(new CartLine(r.itemId(), v.offerId(), v.productId(), v.productName(), v.strength(), v.dosageForm(), v.packageSize(),
                    v.rxRequired(), v.branchId(), v.branchName(), v.pharmacyName(), v.price(),
                    r.expectedPrice() != null && r.expectedPrice().compareTo(v.price()) != 0 ? r.expectedPrice() : null,
                    r.quantity(), v.stock(), lineTotal, status));
        }
        boolean mixed = branches.size() > 1;
        if (mixed) {
            blocked = true;
            issues.add("MIXED_BRANCHES");
        }
        DeliveryInfo delivery = null;
        if (first != null && !mixed) {
            delivery = new DeliveryInfo(first.deliveryAvailable(), first.pickupAvailable(), pricing.deliveryFee(first, subtotal),
                    first.freeDeliveryFrom(), first.deliveryAvailable() ? first.etaMin() : null,
                    first.deliveryAvailable() ? first.etaMax() : null);
        }
        return new CartDto(lines, mixed || first == null ? null : first.branchId(), mixed || first == null ? null : first.branchName(),
                mixed || first == null ? null : first.pharmacyName(), subtotal, "KZT", delivery, rx, blocked, issues, mixed);
    }
}
