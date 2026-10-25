package kz.darman.admin;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import java.util.stream.Stream;
import kz.darman.audit.AuditService;
import kz.darman.catalog.*;
import kz.darman.catalog.CatalogRepositories.*;
import kz.darman.common.ApiException;
import kz.darman.common.PageResponse;
import kz.darman.inventory.Inventory;
import kz.darman.inventory.InventoryRepositories.InventoryRepository;
import kz.darman.inventory.InventoryRepositories.OfferRepository;
import kz.darman.inventory.ProductOffer;
import kz.darman.pharmacies.Pharmacy;
import kz.darman.pharmacies.PharmacyBranch;
import kz.darman.pharmacies.PharmacyRepositories.BranchRepository;
import kz.darman.pharmacies.PharmacyRepositories.PharmacyRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminCatalogService {
    public record CategoryRequest(@NotBlank @Size(max = 80) @Pattern(regexp = "[a-z0-9-]+") String slug, @NotBlank @Size(max = 120) String nameRu,
                                  @NotBlank @Size(max = 120) String nameKk, @NotBlank @Size(max = 120) String nameEn,
                                  @Size(max = 48) String icon, Integer sortOrder, Boolean active) {}

    public record CategoryAdminDto(UUID id, String slug, String nameRu, String nameKk, String nameEn, String icon, int sortOrder, boolean active) {}

    public record ManufacturerRequest(@NotBlank @Size(max = 160) String name, @Size(max = 80) String country) {}

    public record ManufacturerDto(UUID id, String name, String country) {}

    public record ProductRequest(@NotBlank @Size(max = 160) @Pattern(regexp = "[a-z0-9-]+") String slug, @NotBlank @Size(max = 200) String name,
                                 @Size(max = 120) String brand, @Size(max = 200) String activeIngredient, @Size(max = 80) String strength,
                                 @Size(max = 80) String dosageForm, @Size(max = 80) String packageSize, UUID manufacturerId,
                                 @NotNull UUID categoryId, boolean rxRequired, String descriptionRu, String descriptionKk, String descriptionEn,
                                 Boolean active, Integer popularity) {}

    public record ProductAdminDto(UUID id, String slug, String name, String brand, String activeIngredient, String strength, String dosageForm,
                                  String packageSize, UUID manufacturerId, UUID categoryId, String saleClass, boolean rxRequired,
                                  String descriptionRu, String descriptionKk, String descriptionEn, boolean active, int popularity, boolean demo) {}

    public record InfoRequest(@NotBlank @Pattern(regexp = "USAGE|STORAGE|WARNINGS|CONTRAINDICATIONS|COMPOSITION") String section,
                              @NotBlank @Pattern(regexp = "ru|kk|en") String locale, @NotBlank @Size(max = 8000) String body,
                              @NotBlank @Size(max = 255) String source, boolean verified) {}

    public record PharmacyRequest(@NotBlank @Size(max = 160) String name, @Size(max = 500) String description, Boolean active) {}

    public record BranchRequest(@NotBlank @Size(max = 160) String name, @NotBlank @Size(max = 80) String city, @NotBlank @Size(max = 255) String address,
                                Double latitude, Double longitude, @Size(max = 32) String phone, @Size(max = 120) String openingHours,
                                boolean pickupAvailable, boolean deliveryAvailable, @DecimalMin("0") BigDecimal deliveryFee,
                                @DecimalMin("0") BigDecimal freeDeliveryFrom, @Min(0) Integer etaMinMinutes, @Min(0) Integer etaMaxMinutes,
                                Boolean active) {}

    public record OfferRequest(@NotNull UUID productId, @NotNull UUID branchId, @NotNull @DecimalMin("0") BigDecimal price,
                               @DecimalMin("0") BigDecimal oldPrice, @NotNull @Min(0) @Max(100000) Integer quantity, Boolean active) {}

    public record StockRequest(@NotNull @Min(0) @Max(100000) Integer quantity) {}

    public record OfferAdminDto(UUID id, UUID productId, String productName, UUID branchId, String branchName, String pharmacyName,
                                BigDecimal price, BigDecimal oldPrice, boolean active, int quantity) {}

    private final CategoryRepository categories;
    private final ProductRepository products;
    private final ManufacturerRepository manufacturers;
    private final ProductInfoRepository infos;
    private final PharmacyRepository pharmacies;
    private final BranchRepository branches;
    private final OfferRepository offers;
    private final InventoryRepository inventory;
    private final NamedParameterJdbcTemplate jdbc;
    private final AuditService audit;

    public AdminCatalogService(CategoryRepository categories, ProductRepository products, ManufacturerRepository manufacturers,
                               ProductInfoRepository infos, PharmacyRepository pharmacies, BranchRepository branches, OfferRepository offers,
                               InventoryRepository inventory, NamedParameterJdbcTemplate jdbc, AuditService audit) {
        this.categories = categories;
        this.products = products;
        this.manufacturers = manufacturers;
        this.infos = infos;
        this.pharmacies = pharmacies;
        this.branches = branches;
        this.offers = offers;
        this.inventory = inventory;
        this.jdbc = jdbc;
        this.audit = audit;
    }

    // categories
    @Transactional(readOnly = true)
    public List<CategoryAdminDto> categories() {
        return categories.findAll(Sort.by("sortOrder")).stream().map(AdminCatalogService::dto).toList();
    }

    @Transactional
    public CategoryAdminDto saveCategory(UUID id, CategoryRequest r) {
        Category c = id == null ? new Category() : categories.findById(id).orElseThrow(() -> ApiException.notFound("Category"));
        c.setSlug(r.slug());
        c.setNameRu(r.nameRu());
        c.setNameKk(r.nameKk());
        c.setNameEn(r.nameEn());
        if (r.icon() != null) c.setIcon(r.icon());
        if (r.sortOrder() != null) c.setSortOrder(r.sortOrder());
        if (r.active() != null) c.setActive(r.active());
        audit.record(id == null ? "CATEGORY_CREATED" : "CATEGORY_UPDATED", "Category", r.slug(), null);
        return dto(categories.save(c));
    }

    // manufacturers
    @Transactional(readOnly = true)
    public List<ManufacturerDto> manufacturers() {
        return manufacturers.findAll(Sort.by("name")).stream().map(m -> new ManufacturerDto(m.getId(), m.getName(), m.getCountry())).toList();
    }

    @Transactional
    public ManufacturerDto saveManufacturer(UUID id, ManufacturerRequest r) {
        Manufacturer m = id == null ? new Manufacturer() : manufacturers.findById(id).orElseThrow(() -> ApiException.notFound("Manufacturer"));
        m.setName(r.name().trim());
        m.setCountry(r.country());
        m = manufacturers.save(m);
        audit.record("MANUFACTURER_SAVED", "Manufacturer", m.getId(), null);
        return new ManufacturerDto(m.getId(), m.getName(), m.getCountry());
    }

    // products
    @Transactional(readOnly = true)
    public PageResponse<ProductAdminDto> products(String q, int page, int size) {
        String like = "%" + (q == null ? "" : q.trim().toLowerCase(Locale.ROOT)) + "%";
        var params = new MapSqlParameterSource("like", like).addValue("limit", size).addValue("offset", page * size);
        Long total = jdbc.queryForObject("select count(*) from products where search_text like :like", params, Long.class);
        List<UUID> ids = jdbc.queryForList("select id from products where search_text like :like order by name limit :limit offset :offset", params, UUID.class);
        List<ProductAdminDto> items = ids.isEmpty() ? List.of() : products.findAllById(ids).stream()
                .sorted(java.util.Comparator.comparing(Product::getName)).map(AdminCatalogService::dto).toList();
        return PageResponse.of(items, page, size, total == null ? 0 : total);
    }

    @Transactional
    public ProductAdminDto saveProduct(UUID id, ProductRequest r) {
        Category cat = categories.findById(r.categoryId()).orElseThrow(() -> ApiException.badRequest("UNKNOWN_CATEGORY", "Unknown category"));
        Manufacturer man = r.manufacturerId() == null ? null
                : manufacturers.findById(r.manufacturerId()).orElseThrow(() -> ApiException.badRequest("UNKNOWN_MANUFACTURER", "Unknown manufacturer"));
        Product p = id == null ? new Product() : products.findById(id).orElseThrow(() -> ApiException.notFound("Product"));
        p.setSlug(r.slug());
        p.setName(r.name().trim());
        p.setBrand(r.brand());
        p.setActiveIngredient(r.activeIngredient());
        p.setStrength(r.strength());
        p.setDosageForm(r.dosageForm());
        p.setPackageSize(r.packageSize());
        p.setManufacturerId(r.manufacturerId());
        p.setCategoryId(r.categoryId());
        p.setRxRequired(r.rxRequired());
        p.setSaleClass(r.rxRequired() ? "RX" : "OTC");
        p.setDescriptionRu(r.descriptionRu());
        p.setDescriptionKk(r.descriptionKk());
        p.setDescriptionEn(r.descriptionEn());
        if (r.active() != null) p.setActive(r.active());
        if (r.popularity() != null) p.setPopularity(r.popularity());
        p.setSearchText(Stream.of(p.getName(), p.getBrand(), p.getActiveIngredient(), p.getStrength(), p.getDosageForm(), p.getPackageSize(),
                        man == null ? null : man.getName(), cat.getNameRu(), cat.getNameKk(), cat.getNameEn())
                .filter(s -> s != null && !s.isBlank()).map(s -> s.toLowerCase(Locale.ROOT)).reduce((a, b) -> a + " " + b).orElse(""));
        p = products.save(p);
        audit.record(id == null ? "PRODUCT_CREATED" : "PRODUCT_UPDATED", "Product", p.getId(), p.getName());
        return dto(p);
    }

    @Transactional
    public void deactivateProduct(UUID id) {
        Product p = products.findById(id).orElseThrow(() -> ApiException.notFound("Product"));
        p.setActive(false);
        audit.record("PRODUCT_DEACTIVATED", "Product", id, null);
    }

    @Transactional
    public void putInfo(UUID productId, InfoRequest r) {
        if (!products.existsById(productId)) throw ApiException.notFound("Product");
        ProductInfo i = infos.findByProductIdAndSectionAndLocale(productId, r.section(), r.locale()).orElseGet(ProductInfo::new);
        i.setProductId(productId);
        i.setSection(r.section());
        i.setLocale(r.locale());
        i.setBody(r.body());
        i.setSource(r.source());
        i.setVerified(r.verified());
        infos.save(i);
        audit.record("PRODUCT_INFO_SAVED", "Product", productId, r.section() + "/" + r.locale() + " source=" + r.source());
    }

    // pharmacies
    @Transactional
    public Pharmacy savePharmacy(UUID id, PharmacyRequest r) {
        Pharmacy p = id == null ? new Pharmacy() : pharmacies.findById(id).orElseThrow(() -> ApiException.notFound("Pharmacy"));
        p.setName(r.name().trim());
        p.setDescription(r.description());
        if (r.active() != null) p.setActive(r.active());
        // license_verified is intentionally not editable here: it must come from a documented verification process.
        audit.record(id == null ? "PHARMACY_CREATED" : "PHARMACY_UPDATED", "Pharmacy", r.name(), null);
        return pharmacies.save(p);
    }

    @Transactional
    public PharmacyBranch saveBranch(UUID pharmacyId, UUID branchId, BranchRequest r) {
        if (!pharmacies.existsById(pharmacyId)) throw ApiException.notFound("Pharmacy");
        PharmacyBranch b = branchId == null ? new PharmacyBranch() : branches.findById(branchId).filter(x -> x.getPharmacyId().equals(pharmacyId))
                .orElseThrow(() -> ApiException.notFound("Branch"));
        b.setPharmacyId(pharmacyId);
        b.setName(r.name());
        b.setCity(r.city());
        b.setAddress(r.address());
        b.setLatitude(r.latitude());
        b.setLongitude(r.longitude());
        b.setPhone(r.phone());
        b.setOpeningHours(r.openingHours());
        b.setPickupAvailable(r.pickupAvailable());
        b.setDeliveryAvailable(r.deliveryAvailable());
        b.setDeliveryFee(r.deliveryFee() == null ? BigDecimal.ZERO : r.deliveryFee());
        b.setFreeDeliveryFrom(r.freeDeliveryFrom());
        b.setDeliveryEtaMin(r.etaMinMinutes());
        b.setDeliveryEtaMax(r.etaMaxMinutes());
        if (r.active() != null) b.setActive(r.active());
        audit.record(branchId == null ? "BRANCH_CREATED" : "BRANCH_UPDATED", "PharmacyBranch", r.name(), null);
        return branches.save(b);
    }

    // offers & stock
    @Transactional(readOnly = true)
    public PageResponse<OfferAdminDto> offers(UUID branchId, UUID productId, int page, int size) {
        var params = new MapSqlParameterSource().addValue("branch", branchId).addValue("product", productId).addValue("limit", size)
                .addValue("offset", page * size);
        String where = "where (cast(:branch as uuid) is null or o.branch_id = :branch) and (cast(:product as uuid) is null or o.product_id = :product)";
        Long total = jdbc.queryForObject("select count(*) from product_offers o " + where, params, Long.class);
        List<OfferAdminDto> items = jdbc.query("""
                select o.id, o.product_id, p.name, o.branch_id, b.name as branch_name, ph.name as pharmacy_name, o.price, o.old_price,
                       o.active, coalesce(i.quantity, 0) as quantity
                from product_offers o join products p on p.id = o.product_id join pharmacy_branches b on b.id = o.branch_id
                join pharmacies ph on ph.id = b.pharmacy_id left join inventory i on i.offer_id = o.id """ + " " + where
                + " order by p.name, b.name limit :limit offset :offset", params, (rs, n) -> new OfferAdminDto(rs.getObject("id", UUID.class),
                rs.getObject("product_id", UUID.class), rs.getString("name"), rs.getObject("branch_id", UUID.class), rs.getString("branch_name"),
                rs.getString("pharmacy_name"), rs.getBigDecimal("price"), rs.getBigDecimal("old_price"), rs.getBoolean("active"), rs.getInt("quantity")));
        return PageResponse.of(items, page, size, total == null ? 0 : total);
    }

    @Transactional
    public OfferAdminDto upsertOffer(OfferRequest r) {
        if (!products.existsById(r.productId())) throw ApiException.notFound("Product");
        if (!branches.existsById(r.branchId())) throw ApiException.notFound("Branch");
        ProductOffer o = offers.findByProductId(r.productId()).stream().filter(x -> x.getBranchId().equals(r.branchId())).findFirst().orElseGet(ProductOffer::new);
        o.setProductId(r.productId());
        o.setBranchId(r.branchId());
        o.setPrice(r.price());
        o.setOldPrice(r.oldPrice());
        if (r.active() != null) o.setActive(r.active());
        o = offers.saveAndFlush(o);
        Inventory inv = inventory.findById(o.getId()).orElseGet(() -> new Inventory(null, 0));
        inv.setOfferId(o.getId());
        inv.setQuantity(r.quantity());
        inv.setUpdatedAt(java.time.Instant.now());
        inventory.saveAndFlush(inv);
        audit.record("OFFER_UPSERTED", "ProductOffer", o.getId(), "price=" + r.price() + " qty=" + r.quantity());
        return find(o.getId());
    }

    @Transactional
    public OfferAdminDto setStock(UUID offerId, StockRequest r) {
        Inventory inv = inventory.findById(offerId).orElseThrow(() -> ApiException.notFound("Offer"));
        inv.setQuantity(r.quantity());
        inv.setUpdatedAt(java.time.Instant.now());
        inventory.save(inv);
        audit.record("STOCK_SET", "ProductOffer", offerId, "qty=" + r.quantity());
        return find(offerId);
    }

    @Transactional
    public void setOfferActive(UUID offerId, boolean active) {
        ProductOffer o = offers.findById(offerId).orElseThrow(() -> ApiException.notFound("Offer"));
        o.setActive(active);
        audit.record(active ? "OFFER_ENABLED" : "OFFER_DISABLED", "ProductOffer", offerId, null);
    }

    private OfferAdminDto find(UUID offerId) {
        return jdbc.query("""
                select o.id, o.product_id, p.name, o.branch_id, b.name as branch_name, ph.name as pharmacy_name, o.price, o.old_price,
                       o.active, coalesce(i.quantity, 0) as quantity
                from product_offers o join products p on p.id = o.product_id join pharmacy_branches b on b.id = o.branch_id
                join pharmacies ph on ph.id = b.pharmacy_id left join inventory i on i.offer_id = o.id where o.id = :id""",
                new MapSqlParameterSource("id", offerId), (rs, n) -> new OfferAdminDto(rs.getObject("id", UUID.class),
                        rs.getObject("product_id", UUID.class), rs.getString("name"), rs.getObject("branch_id", UUID.class), rs.getString("branch_name"),
                        rs.getString("pharmacy_name"), rs.getBigDecimal("price"), rs.getBigDecimal("old_price"), rs.getBoolean("active"),
                        rs.getInt("quantity"))).stream().findFirst().orElseThrow(() -> ApiException.notFound("Offer"));
    }

    private static CategoryAdminDto dto(Category c) {
        return new CategoryAdminDto(c.getId(), c.getSlug(), c.getNameRu(), c.getNameKk(), c.getNameEn(), c.getIcon(), c.getSortOrder(), c.isActive());
    }

    private static ProductAdminDto dto(Product p) {
        return new ProductAdminDto(p.getId(), p.getSlug(), p.getName(), p.getBrand(), p.getActiveIngredient(), p.getStrength(), p.getDosageForm(),
                p.getPackageSize(), p.getManufacturerId(), p.getCategoryId(), p.getSaleClass(), p.isRxRequired(), p.getDescriptionRu(),
                p.getDescriptionKk(), p.getDescriptionEn(), p.isActive(), p.getPopularity(), p.isDemo());
    }
}
