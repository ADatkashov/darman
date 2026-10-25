package kz.darman.users;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true)
    private String phone;

    private String fullName;
    private String email;

    @Column(nullable = false)
    private String passwordHash;

    @Column(name = "role_code", nullable = false)
    private String roleCode = "CUSTOMER";

    @Column(nullable = false)
    private String locale = "ru";

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserStatus status = UserStatus.PENDING_VERIFICATION;

    private Instant phoneVerifiedAt;
    private boolean notifyOrders = true;
    private boolean notifyPromotions = false;
    private boolean notifyPrescriptions = true;
    private Instant privacyConsentAt;
    private Instant deletionRequestedAt;

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

    public boolean isStaff() {
        return !"CUSTOMER".equals(roleCode);
    }
}
