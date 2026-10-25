package kz.darman.config;

import kz.darman.payments.PaymentService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Public runtime flags so the mobile app can label demo behaviour honestly. */
@RestController
@RequestMapping("/api/v1/config")
public class AppConfigController {
    private final AppProperties props;
    private final PaymentService payments;

    public AppConfigController(AppProperties props, PaymentService payments) {
        this.props = props;
        this.payments = payments;
    }

    public record AppConfig(boolean demoMode, boolean demoOtp, boolean onlinePaymentAvailable, boolean onlinePaymentIsDemo, String currency,
                            String defaultCity, String privacyPolicyUrl, String termsUrl, String supportPhone, int maxPrescriptionFiles,
                            long maxPrescriptionFileBytes) {}

    @GetMapping
    public AppConfig config() {
        return new AppConfig(props.demo().enabled(), props.otp().isDemo(), payments.onlineAvailable(), props.payments().demoEnabled(), "KZT",
                "Алматы", nz(props.legal().privacyPolicyUrl()), nz(props.legal().termsUrl()), nz(props.legal().supportPhone()),
                props.storage().maxFilesPerPrescription(), props.storage().maxFileBytes());
    }

    private static String nz(String s) {
        return s == null ? "" : s;
    }
}
