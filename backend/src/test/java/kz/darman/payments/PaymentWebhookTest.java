package kz.darman.payments;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.nio.charset.StandardCharsets;
import java.util.UUID;
import kz.darman.support.IntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

class PaymentWebhookTest extends IntegrationTest {
    private static final String SECRET = "test-webhook-secret-123456";

    private record Pending(String orderId, String ref, double total) {}

    private Pending pendingOrder() throws Exception {
        Session s = registerCustomer();
        var o = body(mvc.perform(post("/api/v1/orders", s, orderJson(offer("paradem-500-20", "Тау — Достык"), 1, "PICKUP", null, "CASH", null))).andReturn());
        String id = o.get("id").asText();
        String ref = "acme_" + UUID.randomUUID();
        jdbc.update("update orders set payment_method = 'CARD_ONLINE', payment_status = 'PENDING' where id = ?::uuid", id);
        jdbc.update("insert into payment_attempts (order_id, provider, status, amount, idempotency_key, provider_ref) values (?::uuid, 'acme', 'PENDING', ?, ?, ?)",
                id, o.get("total").asDouble(), "test-" + UUID.randomUUID(), ref);
        return new Pending(id, ref, o.get("total").asDouble());
    }

    private org.springframework.test.web.servlet.ResultActions send(String body, String signature) throws Exception {
        var req = MockMvcRequestBuilders.post("/api/v1/payments/webhooks/acme").contentType(MediaType.APPLICATION_JSON).content(body);
        if (signature != null) req.header("X-Signature", signature);
        return mvc.perform(req);
    }

    private String sign(String body) {
        return PaymentService.sign(SECRET, body.getBytes(StandardCharsets.UTF_8));
    }

    private String paymentStatus(String orderId) {
        return jdbc.queryForObject("select payment_status from orders where id = ?::uuid", String.class, orderId);
    }

    @Test
    void unsignedOrWronglySignedWebhooksAreRejectedAndChangeNothing() throws Exception {
        Pending p = pendingOrder();
        String body = "{\"eventId\":\"e-%s\",\"type\":\"payment.succeeded\",\"providerRef\":\"%s\",\"amount\":%s}".formatted(UUID.randomUUID(), p.ref(), p.total());
        send(body, null).andExpect(status().isUnauthorized());
        send(body, "deadbeef").andExpect(status().isUnauthorized());
        send(body, PaymentService.sign("another-secret-another-secret", body.getBytes(StandardCharsets.UTF_8))).andExpect(status().isUnauthorized());
        assertThat(paymentStatus(p.orderId())).isEqualTo("PENDING");
    }

    @Test
    void signedWebhookMarksOrderPaidExactlyOnceEvenWhenReplayed() throws Exception {
        Pending p = pendingOrder();
        String eventId = "e-" + UUID.randomUUID();
        String body = "{\"eventId\":\"%s\",\"type\":\"payment.succeeded\",\"providerRef\":\"%s\",\"amount\":%s}".formatted(eventId, p.ref(), p.total());
        send(body, sign(body)).andExpect(status().isOk()).andExpect(jsonPath("$.status").value("processed"));
        assertThat(paymentStatus(p.orderId())).isEqualTo("PAID");
        // provider retries the same event, and even a late "failed" with the same id must not alter anything
        send(body, sign(body)).andExpect(status().isOk()).andExpect(jsonPath("$.status").value("duplicate"));
        send(body, sign(body)).andExpect(status().isOk()).andExpect(jsonPath("$.status").value("duplicate"));
        Integer stored = jdbc.queryForObject("select count(*) from payment_webhook_events where event_id = ?", Integer.class, eventId);
        assertThat(stored).isEqualTo(1);
        Integer audits = jdbc.queryForObject("select count(*) from audit_events where action = 'PAYMENT_PAID' and entity_id = ? and details like ?", Integer.class,
                p.orderId(), "%" + eventId + "%");
        assertThat(audits).isEqualTo(1);
    }

    @Test
    void amountMismatchAndStateRegressionsAreIgnored() throws Exception {
        Pending p = pendingOrder();
        String bad = "{\"eventId\":\"e-%s\",\"type\":\"payment.succeeded\",\"providerRef\":\"%s\",\"amount\":1}".formatted(UUID.randomUUID(), p.ref());
        send(bad, sign(bad)).andExpect(jsonPath("$.status").value("amount_mismatch"));
        assertThat(paymentStatus(p.orderId())).isEqualTo("PENDING");

        String ok = "{\"eventId\":\"e-%s\",\"type\":\"payment.succeeded\",\"providerRef\":\"%s\",\"amount\":%s}".formatted(UUID.randomUUID(), p.ref(), p.total());
        send(ok, sign(ok)).andExpect(jsonPath("$.status").value("processed"));
        String failedLate = "{\"eventId\":\"e-%s\",\"type\":\"payment.failed\",\"providerRef\":\"%s\"}".formatted(UUID.randomUUID(), p.ref());
        send(failedLate, sign(failedLate)).andExpect(status().isOk());
        assertThat(paymentStatus(p.orderId())).isEqualTo("PAID");
    }

    @Test
    void unknownReferencesAndMalformedPayloadsAreHandledSafely() throws Exception {
        String unknown = "{\"eventId\":\"e-%s\",\"type\":\"payment.succeeded\",\"providerRef\":\"nope\"}".formatted(UUID.randomUUID());
        send(unknown, sign(unknown)).andExpect(jsonPath("$.status").value("ignored"));
        String bad = "{\"type\":\"x\"}";
        send(bad, sign(bad)).andExpect(status().isBadRequest());
        String garbage = "not json";
        send(garbage, sign(garbage)).andExpect(status().isBadRequest());
    }

    @Test
    void cardPaymentIsRefusedWhenNoProviderIsConfigured() {
        PaymentService service = new PaymentService(new org.springframework.beans.factory.support.DefaultListableBeanFactory().getBeanProvider(PaymentProvider.class),
                null, null, null, new kz.darman.config.AppProperties(null, null, new kz.darman.config.AppProperties.Payments(false, ""), null, null, null, null, null),
                null, null);
        org.assertj.core.api.Assertions.assertThatThrownBy(() -> service.assertAvailable(kz.darman.orders.PaymentMethod.CARD_ONLINE))
                .hasMessageContaining("not available");
        service.assertAvailable(kz.darman.orders.PaymentMethod.CASH);
    }
}
