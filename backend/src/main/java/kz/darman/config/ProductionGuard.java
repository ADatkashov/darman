package kz.darman.config;

import jakarta.annotation.PostConstruct;
import org.springframework.core.env.Environment;
import org.springframework.core.env.Profiles;
import org.springframework.stereotype.Component;

/** Fails fast when demo-only behaviour is enabled together with the production profile. */
@Component
public class ProductionGuard {
    private final Environment env;
    private final AppProperties props;

    public ProductionGuard(Environment env, AppProperties props) {
        this.env = env;
        this.props = props;
    }

    @PostConstruct
    void verify() {
        if (!env.acceptsProfiles(Profiles.of("prod"))) {
            return;
        }
        if (props.otp().isDemo() || props.payments().demoEnabled() || props.demo().enabled() || props.demo().seedAccounts()
                || props.demo().autoProgress() || props.demo().autoReviewPrescriptions()) {
            throw new IllegalStateException("Demo adapters must be disabled when the 'prod' profile is active");
        }
        if (props.jwt().secret() == null || props.jwt().secret().length() < 32) {
            throw new IllegalStateException("DARMAN_JWT_SECRET (>= 32 chars) is required in production");
        }
        if (props.payments().webhookSecret() == null || props.payments().webhookSecret().length() < 16) {
            throw new IllegalStateException("DARMAN_PAYMENT_WEBHOOK_SECRET is required in production");
        }
    }
}
