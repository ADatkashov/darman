package kz.darman.notifications;

import java.util.Map;
import java.util.UUID;
import kz.darman.common.PageResponse;
import kz.darman.config.AuthUser;
import kz.darman.notifications.NotificationService.NotificationDto;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/notifications")
public class NotificationController {
    private final NotificationService service;

    public NotificationController(NotificationService service) {
        this.service = service;
    }

    @GetMapping
    public PageResponse<NotificationDto> list(@AuthenticationPrincipal AuthUser user, @RequestParam(defaultValue = "0") int page,
                                              @RequestParam(defaultValue = "20") int size) {
        return service.list(user.id(), Math.max(0, page), Math.min(Math.max(1, size), 50));
    }

    @GetMapping("/unread-count")
    public Map<String, Long> unread(@AuthenticationPrincipal AuthUser user) {
        return Map.of("count", service.unread(user.id()));
    }

    @PostMapping("/{id}/read")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void read(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id) {
        service.markRead(user.id(), id);
    }
}
