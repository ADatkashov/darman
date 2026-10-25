package kz.darman.config;

import java.util.Set;
import java.util.UUID;

/** Authenticated principal stored in the SecurityContext. */
public record AuthUser(UUID id, String role, Set<String> permissions) {
    public boolean has(String permission) {
        return permissions.contains(permission);
    }

    public boolean isStaff() {
        return !"CUSTOMER".equals(role);
    }
}
