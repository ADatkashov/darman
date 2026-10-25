package kz.darman.payments;

import java.io.IOException;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/payments/webhooks")
public class PaymentWebhookController {
    private final PaymentService service;

    public PaymentWebhookController(PaymentService service) {
        this.service = service;
    }

    /** Raw body is required for signature verification (HMAC-SHA256, hex, header X-Signature). */
    @PostMapping("/{provider}")
    public PaymentService.WebhookResult receive(@PathVariable String provider, @RequestHeader(value = "X-Signature", required = false) String signature,
                                                HttpServletRequest request) throws IOException {
        byte[] body = request.getInputStream().readNBytes(256 * 1024);
        return service.handleWebhook(provider, signature, body);
    }
}
