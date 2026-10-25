package kz.darman.prescriptions;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "prescription_review_events")
@Getter
@Setter
@NoArgsConstructor
public class PrescriptionReviewEvent {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false)
    private UUID prescriptionId;
    private UUID actorId;
    @Column(nullable = false)
    private String eventType;
    private String fromStatus;
    private String toStatus;
    private String comment;
    @Column(nullable = false, updatable = false)
    private Instant createdAt = Instant.now();
}
