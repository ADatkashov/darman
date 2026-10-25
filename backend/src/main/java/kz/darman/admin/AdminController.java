package kz.darman.admin;

import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import kz.darman.admin.AdminCatalogService.*;
import kz.darman.admin.AdminPromotionService.*;
import kz.darman.admin.AdminStaffService.*;
import kz.darman.audit.AuditEvent;
import kz.darman.audit.AuditEventRepository;
import kz.darman.common.PageResponse;
import kz.darman.config.AuthUser;
import kz.darman.orders.OrderDtos.*;
import kz.darman.orders.OrderService;
import kz.darman.orders.OrderStatus;
import kz.darman.pharmacies.Pharmacy;
import kz.darman.pharmacies.PharmacyBranch;
import kz.darman.prescriptions.PrescriptionDtos.*;
import kz.darman.prescriptions.PrescriptionService;
import kz.darman.prescriptions.PrescriptionStatus;
import kz.darman.users.UserDto;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

/** Staff API. Every method is gated by a permission; customers (no permissions) always receive 403. */
@RestController
@RequestMapping("/api/v1/admin")
public class AdminController {
    private final AdminCatalogService catalog;
    private final AdminPromotionService promotions;
    private final AdminStaffService staff;
    private final OrderService orders;
    private final PrescriptionService prescriptions;
    private final AuditEventRepository auditRepo;

    public AdminController(AdminCatalogService catalog, AdminPromotionService promotions, AdminStaffService staff, OrderService orders,
                           PrescriptionService prescriptions, AuditEventRepository auditRepo) {
        this.catalog = catalog;
        this.promotions = promotions;
        this.staff = staff;
        this.orders = orders;
        this.prescriptions = prescriptions;
        this.auditRepo = auditRepo;
    }

    @GetMapping("/me")
    @PreAuthorize("hasAnyRole('PHARMACIST','OPERATOR','CATALOG_MANAGER','ADMIN')")
    public Map<String, Object> me(@AuthenticationPrincipal AuthUser user) {
        return Map.of("id", user.id(), "role", user.role(), "permissions", user.permissions());
    }

    // ───── catalog ─────
    @GetMapping("/categories")
    @PreAuthorize("hasAuthority('CATALOG_WRITE')")
    public List<CategoryAdminDto> categories() {
        return catalog.categories();
    }

    @PostMapping("/categories")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('CATALOG_WRITE')")
    public CategoryAdminDto createCategory(@Valid @RequestBody CategoryRequest r) {
        return catalog.saveCategory(null, r);
    }

    @PutMapping("/categories/{id}")
    @PreAuthorize("hasAuthority('CATALOG_WRITE')")
    public CategoryAdminDto updateCategory(@PathVariable UUID id, @Valid @RequestBody CategoryRequest r) {
        return catalog.saveCategory(id, r);
    }

    @GetMapping("/manufacturers")
    @PreAuthorize("hasAuthority('CATALOG_WRITE')")
    public List<ManufacturerDto> manufacturers() {
        return catalog.manufacturers();
    }

    @PostMapping("/manufacturers")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('CATALOG_WRITE')")
    public ManufacturerDto createManufacturer(@Valid @RequestBody ManufacturerRequest r) {
        return catalog.saveManufacturer(null, r);
    }

    @GetMapping("/products")
    @PreAuthorize("hasAnyAuthority('CATALOG_WRITE','INVENTORY_WRITE')")
    public PageResponse<ProductAdminDto> products(@RequestParam(required = false) String q, @RequestParam(defaultValue = "0") int page,
                                                  @RequestParam(defaultValue = "20") int size) {
        return catalog.products(q, Math.max(0, page), Math.min(Math.max(1, size), 100));
    }

    @PostMapping("/products")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('CATALOG_WRITE')")
    public ProductAdminDto createProduct(@Valid @RequestBody ProductRequest r) {
        return catalog.saveProduct(null, r);
    }

    @PutMapping("/products/{id}")
    @PreAuthorize("hasAuthority('CATALOG_WRITE')")
    public ProductAdminDto updateProduct(@PathVariable UUID id, @Valid @RequestBody ProductRequest r) {
        return catalog.saveProduct(id, r);
    }

    @DeleteMapping("/products/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasAuthority('CATALOG_WRITE')")
    public void deactivateProduct(@PathVariable UUID id) {
        catalog.deactivateProduct(id);
    }

