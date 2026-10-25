package kz.darman.orders;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import kz.darman.cart.CartDtos.LineInput;

public final class OrderDtos {
    private OrderDtos() {}

    /** items may be omitted to use the server-side cart. consent must be true (privacy + terms). */
    public record PlaceOrderRequest(@Size(max = 50) List<@Valid LineInput> items, @NotNull Fulfillment fulfillment, UUID addressId,
                                    @NotBlank @Size(max = 160) String contactName, @NotBlank @Size(max = 32) String contactPhone,
                                    @Size(max = 500) String deliveryNotes, Instant slotStart, @NotNull PaymentMethod paymentMethod,
                                    @Size(max = 40) String promoCode, UUID prescriptionId, BigDecimal expectedTotal, boolean consent) {}

    public record CancelRequest(@Size(max = 255) String reason) {}

    public record StatusRequest(@NotNull OrderStatus status, @Size(max = 255) String comment) {}

    public record CourierRequest(@NotBlank @Size(max = 160) String name, @NotBlank @Size(max = 32) String phone) {}

    public record ItemDto(UUID id, UUID productId, UUID offerId, String productName, String brand, String strength, String dosageForm,
                          String packageSize, boolean rxRequired, BigDecimal unitPrice, int quantity, BigDecimal lineTotal) {}

    public record HistoryDto(String status, String comment, Instant createdAt) {}

    public record CourierDto(String name, String phone, boolean demo) {}

    public record OrderDto(UUID id, String number, String status, String fulfillment, Instant createdAt, Instant updatedAt, List<ItemDto> items,
                           BigDecimal subtotal, BigDecimal deliveryFee, BigDecimal discount, BigDecimal total, String currency,
                           String promoCode, String contactName, String contactPhone, String deliveryAddress, String deliveryNotes,
                           Instant slotStart, Instant slotEnd, Instant etaFrom, Instant etaTo, String paymentMethod, String paymentStatus,
                           boolean paymentIsDemo, UUID prescriptionId, UUID branchId, String branchName, String pharmacyName,
                           String branchAddress, String branchPhone, List<HistoryDto> history, CourierDto courier, boolean canCancel,
                           boolean receiptAvailable, boolean demo) {}

    public record OrderSummary(UUID id, String number, String status, String fulfillment, Instant createdAt, BigDecimal total, String currency,
                               int itemCount, String firstItemName, String pharmacyName, boolean canCancel) {}

    public record Receipt(String number, Instant paidAt, String pharmacyName, String branchName, List<ItemDto> items, BigDecimal subtotal,
                          BigDecimal deliveryFee, BigDecimal discount, BigDecimal total, String currency, String paymentMethod,
                          String paymentStatus, boolean demo, String notice) {}
}
