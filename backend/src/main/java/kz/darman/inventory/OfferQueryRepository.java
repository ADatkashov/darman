package kz.darman.inventory;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import kz.darman.catalog.CatalogDtos.OfferDto;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class OfferQueryRepository {
    private static final String SELECT = """
            SELECT o.id, o.product_id, o.branch_id, b.name AS branch_name, ph.id AS pharmacy_id, ph.name AS pharmacy_name,
                   b.address, b.latitude, b.longitude, o.price, o.old_price, o.currency, i.quantity,
                   b.pickup_available, b.delivery_available, b.delivery_fee, b.free_delivery_from,
                   b.delivery_eta_min, b.delivery_eta_max, o.updated_at, ph.is_demo
            FROM product_offers o
            JOIN inventory i ON i.offer_id = o.id
            JOIN pharmacy_branches b ON b.id = o.branch_id AND b.active
            JOIN pharmacies ph ON ph.id = b.pharmacy_id AND ph.active
            WHERE o.active AND %s
            """;

    private final NamedParameterJdbcTemplate jdbc;

    public OfferQueryRepository(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<OfferDto> MAPPER = (rs, n) -> {
        int qty = rs.getInt("quantity");
        boolean delivery = rs.getBoolean("delivery_available");
        Integer etaMin = (Integer) rs.getObject("delivery_eta_min");
        Integer etaMax = (Integer) rs.getObject("delivery_eta_max");
        return new OfferDto(rs.getObject("id", UUID.class), rs.getObject("product_id", UUID.class), rs.getObject("branch_id", UUID.class),
                rs.getString("branch_name"), rs.getObject("pharmacy_id", UUID.class), rs.getString("pharmacy_name"),
                rs.getString("address"), (Double) rs.getObject("latitude"), (Double) rs.getObject("longitude"),
                rs.getBigDecimal("price"), rs.getBigDecimal("old_price"), rs.getString("currency"),
                qty <= 0 ? "OUT_OF_STOCK" : qty <= 5 ? "LOW_STOCK" : "IN_STOCK", qty, rs.getBoolean("pickup_available"), delivery,
                rs.getBigDecimal("delivery_fee"), rs.getBigDecimal("free_delivery_from"),
                delivery ? etaMin : null, delivery ? etaMax : null, true,
                rs.getTimestamp("updated_at").toInstant(), rs.getBoolean("is_demo"));
    };

    public List<OfferDto> forProduct(UUID productId, String sort) {
        String order = "price_desc".equals(sort) ? "o.price DESC" : "o.price ASC";
        return jdbc.query(SELECT.formatted("o.product_id = :id") + " ORDER BY (i.quantity > 0) DESC, " + order,
                Map.of("id", productId), MAPPER);
    }

    public List<OfferDto> byIds(java.util.Collection<UUID> ids) {
        if (ids.isEmpty()) return List.of();
        return jdbc.query(SELECT.formatted("o.id IN (:ids)"), Map.of("ids", ids), MAPPER);
    }

    public List<OfferDto> forBranch(UUID branchId, int limit, int offset) {
        return jdbc.query(SELECT.formatted("o.branch_id = :id") + " ORDER BY o.product_id LIMIT :limit OFFSET :offset",
                Map.of("id", branchId, "limit", limit, "offset", offset), MAPPER);
    }
}
