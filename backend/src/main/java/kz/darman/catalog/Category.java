package kz.darman.catalog;

import jakarta.persistence.*;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "categories")
@Getter
@Setter
@NoArgsConstructor
public class Category {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false, unique = true)
    private String slug;
    @Column(nullable = false)
    private String nameRu;
    @Column(nullable = false)
    private String nameKk;
    @Column(nullable = false)
    private String nameEn;
    @Column(nullable = false)
    private String icon = "medication";
    private int sortOrder;
    private UUID parentId;
    private boolean active = true;
}
