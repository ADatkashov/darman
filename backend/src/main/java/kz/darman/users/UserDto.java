package kz.darman.users;

import java.time.Instant;
import java.util.UUID;

public record UserDto(UUID id, String phone, String fullName, String email, String role, String locale, String status,
                      boolean notifyOrders, boolean notifyPromotions, boolean notifyPrescriptions, Instant privacyConsentAt,
                      Instant deletionRequestedAt, Instant createdAt) {
    public static UserDto of(User u) {
        return new UserDto(u.getId(), u.getPhone(), u.getFullName(), u.getEmail(), u.getRoleCode(), u.getLocale(),
                u.getStatus().name(), u.isNotifyOrders(), u.isNotifyPromotions(), u.isNotifyPrescriptions(),
                u.getPrivacyConsentAt(), u.getDeletionRequestedAt(), u.getCreatedAt());
    }
}
