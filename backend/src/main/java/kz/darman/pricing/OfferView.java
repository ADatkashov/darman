package kz.darman.pricing;

import java.math.BigDecimal;
import java.util.UUID;

/** Denormalised read model of an offer joined with product, stock and branch data. */
public record OfferView(UUID offerId, UUID productId, String productName, String brand, String strength, String dosageForm,
                        String packageSize, boolean rxRequired, boolean productActive, BigDecimal price, String currency,
                        boolean offerActive, int stock, UUID branchId, String branchName, String pharmacyName, boolean branchActive,
                        boolean pickupAvailable, boolean deliveryAvailable, BigDecimal deliveryFee, BigDecimal freeDeliveryFrom,
                        Integer etaMin, Integer etaMax) {
    public boolean purchasable() {
        return productActive && offerActive && branchActive;
    }
}
