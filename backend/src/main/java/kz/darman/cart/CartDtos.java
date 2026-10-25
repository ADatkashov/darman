package kz.darman.cart;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public final class CartDtos {
    private CartDtos() {}

    public static final int MAX_QTY = 99;

    public record LineInput(@NotNull UUID offerId, @Min(1) @Max(MAX_QTY) int quantity, BigDecimal expectedPrice) {}

    public record ValidateRequest(@NotNull @Size(max = 50) List<@Valid LineInput> items) {}

    public record AddItemRequest(@NotNull UUID offerId, @Min(1) @Max(MAX_QTY) int quantity, boolean replaceCart) {}

    public record UpdateItemRequest(@Min(1) @Max(MAX_QTY) int quantity) {}

    /** status: OK | PRICE_CHANGED | LOW_STOCK_ADJUSTMENT_NEEDED | OUT_OF_STOCK | UNAVAILABLE */
    public record CartLine(UUID itemId, UUID offerId, UUID productId, String productName, String strength, String dosageForm,
                           String packageSize, boolean rxRequired, UUID branchId, String branchName, String pharmacyName,
                           BigDecimal unitPrice, BigDecimal previousPrice, int quantity, int availableQuantity, BigDecimal lineTotal,
                           String status) {}

    public record DeliveryInfo(boolean deliveryAvailable, boolean pickupAvailable, BigDecimal fee, BigDecimal freeFrom,
                               Integer etaMinMinutes, Integer etaMaxMinutes) {}

    public record CartDto(List<CartLine> items, UUID branchId, String branchName, String pharmacyName, BigDecimal subtotal,
                          String currency, DeliveryInfo delivery, boolean prescriptionRequired, boolean checkoutBlocked,
                          List<String> issues, boolean mixedBranches) {}
}
