package kz.darman.inventory;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import kz.darman.common.ApiException;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "inventory")
@Getter
@Setter
@NoArgsConstructor
public class Inventory {
    @Id
    @Column(name = "offer_id")
    private UUID offerId;
    @Column(nullable = false)
    private int quantity;
    @Column(nullable = false)
    private Instant updatedAt = Instant.now();
    @Version
    private long version;

    public Inventory(UUID offerId, int quantity) {
        this.offerId = offerId;
        this.quantity = quantity;
    }

    public void take(int qty) {
        if (qty <= 0 || quantity < qty) {
            throw ApiException.conflict("INSUFFICIENT_STOCK", "Not enough stock for offer " + offerId);
        }
        quantity -= qty;
        updatedAt = Instant.now();
    }

    public void giveBack(int qty) {
        quantity += qty;
        updatedAt = Instant.now();
    }
}
