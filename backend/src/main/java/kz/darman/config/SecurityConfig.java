package kz.darman.config;

import java.util.Arrays;
import java.util.List;
import kz.darman.identity.JwtAuthFilter;
import kz.darman.identity.JwtService;
import kz.darman.identity.PermissionService;
import kz.darman.identity.RateLimitFilter;
import kz.darman.users.UserRepository;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(11);
    }

    @Bean
    SecurityFilterChain filterChain(HttpSecurity http, JwtService jwt, UserRepository users, PermissionService permissions,
                                    AppProperties props) throws Exception {
        http.csrf(AbstractHttpConfigurer::disable)
                .cors(c -> c.configurationSource(corsSource(props)))
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .headers(h -> h.frameOptions(f -> f.deny()).contentTypeOptions(c -> {}))
                .authorizeHttpRequests(a -> a
                        .requestMatchers("/api/v1/auth/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/v1/categories/**", "/api/v1/products/**", "/api/v1/search/**",
                                "/api/v1/search", "/api/v1/pharmacies/**", "/api/v1/promotions/**", "/api/v1/delivery/slots",
                                "/api/v1/config").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/v1/cart/validate", "/api/v1/payments/webhooks/*",
                                "/api/v1/promotions/validate").permitAll()
                        .requestMatchers("/actuator/health", "/actuator/health/**", "/actuator/info").permitAll()
                        .requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()
                        .requestMatchers("/admin/**", "/", "/favicon.ico", "/error").permitAll()
                        // Staff-only surface: customers are refused before request binding/validation even runs.
                        .requestMatchers("/api/v1/admin/**").hasAnyRole("PHARMACIST", "OPERATOR", "CATALOG_MANAGER", "ADMIN")
                        .requestMatchers("/api/**").authenticated()
                        .anyRequest().denyAll())
                .exceptionHandling(e -> e
                        .authenticationEntryPoint((req, res, ex) -> {
                            res.setStatus(401);
                            res.setContentType(MediaType.APPLICATION_JSON_VALUE);
                            res.getWriter().write("{\"status\":401,\"code\":\"UNAUTHORIZED\",\"message\":\"Authentication required\"}");
                        })
                        .accessDeniedHandler((req, res, ex) -> {
                            res.setStatus(403);
                            res.setContentType(MediaType.APPLICATION_JSON_VALUE);
                            res.getWriter().write("{\"status\":403,\"code\":\"FORBIDDEN\",\"message\":\"Access denied\"}");
                        }))
                .addFilterBefore(new RateLimitFilter(props.rateLimit().authPerMinute()), UsernamePasswordAuthenticationFilter.class)
                .addFilterBefore(new JwtAuthFilter(jwt, users, permissions), UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    private CorsConfigurationSource corsSource(AppProperties props) {
        CorsConfiguration cfg = new CorsConfiguration();
        String origins = props.cors().allowedOrigins();
        if (origins != null && !origins.isBlank()) {
            cfg.setAllowedOrigins(Arrays.stream(origins.split(",")).map(String::trim).filter(s -> !s.isEmpty()).toList());
        }
        cfg.setAllowedMethods(List.of("GET", "POST", "PATCH", "PUT", "DELETE", "OPTIONS"));
        cfg.setAllowedHeaders(List.of("Authorization", "Content-Type", "Accept-Language", "Idempotency-Key", "X-Request-Id"));
        cfg.setExposedHeaders(List.of("X-Request-Id"));
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", cfg);
        return source;
    }
}
