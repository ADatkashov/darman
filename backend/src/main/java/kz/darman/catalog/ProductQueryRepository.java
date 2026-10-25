package kz.darman.catalog;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import kz.darman.catalog.CatalogDtos.ProductCard;
import kz.darman.catalog.CatalogDtos.SearchFilters;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

/** Read model for product lists/search. One round trip aggregates the best offer and availability per product. */
@Repository
public class ProductQueryRepository {
    private static final String BASE_CTE = """
            WITH best AS (
              SELECT DISTINCT ON (o.product_id) o.product_id, o.id AS offer_id, o.price, o.old_price, o.currency,
                     (i.quantity > 0) AS in_stock, b.name AS branch_name, ph.name AS pharmacy_name
              FROM product_offers o
              JOIN inventory i ON i.offer_id = o.id
              JOIN pharmacy_branches b ON b.id = o.branch_id AND b.active
              JOIN pharmacies ph ON ph.id = b.pharmacy_id AND ph.active
              WHERE o.active
              ORDER BY o.product_id, (i.quantity > 0) DESC, o.price ASC
            ), cnt AS (
              SELECT o.product_id, count(*) FILTER (WHERE i.quantity > 0) AS available
              FROM product_offers o JOIN inventory i ON i.offer_id = o.id
              WHERE o.active GROUP BY o.product_id
            )
            """;

    private static final String SELECT = """
            SELECT p.id, p.slug, p.name, p.brand, p.active_ingredient, p.strength, p.dosage_form, p.package_size,
                   m.name AS manufacturer, p.category_id, c.slug AS category_slug, p.rx_required,
                   (SELECT pi.url FROM product_images pi WHERE pi.product_id = p.id ORDER BY pi.sort_order LIMIT 1) AS image_url,
                   best.price, best.old_price, coalesce(best.currency, 'KZT') AS currency, best.offer_id,
                   best.pharmacy_name, best.branch_name, coalesce(cnt.available, 0) AS available,
                   coalesce(best.in_stock, false) AS in_stock, p.popularity, p.is_demo
            FROM products p
            JOIN categories c ON c.id = p.category_id
            LEFT JOIN manufacturers m ON m.id = p.manufacturer_id
            LEFT JOIN best ON best.product_id = p.id
            LEFT JOIN cnt ON cnt.product_id = p.id
            """;

    private static final RowMapper<ProductCard> MAPPER = ProductQueryRepository::map;

    private final NamedParameterJdbcTemplate jdbc;

