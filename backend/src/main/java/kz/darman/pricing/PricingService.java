package kz.darman.pricing;

import java.math.BigDecimal;
import org.springframework.stereotype.Service;

@Service
public class PricingService {
    /** Delivery fee for a branch and subtotal; zero once the branch's free-delivery threshold is reached. */
    public BigDecimal deliveryFee(OfferView branchInfo, BigDecimal subtotal) {
        BigDecimal fee = branchInfo.deliveryFee() == null ? BigDecimal.ZERO : branchInfo.deliveryFee();
        if (branchInfo.freeDeliveryFrom() != null && subtotal.compareTo(branchInfo.freeDeliveryFrom()) >= 0) return BigDecimal.ZERO;
        return fee;
    }
}
