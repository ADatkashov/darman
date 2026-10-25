package kz.darman.prescriptions;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "prescriptions")
@Getter
@Setter
@NoArgsConstructor
public class Prescription {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false)
    private UUID userId;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PrescriptionStatus status = PrescriptionStatus.DRAFT;
    private String note;
    private String rejectionReason;
    private UUID reviewedBy;
    private Instant reviewedAt;
    private Instant submittedAt;
    private Instant expiresAt;
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

    /** Status as seen by clients: an approved prescription past its expiry is reported as EXPIRED. */
    public PrescriptionStatus effectiveStatus() {
        if (status == PrescriptionStatus.APPROVED && expiresAt != null && expiresAt.isBefore(Instant.now())) {
            return PrescriptionStatus.EXPIRED;
        }
        return status;
    }
}
