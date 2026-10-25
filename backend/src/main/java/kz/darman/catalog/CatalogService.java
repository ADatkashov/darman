package kz.darman.catalog;

import java.util.*;
import java.util.stream.Collectors;
import kz.darman.catalog.CatalogDtos.*;
import kz.darman.catalog.CatalogRepositories.*;
import kz.darman.common.ApiException;
import kz.darman.common.Lang;
import kz.darman.inventory.OfferQueryRepository;
import kz.darman.users.FavoriteRepository;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class CatalogService {
    private final CategoryRepository categories;
    private final ProductRepository products;
    private final ProductInfoRepository infos;
    private final ProductImageRepository images;
    private final ProductQueryRepository query;
    private final OfferQueryRepository offers;
    private final FavoriteRepository favorites;
    private final JdbcTemplate jdbc;

    public CatalogService(CategoryRepository categories, ProductRepository products, ProductInfoRepository infos,
                          ProductImageRepository images, ProductQueryRepository query, OfferQueryRepository offers,
                          FavoriteRepository favorites, JdbcTemplate jdbc) {
        this.categories = categories;
        this.products = products;
        this.infos = infos;
        this.images = images;
        this.query = query;
        this.offers = offers;
        this.favorites = favorites;
        this.jdbc = jdbc;
    }

    public List<CategoryDto> categories(String lang) {
        Map<UUID, Long> counts = new HashMap<>();
        jdbc.query("select category_id, count(*) c from products where active group by category_id",
                rs -> { counts.put(rs.getObject(1, UUID.class), rs.getLong(2)); });
        return categories.findByActiveTrueOrderBySortOrderAsc().stream()
                .map(c -> new CategoryDto(c.getId(), c.getSlug(), Lang.pick(lang, c.getNameRu(), c.getNameKk(), c.getNameEn()),
                        c.getIcon(), counts.getOrDefault(c.getId(), 0L))).toList();
    }

    public SearchResult search(SearchFilters f) {
        ProductQueryRepository.Page page = query.search(f);
        int pages = (int) Math.ceil(page.total() / (double) f.size());
        return new SearchResult(page.items(), f.page(), f.size(), page.total(), pages, f.page() + 1 < pages,
                ProductQueryRepository.normalize(f.q()), f.page() == 0 ? query.manufacturers() : null);
    }

    public List<Suggestion> suggestions(String q) {
        return query.suggestions(q, 8);
    }

    public ProductDetail detail(UUID id, String lang, UUID userId) {
        ProductCard card = query.findCard(id).orElseThrow(() -> ApiException.notFound("Product"));
        Product p = products.findById(id).orElseThrow(() -> ApiException.notFound("Product"));
        List<String> imgs = images.findByProductIdOrderBySortOrderAsc(id).stream().map(ProductImage::getUrl).toList();
        List<InfoSection> info = infos.findByProductId(id).stream()
                .filter(i -> i.getLocale().equals(lang) || (i.getLocale().equals("ru") && infos.findByProductIdAndSectionAndLocale(id, i.getSection(), lang).isEmpty()))
                .map(i -> new InfoSection(i.getSection(), i.getBody(), i.getSource(), i.isVerified()))
                .sorted(Comparator.comparing(InfoSection::section)).toList();
        boolean fav = userId != null && favorites.existsByUserIdAndProductId(userId, id);
        return new ProductDetail(card, p.getSaleClass(), Lang.pick(lang, p.getDescriptionRu(), p.getDescriptionKk(), p.getDescriptionEn()),
                imgs, info, !info.isEmpty(), false, fav);
    }

    public List<OfferDto> offersFor(UUID productId, String sort) {
        if (!products.existsById(productId)) throw ApiException.notFound("Product");
        return offers.forProduct(productId, sort);
    }

    public List<ProductCard> cardsInOrder(List<UUID> ids) {
        Map<UUID, ProductCard> byId = query.findCards(ids).stream().collect(Collectors.toMap(ProductCard::id, c -> c));
        return ids.stream().map(byId::get).filter(Objects::nonNull).toList();
    }
}