    @PutMapping("/products/{id}/info")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasAuthority('CATALOG_WRITE')")
    public void putInfo(@PathVariable UUID id, @Valid @RequestBody InfoRequest r) {
        catalog.putInfo(id, r);
    }

    // ───── pharmacies ─────
    @PostMapping("/pharmacies")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('PHARMACY_WRITE')")
    public Map<String, Object> createPharmacy(@Valid @RequestBody PharmacyRequest r) {
        Pharmacy p = catalog.savePharmacy(null, r);
        return Map.of("id", p.getId(), "name", p.getName());
    }

    @PutMapping("/pharmacies/{id}")
    @PreAuthorize("hasAuthority('PHARMACY_WRITE')")
    public Map<String, Object> updatePharmacy(@PathVariable UUID id, @Valid @RequestBody PharmacyRequest r) {
        Pharmacy p = catalog.savePharmacy(id, r);
        return Map.of("id", p.getId(), "name", p.getName());
    }

    @PostMapping("/pharmacies/{id}/branches")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('PHARMACY_WRITE')")
    public Map<String, Object> createBranch(@PathVariable UUID id, @Valid @RequestBody BranchRequest r) {
        PharmacyBranch b = catalog.saveBranch(id, null, r);
        return Map.of("id", b.getId(), "name", b.getName());
    }

    @PutMapping("/pharmacies/{id}/branches/{branchId}")
    @PreAuthorize("hasAuthority('PHARMACY_WRITE')")
    public Map<String, Object> updateBranch(@PathVariable UUID id, @PathVariable UUID branchId, @Valid @RequestBody BranchRequest r) {
        PharmacyBranch b = catalog.saveBranch(id, branchId, r);
        return Map.of("id", b.getId(), "name", b.getName());
    }

