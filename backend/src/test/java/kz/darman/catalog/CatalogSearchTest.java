package kz.darman.catalog;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import java.util.ArrayList;
import java.util.List;
import kz.darman.support.IntegrationTest;
import org.junit.jupiter.api.Test;

class CatalogSearchTest extends IntegrationTest {

    private JsonNode search(String query) throws Exception {
        return body(mvc.perform(get("/api/v1/search?" + query, null)).andExpect(status().isOk()).andReturn());
    }

    @Test
    void categoriesAreLocalized() throws Exception {
        mvc.perform(get("/api/v1/categories?lang=kk", null)).andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(10)).andExpect(jsonPath("$[0].name").value("Ауырсынуды басатын"));
        mvc.perform(get("/api/v1/categories", null).header("Accept-Language", "en")).andExpect(jsonPath("$[0].name").value("Pain relief"));
        mvc.perform(get("/api/v1/categories", null)).andExpect(jsonPath("$[0].name").value("Обезболивающие"));
    }

    @Test
    void searchByNameIngredientBrandAndStrength() throws Exception {
        assertThat(search("q=ибупрофен").get("totalItems").asInt()).isEqualTo(3);
        assertThat(search("q=ibuprofen").get("totalItems").asInt()).isEqualTo(3);
        assertThat(search("q=ИбуДем").get("totalItems").asInt()).isEqualTo(3);
        JsonNode r = search("q=ибудем 400");
        assertThat(r.get("totalItems").asInt()).isEqualTo(1);
        assertThat(r.get("items").get(0).get("strength").asText()).isEqualTo("400 мг");
        assertThat(search("q=гель").get("totalItems").asInt()).isGreaterThanOrEqualTo(3);
    }

    @Test
    void noMatchNeverReturnsUnrelatedProducts() throws Exception {
        JsonNode r = search("q=qwertyzzz");
        assertThat(r.get("totalItems").asInt()).isZero();
        assertThat(r.get("items")).isEmpty();
    }

    @Test
    void sqlWildcardCharactersAreTreatedLiterally() throws Exception {
        assertThat(search("q=%25").get("totalItems").asInt()).isZero();
        assertThat(search("q=_").get("totalItems").asInt()).isZero();
        mvc.perform(get("/api/v1/search?q=%27%3B%20drop%20table%20products%3B--", null)).andExpect(status().isOk());
    }

    @Test
    void sortByPriceAndFilters() throws Exception {
        JsonNode asc = search("q=ибудем&sort=price_asc");
        List<Double> prices = new ArrayList<>();
        asc.get("items").forEach(i -> prices.add(i.get("price").asDouble()));
        assertThat(prices).isSorted();

        JsonNode desc = search("q=ибудем&sort=price_desc");
        assertThat(desc.get("items").get(0).get("price").asDouble()).isEqualTo(prices.get(prices.size() - 1));

        JsonNode cheap = search("q=ибудем&maxPrice=1000");
        cheap.get("items").forEach(i -> assertThat(i.get("price").asDouble()).isLessThanOrEqualTo(1000));

        JsonNode rx = search("q=амло&rxRequired=true");
        assertThat(rx.get("items").get(0).get("rxRequired").asBoolean()).isTrue();
        JsonNode otcOnly = search("q=амло&rxRequired=false");
        assertThat(otcOnly.get("totalItems").asInt()).isZero();
    }

    @Test
    void paginationWalksAllProducts() throws Exception {
        JsonNode p0 = body(mvc.perform(get("/api/v1/products?size=10&page=0", null)).andReturn());
        assertThat(p0.get("items")).hasSize(10);
        assertThat(p0.get("totalItems").asInt()).isGreaterThanOrEqualTo(44);
        assertThat(p0.get("hasNext").asBoolean()).isTrue();
        JsonNode p1 = body(mvc.perform(get("/api/v1/products?size=10&page=1", null)).andReturn());
        assertThat(p1.get("items").get(0).get("id").asText()).isNotEqualTo(p0.get("items").get(0).get("id").asText());
    }

    @Test
    void categoryFilterAndSuggestions() throws Exception {
        JsonNode r = body(mvc.perform(get("/api/v1/products?categorySlug=prescription&size=50", null)).andReturn());
        assertThat(r.get("totalItems").asInt()).isEqualTo(5);
        r.get("items").forEach(i -> assertThat(i.get("rxRequired").asBoolean()).isTrue());

        JsonNode sug = body(mvc.perform(get("/api/v1/search/suggestions?q=ибу", null)).andReturn());
        assertThat(sug.size()).isPositive();
    }

    @Test
    void productDetailAndOffersAreSortedByPrice() throws Exception {
        String id = productId("paradem-500-20").toString();
        mvc.perform(get("/api/v1/products/" + id, null)).andExpect(status().isOk())
                .andExpect(jsonPath("$.card.name").value("ПараДем 500 мг, 20 таблеток"))
                .andExpect(jsonPath("$.officialInfoAvailable").value(false))
                .andExpect(jsonPath("$.card.demo").value(true));
        JsonNode offers = body(mvc.perform(get("/api/v1/products/" + id + "/offers?sort=price_asc", null)).andExpect(status().isOk()).andReturn());
        assertThat(offers.size()).isGreaterThanOrEqualTo(2);
        List<Double> prices = new ArrayList<>();
        offers.forEach(o -> {
            if (!"OUT_OF_STOCK".equals(o.get("availability").asText())) prices.add(o.get("price").asDouble());
            assertThat(o.get("etaIsEstimate").asBoolean()).isTrue();
        });
        assertThat(prices).isSorted();
        mvc.perform(get("/api/v1/products/" + java.util.UUID.randomUUID(), null)).andExpect(status().isNotFound());
    }

    @Test
    void pharmaciesListWithDistanceSorting() throws Exception {
        JsonNode list = body(mvc.perform(get("/api/v1/pharmacies?lat=43.238&lon=76.957", null)).andExpect(status().isOk()).andReturn());
        assertThat(list.size()).isEqualTo(6);
        assertThat(list.get(0).get("distanceKm").asDouble()).isLessThanOrEqualTo(list.get(5).get("distanceKm").asDouble());
        assertThat(list.get(0).get("licenseVerified").asBoolean()).isFalse();
        String pharmacyId = list.get(0).get("pharmacyId").asText();
        mvc.perform(get("/api/v1/pharmacies/" + pharmacyId + "/products?size=5", null)).andExpect(status().isOk())
                .andExpect(jsonPath("$.items.length()").value(5));
    }

    @Test
    void byIdsKeepsOrderAndOnSaleFilterOnlyReturnsDiscountedInStockItems() throws Exception {
        String a = productId("zinc-25-30").toString();
        String b = productId("paradem-500-20").toString();
        JsonNode r = body(mvc.perform(get("/api/v1/products/by-ids?ids=" + a + "," + b, null)).andExpect(status().isOk()).andReturn());
        assertThat(r.get(0).get("id").asText()).isEqualTo(a);
        assertThat(r.get(1).get("id").asText()).isEqualTo(b);
        JsonNode sale = search("q=&onSale=true&size=50");
        sale.get("items").forEach(i -> {
            assertThat(i.get("oldPrice").asDouble()).isGreaterThan(i.get("price").asDouble());
            assertThat(i.get("inStock").asBoolean()).isTrue();
        });
    }
}
