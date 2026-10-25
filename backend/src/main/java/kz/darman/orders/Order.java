package kz.darman.orders;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "orders")
@Getter
@Setter
@NoArgsConstructor
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false, unique = true)
    private String number;
    @Column(nullable = false)
    private UUID userId;
    @Column(nullable = false)
    private UUID branchId;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OrderStatus status = OrderStatus.PLACED;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Fulfillment fulfillment;
    @Column(nullable = false)
    private String currency = "KZT";
    @Column(nullable = false)
    private BigDecimal subtotal;
    @Column(nullable = false)
    private BigDecimal deliveryFee = BigDecimal.ZERO;
    @Column(nullable = false)
    private BigDecimal discount = BigDecimal.ZERO;
    @Column(nullable = false)
    private BigDecimal total;
    private String promoCode;
    @Column(nullable = false)
    private String contactName;
    @Column(nullable = false)
    private String contactPhone;
    private String deliveryAddress;
    private String deliveryNotes;
    private Instant slotStart;
    private Instant slotEnd;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentMethod paymentMethod;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentStatus paymentStatus;
    private UUID prescriptionId;
    private String idempotencyKey;
    @Column(nullable = false)
    private Instant consentAcceptedAt;
    @Column(nullable = false, updatable = false)
    private Instant createdAt;
    @Column(nullable = false)
    private Instant updatedAt;
    @Version
    private long version;

    @PrePersist
    void onCreate() {
        createdAt = createdAt == null ? Instant.now() : createdAt;
        updatedAt = Instant.now();
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = Instant.now();
    }
}
