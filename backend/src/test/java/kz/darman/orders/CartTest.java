package kz.darman.orders;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import java.util.UUID;
import kz.darman.support.IntegrationTest;
import org.junit.jupiter.api.Test;

class CartTest extends IntegrationTest {

    @Test
    void addUpdateRemoveAndTotals() throws Exception {
        Session s = registerCustomer();
        UUID offer = offer("paradem-500-20", "Тау — Достык");
        JsonNode cart = body(mvc.perform(post("/api/v1/cart/items", s, "{\"offerId\":\"%s\",\"quantity\":2}".formatted(offer)))
                .andExpect(status().isCreated()).andReturn());
        assertThat(cart.get("items")).hasSize(1);
        double unit = cart.get("items").get(0).get("unitPrice").asDouble();
        assertThat(cart.get("subtotal").asDouble()).isEqualTo(unit * 2);
        String itemId = cart.get("items").get(0).get("itemId").asText();

        // Adding the same offer merges into one line instead of duplicating it.
        cart = body(mvc.perform(post("/api/v1/cart/items", s, "{\"offerId\":\"%s\",\"quantity\":1}".formatted(offer))).andReturn());
        assertThat(cart.get("items")).hasSize(1);
        assertThat(cart.get("items").get(0).get("quantity").asInt()).isEqualTo(3);

        mvc.perform(patch("/api/v1/cart/items/" + itemId, s, "{\"quantity\":1}")).andExpect(status().isOk())
                .andExpect(jsonPath("$.items[0].quantity").value(1));
        mvc.perform(patch("/api/v1/cart/items/" + itemId, s, "{\"quantity\":0}")).andExpect(status().isBadRequest());
        mvc.perform(patch("/api/v1/cart/items/" + itemId, s, "{\"quantity\":100}")).andExpect(status().isBadRequest());
        mvc.perform(delete("/api/v1/cart/items/" + itemId, s)).andExpect(status().isOk()).andExpect(jsonPath("$.items.length()").value(0));
    }

    @Test
    void cartCannotMixPharmacyBranchesUnlessReplaced() throws Exception {
        Session s = registerCustomer();
        UUID a = offer("paradem-500-20", "Тау — Достык");
        UUID b = offer("paradem-500-20", "Алатау Фарм — Абая");
        mvc.perform(post("/api/v1/cart/items", s, "{\"offerId\":\"%s\",\"quantity\":1}".formatted(a))).andExpect(status().isCreated());
        mvc.perform(post("/api/v1/cart/items", s, "{\"offerId\":\"%s\",\"quantity\":1}".formatted(b))).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("CART_BRANCH_MISMATCH"));
        mvc.perform(post("/api/v1/cart/items", s, "{\"offerId\":\"%s\",\"quantity\":1,\"replaceCart\":true}".formatted(b))).andExpect(status().isCreated())
                .andExpect(jsonPath("$.items.length()").value(1)).andExpect(jsonPath("$.branchName").value("Алатау Фарм — Абая"));
    }

    @Test
    void quantityCannotExceedStock() throws Exception {
        Session s = registerCustomer();
        UUID offer = offer("paradem-500-20", "Тау — Достык");
        jdbc.update("update inventory set quantity = 3 where offer_id = ?", offer);
        mvc.perform(post("/api/v1/cart/items", s, "{\"offerId\":\"%s\",\"quantity\":4}".formatted(offer))).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("INSUFFICIENT_STOCK"));
        jdbc.update("update inventory set quantity = 30 where offer_id = ?", offer);
    }

    @Test
    void validateEndpointFlagsPriceChangesAndUnavailableOffers() throws Exception {
        UUID offer = offer("ibudem-200-20", "Тау — Достык");
        JsonNode ok = body(mvc.perform(post("/api/v1/cart/validate", null, "{\"items\":[{\"offerId\":\"%s\",\"quantity\":2}]}".formatted(offer)))
                .andExpect(status().isOk()).andReturn());
        assertThat(ok.get("checkoutBlocked").asBoolean()).isFalse();
        assertThat(ok.get("delivery").get("deliveryAvailable").asBoolean()).isTrue();

        JsonNode changed = body(mvc.perform(post("/api/v1/cart/validate", null,
                "{\"items\":[{\"offerId\":\"%s\",\"quantity\":1,\"expectedPrice\":1}]}".formatted(offer))).andReturn());
        assertThat(changed.get("items").get(0).get("status").asText()).isEqualTo("PRICE_CHANGED");
        assertThat(changed.get("items").get(0).get("previousPrice").asInt()).isEqualTo(1);
        assertThat(changed.get("checkoutBlocked").asBoolean()).isFalse();

        JsonNode ghost = body(mvc.perform(post("/api/v1/cart/validate", null,
                "{\"items\":[{\"offerId\":\"%s\",\"quantity\":1}]}".formatted(UUID.randomUUID()))).andReturn());
        assertThat(ghost.get("items").get(0).get("status").asText()).isEqualTo("UNAVAILABLE");
        assertThat(ghost.get("checkoutBlocked").asBoolean()).isTrue();

        UUID other = offer("ibudem-200-20", "Алатау Фарм — Абая");
        JsonNode mixed = body(mvc.perform(post("/api/v1/cart/validate", null,
                "{\"items\":[{\"offerId\":\"%s\",\"quantity\":1},{\"offerId\":\"%s\",\"quantity\":1}]}".formatted(offer, other))).andReturn());
        assertThat(mixed.get("mixedBranches").asBoolean()).isTrue();
        assertThat(mixed.get("checkoutBlocked").asBoolean()).isTrue();

        UUID oos = offer("ibudem-200-20", "Тау — Самал");
        jdbc.update("update inventory set quantity = 0 where offer_id = ?", oos);
        JsonNode out = body(mvc.perform(post("/api/v1/cart/validate", null, "{\"items\":[{\"offerId\":\"%s\",\"quantity\":1}]}".formatted(oos))).andReturn());
        assertThat(out.get("items").get(0).get("status").asText()).isEqualTo("OUT_OF_STOCK");
    }

    @Test
    void emptyOrOversizedValidationRequestsAreRejected() throws Exception {
        mvc.perform(post("/api/v1/cart/validate", null, "{\"items\":[{\"offerId\":\"%s\",\"quantity\":500}]}".formatted(UUID.randomUUID())))
                .andExpect(status().isBadRequest());
        mvc.perform(post("/api/v1/cart/validate", null, "{}")).andExpect(status().isBadRequest());
    }
}
