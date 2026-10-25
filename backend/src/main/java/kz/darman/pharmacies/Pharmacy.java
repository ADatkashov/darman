package kz.darman.pharmacies;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "pharmacies")
@Getter
@Setter
@NoArgsConstructor
public class Pharmacy {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false)
    private String name;
    private String description;
    @Column(name = "is_demo")
    private boolean demo;
    private boolean licenseVerified;
    private boolean active = true;
    @Column(nullable = false, updatable = false)
    private Instant createdAt = Instant.now();
}
