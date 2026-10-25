package kz.darman.identity;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;
import java.util.UUID;
import kz.darman.audit.AuditService;
import kz.darman.common.ApiException;
import kz.darman.common.Phones;
import kz.darman.config.AppProperties;
import kz.darman.identity.AuthDtos.*;
import kz.darman.users.User;
import kz.darman.users.UserDto;
import kz.darman.users.UserRepository;
import kz.darman.users.UserStatus;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final java.util.Set<String> LOCALES = java.util.Set.of("ru", "kk", "en");

    private final UserRepository users;
    private final OtpCodeRepository otps;
    private final RefreshTokenRepository refreshTokens;
    private final OtpProvider otpProvider;
    private final JwtService jwt;
    private final PasswordEncoder encoder;
    private final AppProperties props;
    private final AuditService audit;

    public AuthService(UserRepository users, OtpCodeRepository otps, RefreshTokenRepository refreshTokens, OtpProvider otpProvider,
                       JwtService jwt, PasswordEncoder encoder, AppProperties props, AuditService audit) {
        this.users = users;
        this.otps = otps;
        this.refreshTokens = refreshTokens;
        this.otpProvider = otpProvider;
        this.jwt = jwt;
        this.encoder = encoder;
        this.props = props;
        this.audit = audit;
    }

    @Transactional
    public OtpChallenge register(RegisterRequest req) {
        String phone = requirePhone(req.phone());
        validatePassword(req.password());
        User user = users.findByPhone(phone).orElse(null);
        if (user != null && user.getStatus() != UserStatus.PENDING_VERIFICATION) {
            throw ApiException.conflict("PHONE_ALREADY_REGISTERED", "This phone number is already registered");
        }
        if (user == null) {
            user = new User();
            user.setPhone(phone);
        }
        user.setPasswordHash(encoder.encode(req.password()));
        user.setFullName(req.fullName() == null || req.fullName().isBlank() ? null : req.fullName().trim());
        user.setLocale(req.locale() != null && LOCALES.contains(req.locale()) ? req.locale() : "ru");
        user.setPrivacyConsentAt(Instant.now());
        users.save(user);
        return issueOtp(phone);
    }

    @Transactional
    public OtpChallenge resendOtp(String rawPhone) {
        String phone = requirePhone(rawPhone);
        User user = users.findByPhone(phone).orElse(null);
        // Do not reveal whether the account exists: respond identically but only send for pending accounts.
        if (user == null || user.getStatus() != UserStatus.PENDING_VERIFICATION) {
            return new OtpChallenge(phone, props.otp().ttl().toSeconds(), null);
        }
        return issueOtp(phone);
    }

    private OtpChallenge issueOtp(String phone) {
        otps.findFirstByPhoneOrderByCreatedAtDesc(phone).ifPresent(prev -> {
            if (prev.getCreatedAt().isAfter(Instant.now().minusSeconds(30))) {
                throw new ApiException(HttpStatus.TOO_MANY_REQUESTS, "OTP_TOO_SOON", "Please wait before requesting another code");
            }
        });
        String code = "%06d".formatted(RANDOM.nextInt(1_000_000));
        OtpCode otp = new OtpCode();
        otp.setPhone(phone);
        otp.setCodeHash(hash(phone + ":" + code));
        otp.setExpiresAt(Instant.now().plus(props.otp().ttl()));
        otps.save(otp);
        otpProvider.send(phone, code);
        return new OtpChallenge(phone, props.otp().ttl().toSeconds(), otpProvider.exposesCode() ? code : null);
    }

    @Transactional(noRollbackFor = ApiException.class)
    public AuthResponse verifyOtp(VerifyOtpRequest req) {
        String phone = requirePhone(req.phone());
        OtpCode otp = otps.findFirstByPhoneOrderByCreatedAtDesc(phone)
                .orElseThrow(() -> ApiException.badRequest("OTP_INVALID", "Invalid or expired code"));
        if (otp.getConsumedAt() != null || otp.getExpiresAt().isBefore(Instant.now())
                || otp.getAttempts() >= props.otp().maxAttempts()) {
            throw ApiException.badRequest("OTP_INVALID", "Invalid or expired code");
        }
        otp.setAttempts(otp.getAttempts() + 1);
        if (!MessageDigest.isEqual(hash(phone + ":" + req.code().trim()).getBytes(StandardCharsets.UTF_8),
                otp.getCodeHash().getBytes(StandardCharsets.UTF_8))) {
            otps.save(otp);
            throw ApiException.badRequest("OTP_INVALID", "Invalid or expired code");
        }
        otp.setConsumedAt(Instant.now());
        otps.save(otp);
        User user = users.findByPhone(phone).orElseThrow(() -> ApiException.badRequest("OTP_INVALID", "Invalid or expired code"));
        if (user.getStatus() == UserStatus.DISABLED) {
            throw ApiException.forbidden("Account is disabled");
        }
        if (user.getStatus() == UserStatus.PENDING_VERIFICATION) {
            user.setStatus(UserStatus.ACTIVE);
            user.setPhoneVerifiedAt(Instant.now());
            users.save(user);
        }
        audit.recordAs(user.getId(), user.getRoleCode(), "AUTH_PHONE_VERIFIED", "User", user.getId(), null);
        return startSession(user, UUID.randomUUID());
    }

    @Transactional
    public AuthResponse login(LoginRequest req) {
        String phone = Phones.normalize(req.phone());
        User user = phone == null ? null : users.findByPhone(phone).orElse(null);
        if (user == null || !encoder.matches(req.password(), user.getPasswordHash())) {
            if (phone != null) audit.recordAs(null, null, "AUTH_LOGIN_FAILED", "User", phone, null);
            throw ApiException.unauthorized("INVALID_CREDENTIALS", "Invalid phone or password");
        }
        if (user.getStatus() == UserStatus.PENDING_VERIFICATION) {
            throw ApiException.forbidden("Phone number is not verified").withCode("PHONE_NOT_VERIFIED");
        }
        if (user.getStatus() == UserStatus.DISABLED) {
            throw ApiException.forbidden("Account is disabled").withCode("ACCOUNT_DISABLED");
        }
        return startSession(user, UUID.randomUUID());
    }

    @Transactional(noRollbackFor = ApiException.class)
    public AuthResponse refresh(String rawToken) {
        RefreshToken current = refreshTokens.findByTokenHash(hash(rawToken))
                .orElseThrow(() -> ApiException.unauthorized("INVALID_REFRESH_TOKEN", "Invalid refresh token"));
        if (current.getRevokedAt() != null) {
            // Reuse of a rotated token: assume theft and kill the whole family.
            refreshTokens.revokeFamily(current.getFamilyId(), Instant.now());
            audit.recordAs(current.getUserId(), null, "AUTH_REFRESH_REUSE_DETECTED", "User", current.getUserId(), null);
            throw ApiException.unauthorized("INVALID_REFRESH_TOKEN", "Invalid refresh token");
        }
        if (current.getExpiresAt().isBefore(Instant.now())) {
            throw ApiException.unauthorized("INVALID_REFRESH_TOKEN", "Refresh token expired");
        }
        User user = users.findById(current.getUserId()).filter(u -> u.getStatus() == UserStatus.ACTIVE)
                .orElseThrow(() -> ApiException.unauthorized("INVALID_REFRESH_TOKEN", "Invalid refresh token"));
        AuthResponse next = startSession(user, current.getFamilyId());
        RefreshToken created = refreshTokens.findByTokenHash(hash(next.refreshToken())).orElseThrow();
        current.setRevokedAt(Instant.now());
        current.setReplacedBy(created.getId());
        refreshTokens.save(current);
        return next;
    }

    @Transactional
    public void logout(String rawToken) {
        refreshTokens.findByTokenHash(hash(rawToken)).ifPresent(t -> refreshTokens.revokeFamily(t.getFamilyId(), Instant.now()));
    }

    private AuthResponse startSession(User user, UUID family) {
        byte[] raw = new byte[48];
        RANDOM.nextBytes(raw);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(raw);
        RefreshToken rt = new RefreshToken();
        rt.setUserId(user.getId());
        rt.setFamilyId(family);
        rt.setTokenHash(hash(token));
        rt.setExpiresAt(Instant.now().plus(props.jwt().refreshTtl()));
        refreshTokens.save(rt);
        return new AuthResponse(jwt.issueAccessToken(user.getId(), user.getRoleCode()), token, jwt.accessTtlSeconds(), UserDto.of(user));
    }

    private static String requirePhone(String raw) {
        String phone = Phones.normalize(raw);
        if (phone == null) throw ApiException.badRequest("INVALID_PHONE", "Enter a valid Kazakhstan phone number (+7 XXX XXX XX XX)");
        return phone;
    }

    static void validatePassword(String password) {
        boolean letter = password.chars().anyMatch(Character::isLetter);
        boolean digit = password.chars().anyMatch(Character::isDigit);
        if (!letter || !digit) {
            throw ApiException.badRequest("WEAK_PASSWORD", "Password must contain letters and digits");
        }
    }

    static String hash(String value) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (java.security.NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }
}
