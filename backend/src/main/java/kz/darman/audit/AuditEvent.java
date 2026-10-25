package kz.darman.audit;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "audit_events")
@Getter
@Setter
@NoArgsConstructor
public class AuditEvent {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    private UUID actorId;
    private String actorRole;
    @Column(nullable = false)
    private String action;
    private String entityType;
    private String entityId;
    private String details;
    private String ipAddress;
    @Column(nullable = false, updatable = false)
    private Instant createdAt = Instant.now();
}
