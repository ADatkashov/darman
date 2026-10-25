package kz.darman.identity;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import kz.darman.common.ApiException;
import kz.darman.config.AppProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

/**
 * Generic HTTP SMS-gateway adapter. POSTs {"to","text","sender"} with a bearer key to DARMAN_SMS_GATEWAY_URL.
 * Adapt the payload to the chosen Kazakhstan SMS provider (see docs/integrations). When the gateway is not configured the
 * request fails with 503 — a verification code is never reported as sent unless the gateway accepted it.
 */
@Component
@ConditionalOnProperty(name = "darman.otp.provider", havingValue = "sms", matchIfMissing = true)
public class HttpSmsOtpProvider implements OtpProvider {
    private static final Logger log = LoggerFactory.getLogger(HttpSmsOtpProvider.class);
    private final AppProperties.Sms sms;
    private final HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();

    public HttpSmsOtpProvider(AppProperties props) {
        this.sms = props.otp().sms();
    }

    @Override
    public void send(String phone, String code) {
        if (sms == null || sms.gatewayUrl() == null || sms.gatewayUrl().isBlank()) {
            throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE, "OTP_PROVIDER_NOT_CONFIGURED",
                    "SMS verification provider is not configured");
        }
        String body = "{\"to\":\"%s\",\"sender\":\"%s\",\"text\":\"DARMAN: %s\"}".formatted(phone, sms.sender(), code);
        try {
            HttpRequest req = HttpRequest.newBuilder(URI.create(sms.gatewayUrl())).timeout(Duration.ofSeconds(10))
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + (sms.apiKey() == null ? "" : sms.apiKey()))
                    .POST(HttpRequest.BodyPublishers.ofString(body)).build();
            HttpResponse<Void> res = client.send(req, HttpResponse.BodyHandlers.discarding());
            if (res.statusCode() / 100 != 2) {
                log.error("SMS gateway rejected the message: HTTP {}", res.statusCode());
                throw new ApiException(HttpStatus.BAD_GATEWAY, "OTP_DELIVERY_FAILED", "Could not deliver the verification code");
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new ApiException(HttpStatus.BAD_GATEWAY, "OTP_DELIVERY_FAILED", "Could not deliver the verification code");
        } catch (java.io.IOException | IllegalArgumentException e) {
            log.error("SMS gateway call failed: {}", e.getMessage());
            throw new ApiException(HttpStatus.BAD_GATEWAY, "OTP_DELIVERY_FAILED", "Could not deliver the verification code");
        }
    }
}
