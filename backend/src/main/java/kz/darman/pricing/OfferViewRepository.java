package kz.darman.pricing;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class OfferViewRepository {
    private final NamedParameterJdbcTemplate jdbc;

    public OfferViewRepository(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public Map<UUID, OfferView> findByIds(Collection<UUID> ids) {
        if (ids.isEmpty()) return Map.of();
        List<OfferView> list = jdbc.query("""
                SELECT o.id, p.id AS product_id, p.name, p.brand, p.strength, p.dosage_form, p.package_size, p.rx_required,
                       p.active AS product_active, o.price, o.currency, o.active AS offer_active, coalesce(i.quantity, 0) AS stock,
                       b.id AS branch_id, b.name AS branch_name, ph.name AS pharmacy_name, (b.active AND ph.active) AS branch_active,
                       b.pickup_available, b.delivery_available, b.delivery_fee, b.free_delivery_from, b.delivery_eta_min, b.delivery_eta_max
                FROM product_offers o
                JOIN products p ON p.id = o.product_id
                JOIN pharmacy_branches b ON b.id = o.branch_id
                JOIN pharmacies ph ON ph.id = b.pharmacy_id
                LEFT JOIN inventory i ON i.offer_id = o.id
                WHERE o.id IN (:ids)""", Map.of("ids", ids), (rs, n) -> new OfferView(rs.getObject("id", UUID.class),
                rs.getObject("product_id", UUID.class), rs.getString("name"), rs.getString("brand"), rs.getString("strength"),
                rs.getString("dosage_form"), rs.getString("package_size"), rs.getBoolean("rx_required"), rs.getBoolean("product_active"),
                rs.getBigDecimal("price"), rs.getString("currency"), rs.getBoolean("offer_active"), rs.getInt("stock"),
                rs.getObject("branch_id", UUID.class), rs.getString("branch_name"), rs.getString("pharmacy_name"),
                rs.getBoolean("branch_active"), rs.getBoolean("pickup_available"), rs.getBoolean("delivery_available"),
                rs.getBigDecimal("delivery_fee"), rs.getBigDecimal("free_delivery_from"), (Integer) rs.getObject("delivery_eta_min"),
                (Integer) rs.getObject("delivery_eta_max")));
        return list.stream().collect(Collectors.toMap(OfferView::offerId, Function.identity()));
    }
}
