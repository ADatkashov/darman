package kz.darman.admin;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import kz.darman.audit.AuditService;
import kz.darman.common.ApiException;
import kz.darman.common.PageResponse;
import kz.darman.common.Phones;
import kz.darman.config.AuthUser;
import kz.darman.identity.PermissionService;
import kz.darman.identity.RefreshTokenRepository;
import kz.darman.users.User;
import kz.darman.users.UserDto;
import kz.darman.users.UserRepository;
import kz.darman.users.UserStatus;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminStaffService {
    public record CreateStaffRequest(@NotBlank @Size(max = 32) String phone, @NotBlank @Size(min = 12, max = 72) String password,
                                     @Size(max = 160) String fullName, @NotBlank String role) {}

    public record UpdateStaffRequest(String role, UserStatus status) {}

    private final UserRepository users;
    private final PermissionService permissions;
    private final PasswordEncoder encoder;
    private final RefreshTokenRepository refreshTokens;
    private final AuditService audit;

    public AdminStaffService(UserRepository users, PermissionService permissions, PasswordEncoder encoder, RefreshTokenRepository refreshTokens,
                             AuditService audit) {
        this.users = users;
        this.permissions = permissions;
        this.encoder = encoder;
        this.refreshTokens = refreshTokens;
        this.audit = audit;
    }

    @Transactional(readOnly = true)
    public PageResponse<UserDto> list(int page, int size) {
        return PageResponse.of(users.findStaff(PageRequest.of(page, size)), UserDto::of);
    }

    public List<Map<String, Object>> roles() {
        return permissions.matrix();
    }

    @Transactional
    public UserDto create(CreateStaffRequest r) {
        String phone = Phones.normalize(r.phone());
        if (phone == null) throw ApiException.badRequest("INVALID_PHONE", "Invalid phone");
        if ("CUSTOMER".equals(r.role()) || !permissions.roleExists(r.role())) throw ApiException.badRequest("INVALID_ROLE", "Unknown staff role");
        if (users.findByPhone(phone).isPresent()) throw ApiException.conflict("PHONE_ALREADY_REGISTERED", "Phone already registered");
        User u = new User();
        u.setPhone(phone);
        u.setFullName(r.fullName());
        u.setPasswordHash(encoder.encode(r.password()));
        u.setRoleCode(r.role());
        u.setStatus(UserStatus.ACTIVE);
        u.setPhoneVerifiedAt(java.time.Instant.now());
        users.save(u);
        audit.record("STAFF_CREATED", "User", u.getId(), "role=" + r.role());
        return UserDto.of(u);
    }

    @Transactional
    public UserDto update(AuthUser actor, UUID id, UpdateStaffRequest r) {
        User u = users.findById(id).orElseThrow(() -> ApiException.notFound("User"));
        if (u.getId().equals(actor.id())) throw ApiException.conflict("SELF_CHANGE", "You cannot change your own role or status");
        if (r.role() != null) {
            if (!permissions.roleExists(r.role())) throw ApiException.badRequest("INVALID_ROLE", "Unknown role");
            u.setRoleCode(r.role());
        }
        if (r.status() != null && r.status() != UserStatus.PENDING_VERIFICATION) {
            u.setStatus(r.status());
            if (r.status() == UserStatus.DISABLED) refreshTokens.revokeAllForUser(id, java.time.Instant.now());
        }
        users.save(u);
        audit.record("STAFF_UPDATED", "User", id, "role=" + u.getRoleCode() + " status=" + u.getStatus());
        return UserDto.of(u);
    }
}
