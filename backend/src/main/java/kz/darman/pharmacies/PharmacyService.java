package kz.darman.pharmacies;

import java.math.BigDecimal;
import java.util.*;
import kz.darman.common.ApiException;
import kz.darman.common.PageResponse;
import kz.darman.pharmacies.PharmacyRepositories.*;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class PharmacyService {
    public record BranchDto(UUID id, UUID pharmacyId, String pharmacyName, String name, String city, String address, Double latitude,
                            Double longitude, String phone, String openingHours, boolean pickupAvailable, boolean deliveryAvailable,
                            BigDecimal deliveryFee, BigDecimal freeDeliveryFrom, Integer etaMinMinutes, Integer etaMaxMinutes,
                            Double distanceKm, boolean demo, boolean licenseVerified) {}

    public record PharmacyDto(UUID id, String name, String description, boolean demo, boolean licenseVerified, List<BranchDto> branches) {}

    public record PharmacyProductDto(UUID productId, String name, String strength, String dosageForm, String packageSize,
                                     boolean rxRequired, UUID offerId, UUID branchId, String branchName, BigDecimal price,
                                     String availability, int availableQuantity) {}

    private final PharmacyRepository pharmacies;
    private final BranchRepository branches;
    private final NamedParameterJdbcTemplate jdbc;

    public PharmacyService(PharmacyRepository pharmacies, BranchRepository branches, NamedParameterJdbcTemplate jdbc) {
        this.pharmacies = pharmacies;
        this.branches = branches;
        this.jdbc = jdbc;
    }

    public List<BranchDto> nearby(String city, Double lat, Double lon, Boolean deliveryOnly) {
        Map<UUID, Pharmacy> byId = new HashMap<>();
        pharmacies.findByActiveTrueOrderByNameAsc().forEach(p -> byId.put(p.getId(), p));
        List<BranchDto> out = new ArrayList<>();
        for (PharmacyBranch b : branches.findByActiveTrueOrderByNameAsc()) {
            Pharmacy p = byId.get(b.getPharmacyId());
            if (p == null) continue;
            if (city != null && !city.isBlank() && !b.getCity().equalsIgnoreCase(city)) continue;
            if (Boolean.TRUE.equals(deliveryOnly) && !b.isDeliveryAvailable()) continue;
            out.add(toDto(b, p, lat, lon));
        }
        if (lat != null && lon != null) {
            out.sort(Comparator.comparing(BranchDto::distanceKm, Comparator.nullsLast(Comparator.naturalOrder())));
        }
        return out;
    }

    public PharmacyDto get(UUID id) {
        Pharmacy p = pharmacies.findById(id).filter(Pharmacy::isActive).orElseThrow(() -> ApiException.notFound("Pharmacy"));
        List<BranchDto> bs = branches.findByPharmacyIdAndActiveTrue(id).stream().map(b -> toDto(b, p, null, null)).toList();
        return new PharmacyDto(p.getId(), p.getName(), p.getDescription(), p.isDemo(), p.isLicenseVerified(), bs);
    }

    public PageResponse<PharmacyProductDto> products(UUID pharmacyId, int page, int size) {
        if (!pharmacies.existsById(pharmacyId)) throw ApiException.notFound("Pharmacy");
        var params = Map.<String, Object>of("id", pharmacyId, "limit", size, "offset", page * size);
        Long total = jdbc.queryForObject("""
                select count(*) from product_offers o join pharmacy_branches b on b.id = o.branch_id
                join products p on p.id = o.product_id where b.pharmacy_id = :id and o.active and p.active""", params, Long.class);
        List<PharmacyProductDto> items = jdbc.query("""
                select p.id, p.name, p.strength, p.dosage_form, p.package_size, p.rx_required, o.id as offer_id, b.id as branch_id,
                       b.name as branch_name, o.price, i.quantity
                from product_offers o join pharmacy_branches b on b.id = o.branch_id and b.active
                join products p on p.id = o.product_id and p.active join inventory i on i.offer_id = o.id
                where b.pharmacy_id = :id and o.active order by p.name, b.name limit :limit offset :offset""", params, (rs, n) -> {
            int qty = rs.getInt("quantity");
            return new PharmacyProductDto(rs.getObject("id", UUID.class), rs.getString("name"), rs.getString("strength"),
                    rs.getString("dosage_form"), rs.getString("package_size"), rs.getBoolean("rx_required"),
                    rs.getObject("offer_id", UUID.class), rs.getObject("branch_id", UUID.class), rs.getString("branch_name"),
                    rs.getBigDecimal("price"), qty <= 0 ? "OUT_OF_STOCK" : qty <= 5 ? "LOW_STOCK" : "IN_STOCK", qty);
        });
        return PageResponse.of(items, page, size, total == null ? 0 : total);
    }

    private BranchDto toDto(PharmacyBranch b, Pharmacy p, Double lat, Double lon) {
        Double dist = null;
        if (lat != null && lon != null && b.getLatitude() != null && b.getLongitude() != null) {
            dist = Math.round(haversine(lat, lon, b.getLatitude(), b.getLongitude()) * 10) / 10.0;
        }
        return new BranchDto(b.getId(), p.getId(), p.getName(), b.getName(), b.getCity(), b.getAddress(), b.getLatitude(), b.getLongitude(),
                b.getPhone(), b.getOpeningHours(), b.isPickupAvailable(), b.isDeliveryAvailable(), b.getDeliveryFee(),
                b.getFreeDeliveryFrom(), b.getDeliveryEtaMin(), b.getDeliveryEtaMax(), dist, p.isDemo(), p.isLicenseVerified());
    }

    static double haversine(double lat1, double lon1, double lat2, double lon2) {
        double r = 6371.0;
        double dLat = Math.toRadians(lat2 - lat1), dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return 2 * r * Math.asin(Math.sqrt(a));
    }
}
