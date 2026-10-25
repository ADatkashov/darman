# 5. Architecture and module boundaries

```
Flutter app ──HTTPS/JSON──▶ Spring Boot modular monolith ──JDBC──▶ PostgreSQL 16 (Flyway)
                                  │ private files ─▶ FileStorage (local | S3 adapter)
                                  └ adapters: OtpProvider, PaymentProvider
```
Backend packages (`kz.darman.*`): `identity` (auth, JWT, OTP, refresh rotation, rate limit) · `users` (profile, addresses, favorites) · `catalog` (+search read model) ·
`pharmacies` · `inventory` (offers, stock) · `pricing` (offer view, delivery fee) · `cart` · `prescriptions` · `orders` · `payments` · `delivery` (slots) ·
`promotions` · `notifications` · `audit` · `admin` · `storage` · `demo` (profile-gated) · `common`/`config`.

Cross-cutting: DTO records (entities never serialized), `GlobalExceptionHandler` envelope, `X-Request-Id` correlation (MDC), Bean Validation, method security, structured ECS logging in `prod`, actuator health/readiness, OpenAPI at `/swagger-ui.html` (disabled in prod).
Transactions: audit events join the business transaction (`record`) or use `REQUIRES_NEW` for denied/failed attempts (`recordIndependent`).
Not used: Redis (no demonstrated need; rate limiting is in-memory per node — use a shared limiter when scaling out).

Mobile (`mobile/lib`): `core` (theme, network, storage, utils) · `data` (models, repositories) · `state` (Riverpod notifiers/providers) · `design` (reusable widgets, painters) · `features/*` (screens) · `router`.
