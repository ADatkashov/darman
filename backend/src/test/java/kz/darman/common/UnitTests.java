package kz.darman.common;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import kz.darman.cart.CartCalculator;
import kz.darman.cart.CartDtos.CartDto;
import kz.darman.orders.Fulfillment;
import kz.darman.orders.OrderStatus;
import kz.darman.pricing.OfferView;
import kz.darman.pricing.PricingService;
import org.junit.jupiter.api.Test;

class UnitTests {

    @Test
    void phonesAreNormalizedToE164() {
        assertThat(Phones.normalize("8 (701) 123-45-67")).isEqualTo("+77011234567");
        assertThat(Phones.normalize("+7 701 123 45 67")).isEqualTo("+77011234567");
        assertThat(Phones.normalize("7011234567")).isEqualTo("+77011234567");
        assertThat(Phones.normalize("12345")).isNull();
        assertThat(Phones.normalize(null)).isNull();
        assertThat(Phones.normalize("+44 7911 123456")).isNull();
    }

    @Test
    void languageResolutionFallsBackToRussian() {
        org.springframework.context.i18n.LocaleContextHolder.setLocale(java.util.Locale.forLanguageTag("fr"));
        assertThat(Lang.resolve("kk")).isEqualTo("kk");
        assertThat(Lang.resolve("fr")).isEqualTo("ru");
        assertThat(Lang.pick("kk", "ру", null, "en")).isEqualTo("ру");
        assertThat(Lang.pick("en", "ру", "қаз", "en")).isEqualTo("en");
        org.springframework.context.i18n.LocaleContextHolder.resetLocaleContext();
    }

    @Test
    void orderTimelineDiffersForPickupAndDelivery() {
        assertThat(OrderStatus.PREPARING.next(Fulfillment.DELIVERY)).isEqualTo(OrderStatus.IN_TRANSIT);
        assertThat(OrderStatus.PREPARING.next(Fulfillment.PICKUP)).isEqualTo(OrderStatus.READY_FOR_PICKUP);
        assertThat(OrderStatus.DELIVERED.next(Fulfillment.PICKUP)).isNull();
        assertThat(OrderStatus.CANCELLED.isTerminal()).isTrue();
    }

    private static OfferView offer(UUID id, UUID branch, String price, int stock, boolean rx, String freeFrom) {
        return new OfferView(id, UUID.randomUUID(), "Товар", null, null, null, null, rx, true, new BigDecimal(price), "KZT", true, stock, branch, "Филиал",
                "Аптека", true, true, true, new BigDecimal("500"), freeFrom == null ? null : new BigDecimal(freeFrom), 40, 70);
    }

    @Test
    void cartTotalsDeliveryFeeAndFreeDeliveryThreshold() {
        CartCalculator calc = new CartCalculator(new PricingService());
        UUID branch = UUID.randomUUID(), a = UUID.randomUUID(), b = UUID.randomUUID();
        Map<UUID, OfferView> views = Map.of(a, offer(a, branch, "1000", 10, false, "5000"), b, offer(b, branch, "250", 10, true, "5000"));
        CartDto small = calc.compute(List.of(new CartCalculator.Raw(null, a, 2, null), new CartCalculator.Raw(null, b, 3, null)), views);
        assertThat(small.subtotal()).isEqualByComparingTo("2750");
        assertThat(small.delivery().fee()).isEqualByComparingTo("500");
        assertThat(small.prescriptionRequired()).isTrue();
        assertThat(small.checkoutBlocked()).isFalse();

        CartDto big = calc.compute(List.of(new CartCalculator.Raw(null, a, 6, null)), views);
        assertThat(big.delivery().fee()).isEqualByComparingTo("0");
    }

    @Test
    void cartStatusesDescribeWhatChanged() {
        CartCalculator calc = new CartCalculator(new PricingService());
        UUID branch = UUID.randomUUID(), a = UUID.randomUUID(), b = UUID.randomUUID(), c = UUID.randomUUID();
        Map<UUID, OfferView> views = Map.of(a, offer(a, branch, "100", 1, false, null), b, offer(b, branch, "100", 0, false, null), c, offer(c, branch, "120", 5, false, null));
        CartDto cart = calc.compute(List.of(new CartCalculator.Raw(null, a, 3, null), new CartCalculator.Raw(null, b, 1, null),
                new CartCalculator.Raw(null, c, 1, new BigDecimal("100"))), views);
        assertThat(cart.items().get(0).status()).isEqualTo("LOW_STOCK_ADJUSTMENT_NEEDED");
        assertThat(cart.items().get(1).status()).isEqualTo("OUT_OF_STOCK");
        assertThat(cart.items().get(2).status()).isEqualTo("PRICE_CHANGED");
        assertThat(cart.items().get(2).previousPrice()).isEqualByComparingTo("100");
        assertThat(cart.checkoutBlocked()).isTrue();
    }
}
