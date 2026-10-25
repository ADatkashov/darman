package kz.darman.identity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "otp_codes")
@Getter
@Setter
@NoArgsConstructor
public class OtpCode {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false)
    private String phone;
    @Column(nullable = false)
    private String codeHash;
    @Column(nullable = false)
    private Instant expiresAt;
    private int attempts;
    private Instant consumedAt;
    @Column(nullable = false, updatable = false)
    private Instant createdAt = Instant.now();
}
