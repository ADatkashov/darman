package kz.darman.support;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.UUID;
import org.junit.jupiter.api.BeforeAll;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.testcontainers.containers.PostgreSQLContainer;

/**
 * Base for integration tests. Uses a Testcontainers PostgreSQL when Docker is available; otherwise an externally provided
 * database via DARMAN_TEST_DB_URL / DARMAN_TEST_DB_USER / DARMAN_TEST_DB_PASSWORD (must be empty on first run).
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles({"test"})
public abstract class IntegrationTest {
    public static final String DEMO_PASSWORD = "Test-Passw0rd-Demo";
    private static final PostgreSQLContainer<?> PG;
    private static final Path STORAGE;

    static {
        try {
            STORAGE = Files.createTempDirectory("darman-test-storage");
        } catch (java.io.IOException e) {
            throw new IllegalStateException(e);
        }
        if (System.getenv("DARMAN_TEST_DB_URL") == null) {
            PG = new PostgreSQLContainer<>("postgres:16");
            PG.start();
        } else {
            PG = null;
        }
    }

    @DynamicPropertySource
    static void props(DynamicPropertyRegistry r) {
        if (PG != null) {
            r.add("spring.datasource.url", PG::getJdbcUrl);
            r.add("spring.datasource.username", PG::getUsername);
            r.add("spring.datasource.password", PG::getPassword);
        } else {
            r.add("spring.datasource.url", () -> System.getenv("DARMAN_TEST_DB_URL"));
            r.add("spring.datasource.username", () -> System.getenv().getOrDefault("DARMAN_TEST_DB_USER", "darman"));
            r.add("spring.datasource.password", () -> System.getenv().getOrDefault("DARMAN_TEST_DB_PASSWORD", ""));
        }
        r.add("darman.storage.private-path", STORAGE::toString);
    }

    @Autowired protected MockMvc mvc;
    @Autowired protected ObjectMapper json;
    @Autowired protected JdbcTemplate jdbc;

    private static int phoneCounter = 0;

    // ───── helpers ─────

    public record Session(String access, String refresh, UUID userId, String phone) {}

    protected static synchronized String freshPhone() {
        long base = 7_100_000_000L + (System.nanoTime() % 800_000_000L) + (phoneCounter++);
        return "+7" + base;
    }

    protected JsonNode body(MvcResult r) throws Exception {
        return json.readTree(r.getResponse().getContentAsString());
    }

    protected Session registerCustomer() throws Exception {
        String phone = freshPhone();
        MvcResult reg = mvc.perform(post("/api/v1/auth/register", null, "{\"phone\":\"%s\",\"password\":\"Abcdef12\",\"fullName\":\"Тест Покупатель\",\"privacyConsent\":true}".formatted(phone)))
                .andReturn();
        if (reg.getResponse().getStatus() != 202) throw new IllegalStateException("register failed: " + reg.getResponse().getContentAsString());
        String code = body(reg).get("devOtp").asText();
        MvcResult ver = mvc.perform(post("/api/v1/auth/verify-otp", null, "{\"phone\":\"%s\",\"code\":\"%s\"}".formatted(phone, code))).andReturn();
        JsonNode b = body(ver);
        return new Session(b.get("accessToken").asText(), b.get("refreshToken").asText(), UUID.fromString(b.get("user").get("id").asText()), phone);
    }

    protected Session loginStaff(String phone) throws Exception {
        MvcResult res = mvc.perform(post("/api/v1/auth/login", null, "{\"phone\":\"%s\",\"password\":\"%s\"}".formatted(phone, DEMO_PASSWORD))).andReturn();
        JsonNode b = body(res);
        return new Session(b.get("accessToken").asText(), b.get("refreshToken").asText(), UUID.fromString(b.get("user").get("id").asText()), phone);
    }

    protected Session admin() throws Exception { return loginStaff("+77000000001"); }
    protected Session pharmacist() throws Exception { return loginStaff("+77000000002"); }

    protected MockHttpServletRequestBuilder post(String url, Session s, String content) {
        return withAuth(MockMvcRequestBuilders.post(url), s).contentType(MediaType.APPLICATION_JSON).content(content);
    }

    protected MockHttpServletRequestBuilder get(String url, Session s) {
        return withAuth(MockMvcRequestBuilders.get(url), s);
    }

    protected MockHttpServletRequestBuilder patch(String url, Session s, String content) {
        return withAuth(MockMvcRequestBuilders.patch(url), s).contentType(MediaType.APPLICATION_JSON).content(content);
    }

    protected MockHttpServletRequestBuilder put(String url, Session s, String content) {
        return withAuth(MockMvcRequestBuilders.put(url), s).contentType(MediaType.APPLICATION_JSON).content(content);
    }

    protected MockHttpServletRequestBuilder delete(String url, Session s) {
        return withAuth(MockMvcRequestBuilders.delete(url), s);
    }

    protected MockHttpServletRequestBuilder withAuth(MockHttpServletRequestBuilder b, Session s) {
        return s == null ? b : b.header("Authorization", "Bearer " + s.access());
    }

    protected static final byte[] JPEG = new byte[]{(byte) 0xFF, (byte) 0xD8, (byte) 0xFF, (byte) 0xE0, 0, 16, 'J', 'F', 'I', 'F', 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, (byte) 0xFF, (byte) 0xD9};

    protected MockMultipartFile file(String name, byte[] content) {
        return new MockMultipartFile("files", name, "image/jpeg", content);
    }

    /** First in-stock offer id for a product slug at a given branch name. */
    protected UUID offer(String slug, String branch) {
        return jdbc.queryForObject("""
                select o.id from product_offers o join products p on p.id = o.product_id join pharmacy_branches b on b.id = o.branch_id
                where p.slug = ? and b.name = ?""", UUID.class, slug, branch);
    }

    protected UUID productId(String slug) {
        return jdbc.queryForObject("select id from products where slug = ?", UUID.class, slug);
    }

    protected UUID addressFor(Session s) throws Exception {
        MvcResult r = mvc.perform(post("/api/v1/users/me/addresses", s,
                "{\"city\":\"Алматы\",\"street\":\"ул. Тестовая\",\"house\":\"1\",\"apartment\":\"2\"}")).andReturn();
        return UUID.fromString(body(r).get("id").asText());
    }

    protected String orderJson(UUID offerId, int qty, String fulfillment, UUID addressId, String payment, String extra) {
        return ("{\"items\":[{\"offerId\":\"%s\",\"quantity\":%d}],\"fulfillment\":\"%s\"%s,\"contactName\":\"Тест\",\"contactPhone\":\"+77011234567\"," +
                "\"paymentMethod\":\"%s\",\"consent\":true%s}").formatted(offerId, qty, fulfillment,
                addressId == null ? "" : ",\"addressId\":\"" + addressId + "\"", payment, extra == null ? "" : "," + extra);
    }
}
