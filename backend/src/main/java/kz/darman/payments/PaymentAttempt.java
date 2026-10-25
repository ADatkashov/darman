package kz.darman.payments;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "payment_attempts")
@Getter
@Setter
@NoArgsConstructor
public class PaymentAttempt {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false)
    private UUID orderId;
    @Column(nullable = false)
    private String provider;
    @Column(nullable = false)
    private String status;
    @Column(nullable = false)
    private BigDecimal amount;
    @Column(nullable = false)
    private String currency = "KZT";
    private String providerRef;
    @Column(nullable = false, unique = true)
    private String idempotencyKey;
    @Column(nullable = false, updatable = false)
    private Instant createdAt = Instant.now();
    @Column(nullable = false)
    private Instant updatedAt = Instant.now();
}
