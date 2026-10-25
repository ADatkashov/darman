package kz.darman.prescriptions;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import java.util.UUID;
import kz.darman.support.IntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

class PrescriptionFlowTest extends IntegrationTest {
    private static final String DOSTYK = "Тау — Достык";

    private String createWithFile(Session s) throws Exception {
        return body(mvc.perform(MockMvcRequestBuilders.multipart("/api/v1/prescriptions").file(file("rx.jpg", JPEG))
                .param("note", "тест").header("Authorization", "Bearer " + s.access())).andExpect(status().isCreated())
                .andExpect(jsonPath("$.status").value("DRAFT")).andReturn()).get("id").asText();
    }

    private void submit(Session s, String id) throws Exception {
        mvc.perform(post("/api/v1/prescriptions/" + id + "/submit", s, "")).andExpect(status().isOk()).andExpect(jsonPath("$.status").value("SUBMITTED"));
    }

    private void approve(String id) throws Exception {
        Session ph = pharmacist();
        mvc.perform(post("/api/v1/admin/prescriptions/" + id + "/start-review", ph, "")).andExpect(status().isOk()).andExpect(jsonPath("$.status").value("UNDER_REVIEW"));
        mvc.perform(post("/api/v1/admin/prescriptions/" + id + "/approve", ph, "{\"comment\":\"проверено\",\"validDays\":10}")).andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("APPROVED"));
    }

    @Test
    void fileContentIsSniffedNotTrusted() throws Exception {
        Session s = registerCustomer();
        MockMultipartFile fake = new MockMultipartFile("files", "evil.jpg", "image/jpeg", "<script>alert(1)</script>".getBytes());
        mvc.perform(MockMvcRequestBuilders.multipart("/api/v1/prescriptions").file(fake).header("Authorization", "Bearer " + s.access()))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code").value("UNSUPPORTED_FILE_TYPE"));
        MockMultipartFile empty = new MockMultipartFile("files", "empty.jpg", "image/jpeg", new byte[0]);
        mvc.perform(MockMvcRequestBuilders.multipart("/api/v1/prescriptions").file(empty).header("Authorization", "Bearer " + s.access()))
                .andExpect(status().isBadRequest());
        byte[] pdf = "%PDF-1.4\n%%EOF".getBytes();
        mvc.perform(MockMvcRequestBuilders.multipart("/api/v1/prescriptions").file(new MockMultipartFile("files", "rx.pdf", "application/pdf", pdf))
                .header("Authorization", "Bearer " + s.access())).andExpect(status().isCreated()).andExpect(jsonPath("$.files[0].mimeType").value("application/pdf"));
    }

    @Test
    void draftMustHaveFilesAndIsLockedAfterSubmission() throws Exception {
        Session s = registerCustomer();
        String empty = body(mvc.perform(MockMvcRequestBuilders.multipart("/api/v1/prescriptions").header("Authorization", "Bearer " + s.access()))
                .andExpect(status().isCreated()).andReturn()).get("id").asText();
        mvc.perform(post("/api/v1/prescriptions/" + empty + "/submit", s, "")).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("PRESCRIPTION_FILES_REQUIRED"));

        String id = createWithFile(s);
        mvc.perform(MockMvcRequestBuilders.multipart("/api/v1/prescriptions/" + id + "/files").file(file("second.jpg", JPEG))
                .header("Authorization", "Bearer " + s.access())).andExpect(status().isOk()).andExpect(jsonPath("$.files.length()").value(2));
        submit(s, id);
        mvc.perform(MockMvcRequestBuilders.multipart("/api/v1/prescriptions/" + id + "/files").file(file("late.jpg", JPEG))
                .header("Authorization", "Bearer " + s.access())).andExpect(status().isConflict());
        mvc.perform(delete("/api/v1/prescriptions/" + id, s)).andExpect(status().isConflict());
        mvc.perform(post("/api/v1/prescriptions/" + id + "/submit", s, "")).andExpect(status().isConflict());
    }

    @Test
    void uploadingNeverApprovesAndReviewFollowsTheStateMachine() throws Exception {
        Session s = registerCustomer();
        String id = createWithFile(s);
        submit(s, id);
        Session ph = pharmacist();
        // cannot approve straight from SUBMITTED, a review must be started first
        mvc.perform(post("/api/v1/admin/prescriptions/" + id + "/approve", ph, "{}")).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("INVALID_PRESCRIPTION_STATE"));
        // customers cannot review
        mvc.perform(post("/api/v1/admin/prescriptions/" + id + "/start-review", s, "")).andExpect(status().isForbidden());
        mvc.perform(post("/api/v1/admin/prescriptions/" + id + "/start-review", ph, "")).andExpect(status().isOk());
        // rejection needs a reason
        mvc.perform(post("/api/v1/admin/prescriptions/" + id + "/reject", ph, "{}")).andExpect(status().isBadRequest());
        mvc.perform(post("/api/v1/admin/prescriptions/" + id + "/reject", ph, "{\"reason\":\"Нечитаемое фото\"}")).andExpect(status().isOk());
        JsonNode rx = body(mvc.perform(get("/api/v1/prescriptions/" + id, s)).andReturn());
        assertThat(rx.get("status").asText()).isEqualTo("REJECTED");
        assertThat(rx.get("rejectionReason").asText()).isEqualTo("Нечитаемое фото");
        assertThat(rx.get("events")).hasSizeGreaterThanOrEqualTo(4);
        assertThat(rx.get("usableForOrder").asBoolean()).isFalse();
    }

    @Test
    void staffCannotReviewTheirOwnPrescription() throws Exception {
        Session ph = pharmacist();
        String id = createWithFile(ph);
        submit(ph, id);
        mvc.perform(post("/api/v1/admin/prescriptions/" + id + "/start-review", ph, "")).andExpect(status().isForbidden());
    }

    @Test
    void prescriptionOnlyProductsNeedAnApprovedUnusedPrescription() throws Exception {
        Session s = registerCustomer();
        UUID amlo = offer("amlodem-5-30", DOSTYK);
        String payload = orderJson(amlo, 1, "PICKUP", null, "CASH", null);

        mvc.perform(post("/api/v1/orders", s, payload)).andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code").value("PRESCRIPTION_REQUIRED"));

        String id = createWithFile(s);
        String withRx = orderJson(amlo, 1, "PICKUP", null, "CASH", "\"prescriptionId\":\"" + id + "\"");
        mvc.perform(post("/api/v1/orders", s, withRx)).andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code").value("PRESCRIPTION_NOT_APPROVED"));
        submit(s, id);
        mvc.perform(post("/api/v1/orders", s, withRx)).andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code").value("PRESCRIPTION_NOT_APPROVED"));

        approve(id);
        mvc.perform(get("/api/v1/prescriptions/" + id, s)).andExpect(jsonPath("$.usableForOrder").value(true));
        // someone else's approved prescription cannot be used
        Session other = registerCustomer();
        mvc.perform(post("/api/v1/orders", other, withRx)).andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code").value("PRESCRIPTION_REQUIRED"));

        String orderId = body(mvc.perform(post("/api/v1/orders", s, withRx)).andExpect(status().isCreated()).andReturn()).get("id").asText();
        // a prescription is single-use
        mvc.perform(post("/api/v1/orders", s, withRx)).andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code").value("PRESCRIPTION_ALREADY_USED"));
        // cancelling the order releases it again
        mvc.perform(post("/api/v1/orders/" + orderId + "/cancel", s, "{}")).andExpect(status().isOk());
        mvc.perform(post("/api/v1/orders", s, withRx)).andExpect(status().isCreated());
    }

    @Test
    void expiredPrescriptionsAreRefused() throws Exception {
        Session s = registerCustomer();
        UUID amlo = offer("losardem-50-30", DOSTYK);
        String id = createWithFile(s);
        submit(s, id);
        approve(id);
        jdbc.update("update prescriptions set expires_at = now() - interval '1 day' where id = ?::uuid", id);
        mvc.perform(get("/api/v1/prescriptions/" + id, s)).andExpect(jsonPath("$.status").value("EXPIRED")).andExpect(jsonPath("$.usableForOrder").value(false));
        mvc.perform(post("/api/v1/orders", s, orderJson(amlo, 1, "PICKUP", null, "CASH", "\"prescriptionId\":\"" + id + "\"")))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code").value("PRESCRIPTION_NOT_APPROVED"));
    }

    @Test
    void reviewQueueListsSubmittedItemsWithoutContactDetails() throws Exception {
        Session s = registerCustomer();
        String id = createWithFile(s);
        submit(s, id);
        String queue = mvc.perform(get("/api/v1/admin/prescriptions", pharmacist())).andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
        assertThat(queue).contains(id);
        assertThat(queue).doesNotContain(s.phone());
    }
}
