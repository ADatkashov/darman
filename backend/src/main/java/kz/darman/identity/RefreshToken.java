package kz.darman.identity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "refresh_tokens")
@Getter
@Setter
@NoArgsConstructor
public class RefreshToken {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false)
    private UUID userId;
    @Column(nullable = false, unique = true)
    private String tokenHash;
    @Column(nullable = false)
    private UUID familyId;
    @Column(nullable = false)
    private Instant expiresAt;
    private Instant revokedAt;
    private UUID replacedBy;
    @Column(nullable = false, updatable = false)
    private Instant createdAt = Instant.now();
}
