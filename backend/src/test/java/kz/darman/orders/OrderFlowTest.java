package kz.darman.orders;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.*;
import kz.darman.support.IntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MvcResult;

class OrderFlowTest extends IntegrationTest {
    private static final String DOSTYK = "Тау — Достык";

    private int stock(UUID offer) {
        return jdbc.queryForObject("select quantity from inventory where offer_id = ?", Integer.class, offer);
    }

    @Test
    void placeDeliveryOrderWithServerSidePricing() throws Exception {
        Session s = registerCustomer();
        UUID addr = addressFor(s);
        UUID offer = offer("ibudem-200-20", DOSTYK);
        int before = stock(offer);
        double price = jdbc.queryForObject("select price from product_offers where id = ?", Double.class, offer);

        JsonNode o = body(mvc.perform(post("/api/v1/orders", s, orderJson(offer, 2, "DELIVERY", addr, "CASH", null)))
                .andExpect(status().isCreated()).andReturn());
        assertThat(o.get("status").asText()).isEqualTo("PLACED");
        assertThat(o.get("subtotal").asDouble()).isEqualTo(price * 2);
        assertThat(o.get("paymentStatus").asText()).isEqualTo("UNPAID");
        assertThat(o.get("number").asText()).startsWith("DM-");
        assertThat(o.get("deliveryAddress").asText()).contains("ул. Тестовая");
        assertThat(o.get("canCancel").asBoolean()).isTrue();
        assertThat(o.has("courier")).isFalse();
        assertThat(stock(offer)).isEqualTo(before - 2);
        assertThat(o.get("history")).hasSize(1);
    }

