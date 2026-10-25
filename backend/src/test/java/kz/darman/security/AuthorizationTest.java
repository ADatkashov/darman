package kz.darman.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.UUID;
import kz.darman.support.IntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

class AuthorizationTest extends IntegrationTest {

    @Test
    void customersCannotReachAnyAdminEndpoint() throws Exception {
        Session c = registerCustomer();
        for (String url : new String[]{"/api/v1/admin/orders", "/api/v1/admin/prescriptions", "/api/v1/admin/audit", "/api/v1/admin/staff",
                "/api/v1/admin/products", "/api/v1/admin/offers", "/api/v1/admin/promotions", "/api/v1/admin/roles", "/api/v1/admin/me"}) {
            mvc.perform(get(url, c)).andExpect(status().isForbidden());
            mvc.perform(get(url, null)).andExpect(status().isUnauthorized());
        }
        mvc.perform(post("/api/v1/admin/promotions", c, "{}")).andExpect(status().isForbidden());
    }

    @Test
    void staffPermissionsAreEnforcedPerRole() throws Exception {
        Session pharm = pharmacist();
        mvc.perform(get("/api/v1/admin/prescriptions", pharm)).andExpect(status().isOk());
        mvc.perform(get("/api/v1/admin/orders", pharm)).andExpect(status().isOk());
        mvc.perform(get("/api/v1/admin/audit", pharm)).andExpect(status().isForbidden());
        mvc.perform(get("/api/v1/admin/staff", pharm)).andExpect(status().isForbidden());
        mvc.perform(get("/api/v1/admin/offers", pharm)).andExpect(status().isForbidden());

        Session ops = loginStaff("+77000000003");
        mvc.perform(get("/api/v1/admin/offers", ops)).andExpect(status().isOk());
        mvc.perform(get("/api/v1/admin/prescriptions", ops)).andExpect(status().isForbidden());

        Session adm = admin();
        mvc.perform(get("/api/v1/admin/audit", adm)).andExpect(status().isOk());
        mvc.perform(get("/api/v1/admin/staff", adm)).andExpect(status().isOk());
    }

    @Test
    void userCannotReadAnotherUsersOrdersAddressesOrCart() throws Exception {
        Session alice = registerCustomer();
        Session bob = registerCustomer();
        UUID addr = addressFor(alice);
        UUID offer = offer("paradem-500-20", "Тау — Достык");
        String orderId = body(mvc.perform(post("/api/v1/orders", alice, orderJson(offer, 1, "DELIVERY", addr, "CASH", null)))
                .andExpect(status().isCreated()).andReturn()).get("id").asText();

        mvc.perform(get("/api/v1/orders/" + orderId, alice)).andExpect(status().isOk());
        mvc.perform(get("/api/v1/orders/" + orderId, bob)).andExpect(status().isNotFound());
        mvc.perform(post("/api/v1/orders/" + orderId + "/cancel", bob, "{}")).andExpect(status().isNotFound());
        mvc.perform(get("/api/v1/orders/" + orderId + "/receipt", bob)).andExpect(status().isNotFound());
        mvc.perform(post("/api/v1/orders/" + orderId + "/reorder", bob, "{}")).andExpect(status().isNotFound());
        mvc.perform(get("/api/v1/orders", bob)).andExpect(jsonPath("$.items.length()").value(0));

        // Bob cannot use Alice's saved address for his own order.
        mvc.perform(post("/api/v1/orders", bob, orderJson(offer, 1, "DELIVERY", addr, "CASH", null))).andExpect(status().isNotFound());
        mvc.perform(patch("/api/v1/users/me/addresses/" + addr, bob, "{\"city\":\"X\",\"street\":\"Y\",\"house\":\"1\"}")).andExpect(status().isNotFound());
        mvc.perform(delete("/api/v1/users/me/addresses/" + addr, bob)).andExpect(status().isNotFound());
    }

    @Test
    void prescriptionsArePrivateToOwnerAndReviewers() throws Exception {
        Session alice = registerCustomer();
        Session bob = registerCustomer();
        String rxId = body(mvc.perform(MockMvcRequestBuilders.multipart("/api/v1/prescriptions").file(file("rx.jpg", JPEG))
                .header("Authorization", "Bearer " + alice.access())).andExpect(status().isCreated()).andReturn()).get("id").asText();
        String fileId = body(mvc.perform(get("/api/v1/prescriptions/" + rxId, alice)).andReturn()).get("files").get(0).get("id").asText();

        mvc.perform(get("/api/v1/prescriptions/" + rxId, alice)).andExpect(status().isOk());
        mvc.perform(get("/api/v1/prescriptions/" + rxId + "/files/" + fileId, alice)).andExpect(status().isOk())
                .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.header().string("Cache-Control", "no-store"));
        // Another customer gets 404 (existence is not leaked) for the record and its file.
        mvc.perform(get("/api/v1/prescriptions/" + rxId, bob)).andExpect(status().isNotFound());
        mvc.perform(get("/api/v1/prescriptions/" + rxId + "/files/" + fileId, bob)).andExpect(status().isNotFound());
        mvc.perform(post("/api/v1/prescriptions/" + rxId + "/submit", bob, "")).andExpect(status().isNotFound());
        mvc.perform(get("/api/v1/prescriptions", bob)).andExpect(jsonPath("$.length()").value(0));
        // Unauthenticated access is refused.
        mvc.perform(get("/api/v1/prescriptions/" + rxId + "/files/" + fileId, null)).andExpect(status().isUnauthorized());
        // Operators without the review permission cannot read it either.
        mvc.perform(get("/api/v1/prescriptions/" + rxId, loginStaff("+77000000003"))).andExpect(status().isNotFound());
        // The pharmacist can, and the access leaves an audit trail.
        mvc.perform(get("/api/v1/prescriptions/" + rxId + "/files/" + fileId, pharmacist())).andExpect(status().isOk());
        Integer events = jdbc.queryForObject("select count(*) from audit_events where action = 'PRESCRIPTION_FILE_ACCESSED' and details like ?",
                Integer.class, "%prescription=" + rxId + "%");
        assertThat(events).isGreaterThanOrEqualTo(2);
        Integer denied = jdbc.queryForObject("select count(*) from audit_events where action = 'PRESCRIPTION_ACCESS_DENIED' and entity_id = ?", Integer.class, rxId);
        assertThat(denied).isGreaterThanOrEqualTo(3);
    }

    @Test
    void publicEndpointsStayPublicAndErrorsUseTheStandardEnvelope() throws Exception {
        mvc.perform(get("/api/v1/categories", null)).andExpect(status().isOk());
        mvc.perform(get("/actuator/health", null)).andExpect(status().isOk());
        mvc.perform(get("/api/v1/orders/not-a-uuid", registerCustomer())).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("BAD_REQUEST")).andExpect(jsonPath("$.correlationId").exists());
        mvc.perform(MockMvcRequestBuilders.post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON).content("{bad json"))
                .andExpect(status().isBadRequest());
        MockMultipartFile ignored = file("x", JPEG);
        assertThat(ignored).isNotNull();
    }
}
