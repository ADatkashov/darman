package kz.darman.identity;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import kz.darman.config.AuthUser;
import kz.darman.users.UserRepository;
import kz.darman.users.UserStatus;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

public class JwtAuthFilter extends OncePerRequestFilter {
    private final JwtService jwt;
    private final UserRepository users;
    private final PermissionService permissions;

    public JwtAuthFilter(JwtService jwt, UserRepository users, PermissionService permissions) {
        this.jwt = jwt;
        this.users = users;
        this.permissions = permissions;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            jwt.parseUserId(header.substring(7).trim()).flatMap(users::findById)
                    .filter(u -> u.getStatus() == UserStatus.ACTIVE)
                    .ifPresent(u -> {
                        var perms = permissions.permissionsOf(u.getRoleCode());
                        List<GrantedAuthority> authorities = new ArrayList<>();
                        authorities.add(new SimpleGrantedAuthority("ROLE_" + u.getRoleCode()));
                        perms.forEach(p -> authorities.add(new SimpleGrantedAuthority(p)));
                        var principal = new AuthUser(u.getId(), u.getRoleCode(), perms);
                        SecurityContextHolder.getContext()
                                .setAuthentication(new UsernamePasswordAuthenticationToken(principal, null, authorities));
                    });
        }
        chain.doFilter(request, response);
    }
}
