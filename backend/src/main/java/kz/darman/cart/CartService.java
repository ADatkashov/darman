package kz.darman.cart;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import kz.darman.cart.CartCalculator.Raw;
import kz.darman.cart.CartDtos.*;
import kz.darman.cart.CartRepositories.*;
import kz.darman.common.ApiException;
import kz.darman.pricing.OfferView;
import kz.darman.pricing.OfferViewRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CartService {
    private final CartRepository carts;
    private final CartItemRepository items;
    private final OfferViewRepository views;
    private final CartCalculator calculator;

    public CartService(CartRepository carts, CartItemRepository items, OfferViewRepository views, CartCalculator calculator) {
        this.carts = carts;
        this.items = items;
        this.views = views;
        this.calculator = calculator;
    }

    @Transactional
    public CartDto get(UUID userId) {
        return render(cartOf(userId));
    }

    @Transactional
    public CartDto add(UUID userId, AddItemRequest req) {
        Cart cart = cartOf(userId);
        OfferView offer = views.findByIds(List.of(req.offerId())).get(req.offerId());
        if (offer == null || !offer.purchasable()) throw ApiException.notFound("Offer");
        if (offer.stock() <= 0) throw ApiException.conflict("OUT_OF_STOCK", "This offer is out of stock");
        List<CartItem> existing = items.findByCartIdOrderByAddedAtAsc(cart.getId());
        if (!existing.isEmpty()) {
            Map<UUID, OfferView> existingViews = views.findByIds(existing.stream().map(CartItem::getOfferId).toList());
            boolean otherBranch = existing.stream().map(i -> existingViews.get(i.getOfferId()))
                    .anyMatch(v -> v != null && !v.branchId().equals(offer.branchId()));
            if (otherBranch) {
                if (!req.replaceCart()) {
                    throw ApiException.conflict("CART_BRANCH_MISMATCH",
                            "The cart contains items from another pharmacy branch; an order can only be fulfilled by one branch");
                }
                items.deleteByCartId(cart.getId());
                items.flush();
            }
        }
        CartItem item = items.findByCartIdAndOfferId(cart.getId(), offer.offerId()).orElse(null);
        int qty = (item == null ? 0 : item.getQuantity()) + req.quantity();
        if (qty > CartDtos.MAX_QTY || qty > offer.stock()) {
            throw ApiException.conflict("INSUFFICIENT_STOCK", "Only " + Math.min(offer.stock(), CartDtos.MAX_QTY) + " units available");
        }
        if (item == null) {
            item = new CartItem();
            item.setCartId(cart.getId());
            item.setOfferId(offer.offerId());
        }
        item.setQuantity(qty);
        item.setPriceSnapshot(offer.price());
        items.save(item);
        touch(cart);
        return render(cart);
    }

    @Transactional
    public CartDto update(UUID userId, UUID itemId, UpdateItemRequest req) {
        Cart cart = cartOf(userId);
        CartItem item = items.findById(itemId).filter(i -> i.getCartId().equals(cart.getId())).orElseThrow(() -> ApiException.notFound("Cart item"));
        OfferView v = views.findByIds(List.of(item.getOfferId())).get(item.getOfferId());
        if (v == null || !v.purchasable()) throw ApiException.conflict("OFFER_UNAVAILABLE", "This offer is no longer available");
        if (req.quantity() > v.stock()) throw ApiException.conflict("INSUFFICIENT_STOCK", "Only " + v.stock() + " units available");
        item.setQuantity(req.quantity());
        item.setPriceSnapshot(v.price());
        items.save(item);
        touch(cart);
        return render(cart);
    }

    @Transactional
    public CartDto remove(UUID userId, UUID itemId) {
        Cart cart = cartOf(userId);
        items.findById(itemId).filter(i -> i.getCartId().equals(cart.getId())).ifPresent(items::delete);
        touch(cart);
        return render(cart);
    }

    @Transactional
    public CartDto clear(UUID userId) {
        Cart cart = cartOf(userId);
        items.deleteByCartId(cart.getId());
        touch(cart);
        return render(cart);
    }

    /** Stateless re-validation of a client-held cart (guests and the device-local cart). */
    @Transactional(readOnly = true)
    public CartDto validate(List<LineInput> lines) {
        Map<UUID, OfferView> v = views.findByIds(lines.stream().map(LineInput::offerId).collect(Collectors.toSet()));
        List<Raw> raws = lines.stream().map(l -> new Raw(null, l.offerId(), l.quantity(), l.expectedPrice())).toList();
        return calculator.compute(raws, v);
    }

    private CartDto render(Cart cart) {
        List<CartItem> list = items.findByCartIdOrderByAddedAtAsc(cart.getId());
        Map<UUID, OfferView> v = views.findByIds(list.stream().map(CartItem::getOfferId).collect(Collectors.toSet()));
        List<Raw> raws = list.stream().map(i -> new Raw(i.getId(), i.getOfferId(), i.getQuantity(), i.getPriceSnapshot())).toList();
        return calculator.compute(raws, v);
    }

    private Cart cartOf(UUID userId) {
        return carts.findByUserId(userId).orElseGet(() -> {
            Cart c = new Cart();
            c.setUserId(userId);
            return carts.save(c);
        });
    }

    private void touch(Cart cart) {
        cart.setUpdatedAt(Instant.now());
        carts.save(cart);
    }

}
