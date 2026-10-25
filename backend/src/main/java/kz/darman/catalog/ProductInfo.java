package kz.darman.catalog;

import jakarta.persistence.*;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/** Sourced official product information section (USAGE, STORAGE, WARNINGS, CONTRAINDICATIONS...). */
@Entity
@Table(name = "product_info")
@Getter
@Setter
@NoArgsConstructor
public class ProductInfo {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false)
    private UUID productId;
    @Column(nullable = false)
    private String section;
    @Column(nullable = false)
    private String locale;
    @Column(nullable = false)
    private String body;
    @Column(nullable = false)
    private String source;
    private boolean verified;
}
