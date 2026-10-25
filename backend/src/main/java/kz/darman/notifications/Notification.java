package kz.darman.notifications;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "notifications")
@Getter
@Setter
@NoArgsConstructor
public class Notification {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false)
    private UUID userId;
    @Column(nullable = false)
    private String type;
    @Column(nullable = false)
    private String title;
    @Column(nullable = false)
    private String body;
    private UUID refId;
    private Instant readAt;
    @Column(nullable = false, updatable = false)
    private Instant createdAt = Instant.now();
}
