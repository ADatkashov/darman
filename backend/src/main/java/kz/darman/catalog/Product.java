package kz.darman.catalog;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "products")
@Getter
@Setter
@NoArgsConstructor
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false, unique = true)
    private String slug;
    @Column(nullable = false)
    private String name;
    private String brand;
    private String activeIngredient;
    private String strength;
    private String dosageForm;
    private String packageSize;
    private UUID manufacturerId;
    @Column(nullable = false)
    private UUID categoryId;
    @Column(nullable = false)
    private String saleClass = "OTC";
    private boolean rxRequired;
    private String descriptionRu;
    private String descriptionKk;
    private String descriptionEn;
    @Column(name = "is_demo")
    private boolean demo;
    private boolean active = true;
    private int popularity;
    @Column(nullable = false)
    private String searchText;
    @Column(nullable = false, updatable = false)
    private Instant createdAt;
    @Column(nullable = false)
    private Instant updatedAt;
    @Version
    private long version;

    @PrePersist
    void onCreate() {
        createdAt = Instant.now();
        updatedAt = createdAt;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = Instant.now();
    }
}
