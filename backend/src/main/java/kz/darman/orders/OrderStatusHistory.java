package kz.darman.orders;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "order_status_history")
@Getter
@Setter
@NoArgsConstructor
public class OrderStatusHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false)
    private UUID orderId;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OrderStatus status;
    private String comment;
    private UUID actorId;
    @Column(nullable = false, updatable = false)
    private Instant createdAt = Instant.now();
}