    @Test
    void clientSuppliedTotalsAreNeverTrusted() throws Exception {
        Session s = registerCustomer();
        UUID offer = offer("ibudem-200-20", DOSTYK);
        // expectedTotal mismatch -> 409 and nothing is created or reserved
        int before = stock(offer);
        mvc.perform(post("/api/v1/orders", s, orderJson(offer, 1, "PICKUP", null, "CASH", "\"expectedTotal\":1")))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("PRICE_CHANGED"));
        assertThat(stock(offer)).isEqualTo(before);
        mvc.perform(get("/api/v1/orders", s)).andExpect(jsonPath("$.items.length()").value(0));
    }

    @Test
    void idempotencyKeyPreventsDuplicateOrders() throws Exception {
        Session s = registerCustomer();
        UUID offer = offer("paradem-500-20", DOSTYK);
        int before = stock(offer);
        String payload = orderJson(offer, 1, "PICKUP", null, "CASH", null);
        String key = UUID.randomUUID().toString();
        MvcResult first = mvc.perform(post("/api/v1/orders", s, payload).header("Idempotency-Key", key)).andExpect(status().isCreated()).andReturn();
        MvcResult second = mvc.perform(post("/api/v1/orders", s, payload).header("Idempotency-Key", key)).andExpect(status().isOk()).andReturn();
        assertThat(body(second).get("id").asText()).isEqualTo(body(first).get("id").asText());
        assertThat(stock(offer)).isEqualTo(before - 1);
        Integer count = jdbc.queryForObject("select count(*) from orders where user_id = ?", Integer.class, s.userId());
        assertThat(count).isEqualTo(1);
    }

    @Test
    void concurrentIdenticalRequestsCreateOneOrder() throws Exception {
        Session s = registerCustomer();
        UUID offer = offer("paradem-500-20", DOSTYK);
        String payload = orderJson(offer, 1, "PICKUP", null, "CASH", null);
        String key = UUID.randomUUID().toString();
        ExecutorService pool = Executors.newFixedThreadPool(6);
        List<Future<Integer>> results = new ArrayList<>();
        for (int i = 0; i < 6; i++) {
            results.add(pool.submit(() -> mvc.perform(post("/api/v1/orders", s, payload).header("Idempotency-Key", key)).andReturn().getResponse().getStatus()));
        }
        int created = 0;
        for (Future<Integer> f : results) {
            int code = f.get(30, TimeUnit.SECONDS);
            assertThat(code).isIn(200, 201, 409);
            if (code == 201) created++;
        }
        pool.shutdown();
        assertThat(created).isEqualTo(1);
        Integer count = jdbc.queryForObject("select count(*) from orders where user_id = ?", Integer.class, s.userId());
        assertThat(count).isEqualTo(1);
    }

    @Test
    void stockIsNeverOversoldUnderConcurrency() throws Exception {
        // Fresh offer with exactly 5 units, 12 different customers race for it.
        UUID product = productId("pacifier-0");
        UUID branch = jdbc.queryForObject("select id from pharmacy_branches where name = 'Нұр — Аэропорт'", UUID.class);
        MvcResult up = mvc.perform(put("/api/v1/admin/offers", admin(),
                "{\"productId\":\"%s\",\"branchId\":\"%s\",\"price\":1000,\"quantity\":5}".formatted(product, branch))).andExpect(status().isOk()).andReturn();
        UUID offer = UUID.fromString(body(up).get("id").asText());

        List<Session> buyers = new ArrayList<>();
        for (int i = 0; i < 12; i++) buyers.add(registerCustomer());
        ExecutorService pool = Executors.newFixedThreadPool(12);
        CountDownLatch go = new CountDownLatch(1);
        List<Future<Integer>> results = new ArrayList<>();
        for (Session b : buyers) {
            results.add(pool.submit(() -> {
                go.await();
                return mvc.perform(post("/api/v1/orders", b, orderJson(offer, 1, "PICKUP", null, "CASH", null))).andReturn().getResponse().getStatus();
            }));
        }
        go.countDown();
        int ok = 0, conflict = 0;
        for (Future<Integer> f : results) {
            int code = f.get(60, TimeUnit.SECONDS);
            if (code == 201) ok++;
            else if (code == 409) conflict++;
            else throw new AssertionError("unexpected status " + code);
        }
        pool.shutdown();
        assertThat(ok).isEqualTo(5);
        assertThat(conflict).isEqualTo(7);
        assertThat(stock(offer)).isZero();
        List<UUID> buyerIds = buyers.stream().map(Session::userId).toList();
        Integer sold = jdbc.queryForObject("select coalesce(sum(oi.quantity),0) from order_items oi join orders o on o.id = oi.order_id where oi.offer_id = ? and o.user_id in (select unnest(string_to_array(?, ','))::uuid)",
                Integer.class, offer, String.join(",", buyerIds.stream().map(UUID::toString).toList()));
        assertThat(sold).isEqualTo(5);
    }

    @Test
    void insufficientStockLeavesNoPartialState() throws Exception {
        Session s = registerCustomer();
        UUID offer = offer("zinc-25-30", DOSTYK);
        jdbc.update("update inventory set quantity = 2 where offer_id = ?", offer);
        mvc.perform(post("/api/v1/orders", s, orderJson(offer, 3, "PICKUP", null, "CASH", null))).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("INSUFFICIENT_STOCK"));
        assertThat(stock(offer)).isEqualTo(2);
        Integer orders = jdbc.queryForObject("select count(*) from orders where user_id = ?", Integer.class, s.userId());
        assertThat(orders).isZero();
        jdbc.update("update inventory set quantity = 30 where offer_id = ?", offer);
    }

    @Test
    void orderRulesAreEnforced() throws Exception {
        Session s = registerCustomer();
        UUID a = offer("paradem-500-20", DOSTYK);
        UUID other = offer("ibudem-200-20", "Алатау Фарм — Абая");
        UUID addr = addressFor(s);
        // mixed branches
        mvc.perform(post("/api/v1/orders", s, "{\"items\":[{\"offerId\":\"%s\",\"quantity\":1},{\"offerId\":\"%s\",\"quantity\":1}],\"fulfillment\":\"PICKUP\",\"contactName\":\"T\",\"contactPhone\":\"+77011234567\",\"paymentMethod\":\"CASH\",\"consent\":true}".formatted(a, other)))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code").value("MIXED_BRANCHES"));
        // consent
        mvc.perform(post("/api/v1/orders", s, orderJson(a, 1, "PICKUP", null, "CASH", null).replace("\"consent\":true", "\"consent\":false")))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code").value("CONSENT_REQUIRED"));
        // delivery needs an address
        mvc.perform(post("/api/v1/orders", s, orderJson(a, 1, "DELIVERY", null, "CASH", null))).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("ADDRESS_REQUIRED"));
        // branch without delivery cannot deliver
        UUID satpaeva = jdbc.queryForObject("select id from pharmacy_branches where name = 'Алатау Фарм — Сатпаева'", UUID.class);
        UUID noDelivery = UUID.fromString(body(mvc.perform(put("/api/v1/admin/offers", admin(),
                "{\"productId\":\"%s\",\"branchId\":\"%s\",\"price\":500,\"quantity\":10}".formatted(productId("paradem-500-20"), satpaeva)))
                .andExpect(status().isOk()).andReturn()).get("id").asText());
        mvc.perform(post("/api/v1/orders", s, orderJson(noDelivery, 1, "DELIVERY", addr, "CASH", null))).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("DELIVERY_NOT_AVAILABLE"));
        // bad slot
        mvc.perform(post("/api/v1/orders", s, orderJson(a, 1, "DELIVERY", addr, "CASH", "\"slotStart\":\"" + Instant.now().plusSeconds(60) + "\"")))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code").value("INVALID_DELIVERY_SLOT"));
        // empty cart
        mvc.perform(post("/api/v1/orders", s, "{\"fulfillment\":\"PICKUP\",\"contactName\":\"T\",\"contactPhone\":\"+77011234567\",\"paymentMethod\":\"CASH\",\"consent\":true}"))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code").value("EMPTY_CART"));
        // unknown offer
        mvc.perform(post("/api/v1/orders", s, orderJson(UUID.randomUUID(), 1, "PICKUP", null, "CASH", null))).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("OFFER_UNAVAILABLE"));
    }

    @Test
    void validDeliverySlotIsAcceptedAndStored() throws Exception {
        Session s = registerCustomer();
        UUID a = offer("paradem-500-20", DOSTYK);
        UUID branch = jdbc.queryForObject("select branch_id from product_offers where id = ?", UUID.class, a);
        JsonNode slots = body(mvc.perform(get("/api/v1/delivery/slots?branchId=" + branch, null)).andExpect(status().isOk()).andReturn());
        assertThat(slots.get("etaIsEstimate").asBoolean()).isTrue();
        assertThat(slots.get("slots").size()).isPositive();
        String start = slots.get("slots").get(0).get("start").asText();
        JsonNode o = body(mvc.perform(post("/api/v1/orders", s, orderJson(a, 1, "DELIVERY", addressFor(s), "CASH", "\"slotStart\":\"" + start + "\"")))
                .andExpect(status().isCreated()).andReturn());
        assertThat(Instant.parse(o.get("slotStart").asText())).isEqualTo(Instant.parse(start));
    }

    @Test
    void promoCodeAppliesDiscountAndMinimumIsChecked() throws Exception {
        Session s = registerCustomer();
        UUID tonometer = offer("tonometer-auto", DOSTYK);
        JsonNode o = body(mvc.perform(post("/api/v1/orders", s, orderJson(tonometer, 1, "PICKUP", null, "CASH", "\"promoCode\":\"welcome10\"")))
                .andExpect(status().isCreated()).andReturn());
        double subtotal = o.get("subtotal").asDouble();
        assertThat(o.get("discount").asDouble()).isEqualTo(Math.floor(subtotal * 0.10));
        assertThat(o.get("total").asDouble()).isEqualTo(subtotal - o.get("discount").asDouble());
        UUID cheap = offer("charcoal-250-10", DOSTYK);
        mvc.perform(post("/api/v1/orders", s, orderJson(cheap, 1, "PICKUP", null, "CASH", "\"promoCode\":\"WELCOME10\"")))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code").value("PROMO_INVALID"));
        mvc.perform(post("/api/v1/promotions/validate", null, "{\"code\":\"NOPE\",\"subtotal\":5000}")).andExpect(jsonPath("$.valid").value(false));
    }

    @Test
    void demoCardPaymentIsLabelledAsDemoNeverAsRealPayment() throws Exception {
        Session s = registerCustomer();
        UUID offer = offer("paradem-500-20", DOSTYK);
        mvc.perform(post("/api/v1/orders", s, orderJson(offer, 1, "PICKUP", null, "CARD_ONLINE", null))).andExpect(status().isCreated())
                .andExpect(jsonPath("$.paymentStatus").value("DEMO_PAID")).andExpect(jsonPath("$.paymentIsDemo").value(true));
    }

    @Test
    void customerCancellationRestocksAndIsLimitedByStatus() throws Exception {
        Session s = registerCustomer();
        UUID offer = offer("paradem-500-20", DOSTYK);
        int before = stock(offer);
        String id = body(mvc.perform(post("/api/v1/orders", s, orderJson(offer, 2, "PICKUP", null, "CARD_ONLINE", null))).andReturn()).get("id").asText();
        assertThat(stock(offer)).isEqualTo(before - 2);
        mvc.perform(post("/api/v1/orders/" + id + "/cancel", s, "{\"reason\":\"передумал\"}")).andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("CANCELLED")).andExpect(jsonPath("$.paymentStatus").value("REFUNDED"))
                .andExpect(jsonPath("$.canCancel").value(false));
        assertThat(stock(offer)).isEqualTo(before);
        mvc.perform(post("/api/v1/orders/" + id + "/cancel", s, "{}")).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("CANCEL_NOT_ALLOWED"));
        assertThat(stock(offer)).isEqualTo(before);

        // Once the pharmacy is preparing the order, the customer can no longer cancel it.
        String id2 = body(mvc.perform(post("/api/v1/orders", s, orderJson(offer, 1, "PICKUP", null, "CASH", null))).andReturn()).get("id").asText();
        Session adm = admin();
        mvc.perform(post("/api/v1/admin/orders/" + id2 + "/status", adm, "{\"status\":\"CONFIRMED\"}")).andExpect(status().isOk());
        mvc.perform(post("/api/v1/admin/orders/" + id2 + "/status", adm, "{\"status\":\"PREPARING\"}")).andExpect(status().isOk());
        mvc.perform(post("/api/v1/orders/" + id2 + "/cancel", s, "{}")).andExpect(status().isConflict());
    }

    @Test
    void staffMustFollowTheStatusTimelineAndCourierIsOnlyVisibleInTransit() throws Exception {
        Session s = registerCustomer();
        Session adm = admin();
        UUID offer = offer("paradem-500-20", DOSTYK);
        String id = body(mvc.perform(post("/api/v1/orders", s, orderJson(offer, 1, "DELIVERY", addressFor(s), "CASH", null))).andReturn()).get("id").asText();

        mvc.perform(post("/api/v1/admin/orders/" + id + "/status", adm, "{\"status\":\"DELIVERED\"}")).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("INVALID_TRANSITION"));
        mvc.perform(post("/api/v1/admin/orders/" + id + "/status", adm, "{\"status\":\"READY_FOR_PICKUP\"}")).andExpect(status().isConflict());
        for (String st : new String[]{"CONFIRMED", "PREPARING"}) {
            mvc.perform(post("/api/v1/admin/orders/" + id + "/status", adm, "{\"status\":\"%s\"}".formatted(st))).andExpect(status().isOk());
        }
        mvc.perform(put("/api/v1/admin/orders/" + id + "/courier", adm, "{\"name\":\"Курьер Тест\",\"phone\":\"+77010000000\"}")).andExpect(status().isOk());
        // Courier contact stays hidden until the order is actually handed over.
        mvc.perform(get("/api/v1/orders/" + id, s)).andExpect(jsonPath("$.courier").doesNotExist());
        mvc.perform(post("/api/v1/admin/orders/" + id + "/status", adm, "{\"status\":\"IN_TRANSIT\"}")).andExpect(status().isOk());
        mvc.perform(get("/api/v1/orders/" + id, s)).andExpect(jsonPath("$.courier.name").value("Курьер Тест")).andExpect(jsonPath("$.courier.demo").value(false));
        mvc.perform(post("/api/v1/admin/orders/" + id + "/status", adm, "{\"status\":\"DELIVERED\"}")).andExpect(status().isOk());
        mvc.perform(get("/api/v1/orders/" + id, s)).andExpect(jsonPath("$.status").value("DELIVERED")).andExpect(jsonPath("$.paymentStatus").value("PAID"))
                .andExpect(jsonPath("$.courier").doesNotExist()).andExpect(jsonPath("$.history.length()").value(5));
        mvc.perform(post("/api/v1/admin/orders/" + id + "/status", adm, "{\"status\":\"CANCELLED\"}")).andExpect(status().isConflict());
        mvc.perform(get("/api/v1/orders/" + id + "/receipt", s)).andExpect(status().isOk()).andExpect(jsonPath("$.notice").value(org.hamcrest.Matchers.containsString("NOT a fiscal receipt")));
        mvc.perform(get("/api/v1/orders?scope=history", s)).andExpect(jsonPath("$.items.length()").value(1));
        mvc.perform(get("/api/v1/orders?scope=active", s)).andExpect(jsonPath("$.items.length()").value(0));
    }

    @Test
    void historicalOrdersKeepTheirPurchaseTimeSnapshot() throws Exception {
        Session s = registerCustomer();
        UUID offer = offer("omega3-60", DOSTYK);
        JsonNode o = body(mvc.perform(post("/api/v1/orders", s, orderJson(offer, 1, "PICKUP", null, "CASH", null))).andReturn());
        double paid = o.get("items").get(0).get("unitPrice").asDouble();
        jdbc.update("update product_offers set price = price + 500 where id = ?", offer);
        jdbc.update("update products set name = 'Переименован' where slug = 'omega3-60'");
        JsonNode again = body(mvc.perform(get("/api/v1/orders/" + o.get("id").asText(), s)).andReturn());
        assertThat(again.get("items").get(0).get("unitPrice").asDouble()).isEqualTo(paid);
        assertThat(again.get("items").get(0).get("productName").asText()).isEqualTo("Омега-3, 60 капсул (БАД)");
        jdbc.update("update products set name = 'Омега-3, 60 капсул (БАД)' where slug = 'omega3-60'");
        jdbc.update("update product_offers set price = price - 500 where id = ?", offer);
    }

    @Test
    void reorderRevalidatesAvailabilityAndPrices() throws Exception {
        Session s = registerCustomer();
        UUID offer = offer("magnesium-b6-50", DOSTYK);
        String id = body(mvc.perform(post("/api/v1/orders", s, orderJson(offer, 2, "PICKUP", null, "CASH", null))).andReturn()).get("id").asText();
        mvc.perform(post("/api/v1/orders/" + id + "/reorder", s, "{}")).andExpect(status().isOk())
                .andExpect(jsonPath("$.items[0].status").value("OK")).andExpect(jsonPath("$.items[0].quantity").value(2));
        jdbc.update("update product_offers set price = price + 100 where id = ?", offer);
        mvc.perform(post("/api/v1/orders/" + id + "/reorder", s, "{}")).andExpect(jsonPath("$.items[0].status").value("PRICE_CHANGED"));
        jdbc.update("update product_offers set price = price - 100 where id = ?", offer);
        jdbc.update("update inventory set quantity = 1 where offer_id = ?", offer);
        mvc.perform(post("/api/v1/orders/" + id + "/reorder", s, "{}")).andExpect(jsonPath("$.items[0].status").value("LOW_STOCK_ADJUSTMENT_NEEDED"))
                .andExpect(jsonPath("$.checkoutBlocked").value(true));
        jdbc.update("update inventory set quantity = 25 where offer_id = ?", offer);
    }

    @Test
    void orderCanBePlacedFromTheServerCartWhichIsThenCleared() throws Exception {
        Session s = registerCustomer();
        UUID offer = offer("paradem-500-20", DOSTYK);
        mvc.perform(post("/api/v1/cart/items", s, "{\"offerId\":\"%s\",\"quantity\":2}".formatted(offer))).andExpect(status().isCreated());
        String payload = "{\"fulfillment\":\"PICKUP\",\"contactName\":\"T\",\"contactPhone\":\"+77011234567\",\"paymentMethod\":\"CASH\",\"consent\":true}";
        mvc.perform(post("/api/v1/orders", s, payload)).andExpect(status().isCreated()).andExpect(jsonPath("$.items[0].quantity").value(2));
        mvc.perform(get("/api/v1/cart", s)).andExpect(jsonPath("$.items.length()").value(0));
    }
}
