package kz.darman.notifications;

import java.time.Instant;
import java.util.UUID;
import kz.darman.common.ApiException;
import kz.darman.common.PageResponse;
import kz.darman.users.User;
import kz.darman.users.UserRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** In-app notification inbox. Push/SMS/e-mail delivery would plug in here behind the user's notification preferences. */
@Service
public class NotificationService {
    public record NotificationDto(UUID id, String type, String title, String body, UUID refId, boolean read, Instant createdAt) {}

    private final NotificationRepository repo;
    private final UserRepository users;

    public NotificationService(NotificationRepository repo, UserRepository users) {
        this.repo = repo;
        this.users = users;
    }

    /** category: ORDERS, PRESCRIPTIONS or PROMOTIONS — respects the user's preferences. */
    @Transactional
    public void notify(UUID userId, String category, String type, String title, String body, UUID refId) {
        User u = users.findById(userId).orElse(null);
        if (u == null) return;
        boolean allowed = switch (category) {
            case "ORDERS" -> u.isNotifyOrders();
            case "PRESCRIPTIONS" -> u.isNotifyPrescriptions();
            case "PROMOTIONS" -> u.isNotifyPromotions();
            default -> true;
        };
        if (!allowed) return;
        Notification n = new Notification();
        n.setUserId(userId);
        n.setType(type);
        n.setTitle(title);
        n.setBody(body);
        n.setRefId(refId);
        repo.save(n);
    }

    @Transactional(readOnly = true)
    public PageResponse<NotificationDto> list(UUID userId, int page, int size) {
        return PageResponse.of(repo.findByUserIdOrderByCreatedAtDesc(userId, PageRequest.of(page, size)), this::dto);
    }

    @Transactional(readOnly = true)
    public long unread(UUID userId) {
        return repo.countByUserIdAndReadAtIsNull(userId);
    }

    @Transactional
    public void markRead(UUID userId, UUID id) {
        Notification n = repo.findByIdAndUserId(id, userId).orElseThrow(() -> ApiException.notFound("Notification"));
        if (n.getReadAt() == null) n.setReadAt(Instant.now());
    }

    private NotificationDto dto(Notification n) {
        return new NotificationDto(n.getId(), n.getType(), n.getTitle(), n.getBody(), n.getRefId(), n.getReadAt() != null, n.getCreatedAt());
    }
}