    // ───── offers & inventory ─────
    @GetMapping("/offers")
    @PreAuthorize("hasAuthority('INVENTORY_WRITE')")
    public PageResponse<OfferAdminDto> offers(@RequestParam(required = false) UUID branchId, @RequestParam(required = false) UUID productId,
                                              @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "30") int size) {
        return catalog.offers(branchId, productId, Math.max(0, page), Math.min(Math.max(1, size), 100));
    }

    @PutMapping("/offers")
    @PreAuthorize("hasAuthority('INVENTORY_WRITE')")
    public OfferAdminDto upsertOffer(@Valid @RequestBody OfferRequest r) {
        return catalog.upsertOffer(r);
    }

    @PatchMapping("/offers/{id}/stock")
    @PreAuthorize("hasAuthority('INVENTORY_WRITE')")
    public OfferAdminDto setStock(@PathVariable UUID id, @Valid @RequestBody StockRequest r) {
        return catalog.setStock(id, r);
    }

    @PostMapping("/offers/{id}/{state:enable|disable}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasAuthority('INVENTORY_WRITE')")
    public void toggleOffer(@PathVariable UUID id, @PathVariable String state) {
        catalog.setOfferActive(id, "enable".equals(state));
    }

    // ───── orders ─────
    @GetMapping("/orders")
    @PreAuthorize("hasAuthority('ORDERS_PROCESS')")
    public PageResponse<OrderSummary> orders(@RequestParam(required = false) List<OrderStatus> status, @RequestParam(required = false) String q,
                                             @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size) {
        return orders.adminList(status, q, Math.max(0, page), Math.min(Math.max(1, size), 100));
    }

    @GetMapping("/orders/{id}")
    @PreAuthorize("hasAuthority('ORDERS_PROCESS')")
    public OrderDto order(@PathVariable UUID id) {
        return orders.adminGet(id);
    }

    @PostMapping("/orders/{id}/status")
    @PreAuthorize("hasAuthority('ORDERS_PROCESS')")
    public OrderDto setStatus(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id, @Valid @RequestBody StatusRequest r) {
        return orders.adminSetStatus(user.id(), id, r.status(), r.comment());
    }

    @PutMapping("/orders/{id}/courier")
    @PreAuthorize("hasAuthority('ORDERS_PROCESS')")
    public OrderDto setCourier(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id, @Valid @RequestBody CourierRequest r) {
        return orders.adminSetCourier(user.id(), id, r);
    }

    // ───── promotions ─────
    @GetMapping("/promotions")
    @PreAuthorize("hasAuthority('PROMOTIONS_WRITE')")
    public List<PromotionDto> promotions() {
        return promotions.list();
    }

    @PostMapping("/promotions")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('PROMOTIONS_WRITE')")
    public PromotionDto createPromotion(@Valid @RequestBody PromotionRequest r) {
        return promotions.save(null, r);
    }

    @PutMapping("/promotions/{id}")
    @PreAuthorize("hasAuthority('PROMOTIONS_WRITE')")
    public PromotionDto updatePromotion(@PathVariable UUID id, @Valid @RequestBody PromotionRequest r) {
        return promotions.save(id, r);
    }

    @DeleteMapping("/promotions/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasAuthority('PROMOTIONS_WRITE')")
    public void deletePromotion(@PathVariable UUID id) {
        promotions.delete(id);
    }

    // ───── prescriptions ─────
    @GetMapping("/prescriptions")
    @PreAuthorize("hasAuthority('PRESCRIPTION_REVIEW')")
    public PageResponse<ReviewItemDto> prescriptionQueue(@RequestParam(required = false) List<PrescriptionStatus> status,
                                                         @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size) {
        List<PrescriptionStatus> statuses = status == null || status.isEmpty() ? List.of(PrescriptionStatus.SUBMITTED, PrescriptionStatus.UNDER_REVIEW) : status;
        return prescriptions.reviewQueue(statuses, Math.max(0, page), Math.min(Math.max(1, size), 50));
    }

    @GetMapping("/prescriptions/{id}")
    @PreAuthorize("hasAuthority('PRESCRIPTION_REVIEW')")
    public PrescriptionDto prescription(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id) {
        return prescriptions.get(user, id);
    }

    @PostMapping("/prescriptions/{id}/start-review")
    @PreAuthorize("hasAuthority('PRESCRIPTION_REVIEW')")
    public PrescriptionDto startReview(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id) {
        return prescriptions.startReview(user, id);
    }

    @PostMapping("/prescriptions/{id}/approve")
    @PreAuthorize("hasAuthority('PRESCRIPTION_REVIEW')")
    public PrescriptionDto approve(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id, @RequestBody(required = false) ApproveRequest r) {
        return prescriptions.approve(user, id, r);
    }

    @PostMapping("/prescriptions/{id}/reject")
    @PreAuthorize("hasAuthority('PRESCRIPTION_REVIEW')")
    public PrescriptionDto reject(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id, @Valid @RequestBody RejectRequest r) {
        return prescriptions.reject(user, id, r);
    }

    // ───── audit & staff ─────
    @GetMapping("/audit")
    @PreAuthorize("hasAuthority('AUDIT_READ')")
    public PageResponse<AuditEvent> audit(@RequestParam(required = false) String entityType, @RequestParam(required = false) String entityId,
                                          @RequestParam(required = false) String actionPrefix, @RequestParam(defaultValue = "0") int page,
                                          @RequestParam(defaultValue = "50") int size) {
        var pageable = PageRequest.of(Math.max(0, page), Math.min(Math.max(1, size), 100));
        if (entityType != null && entityId != null) {
            return PageResponse.of(auditRepo.findByEntityTypeAndEntityIdOrderByCreatedAtDesc(entityType, entityId, pageable), e -> e);
        }
        if (actionPrefix != null) {
            return PageResponse.of(auditRepo.findByActionStartingWithOrderByCreatedAtDesc(actionPrefix, pageable), e -> e);
        }
        return PageResponse.of(auditRepo.findAll(PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(),
                org.springframework.data.domain.Sort.by("createdAt").descending())), e -> e);
    }

    @GetMapping("/staff")
    @PreAuthorize("hasAuthority('STAFF_MANAGE')")
    public PageResponse<UserDto> staff(@RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "50") int size) {
        return staff.list(Math.max(0, page), Math.min(Math.max(1, size), 100));
    }

    @GetMapping("/roles")
    @PreAuthorize("hasAuthority('STAFF_MANAGE')")
    public List<Map<String, Object>> roles() {
        return staff.roles();
    }

    @PostMapping("/staff")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('STAFF_MANAGE')")
    public UserDto createStaff(@Valid @RequestBody CreateStaffRequest r) {
        return staff.create(r);
    }

    @PatchMapping("/staff/{id}")
    @PreAuthorize("hasAuthority('STAFF_MANAGE')")
    public UserDto updateStaff(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id, @RequestBody UpdateStaffRequest r) {
        return staff.update(user, id, r);
    }
}
