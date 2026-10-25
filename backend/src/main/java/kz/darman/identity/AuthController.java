package kz.darman.identity;

import jakarta.validation.Valid;
import kz.darman.identity.AuthDtos.*;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {
    private final AuthService auth;

    public AuthController(AuthService auth) {
        this.auth = auth;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.ACCEPTED)
    public OtpChallenge register(@Valid @RequestBody RegisterRequest req) {
        return auth.register(req);
    }

    @PostMapping("/resend-otp")
    @ResponseStatus(HttpStatus.ACCEPTED)
    public OtpChallenge resend(@Valid @RequestBody ResendOtpRequest req) {
        return auth.resendOtp(req.phone());
    }

    @PostMapping("/verify-otp")
    public AuthResponse verify(@Valid @RequestBody VerifyOtpRequest req) {
        return auth.verifyOtp(req);
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest req) {
        return auth.login(req);
    }

    @PostMapping("/refresh")
    public AuthResponse refresh(@Valid @RequestBody RefreshRequest req) {
        return auth.refresh(req.refreshToken());
    }

    @PostMapping("/logout")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void logout(@Valid @RequestBody LogoutRequest req) {
        auth.logout(req.refreshToken());
    }
}