    public ProductQueryRepository(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    static ProductCard map(ResultSet rs, int n) throws SQLException {
        return new ProductCard(rs.getObject("id", UUID.class), rs.getString("slug"), rs.getString("name"), rs.getString("brand"),
                rs.getString("active_ingredient"), rs.getString("strength"), rs.getString("dosage_form"), rs.getString("package_size"),
                rs.getString("manufacturer"), rs.getObject("category_id", UUID.class), rs.getString("category_slug"),
                rs.getBoolean("rx_required"), rs.getString("image_url"), rs.getBigDecimal("price"), rs.getBigDecimal("old_price"),
                rs.getString("currency"), rs.getObject("offer_id", UUID.class), rs.getString("pharmacy_name"), rs.getString("branch_name"),
                rs.getInt("available"), rs.getBoolean("in_stock"), rs.getInt("popularity"), rs.getBoolean("is_demo"));
    }

    public Optional<ProductCard> findCard(UUID id) {
        List<ProductCard> r = jdbc.query(BASE_CTE + SELECT + " WHERE p.id = :id AND p.active", Map.of("id", id), MAPPER);
        return r.stream().findFirst();
    }

    public List<ProductCard> findCards(Collection<UUID> ids) {
        if (ids.isEmpty()) return List.of();
        return jdbc.query(BASE_CTE + SELECT + " WHERE p.id IN (:ids) AND p.active", Map.of("ids", ids), MAPPER);
    }

    public record Page(List<ProductCard> items, long total) {}

    public Page search(SearchFilters f) {
        MapSqlParameterSource params = new MapSqlParameterSource();
        List<String> where = new ArrayList<>(List.of("p.active"));
        String q = normalize(f.q());
        String orderRelevance = "p.popularity DESC, p.name ASC";
        if (!q.isEmpty()) {
            String[] tokens = q.split("\\s+");
            for (int i = 0; i < tokens.length && i < 8; i++) {
                params.addValue("t" + i, "%" + escape(tokens[i]) + "%");
                where.add("p.search_text LIKE :t" + i + " ESCAPE '\\'");
            }
            params.addValue("prefix", escape(q) + "%");
            params.addValue("brandPrefix", escape(q) + "%");
            orderRelevance = "CASE WHEN p.search_text LIKE :prefix ESCAPE '\\' THEN 0 WHEN lower(p.brand) LIKE :brandPrefix ESCAPE '\\' THEN 1 ELSE 2 END, p.popularity DESC, p.name ASC";
        }
        if (f.categoryId() != null && !f.categoryId().isBlank()) {
            where.add("p.category_id = :categoryId");
            params.addValue("categoryId", UUID.fromString(f.categoryId()));
        }
        if (f.categorySlug() != null && !f.categorySlug().isBlank()) {
            where.add("c.slug = :categorySlug");
            params.addValue("categorySlug", f.categorySlug());
        }
        if (f.manufacturer() != null && !f.manufacturer().isBlank()) {
            where.add("m.name = :manufacturer");
            params.addValue("manufacturer", f.manufacturer());
        }
        if (Boolean.TRUE.equals(f.inStock())) where.add("coalesce(best.in_stock, false)");
        if (f.rxRequired() != null) {
            where.add("p.rx_required = :rx");
            params.addValue("rx", f.rxRequired());
        }
        if (Boolean.TRUE.equals(f.onSale())) where.add("best.old_price IS NOT NULL AND best.old_price > best.price AND coalesce(best.in_stock, false)");
        if (f.minPrice() != null) {
            where.add("best.price >= :minPrice");
            params.addValue("minPrice", f.minPrice());
        }
        if (f.maxPrice() != null) {
            where.add("best.price <= :maxPrice");
            params.addValue("maxPrice", f.maxPrice());
        }
        String order = switch (f.sort() == null ? "relevance" : f.sort()) {
            case "price_asc" -> "best.price ASC NULLS LAST, p.name ASC";
            case "price_desc" -> "best.price DESC NULLS LAST, p.name ASC";
            case "popularity" -> "p.popularity DESC, p.name ASC";
            default -> orderRelevance;
        };
        String from = SELECT + " WHERE " + String.join(" AND ", where);
        Long total = jdbc.queryForObject(BASE_CTE + "SELECT count(*) FROM (" + from + ") x", params, Long.class);
        params.addValue("limit", f.size());
        params.addValue("offset", (long) f.page() * f.size());
        List<ProductCard> items = jdbc.query(BASE_CTE + from + " ORDER BY " + order + " LIMIT :limit OFFSET :offset", params, MAPPER);
        return new Page(items, total == null ? 0 : total);
    }

    public List<String> manufacturers() {
        return jdbc.getJdbcTemplate().queryForList(
                "SELECT DISTINCT m.name FROM manufacturers m JOIN products p ON p.manufacturer_id = m.id WHERE p.active ORDER BY m.name", String.class);
    }

    public List<CatalogDtos.Suggestion> suggestions(String rawQuery, int limit) {
        String q = normalize(rawQuery);
        if (q.length() < 2) return List.of();
        String like = escape(q) + "%";
        String contains = "%" + escape(q) + "%";
        List<CatalogDtos.Suggestion> out = new ArrayList<>();
        var params = new MapSqlParameterSource().addValue("like", like).addValue("contains", contains).addValue("limit", limit);
        jdbc.query("""
                SELECT s.text, s.type FROM (
                  SELECT DISTINCT p.name AS text, 'product' AS type, p.popularity AS weight
                  FROM products p WHERE p.active AND p.search_text LIKE :contains ESCAPE '\\'
                  UNION
                  SELECT DISTINCT p.brand, 'brand', max(p.popularity) FROM products p
                  WHERE p.active AND p.brand IS NOT NULL AND lower(p.brand) LIKE :like ESCAPE '\\' GROUP BY p.brand
                  UNION
                  SELECT DISTINCT p.active_ingredient, 'ingredient', max(p.popularity) FROM products p
                  WHERE p.active AND p.active_ingredient IS NOT NULL AND lower(p.active_ingredient) LIKE :contains ESCAPE '\\' GROUP BY p.active_ingredient
                ) s ORDER BY (CASE s.type WHEN 'ingredient' THEN 0 WHEN 'brand' THEN 1 ELSE 2 END), s.weight DESC LIMIT :limit
                """, params, rs -> {
            out.add(new CatalogDtos.Suggestion(rs.getString("text"), rs.getString("type")));
        });
        return out;
    }

    public static String normalize(String q) {
        return q == null ? "" : q.trim().toLowerCase(Locale.ROOT).replaceAll("\\s+", " ");
    }

    private static String escape(String s) {
        return s.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
    }

}
