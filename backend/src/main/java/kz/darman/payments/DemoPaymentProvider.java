package kz.darman.payments;

import java.util.UUID;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/** DEMO ONLY: simulates a gateway that always confirms. No money moves. Orders show payment status DEMO_PAID. */
@Component
@ConditionalOnProperty(name = "darman.payments.demo-enabled", havingValue = "true")
public class DemoPaymentProvider implements PaymentProvider {
    @Override
    public String name() {
        return "demo";
    }

    @Override
    public boolean isDemo() {
        return true;
    }

    @Override
    public PaymentResult initiate(PaymentRequest request) {
        return new PaymentResult(PaymentResult.Outcome.SUCCEEDED, "demo_" + UUID.randomUUID(), null);
    }
}
