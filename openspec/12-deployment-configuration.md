# 12. Deployment and configuration

- **Local**: `docker compose up --build` (see README) or run PostgreSQL + `./gradlew bootRun --args='--spring.profiles.active=demo'`.
- **Production**: profile `prod`; PostgreSQL 16 with UTF-8 locale (Cyrillic search depends on it) and `pg_trgm` available; persistent private volume or S3 adapter for prescriptions; TLS at the proxy (`server.forward-headers-strategy=framework` is set); set `DARMAN_JWT_SECRET`, `DARMAN_PAYMENT_WEBHOOK_SECRET`, `DARMAN_DB_*`, `DARMAN_CORS_ORIGINS` (web clients only), legal URLs; run staff creation via a one-off SQL/seed because `prod` seeds no accounts (first admin: insert a user with role ADMIN and a BCrypt hash, then manage staff in `/admin`).
- **Migrations**: Flyway runs on start; `db/demo` is only on the classpath location list in the `demo` profile. Never enable the demo location against production data.
- **Health**: `/actuator/health/liveness`, `/readiness`. **Logging**: ECS JSON in `prod`, correlation id in `X-Request-Id`.
- **Mobile builds**: `flutter build apk|appbundle|ipa --dart-define=API_BASE_URL=https://api.example.kz`. Set application id/signing for your organisation; release builds must use HTTPS.
- **CI**: GitHub Actions run backend tests (Docker available on runners) and Flutter analyze/test.
