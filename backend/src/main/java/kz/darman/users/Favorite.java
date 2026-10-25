package kz.darman.users;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.Instant;
import java.util.UUID;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "favorites")
@IdClass(Favorite.Key.class)
@Getter
@Setter
@NoArgsConstructor
public class Favorite {
    @Id
    @Column(name = "user_id")
    private UUID userId;
    @Id
    @Column(name = "product_id")
    private UUID productId;
    @Column(nullable = false)
    private Instant createdAt = Instant.now();

    public Favorite(UUID userId, UUID productId) {
        this.userId = userId;
        this.productId = productId;
    }

    @EqualsAndHashCode
    public static class Key implements Serializable {
        private UUID userId;
        private UUID productId;
    }
}
