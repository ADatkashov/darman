package kz.darman.pharmacies;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "pharmacy_branches")
@Getter
@Setter
@NoArgsConstructor
public class PharmacyBranch {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false)
    private UUID pharmacyId;
    @Column(nullable = false)
    private String name;
    @Column(nullable = false)
    private String city;
    @Column(nullable = false)
    private String address;
    private Double latitude;
    private Double longitude;
    private String phone;
    private String openingHours;
    private boolean pickupAvailable = true;
    private boolean deliveryAvailable;
    @Column(nullable = false)
    private BigDecimal deliveryFee = BigDecimal.ZERO;
    private BigDecimal freeDeliveryFrom;
    private Integer deliveryEtaMin;
    private Integer deliveryEtaMax;
    private boolean active = true;
}
