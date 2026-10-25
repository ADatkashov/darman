package kz.darman.delivery;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "deliveries")
@Getter
@Setter
@NoArgsConstructor
public class Delivery {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false, unique = true)
    private UUID orderId;
    private String courierName;
    private String courierPhone;
    private boolean courierDemo;
    private Instant etaFrom;
    private Instant etaTo;
    @Column(nullable = false)
    private Instant updatedAt = Instant.now();
}
