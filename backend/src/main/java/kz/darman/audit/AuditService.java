package kz.darman.audit;

import jakarta.servlet.http.HttpServletRequest;
import java.util.UUID;
import kz.darman.config.AuthUser;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

@Service
public class AuditService {
    private final AuditEventRepository repo;

    public AuditService(AuditEventRepository repo) {
        this.repo = repo;
    }

    /** Records an audit event atomically with the surrounding business transaction. */
    @Transactional(propagation = Propagation.REQUIRED)
    public void record(String action, String entityType, Object entityId, String details) {
        write(action, entityType, entityId, details);
    }

    /** Records an audit event in its own transaction so denied/failed operations are logged even if the caller rolls back. */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void recordIndependent(String action, String entityType, Object entityId, String details) {
        write(action, entityType, entityId, details);
    }

    private void write(String action, String entityType, Object entityId, String details) {
        AuditEvent e = new AuditEvent();
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof AuthUser u) {
            e.setActorId(u.id());
            e.setActorRole(u.role());
        }
        e.setAction(action);
        e.setEntityType(entityType);
        e.setEntityId(entityId == null ? null : entityId.toString());
        e.setDetails(details != null && details.length() > 1000 ? details.substring(0, 1000) : details);
        if (RequestContextHolder.getRequestAttributes() instanceof ServletRequestAttributes attrs) {
            HttpServletRequest req = attrs.getRequest();
            e.setIpAddress(req.getRemoteAddr());
        }
        repo.save(e);
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void recordAs(UUID actorId, String role, String action, String entityType, Object entityId, String details) {
        AuditEvent e = new AuditEvent();
        e.setActorId(actorId);
        e.setActorRole(role);
        e.setAction(action);
        e.setEntityType(entityType);
        e.setEntityId(entityId == null ? null : entityId.toString());
        e.setDetails(details);
        repo.save(e);
    }
}
