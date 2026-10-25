package kz.darman.e2e;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import java.util.UUID;
import kz.darman.support.IntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

/** End-to-end journey through the public API, mirroring what the mobile app does. */
class CustomerJourneyTest extends IntegrationTest {

    @Test
    void browseSearchOrderTrackAndPrescription() throws Exception {
        // 1. Guest browses the catalog and searches without logging in.
        JsonNode categories = body(mvc.perform(get("/api/v1/categories", null)).andExpect(status().isOk()).andReturn());
        assertThat(categories).hasSize(10);
        JsonNode results = body(mvc.perform(get("/api/v1/search?q=парадем&sort=price_asc", null)).andExpect(status().isOk()).andReturn());
        assertThat(results.get("totalItems").asInt()).isEqualTo(2);
        JsonNode first = results.get("items").get(0);

        // 2. Product detail and price comparison across pharmacies.
        String productId = first.get("id").asText();
        mvc.perform(get("/api/v1/products/" + productId, null)).andExpect(status().isOk()).andExpect(jsonPath("$.card.id").value(productId));
        JsonNode offers = body(mvc.perform(get("/api/v1/products/" + productId + "/offers", null)).andReturn());
        assertThat(offers.size()).isGreaterThanOrEqualTo(2);
        String offerId = null;
        double offerPrice = 0;
        for (JsonNode o : offers) {
            if (o.get("deliveryAvailable").asBoolean() && !"OUT_OF_STOCK".equals(o.get("availability").asText())) {
                offerId = o.get("id").asText();
                offerPrice = o.get("price").asDouble();
                break;
            }
        }
        assertThat(offerId).isNotNull();

        // 3. Guest cart validation, then registration (OTP), login-free session after verification.
        mvc.perform(post("/api/v1/cart/validate", null, "{\"items\":[{\"offerId\":\"%s\",\"quantity\":2,\"expectedPrice\":%s}]}".formatted(offerId, offerPrice)))
                .andExpect(status().isOk()).andExpect(jsonPath("$.checkoutBlocked").value(false));
        Session me = registerCustomer();
        mvc.perform(put("/api/v1/users/me/favorites/" + productId, me, "")).andExpect(status().isNoContent());
        mvc.perform(get("/api/v1/users/me/favorites", me)).andExpect(jsonPath("$.length()").value(1));
        mvc.perform(delete("/api/v1/users/me/favorites/" + productId, me)).andExpect(status().isNoContent());
        mvc.perform(get("/api/v1/users/me/favorites", me)).andExpect(jsonPath("$.length()").value(0));

        // 4. Address + checkout in demo mode with a card (clearly flagged as a demo payment).
        UUID addr = addressFor(me);
        mvc.perform(patch("/api/v1/users/me/addresses/" + addr, me, "{\"city\":\"Алматы\",\"street\":\"ул. Новая\",\"house\":\"5\",\"defaultAddress\":true}"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.defaultAddress").value(true));
        JsonNode order = body(mvc.perform(post("/api/v1/orders", me, orderJson(UUID.fromString(offerId), 2, "DELIVERY", addr, "CARD_ONLINE", null))
                .header("Idempotency-Key", UUID.randomUUID().toString())).andExpect(status().isCreated()).andReturn());
        assertThat(order.get("paymentStatus").asText()).isEqualTo("DEMO_PAID");
        String orderId = order.get("id").asText();

        // 5. Order appears in the active list; staff advance it; the customer tracks every step.
        mvc.perform(get("/api/v1/orders?scope=active", me)).andExpect(jsonPath("$.items.length()").value(1));
        Session adm = admin();
        for (String st : new String[]{"CONFIRMED", "PREPARING", "IN_TRANSIT", "DELIVERED"}) {
            mvc.perform(post("/api/v1/admin/orders/" + orderId + "/status", adm, "{\"status\":\"%s\"}".formatted(st))).andExpect(status().isOk());
        }
        JsonNode done = body(mvc.perform(get("/api/v1/orders/" + orderId, me)).andReturn());
        assertThat(done.get("status").asText()).isEqualTo("DELIVERED");
        assertThat(done.get("history")).hasSize(5);
        mvc.perform(get("/api/v1/orders?scope=history", me)).andExpect(jsonPath("$.items.length()").value(1));

        // 6. Prescription upload with review by a pharmacist.
        String rx = body(mvc.perform(MockMvcRequestBuilders.multipart("/api/v1/prescriptions").file(file("rx.jpg", JPEG))
                .header("Authorization", "Bearer " + me.access())).andExpect(status().isCreated()).andReturn()).get("id").asText();
        mvc.perform(post("/api/v1/prescriptions/" + rx + "/submit", me, "")).andExpect(status().isOk());
        Session ph = pharmacist();
        mvc.perform(post("/api/v1/admin/prescriptions/" + rx + "/start-review", ph, "")).andExpect(status().isOk());
        mvc.perform(post("/api/v1/admin/prescriptions/" + rx + "/approve", ph, "{}")).andExpect(status().isOk());
        mvc.perform(get("/api/v1/prescriptions", me)).andExpect(jsonPath("$[0].status").value("APPROVED"));

        // 7. Account deletion request is recorded and reversible; notifications arrived.
        mvc.perform(post("/api/v1/users/me/deletion-request", me, "")).andExpect(status().isOk()).andExpect(jsonPath("$.deletionRequestedAt").exists());
        mvc.perform(delete("/api/v1/users/me/deletion-request", me)).andExpect(status().isOk());
        JsonNode notes = body(mvc.perform(get("/api/v1/notifications", me)).andReturn());
        assertThat(notes.get("totalItems").asInt()).isGreaterThanOrEqualTo(5);
    }
}
