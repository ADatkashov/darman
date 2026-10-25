package kz.darman.identity;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import kz.darman.users.UserDto;

public final class AuthDtos {
    private AuthDtos() {}

    public record RegisterRequest(@NotBlank @Size(max = 32) String phone,
                                  @NotBlank @Size(min = 8, max = 72) String password,
                                  @Size(max = 160) String fullName,
                                  @Size(max = 5) String locale,
                                  @AssertTrue(message = "Privacy consent is required") boolean privacyConsent) {}

    public record LoginRequest(@NotBlank @Size(max = 32) String phone, @NotBlank @Size(max = 72) String password) {}

    public record VerifyOtpRequest(@NotBlank @Size(max = 32) String phone, @NotBlank @Size(min = 4, max = 8) String code) {}

    public record ResendOtpRequest(@NotBlank @Size(max = 32) String phone) {}

    public record RefreshRequest(@NotBlank String refreshToken) {}

    public record LogoutRequest(@NotBlank String refreshToken) {}

    /** devOtp is present only when the demo OTP provider is active. */
    public record OtpChallenge(String phone, long expiresInSeconds, String devOtp) {}

    public record AuthResponse(String accessToken, String refreshToken, long expiresInSeconds, UserDto user) {}
}
