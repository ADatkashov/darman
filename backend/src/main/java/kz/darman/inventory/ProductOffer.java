package kz.darman.inventory;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "product_offers")
@Getter
@Setter
@NoArgsConstructor
public class ProductOffer {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false)
    private UUID productId;
    @Column(nullable = false)
    private UUID branchId;
    @Column(nullable = false)
    private BigDecimal price;
    private BigDecimal oldPrice;
    @Column(nullable = false)
    private String currency = "KZT";
    private boolean active = true;
    @Column(nullable = false)
    private Instant updatedAt = Instant.now();
    @Version
    private long version;

    @PreUpdate
    void touch() {
        updatedAt = Instant.now();
    }
}
