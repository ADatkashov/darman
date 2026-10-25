package kz.darman.cart;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "cart_items")
@Getter
@Setter
@NoArgsConstructor
public class CartItem {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false)
    private UUID cartId;
    @Column(nullable = false)
    private UUID offerId;
    @Column(nullable = false)
    private int quantity;
    @Column(nullable = false)
    private BigDecimal priceSnapshot;
    @Column(nullable = false)
    private Instant addedAt = Instant.now();
}
