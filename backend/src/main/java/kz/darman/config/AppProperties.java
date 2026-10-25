package kz.darman.config;

import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "darman")
public record AppProperties(Jwt jwt, Otp otp, Payments payments, Storage storage, Demo demo, Cors cors, Legal legal,
                            RateLimit rateLimit) {

    public record Jwt(String secret, String issuer, Duration accessTtl, Duration refreshTtl) {}

    public record Otp(String provider, Duration ttl, int maxAttempts, Sms sms) {
        public boolean isDemo() {
            return "demo".equalsIgnoreCase(provider);
        }
    }

    public record Sms(String gatewayUrl, String apiKey, String sender) {}

    public record Payments(boolean demoEnabled, String webhookSecret) {}

    public record Storage(String privatePath, long maxFileBytes, int maxFilesPerPrescription) {}

    public record Demo(boolean enabled, boolean seedAccounts, boolean autoProgress, boolean autoReviewPrescriptions, int stepSeconds,
                       String password) {}

    public record Cors(String allowedOrigins) {}

    public record Legal(String privacyPolicyUrl, String termsUrl, String supportPhone) {}

    public record RateLimit(int authPerMinute) {}
}
