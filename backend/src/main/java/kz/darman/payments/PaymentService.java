package kz.darman.payments;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Instant;
import java.util.HexFormat;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import kz.darman.audit.AuditService;
import kz.darman.common.ApiException;
import kz.darman.config.AppProperties;
import kz.darman.orders.Order;
import kz.darman.orders.OrderRepositories.OrderRepository;
import kz.darman.orders.OrderRepositories.PaymentAttemptRepository;
import kz.darman.orders.PaymentMethod;
import kz.darman.orders.PaymentStatus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PaymentService {
    private static final Logger log = LoggerFactory.getLogger(PaymentService.class);
    private final org.springframework.beans.factory.ObjectProvider<PaymentProvider> providerBeans;
    private final PaymentAttemptRepository attempts;
    private final OrderRepository orders;
    private final JdbcTemplate jdbc;
    private final AppProperties props;
    private final ObjectMapper mapper;
    private final AuditService audit;

    public PaymentService(org.springframework.beans.factory.ObjectProvider<PaymentProvider> providers, PaymentAttemptRepository attempts, OrderRepository orders, JdbcTemplate jdbc,
                          AppProperties props, ObjectMapper mapper, AuditService audit) {
        this.providerBeans = providers;
        this.attempts = attempts;
        this.orders = orders;
        this.jdbc = jdbc;
        this.props = props;
        this.mapper = mapper;
        this.audit = audit;
    }

    private List<PaymentProvider> providers() {
        return providerBeans.orderedStream().toList();
    }

    /** Fails fast (before any order is created) if online payment is requested but no provider is configured. */
    public void assertAvailable(PaymentMethod method) {
        if (method == PaymentMethod.CARD_ONLINE && providers().isEmpty()) {
            throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE, "PAYMENT_PROVIDER_NOT_CONFIGURED",
                    "Online card payment is not available. Choose cash on receipt.");
        }
    }

    public boolean onlineAvailable() {
        return !providers().isEmpty();
    }

    /** Starts payment for a new order and returns the resulting payment status. Caller persists it on the order. */
    @Transactional
    public PaymentStatus start(Order order) {
        if (order.getPaymentMethod() == PaymentMethod.CASH) return PaymentStatus.UNPAID;
        PaymentProvider provider = providers().get(0);
        PaymentAttempt attempt = new PaymentAttempt();
        attempt.setOrderId(order.getId());
        attempt.setProvider(provider.name());
        attempt.setAmount(order.getTotal());
        attempt.setCurrency(order.getCurrency());
        attempt.setIdempotencyKey("order-" + order.getId());
        var result = provider.initiate(new PaymentProvider.PaymentRequest(order.getId(), order.getNumber(), order.getTotal(),
                order.getCurrency(), attempt.getIdempotencyKey()));
        attempt.setProviderRef(result.providerRef());
        PaymentStatus status = switch (result.outcome()) {
            case SUCCEEDED -> provider.isDemo() ? PaymentStatus.DEMO_PAID : PaymentStatus.PAID;
            case PENDING -> PaymentStatus.PENDING;
            case FAILED -> PaymentStatus.FAILED;
        };
        attempt.setStatus(status.name());
        attempts.save(attempt);
        return status;
    }

    // ───────────── webhooks ─────────────

    public record WebhookResult(String status) {}

    /**
     * Handles a signed provider callback. Idempotent on (provider, eventId): replays are acknowledged without side effects.
     * Unsigned or wrongly signed requests are rejected; with no secret configured every webhook is rejected.
     */
    @Transactional
    public WebhookResult handleWebhook(String provider, String signatureHex, byte[] rawBody) {
        String secret = props.payments().webhookSecret();
        if (secret == null || secret.isBlank()) {
            throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE, "WEBHOOKS_NOT_CONFIGURED", "Payment webhooks are not configured");
        }
        if (!validSignature(secret, rawBody, signatureHex)) {
            audit.recordAs(null, null, "PAYMENT_WEBHOOK_REJECTED", "PaymentWebhook", provider, "invalid signature");
            throw ApiException.unauthorized("INVALID_SIGNATURE", "Invalid webhook signature");
        }
        JsonNode json;
        try {
            json = mapper.readTree(rawBody);
        } catch (java.io.IOException e) {
            throw ApiException.badRequest("BAD_PAYLOAD", "Malformed webhook payload");
        }
        String eventId = text(json, "eventId");
        String type = text(json, "type");
        String providerRef = text(json, "providerRef");
        if (eventId == null || type == null || providerRef == null) throw ApiException.badRequest("BAD_PAYLOAD", "Missing eventId, type or providerRef");

        int inserted = jdbc.update("""
                insert into payment_webhook_events (provider, event_id, event_type, payload) values (?, ?, ?, ?)
                on conflict (provider, event_id) do nothing""", provider, eventId, type, new String(rawBody, StandardCharsets.UTF_8));
        if (inserted == 0) {
            return new WebhookResult("duplicate");
        }

        Optional<PaymentAttempt> found = attempts.findByProviderAndProviderRef(provider, providerRef);
        if (found.isEmpty()) {
            log.warn("Webhook {} for unknown payment reference", eventId);
            return new WebhookResult("ignored");
        }
        PaymentAttempt attempt = found.get();
        Order order = orders.findById(attempt.getOrderId()).orElseThrow();
        BigDecimal amount = json.hasNonNull("amount") ? new BigDecimal(json.get("amount").asText()) : null;
        if (amount != null && amount.compareTo(attempt.getAmount()) != 0) {
            audit.recordAs(null, null, "PAYMENT_WEBHOOK_AMOUNT_MISMATCH", "Order", order.getId(), "event=" + eventId);
            jdbc.update("update payment_webhook_events set processed_at = now() where provider = ? and event_id = ?", provider, eventId);
            return new WebhookResult("amount_mismatch");
        }
        PaymentStatus next = switch (type) {
            case "payment.succeeded" -> PaymentStatus.PAID;
            case "payment.failed" -> PaymentStatus.FAILED;
            case "payment.refunded" -> PaymentStatus.REFUNDED;
            default -> null;
        };
        if (next != null && transitionAllowed(order.getPaymentStatus(), next)) {
            order.setPaymentStatus(next);
            attempt.setStatus(next.name());
            attempt.setUpdatedAt(Instant.now());
            orders.save(order);
            attempts.save(attempt);
            audit.recordAs(null, null, "PAYMENT_" + next.name(), "Order", order.getId(), "event=" + eventId);
        }
        jdbc.update("update payment_webhook_events set processed_at = now() where provider = ? and event_id = ?", provider, eventId);
        return new WebhookResult("processed");
    }

    static boolean transitionAllowed(PaymentStatus from, PaymentStatus to) {
        return switch (to) {
            case PAID -> from == PaymentStatus.PENDING || from == PaymentStatus.FAILED;
            case FAILED -> from == PaymentStatus.PENDING;
            case REFUNDED -> from == PaymentStatus.PAID || from == PaymentStatus.REFUND_PENDING;
            default -> false;
        };
    }

    public static String sign(String secret, byte[] body) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return HexFormat.of().formatHex(mac.doFinal(body));
        } catch (java.security.GeneralSecurityException e) {
            throw new IllegalStateException(e);
        }
    }

    private static boolean validSignature(String secret, byte[] body, String provided) {
        if (provided == null) return false;
        String expected = sign(secret, body);
        return MessageDigest.isEqual(expected.getBytes(StandardCharsets.UTF_8), provided.trim().toLowerCase().getBytes(StandardCharsets.UTF_8));
    }

    private static String text(JsonNode n, String field) {
        return n.hasNonNull(field) ? n.get(field).asText() : null;
    }

}
