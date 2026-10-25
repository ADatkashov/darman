package kz.darman.orders;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;
import kz.darman.audit.AuditService;
import kz.darman.cart.CartCalculator;
import kz.darman.cart.CartDtos;
import kz.darman.cart.CartDtos.CartDto;
import kz.darman.cart.CartDtos.LineInput;
import kz.darman.cart.CartRepositories.CartItemRepository;
import kz.darman.cart.CartRepositories.CartRepository;
import kz.darman.common.ApiException;
import kz.darman.common.PageResponse;
import kz.darman.common.Phones;
import kz.darman.config.AppProperties;
import kz.darman.delivery.Delivery;
import kz.darman.delivery.DeliverySlotService;
import kz.darman.inventory.Inventory;
import kz.darman.inventory.InventoryRepositories.InventoryRepository;
import kz.darman.notifications.NotificationService;
import kz.darman.orders.OrderDtos.*;
import kz.darman.orders.OrderRepositories.*;
import kz.darman.payments.PaymentService;
import kz.darman.pharmacies.PharmacyBranch;
import kz.darman.pharmacies.PharmacyRepositories.BranchRepository;
import kz.darman.pharmacies.PharmacyRepositories.PharmacyRepository;
import kz.darman.pricing.OfferView;
import kz.darman.pricing.OfferViewRepository;
import kz.darman.pricing.PricingService;
import kz.darman.prescriptions.PrescriptionService;
import kz.darman.promotions.PromotionService;
import kz.darman.users.Address;
import kz.darman.users.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OrderService {
    private static final Logger log = LoggerFactory.getLogger(OrderService.class);
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final Set<OrderStatus> ACTIVE = EnumSet.complementOf(EnumSet.of(OrderStatus.DELIVERED, OrderStatus.CANCELLED));
    private static final Set<OrderStatus> CUSTOMER_CANCELLABLE = EnumSet.of(OrderStatus.PLACED, OrderStatus.CONFIRMED);
    private static final Set<OrderStatus> STAFF_CANCELLABLE = EnumSet.of(OrderStatus.PLACED, OrderStatus.CONFIRMED, OrderStatus.PREPARING,
            OrderStatus.READY_FOR_PICKUP);

    private final OrderRepository orders;
    private final OrderItemRepository orderItems;
    private final HistoryRepository history;
    private final DeliveryRepository deliveries;
    private final PaymentAttemptRepository payments;
    private final OfferViewRepository views;
    private final InventoryRepository inventory;
    private final PricingService pricing;
    private final PromotionService promotions;
    private final PrescriptionService prescriptions;
    private final PaymentService paymentService;
    private final DeliverySlotService slots;
    private final UserService userService;
    private final CartRepository carts;
    private final CartItemRepository cartItems;
    private final CartCalculator calculator;
    private final BranchRepository branches;
    private final PharmacyRepository pharmacies;
    private final NotificationService notifications;
    private final AuditService audit;
    private final AppProperties props;

    public OrderService(OrderRepository orders, OrderItemRepository orderItems, HistoryRepository history, DeliveryRepository deliveries,
                        PaymentAttemptRepository payments, OfferViewRepository views, InventoryRepository inventory, PricingService pricing,
                        PromotionService promotions, PrescriptionService prescriptions, PaymentService paymentService,
                        DeliverySlotService slots, UserService userService, CartRepository carts, CartItemRepository cartItems,
                        CartCalculator calculator, BranchRepository branches, PharmacyRepository pharmacies,
                        NotificationService notifications, AuditService audit, AppProperties props) {
        this.orders = orders;
        this.orderItems = orderItems;
        this.history = history;
        this.deliveries = deliveries;
        this.payments = payments;
        this.views = views;
        this.inventory = inventory;
        this.pricing = pricing;
        this.promotions = promotions;
        this.prescriptions = prescriptions;
        this.paymentService = paymentService;
        this.slots = slots;
        this.userService = userService;
        this.carts = carts;
        this.cartItems = cartItems;
        this.calculator = calculator;
        this.branches = branches;
        this.pharmacies = pharmacies;
        this.notifications = notifications;
        this.audit = audit;
        this.props = props;
    }

    // ───────────── placement ─────────────

    public record Placement(OrderDto order, boolean replay) {}

    /**
     * Places an order. Everything is validated server-side against current data: stock (row-locked), prices,
     * branch eligibility, prescription approval, promo code and delivery slot. Idempotent on (user, Idempotency-Key).
     */
    @Transactional
    public Placement place(UUID userId, PlaceOrderRequest req, String idempotencyKey) {
        if (idempotencyKey != null && !idempotencyKey.isBlank()) {
            Optional<Order> existing = orders.findByUserIdAndIdempotencyKey(userId, idempotencyKey);
            if (existing.isPresent()) return new Placement(toDto(existing.get(), userId), true);
        } else {
            idempotencyKey = null;
        }
        if (!req.consent()) throw ApiException.unprocessable("CONSENT_REQUIRED", "Consent to the privacy policy and terms is required");
        String phone = Phones.normalize(req.contactPhone());
        if (phone == null) throw ApiException.badRequest("INVALID_PHONE", "Enter a valid phone number");
        paymentService.assertAvailable(req.paymentMethod());

        // 1. Lines: explicit list or the server cart.
        List<LineInput> lines = req.items() != null && !req.items().isEmpty() ? req.items() : linesFromServerCart(userId);
        if (lines.isEmpty()) throw ApiException.unprocessable("EMPTY_CART", "The cart is empty");
        Map<UUID, Integer> qtyByOffer = new LinkedHashMap<>();
        for (LineInput l : lines) qtyByOffer.merge(l.offerId(), l.quantity(), Integer::sum);
        for (int q : qtyByOffer.values()) {
            if (q > CartDtos.MAX_QTY) throw ApiException.unprocessable("INVALID_QUANTITY", "Quantity out of range");
        }

        // 2. Lock stock rows in a stable order, then read the current offer view (price, rules).
        List<Inventory> locked = inventory.lockAllByIds(qtyByOffer.keySet());
        if (idempotencyKey != null) {
            // A concurrent identical request may have committed while we waited for the row locks.
            Optional<Order> raced = orders.findByUserIdAndIdempotencyKey(userId, idempotencyKey);
            if (raced.isPresent()) return new Placement(toDto(raced.get(), userId), true);
        }
        Map<UUID, Inventory> stock = locked.stream().collect(Collectors.toMap(Inventory::getOfferId, i -> i));
        Map<UUID, OfferView> offerViews = views.findByIds(qtyByOffer.keySet());
        for (UUID offerId : qtyByOffer.keySet()) {
            OfferView v = offerViews.get(offerId);
            if (v == null || !v.purchasable() || !stock.containsKey(offerId)) {
                throw ApiException.conflict("OFFER_UNAVAILABLE", "An item is no longer available: " + offerId);
            }
        }
        Set<UUID> branchIds = offerViews.values().stream().map(OfferView::branchId).collect(Collectors.toSet());
        if (branchIds.size() != 1) throw ApiException.unprocessable("MIXED_BRANCHES", "All items must come from one pharmacy branch");
        OfferView any = offerViews.values().iterator().next();
        UUID branchId = any.branchId();
        PharmacyBranch branch = branches.findById(branchId).orElseThrow();

        // 3. Fulfillment rules.
        String addressText = null;
        Instant slotStart = null, slotEnd = null;
        if (req.fulfillment() == Fulfillment.DELIVERY) {
            if (!branch.isDeliveryAvailable()) throw ApiException.unprocessable("DELIVERY_NOT_AVAILABLE", "This branch does not deliver");
            if (req.addressId() == null) throw ApiException.unprocessable("ADDRESS_REQUIRED", "A delivery address is required");
            Address address = userService.requireAddress(userId, req.addressId());
            addressText = address.oneLine();
            if (req.slotStart() != null) {
                DeliverySlotService.Slot slot = slots.requireValid(branchId, req.slotStart());
                slotStart = slot.start();
                slotEnd = slot.end();
            }
        } else if (!branch.isPickupAvailable()) {
            throw ApiException.unprocessable("PICKUP_NOT_AVAILABLE", "Pickup is not available at this branch");
        }

        // 4. Prescription gate: a prescription-only product can never bypass review.
        boolean needsRx = offerViews.values().stream().anyMatch(OfferView::rxRequired);
        UUID prescriptionId = null;
        if (needsRx) {
            if (req.prescriptionId() == null) throw ApiException.unprocessable("PRESCRIPTION_REQUIRED", "A reviewed prescription is required for some items");
            prescriptionId = prescriptions.requireUsable(userId, req.prescriptionId()).getId();
        }

        // 5. Money.
        BigDecimal subtotal = BigDecimal.ZERO;
        for (var e : qtyByOffer.entrySet()) {
            subtotal = subtotal.add(offerViews.get(e.getKey()).price().multiply(BigDecimal.valueOf(e.getValue())));
        }
        BigDecimal fee = req.fulfillment() == Fulfillment.DELIVERY ? pricing.deliveryFee(any, subtotal) : BigDecimal.ZERO;
        BigDecimal discount = BigDecimal.ZERO;
        String promoCode = null;
        if (req.promoCode() != null && !req.promoCode().isBlank()) {
            var check = promotions.require(req.promoCode(), subtotal);
            discount = check.discountAmount();
            promoCode = check.code();
        }
        BigDecimal total = subtotal.subtract(discount).add(fee).max(BigDecimal.ZERO);
        if (req.expectedTotal() != null && req.expectedTotal().compareTo(total) != 0) {
            throw ApiException.conflict("PRICE_CHANGED", "Prices changed since you last viewed the cart: new total " + total);
        }

        // 6. Take stock (throws INSUFFICIENT_STOCK) and persist.
        for (var e : qtyByOffer.entrySet()) stock.get(e.getKey()).take(e.getValue());
        inventory.saveAll(stock.values());

        Order order = new Order();
        order.setNumber(newNumber());
        order.setUserId(userId);
        order.setBranchId(branchId);
        order.setFulfillment(req.fulfillment());
        order.setSubtotal(subtotal);
        order.setDeliveryFee(fee);
        order.setDiscount(discount);
        order.setTotal(total);
        order.setPromoCode(promoCode);
        order.setContactName(req.contactName().trim());
        order.setContactPhone(phone);
        order.setDeliveryAddress(addressText);
        order.setDeliveryNotes(req.deliveryNotes() == null || req.deliveryNotes().isBlank() ? null : req.deliveryNotes().trim());
        order.setSlotStart(slotStart);
        order.setSlotEnd(slotEnd);
        order.setPaymentMethod(req.paymentMethod());
        order.setPaymentStatus(PaymentStatus.UNPAID);
        order.setPrescriptionId(prescriptionId);
        order.setIdempotencyKey(idempotencyKey);
        order.setConsentAcceptedAt(Instant.now());
        orders.saveAndFlush(order);

        for (var e : qtyByOffer.entrySet()) {
            OfferView v = offerViews.get(e.getKey());
            OrderItem item = new OrderItem();
            item.setOrderId(order.getId());
            item.setProductId(v.productId());
            item.setOfferId(v.offerId());
            item.setProductName(v.productName());
            item.setProductBrand(v.brand());
            item.setStrength(v.strength());
            item.setDosageForm(v.dosageForm());
            item.setPackageSize(v.packageSize());
            item.setPharmacyName(v.pharmacyName());
            item.setBranchName(v.branchName());
            item.setRxRequired(v.rxRequired());
            item.setUnitPrice(v.price());
            item.setQuantity(e.getValue());
            item.setLineTotal(v.price().multiply(BigDecimal.valueOf(e.getValue())));
            orderItems.save(item);
        }
        record(order, OrderStatus.PLACED, null, userId);

        if (req.fulfillment() == Fulfillment.DELIVERY) {
            Delivery d = new Delivery();
            d.setOrderId(order.getId());
            Instant from = slotStart != null ? slotStart : Instant.now().plus(Duration.ofMinutes(branch.getDeliveryEtaMin() == null ? 45 : branch.getDeliveryEtaMin()));
            Instant to = slotEnd != null ? slotEnd : Instant.now().plus(Duration.ofMinutes(branch.getDeliveryEtaMax() == null ? 90 : branch.getDeliveryEtaMax()));
            d.setEtaFrom(from);
            d.setEtaTo(to);
            deliveries.save(d);
        }

        PaymentStatus ps = paymentService.start(order);
        if (ps == PaymentStatus.FAILED) {
            throw new ApiException(HttpStatus.PAYMENT_REQUIRED, "PAYMENT_FAILED", "Payment was declined");
        }
        order.setPaymentStatus(ps);
        orders.save(order);

        if (req.items() == null || req.items().isEmpty()) clearServerCart(userId);
        audit.record("ORDER_PLACED", "Order", order.getId(), "number=" + order.getNumber() + " total=" + total);
        notifications.notify(userId, "ORDERS", "ORDER", "ORDER_PLACED", "Order " + order.getNumber() + " placed", order.getId());
        return new Placement(toDto(order, userId), false);
    }

    /** Looks up an order previously created with this idempotency key (used to resolve a lost insert race). */
    @Transactional(readOnly = true)
    public Optional<OrderDto> findByIdempotencyKey(UUID userId, String key) {
        if (key == null || key.isBlank()) return Optional.empty();
        return orders.findByUserIdAndIdempotencyKey(userId, key).map(o -> toDto(o, userId));
    }

    private List<LineInput> linesFromServerCart(UUID userId) {
        return carts.findByUserId(userId)
                .map(c -> cartItems.findByCartIdOrderByAddedAtAsc(c.getId()).stream()
                        .map(i -> new LineInput(i.getOfferId(), i.getQuantity(), null)).toList())
                .orElse(List.of());
    }

    private void clearServerCart(UUID userId) {
        carts.findByUserId(userId).ifPresent(c -> cartItems.deleteByCartId(c.getId()));
    }

    private String newNumber() {
        String date = DateTimeFormatter.ofPattern("yyMMdd").withZone(ZoneOffset.UTC).format(Instant.now());
        for (int i = 0; i < 10; i++) {
            String candidate = "DM-" + date + "-" + "%05d".formatted(RANDOM.nextInt(100000));
            if (!orders.existsByNumber(candidate)) return candidate;
        }
        throw new IllegalStateException("Could not allocate an order number");
    }

    // ───────────── customer queries ─────────────

    @Transactional(readOnly = true)
    public PageResponse<OrderSummary> list(UUID userId, String scope, int page, int size) {
        Set<OrderStatus> statuses = "active".equalsIgnoreCase(scope) ? ACTIVE
                : "history".equalsIgnoreCase(scope) ? EnumSet.of(OrderStatus.DELIVERED, OrderStatus.CANCELLED) : EnumSet.allOf(OrderStatus.class);
        var result = orders.findByUserIdAndStatusInOrderByCreatedAtDesc(userId, statuses, PageRequest.of(page, size));
        return PageResponse.of(result, this::summary);
    }

    @Transactional(readOnly = true)
    public OrderDto get(UUID userId, UUID id) {
        Order o = orders.findByIdAndUserId(id, userId).orElseThrow(() -> ApiException.notFound("Order"));
        return toDto(o, userId);
    }

    @Transactional(readOnly = true)
    public Receipt receipt(UUID userId, UUID id) {
        Order o = orders.findByIdAndUserId(id, userId).orElseThrow(() -> ApiException.notFound("Order"));
        if (o.getStatus() == OrderStatus.CANCELLED) throw ApiException.conflict("NO_RECEIPT", "No receipt for a cancelled order");
        OrderDto d = toDto(o, userId);
        boolean demoPaid = o.getPaymentStatus() == PaymentStatus.DEMO_PAID;
        return new Receipt(o.getNumber(), o.getUpdatedAt(), d.pharmacyName(), d.branchName(), d.items(), o.getSubtotal(), o.getDeliveryFee(),
                o.getDiscount(), o.getTotal(), o.getCurrency(), o.getPaymentMethod().name(), o.getPaymentStatus().name(),
                demoPaid || props.demo().enabled(),
                "Order summary for your records. This is NOT a fiscal receipt (фискальный чек) and is not tax documentation.");
    }

    @Transactional(readOnly = true)
    public CartDto reorder(UUID userId, UUID id) {
        Order o = orders.findByIdAndUserId(id, userId).orElseThrow(() -> ApiException.notFound("Order"));
        List<OrderItem> items = orderItems.findByOrderId(o.getId());
        // Same offers; availability, current prices, rx and branch eligibility are recomputed from live data.
        Map<UUID, OfferView> v = views.findByIds(items.stream().map(OrderItem::getOfferId).collect(Collectors.toSet()));
        List<CartCalculator.Raw> raws = items.stream()
                .map(i -> new CartCalculator.Raw(null, i.getOfferId(), i.getQuantity(), i.getUnitPrice())).toList();
        return calculator.compute(raws, v);
    }

    // ───────────── cancellation ─────────────

    @Transactional
    public OrderDto cancel(UUID userId, UUID id, String reason) {
        Order o = orders.findByIdAndUserId(id, userId).orElseThrow(() -> ApiException.notFound("Order"));
        if (!CUSTOMER_CANCELLABLE.contains(o.getStatus())) {
            throw ApiException.conflict("CANCEL_NOT_ALLOWED", "The order can no longer be cancelled (status " + o.getStatus() + ")");
        }
        doCancel(o, reason, userId);
        return toDto(o, userId);
    }

    private void doCancel(Order o, String reason, UUID actor) {
        List<OrderItem> items = orderItems.findByOrderId(o.getId());
        Map<UUID, Inventory> stock = inventory.lockAllByIds(items.stream().map(OrderItem::getOfferId).toList()).stream()
                .collect(Collectors.toMap(Inventory::getOfferId, i -> i));
        for (OrderItem i : items) {
            Inventory inv = stock.get(i.getOfferId());
            if (inv != null) inv.giveBack(i.getQuantity());
        }
        inventory.saveAll(stock.values());
        o.setStatus(OrderStatus.CANCELLED);
        o.setPrescriptionId(null);
        o.setPaymentStatus(switch (o.getPaymentStatus()) {
            case PAID -> PaymentStatus.REFUND_PENDING;
            case DEMO_PAID -> PaymentStatus.REFUNDED;
            case PENDING -> PaymentStatus.FAILED;
            default -> o.getPaymentStatus();
        });
        orders.save(o);
        record(o, OrderStatus.CANCELLED, reason, actor);
        audit.record("ORDER_CANCELLED", "Order", o.getId(), reason);
        notifications.notify(o.getUserId(), "ORDERS", "ORDER", "ORDER_CANCELLED", "Order " + o.getNumber() + " cancelled", o.getId());
    }

    // ───────────── staff / demo progression ─────────────

    @Transactional(readOnly = true)
    public PageResponse<OrderSummary> adminList(Collection<OrderStatus> statuses, String q, int page, int size) {
        var result = orders.search(statuses == null || statuses.isEmpty() ? EnumSet.allOf(OrderStatus.class) : statuses,
                q == null ? "" : q.trim(), PageRequest.of(page, size));
        return PageResponse.of(result, this::summary);
    }

    @Transactional(readOnly = true)
    public OrderDto adminGet(UUID id) {
        Order o = orders.findById(id).orElseThrow(() -> ApiException.notFound("Order"));
        return toDto(o, o.getUserId(), true);
    }

    @Transactional
    public OrderDto adminSetStatus(UUID actorId, UUID id, OrderStatus target, String comment) {
        moveTo(id, target, comment, actorId);
        audit.record("ORDER_STATUS_" + target, "Order", id, comment);
        Order o = orders.findById(id).orElseThrow(() -> ApiException.notFound("Order"));
        return toDto(o, o.getUserId(), true);
    }

    /** Validates and applies a staff/system transition. Only the forward happy-path step or a permitted cancellation is legal. */
    @Transactional
    public void moveTo(UUID orderId, OrderStatus target, String comment, UUID actor) {
        Order o = orders.findById(orderId).orElseThrow(() -> ApiException.notFound("Order"));
        if (o.getStatus().isTerminal()) throw ApiException.conflict("ORDER_FINAL", "The order is already " + o.getStatus());
        if (target == OrderStatus.CANCELLED) {
            if (!STAFF_CANCELLABLE.contains(o.getStatus())) {
                throw ApiException.conflict("CANCEL_NOT_ALLOWED", "Cannot cancel an order that is " + o.getStatus());
            }
            doCancel(o, comment, actor);
            return;
        }
        if (o.getStatus().next(o.getFulfillment()) != target) {
            throw ApiException.conflict("INVALID_TRANSITION", "Cannot move from " + o.getStatus() + " to " + target);
        }
        o.setStatus(target);
        if (target == OrderStatus.DELIVERED && o.getPaymentStatus() == PaymentStatus.UNPAID) {
            o.setPaymentStatus(PaymentStatus.PAID); // cash received on handover
        }
        orders.save(o);
        record(o, target, comment, actor);
        notifications.notify(o.getUserId(), "ORDERS", "ORDER", "ORDER_" + target, "Order " + o.getNumber() + ": " + target, o.getId());
    }

    @Transactional
    public OrderDto adminSetCourier(UUID actorId, UUID id, CourierRequest req) {
        Order o = orders.findById(id).orElseThrow(() -> ApiException.notFound("Order"));
        if (o.getFulfillment() != Fulfillment.DELIVERY) throw ApiException.conflict("NOT_A_DELIVERY", "Pickup orders have no courier");
        Delivery d = deliveries.findByOrderId(id).orElseGet(() -> {
            Delivery nd = new Delivery();
            nd.setOrderId(id);
            return nd;
        });
        d.setCourierName(req.name().trim());
        d.setCourierPhone(req.phone().trim());
        d.setCourierDemo(false);
        d.setUpdatedAt(Instant.now());
        deliveries.save(d);
        audit.record("ORDER_COURIER_ASSIGNED", "Order", id, null);
        return toDto(o, o.getUserId(), true);
    }

    /** Demo only: fictional courier so the tracking screen can be demonstrated. Flagged courier_demo=true. */
    @Transactional
    public void assignDemoCourier(UUID orderId) {
        deliveries.findByOrderId(orderId).ifPresent(d -> {
            if (d.getCourierName() == null) {
                d.setCourierName("Демо-курьер (вымышленный)");
                d.setCourierPhone("+7 700 000 00 99");
                d.setCourierDemo(true);
                d.setUpdatedAt(Instant.now());
                deliveries.save(d);
            }
        });
    }

    @Transactional(readOnly = true)
    public Order find(UUID id) {
        return orders.findById(id).orElseThrow(() -> ApiException.notFound("Order"));
    }

    @Transactional(readOnly = true)
    public List<Order> findStale(Collection<OrderStatus> statuses, Instant before) {
        return orders.findByStatusInAndUpdatedAtBefore(statuses, before);
    }

    // ───────────── mapping ─────────────

    private void record(Order o, OrderStatus status, String comment, UUID actor) {
        OrderStatusHistory h = new OrderStatusHistory();
        h.setOrderId(o.getId());
        h.setStatus(status);
        h.setComment(comment == null || comment.isBlank() ? null : comment.trim());
        h.setActorId(actor);
        history.save(h);
    }

    private OrderSummary summary(Order o) {
        List<OrderItem> items = orderItems.findByOrderId(o.getId());
        String pharmacy = items.isEmpty() ? null : items.get(0).getPharmacyName();
        return new OrderSummary(o.getId(), o.getNumber(), o.getStatus().name(), o.getFulfillment().name(), o.getCreatedAt(), o.getTotal(),
                o.getCurrency(), items.stream().mapToInt(OrderItem::getQuantity).sum(), items.isEmpty() ? null : items.get(0).getProductName(),
                pharmacy, CUSTOMER_CANCELLABLE.contains(o.getStatus()));
    }

    OrderDto toDto(Order o, UUID viewerId) {
        return toDto(o, viewerId, false);
    }

    private OrderDto toDto(Order o, UUID viewerId, boolean staffView) {
        List<ItemDto> items = orderItems.findByOrderId(o.getId()).stream().map(i -> new ItemDto(i.getId(), i.getProductId(), i.getOfferId(),
                i.getProductName(), i.getProductBrand(), i.getStrength(), i.getDosageForm(), i.getPackageSize(), i.isRxRequired(),
                i.getUnitPrice(), i.getQuantity(), i.getLineTotal())).toList();
        List<HistoryDto> hist = history.findByOrderIdOrderByCreatedAtAsc(o.getId()).stream()
                .map(h -> new HistoryDto(h.getStatus().name(), h.getComment(), h.getCreatedAt())).toList();
        PharmacyBranch branch = branches.findById(o.getBranchId()).orElse(null);
        String pharmacyName = branch == null ? null : pharmacies.findById(branch.getPharmacyId()).map(p -> p.getName()).orElse(null);
        Delivery d = deliveries.findByOrderId(o.getId()).orElse(null);
        // Courier contact is shown only to the order owner (or staff) and only while the order is actually in transit.
        CourierDto courier = d != null && d.getCourierName() != null && (staffView || (viewerId.equals(o.getUserId()) && o.getStatus() == OrderStatus.IN_TRANSIT))
                ? new CourierDto(d.getCourierName(), d.getCourierPhone(), d.isCourierDemo()) : null;
        boolean demoPay = o.getPaymentStatus() == PaymentStatus.DEMO_PAID
                || payments.findByOrderIdOrderByCreatedAtDesc(o.getId()).stream().anyMatch(a -> "demo".equals(a.getProvider()));
        return new OrderDto(o.getId(), o.getNumber(), o.getStatus().name(), o.getFulfillment().name(), o.getCreatedAt(), o.getUpdatedAt(), items,
                o.getSubtotal(), o.getDeliveryFee(), o.getDiscount(), o.getTotal(), o.getCurrency(), o.getPromoCode(), o.getContactName(),
                o.getContactPhone(), o.getDeliveryAddress(), o.getDeliveryNotes(), o.getSlotStart(), o.getSlotEnd(),
                d == null ? null : d.getEtaFrom(), d == null ? null : d.getEtaTo(), o.getPaymentMethod().name(), o.getPaymentStatus().name(),
                demoPay, o.getPrescriptionId(), o.getBranchId(), branch == null ? null : branch.getName(), pharmacyName,
                branch == null ? null : branch.getAddress(), branch == null ? null : branch.getPhone(), hist, courier,
                CUSTOMER_CANCELLABLE.contains(o.getStatus()), o.getStatus() != OrderStatus.CANCELLED, props.demo().enabled());
    }
}
