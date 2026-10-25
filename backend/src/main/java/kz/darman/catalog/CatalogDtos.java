package kz.darman.catalog;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public final class CatalogDtos {
    private CatalogDtos() {}

    public record CategoryDto(UUID id, String slug, String name, String icon, long productCount) {}

    /** Compact product representation used in lists, search results and favorites. */
    public record ProductCard(UUID id, String slug, String name, String brand, String activeIngredient, String strength,
                              String dosageForm, String packageSize, String manufacturer, UUID categoryId, String categorySlug,
                              boolean rxRequired, String imageUrl, BigDecimal price, BigDecimal oldPrice, String currency,
                              UUID bestOfferId, String pharmacyName, String branchName, int availableOffers, boolean inStock,
                              int popularity, boolean demo) {}

    public record InfoSection(String section, String body, String source, boolean verified) {}

    public record ProductDetail(ProductCard card, String saleClass, String description, List<String> images,
                                List<InfoSection> officialInfo, boolean officialInfoAvailable, boolean ingredientVerified,
                                boolean favorite) {}

    public record SearchFilters(String q, String categoryId, String categorySlug, String manufacturer, Boolean inStock,
                                BigDecimal minPrice, BigDecimal maxPrice, Boolean rxRequired, Boolean onSale, String sort, int page, int size) {}

    public record SearchResult(List<ProductCard> items, int page, int size, long totalItems, int totalPages, boolean hasNext,
                               String query, List<String> manufacturers) {}

    public record Suggestion(String text, String type) {}

    public record OfferDto(UUID id, UUID productId, UUID branchId, String branchName, UUID pharmacyId, String pharmacyName,
                           String address, Double latitude, Double longitude, BigDecimal price, BigDecimal oldPrice,
                           String currency, String availability, int availableQuantity, boolean pickupAvailable,
                           boolean deliveryAvailable, BigDecimal deliveryFee, BigDecimal freeDeliveryFrom, Integer etaMinMinutes,
                           Integer etaMaxMinutes, boolean etaIsEstimate, Instant updatedAt, boolean demoPharmacy) {}
}
