package kz.darman.identity;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.Instant;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.web.filter.OncePerRequestFilter;

/** Small in-memory sliding-window limiter for unauthenticated auth endpoints (per client address). */
public class RateLimitFilter extends OncePerRequestFilter {
    private final int perMinute;
    private final Map<String, Deque<Long>> hits = new ConcurrentHashMap<>();

    public RateLimitFilter(int perMinute) {
        this.perMinute = perMinute;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !request.getRequestURI().startsWith("/api/v1/auth/") || !"POST".equals(request.getMethod());
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        long now = Instant.now().toEpochMilli();
        Deque<Long> q = hits.computeIfAbsent(request.getRemoteAddr(), k -> new ArrayDeque<>());
        boolean limited;
        synchronized (q) {
            while (!q.isEmpty() && now - q.peekFirst() > 60_000) q.pollFirst();
            limited = q.size() >= perMinute;
            if (!limited) q.addLast(now);
        }
        if (limited) {
            response.setStatus(429);
            response.setContentType("application/json");
            response.getWriter().write("{\"status\":429,\"code\":\"RATE_LIMITED\",\"message\":\"Too many requests\"}");
            return;
        }
        chain.doFilter(request, response);
    }
}
