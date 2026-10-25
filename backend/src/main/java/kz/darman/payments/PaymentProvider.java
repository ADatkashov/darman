package kz.darman.payments;

import java.math.BigDecimal;
import java.util.UUID;

/**
 * Boundary to an external payment gateway. Implementations must never receive or store card numbers/CVV:
 * card data is entered on the provider's hosted page or SDK, and DARMAN only learns the outcome.
 */
public interface PaymentProvider {
    String name();

    boolean isDemo();

    PaymentResult initiate(PaymentRequest request);

    record PaymentRequest(UUID orderId, String orderNumber, BigDecimal amount, String currency, String idempotencyKey) {}

    /** SUCCEEDED means the provider itself confirmed the payment. PENDING means an asynchronous confirmation (webhook) is awaited. */
    record PaymentResult(Outcome outcome, String providerRef, String redirectUrl) {
        public enum Outcome { SUCCEEDED, PENDING, FAILED }
    }
}
