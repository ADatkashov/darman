package kz.darman.orders;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/** Purchase-time snapshot: historical orders stay accurate even if the catalog changes. */
@Entity
@Table(name = "order_items")
@Getter
@Setter
@NoArgsConstructor
public class OrderItem {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false)
    private UUID orderId;
    @Column(nullable = false)
    private UUID productId;
    @Column(nullable = false)
    private UUID offerId;
    @Column(nullable = false)
    private String productName;
    private String productBrand;
    private String strength;
    private String dosageForm;
    private String packageSize;
    @Column(nullable = false)
    private String pharmacyName;
    @Column(nullable = false)
    private String branchName;
    private boolean rxRequired;
    @Column(nullable = false)
    private BigDecimal unitPrice;
    @Column(nullable = false)
    private int quantity;
    @Column(nullable = false)
    private BigDecimal lineTotal;
}
