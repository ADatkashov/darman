# DARMAN — Здоровье рядом

Pharmacy marketplace and medicine delivery for Kazakhstan (initial city: Almaty). Languages: Русский (default), Қазақша, English.

| Part | Stack | Path |
|---|---|---|
| Mobile app | Flutter 3.4x / Dart 3.1x, Material 3, Riverpod, GoRouter, Dio | `mobile/` |
| Backend | Java 21, Spring Boot 3.5, Spring Security + JWT, JPA, PostgreSQL 16, Flyway, OpenAPI | `backend/` |
| Staff web panel | Static SPA served by the backend at `/admin` | `backend/src/main/resources/static/admin` |
| Specifications | OpenSpec-style product/architecture docs | `openspec/` |

> **Everything seeded is fictional demo data.** Demo mode uses a demo OTP, a demo payment provider and a simulated courier — none of it is real.
> See [docs/demo-mode.md](docs/demo-mode.md). Production prerequisites (legal/pharmacy review, licensed pharmacist workflow, real SMS/payment/storage
> adapters) are listed in [docs/integrations.md](docs/integrations.md) and [openspec/08-security-privacy.md](openspec/08-security-privacy.md).

## Quick start (demo)

### Option A — Docker Compose
```bash
cp .env.example .env            # set POSTGRES_PASSWORD (and optionally DARMAN_DEMO_PASSWORD)
docker compose up --build
```
Backend: <http://localhost:8080> · API docs: <http://localhost:8080/swagger-ui.html> · Staff panel: <http://localhost:8080/admin>
The seeded demo accounts and their password are printed once in the backend log (`docker compose logs backend | grep -A6 "DEMO ACCOUNTS"`).

### Option B — local toolchain
```bash
# PostgreSQL 16 with a UTF-8 locale (needed for Cyrillic case-folding in search)
createuser -P darman && createdb -O darman darman
cd backend
DARMAN_DB_PASSWORD=... ./gradlew bootRun --args='--spring.profiles.active=demo'
```
```bash
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080     # Android emulator (use your LAN IP on a device)
```

### Demo accounts (password printed in the log, or set `DARMAN_DEMO_PASSWORD`)
| Phone | Role |
|---|---|
| +77000000010 | Customer with demo order history and a saved address |
| +77000000002 | Pharmacist (prescription review, orders) |
| +77000000003 | Operator (orders, offers, stock) |
| +77000000004 | Catalog manager (catalog, promotions) |
| +77000000001 | Administrator (everything, audit, staff) |

New customers register in the app; in demo mode the verification code is shown on screen (never in production).
Promo code `WELCOME10` (10 %, orders ≥ 3 000 ₸) is seeded.

## Verification

```bash
# backend (needs Docker for Testcontainers, or an empty Postgres via DARMAN_TEST_DB_URL / _USER / _PASSWORD)
cd backend && ./gradlew test
# mobile
cd mobile && flutter analyze && flutter test
```

## Documentation
- [openspec/](openspec/) — product overview, requirements, roles, journeys, architecture, contracts, design system, security, prescription workflow, order lifecycle, testing, deployment
- [docs/architecture.md](docs/architecture.md) · [docs/demo-mode.md](docs/demo-mode.md) · [docs/integrations.md](docs/integrations.md) · [docs/deploy-render-neon.md](docs/deploy-render-neon.md) (Render + Neon)

## Not a medical service
The app provides catalog and ordering functionality only. It gives no diagnosis, dosage or treatment advice; product instructions appear only
when loaded from a cited official source. Always consult a doctor or pharmacist.
