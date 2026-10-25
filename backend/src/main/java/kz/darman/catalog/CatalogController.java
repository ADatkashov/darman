package kz.darman.catalog;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import kz.darman.catalog.CatalogDtos.*;
import kz.darman.common.Lang;
import kz.darman.config.AuthUser;
import org.springframework.http.CacheControl;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1")
public class CatalogController {
    private final CatalogService catalog;

    public CatalogController(CatalogService catalog) {
        this.catalog = catalog;
    }

    @GetMapping("/categories")
    public List<CategoryDto> categories(@RequestParam(required = false) String lang) {
        return catalog.categories(Lang.resolve(lang));
    }

    @GetMapping("/products")
    public SearchResult products(@RequestParam(required = false) String q, @RequestParam(required = false) String categoryId,
                                 @RequestParam(required = false) String categorySlug, @RequestParam(required = false) String manufacturer,
                                 @RequestParam(required = false) Boolean inStock, @RequestParam(required = false) BigDecimal minPrice,
                                 @RequestParam(required = false) BigDecimal maxPrice, @RequestParam(required = false) Boolean rxRequired,
                                 @RequestParam(required = false) Boolean onSale, @RequestParam(defaultValue = "relevance") String sort,
                                 @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size) {
        return catalog.search(filters(q, categoryId, categorySlug, manufacturer, inStock, minPrice, maxPrice, rxRequired, onSale, sort, page, size));
    }

    @GetMapping("/search")
    public SearchResult search(@RequestParam String q, @RequestParam(required = false) String categoryId,
                               @RequestParam(required = false) String categorySlug, @RequestParam(required = false) String manufacturer,
                               @RequestParam(required = false) Boolean inStock, @RequestParam(required = false) BigDecimal minPrice,
                               @RequestParam(required = false) BigDecimal maxPrice, @RequestParam(required = false) Boolean rxRequired,
                               @RequestParam(required = false) Boolean onSale, @RequestParam(defaultValue = "relevance") String sort,
                               @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size) {
        return catalog.search(filters(q, categoryId, categorySlug, manufacturer, inStock, minPrice, maxPrice, rxRequired, onSale, sort, page, size));
    }

    @GetMapping("/search/suggestions")
    public List<Suggestion> suggestions(@RequestParam String q) {
        return catalog.suggestions(q);
    }

    /** Up to 50 products by id, preserving the requested order (favorites, recently viewed). */
    @GetMapping("/products/by-ids")
    public List<ProductCard> byIds(@RequestParam List<UUID> ids) {
        return catalog.cardsInOrder(ids.stream().limit(50).toList());
    }

    @GetMapping("/products/{id}")
    public ResponseEntity<ProductDetail> detail(@PathVariable UUID id, @RequestParam(required = false) String lang,
                                                @AuthenticationPrincipal AuthUser user) {
        ProductDetail d = catalog.detail(id, Lang.resolve(lang), user == null ? null : user.id());
        return ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(d);
    }

    @GetMapping("/products/{id}/offers")
    public List<OfferDto> offers(@PathVariable UUID id, @RequestParam(defaultValue = "price_asc") String sort) {
        return catalog.offersFor(id, sort);
    }

    private static SearchFilters filters(String q, String categoryId, String categorySlug, String manufacturer, Boolean inStock,
                                         BigDecimal minPrice, BigDecimal maxPrice, Boolean rx, Boolean onSale, String sort, int page, int size) {
        return new SearchFilters(q, categoryId, categorySlug, manufacturer, inStock, minPrice, maxPrice, rx, onSale, sort,
                Math.max(0, page), Math.min(Math.max(1, size), 50));
    }
}
