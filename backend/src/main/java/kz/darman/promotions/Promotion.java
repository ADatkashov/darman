package kz.darman.promotions;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "promotions")
@Getter
@Setter
@NoArgsConstructor
public class Promotion {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false)
    private String kind;
    private String code;
    @Column(nullable = false)
    private String titleRu;
    @Column(nullable = false)
    private String titleKk;
    @Column(nullable = false)
    private String titleEn;
    private String subtitleRu;
    private String subtitleKk;
    private String subtitleEn;
    private Integer discountPercent;
    private BigDecimal minOrderAmount;
    private Instant startsAt;
    private Instant endsAt;
    private int sortOrder;
    private boolean active = true;

    public boolean isLive(Instant now) {
        return active && (startsAt == null || !startsAt.isAfter(now)) && (endsAt == null || endsAt.isAfter(now));
    }
}
