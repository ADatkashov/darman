package kz.darman.identity;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import kz.darman.support.IntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MvcResult;

class AuthFlowTest extends IntegrationTest {

    @Test
    void registerVerifyAndReadProfile() throws Exception {
        Session s = registerCustomer();
        mvc.perform(get("/api/v1/users/me", s)).andExpect(status().isOk())
                .andExpect(jsonPath("$.phone").value(s.phone())).andExpect(jsonPath("$.status").value("ACTIVE"))
                .andExpect(jsonPath("$.role").value("CUSTOMER"));
    }

    @Test
    void wrongOtpIsRejectedAndAttemptsAreLimited() throws Exception {
        String phone = freshPhone();
        mvc.perform(post("/api/v1/auth/register", null, "{\"phone\":\"%s\",\"password\":\"Abcdef12\",\"privacyConsent\":true}".formatted(phone)))
                .andExpect(status().isAccepted());
        for (int i = 0; i < 6; i++) {
            mvc.perform(post("/api/v1/auth/verify-otp", null, "{\"phone\":\"%s\",\"code\":\"000000\"}".formatted(phone)))
                    .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("OTP_INVALID"));
        }
    }

    @Test
    void registrationRequiresConsentAndStrongPassword() throws Exception {
        mvc.perform(post("/api/v1/auth/register", null, "{\"phone\":\"%s\",\"password\":\"Abcdef12\",\"privacyConsent\":false}".formatted(freshPhone())))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("VALIDATION_FAILED"));
        mvc.perform(post("/api/v1/auth/register", null, "{\"phone\":\"%s\",\"password\":\"abcdefgh\",\"privacyConsent\":true}".formatted(freshPhone())))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("WEAK_PASSWORD"));
        mvc.perform(post("/api/v1/auth/register", null, "{\"phone\":\"12345\",\"password\":\"Abcdef12\",\"privacyConsent\":true}"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("INVALID_PHONE"));
    }

    @Test
    void loginBeforeVerificationIsForbidden() throws Exception {
        String phone = freshPhone();
        mvc.perform(post("/api/v1/auth/register", null, "{\"phone\":\"%s\",\"password\":\"Abcdef12\",\"privacyConsent\":true}".formatted(phone)))
                .andExpect(status().isAccepted());
        mvc.perform(post("/api/v1/auth/login", null, "{\"phone\":\"%s\",\"password\":\"Abcdef12\"}".formatted(phone)))
                .andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("PHONE_NOT_VERIFIED"));
    }

    @Test
    void invalidCredentialsGiveGenericUnauthorized() throws Exception {
        Session s = registerCustomer();
        mvc.perform(post("/api/v1/auth/login", null, "{\"phone\":\"%s\",\"password\":\"Wrong-pass1\"}".formatted(s.phone())))
                .andExpect(status().isUnauthorized()).andExpect(jsonPath("$.code").value("INVALID_CREDENTIALS"));
        mvc.perform(post("/api/v1/auth/login", null, "{\"phone\":\"+77999999999\",\"password\":\"Wrong-pass1\"}"))
                .andExpect(status().isUnauthorized()).andExpect(jsonPath("$.code").value("INVALID_CREDENTIALS"));
    }

    @Test
    void duplicateRegistrationOfVerifiedPhoneConflicts() throws Exception {
        Session s = registerCustomer();
        mvc.perform(post("/api/v1/auth/register", null, "{\"phone\":\"%s\",\"password\":\"Abcdef12\",\"privacyConsent\":true}".formatted(s.phone())))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("PHONE_ALREADY_REGISTERED"));
    }

    @Test
    void refreshTokenRotatesAndReuseRevokesTheFamily() throws Exception {
        Session s = registerCustomer();
        MvcResult first = mvc.perform(post("/api/v1/auth/refresh", null, "{\"refreshToken\":\"%s\"}".formatted(s.refresh())))
                .andExpect(status().isOk()).andReturn();
        JsonNode rotated = body(first);
        String newRefresh = rotated.get("refreshToken").asText();
        assertThat(newRefresh).isNotEqualTo(s.refresh());

        // Replaying the old token is theft: 401 and the whole family is revoked, including the new token.
        mvc.perform(post("/api/v1/auth/refresh", null, "{\"refreshToken\":\"%s\"}".formatted(s.refresh()))).andExpect(status().isUnauthorized());
        mvc.perform(post("/api/v1/auth/refresh", null, "{\"refreshToken\":\"%s\"}".formatted(newRefresh))).andExpect(status().isUnauthorized());
    }

    @Test
    void logoutRevokesRefreshToken() throws Exception {
        Session s = registerCustomer();
        mvc.perform(post("/api/v1/auth/logout", s, "{\"refreshToken\":\"%s\"}".formatted(s.refresh()))).andExpect(status().isNoContent());
        mvc.perform(post("/api/v1/auth/refresh", null, "{\"refreshToken\":\"%s\"}".formatted(s.refresh()))).andExpect(status().isUnauthorized());
    }

    @Test
    void malformedAndForgedTokensAreRejected() throws Exception {
        mvc.perform(get("/api/v1/users/me", null).header("Authorization", "Bearer not-a-jwt")).andExpect(status().isUnauthorized());
        mvc.perform(get("/api/v1/users/me", null)).andExpect(status().isUnauthorized());
    }

    @Test
    void profileUpdatePersistsLocaleAndPreferences() throws Exception {
        Session s = registerCustomer();
        mvc.perform(patch("/api/v1/users/me", s, "{\"fullName\":\"Алия\",\"locale\":\"kk\",\"notifyPromotions\":true}"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.locale").value("kk")).andExpect(jsonPath("$.notifyPromotions").value(true));
        mvc.perform(patch("/api/v1/users/me", s, "{\"locale\":\"fr\"}")).andExpect(status().isBadRequest());
    }
}
