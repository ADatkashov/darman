package kz.darman.users;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "addresses")
@Getter
@Setter
@NoArgsConstructor
public class Address {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    private String label;
    @Column(nullable = false)
    private String city;
    @Column(nullable = false)
    private String street;
    @Column(nullable = false)
    private String house;
    private String apartment;
    private String entrance;
    private String floor;
    private String comment;
    private Double latitude;
    private Double longitude;

    @Column(name = "is_default", nullable = false)
    private boolean defaultAddress;

    @Column(nullable = false, updatable = false)
    private Instant createdAt;
    @Column(nullable = false)
    private Instant updatedAt;

    @PrePersist
    void onCreate() {
        createdAt = Instant.now();
        updatedAt = createdAt;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = Instant.now();
    }

    public String oneLine() {
        StringBuilder sb = new StringBuilder(city).append(", ").append(street).append(", ").append(house);
        if (apartment != null && !apartment.isBlank()) sb.append(", кв. ").append(apartment);
        if (entrance != null && !entrance.isBlank()) sb.append(", подъезд ").append(entrance);
        if (floor != null && !floor.isBlank()) sb.append(", этаж ").append(floor);
        return sb.toString();
    }
}
