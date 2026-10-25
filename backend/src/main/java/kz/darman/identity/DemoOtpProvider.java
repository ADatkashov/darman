package kz.darman.identity;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/** DEVELOPMENT ONLY. Logs the (random) one-time code instead of sending an SMS. Blocked by ProductionGuard under "prod". */
@Component
@ConditionalOnProperty(name = "darman.otp.provider", havingValue = "demo")
public class DemoOtpProvider implements OtpProvider {
    private static final Logger log = LoggerFactory.getLogger(DemoOtpProvider.class);

    @Override
    public void send(String phone, String code) {
        log.warn("[DEMO OTP] code for {} is {} (demo provider, no SMS sent)", phone, code);
    }

    @Override
    public boolean exposesCode() {
        return true;
    }
}
