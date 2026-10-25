package kz.darman.cart;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public final class CartRepositories {
    private CartRepositories() {}

    public interface CartRepository extends JpaRepository<Cart, UUID> {
        Optional<Cart> findByUserId(UUID userId);
    }

    public interface CartItemRepository extends JpaRepository<CartItem, UUID> {
        List<CartItem> findByCartIdOrderByAddedAtAsc(UUID cartId);

        Optional<CartItem> findByCartIdAndOfferId(UUID cartId, UUID offerId);

        void deleteByCartId(UUID cartId);
    }
}
