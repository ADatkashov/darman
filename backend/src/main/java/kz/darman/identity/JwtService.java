package kz.darman.identity;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.Date;
import java.util.Optional;
import java.util.UUID;
import javax.crypto.SecretKey;
import kz.darman.config.AppProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class JwtService {
    private static final Logger log = LoggerFactory.getLogger(JwtService.class);
    private final SecretKey key;
    private final AppProperties props;

    public JwtService(AppProperties props) {
        this.props = props;
        String secret = props.jwt().secret();
        if (secret == null || secret.length() < 32) {
            byte[] random = new byte[64];
            new SecureRandom().nextBytes(random);
            this.key = Keys.hmacShaKeyFor(random);
            log.warn("DARMAN_JWT_SECRET is not set (or shorter than 32 chars): using an ephemeral key, sessions will not survive a restart");
        } else {
            this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        }
    }

    public String issueAccessToken(UUID userId, String role) {
        Instant now = Instant.now();
        return Jwts.builder()
                .issuer(props.jwt().issuer())
                .subject(userId.toString())
                .claim("role", role)
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plus(props.jwt().accessTtl())))
                .signWith(key)
                .compact();
    }

    public long accessTtlSeconds() {
        return props.jwt().accessTtl().toSeconds();
    }

    public Optional<UUID> parseUserId(String token) {
        try {
            Claims claims = Jwts.parser().verifyWith(key).requireIssuer(props.jwt().issuer()).build()
                    .parseSignedClaims(token).getPayload();
            return Optional.of(UUID.fromString(claims.getSubject()));
        } catch (JwtException | IllegalArgumentException e) {
            return Optional.empty();
        }
    }
}
