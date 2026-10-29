# 11. Testing and acceptance

## Automated (all passing at time of writing)
**Backend – 63 tests** (`./gradlew test`, PostgreSQL via Testcontainers or `DARMAN_TEST_DB_URL`): auth flow (OTP, lockout, rotation, reuse detection, logout), catalog/search (ingredient search, no substitution, wildcard safety, filters, sort, pagination, localization), cart (merge, branch rule, stock caps, validation statuses), orders (server pricing, idempotency incl. concurrent replay, 12-way oversell race, rule violations, slots, promo, demo payment labelling, cancel/restock, staff timeline, courier visibility, snapshots, reorder, server-cart checkout), prescriptions (sniffing, state machine, own-review ban, single use, expiry, queue privacy), payment webhooks (signature, replay idempotency, amount mismatch, regressions), authorization (customer→admin 403, per-role permissions, cross-user access 404, audit of file access), unit tests, and an end-to-end customer journey.
**Mobile – 25 tests** (`flutter test`): cart logic & persistence, checkout totals, validators, file sniffing, formatting, model parsing, token refresh/session expiry (scripted HTTP), widget tests for boot, navigation, locales (ru/kk/en), cart badge, guest checkout redirect, login validation. `test/live_contract_test.dart` runs the real mobile models/repositories against a running backend (browse, search, validate, login, order, reorder, favorites, prescription upload).
**CI**: `.github/workflows/backend.yml`, `mobile.yml`.

## Manual acceptance checklist
Onboarding skip · switch language and restart (persists) · search "ibuprofen" / "ибупрофен" / no-match state · compare offers · add from another pharmacy (replace dialog) · kill/restart app (cart persists) · guest checkout → login → order (demo card shows DEMO) · watch tracking advance · cancel a PLACED order · upload a prescription, approve in `/admin`, order an Rx item · customer cannot open `/api/v1/admin/*` · airplane mode shows offline banner.

## Verified on a running stack (2026-10-29)
Demo backend + PostgreSQL 16 + Flutter web build (`--no-web-resources-cdn`): all screens were walked through in a browser (screenshots in `docs/screenshots`, 52 mobile + 8 staff panel), in ru / kk / en and in the dark theme; `test/live_contract_test.dart` passes against the live backend; authorization checked over HTTP (customer → `/api/v1/admin/*` 403, no token 401, pharmacist 200); placing, tracking and reorder verified in the UI.

## Known verification gaps
Android/iOS binaries were **not built** (no Android SDK/Xcode: `dl.google.com` is not reachable from the cloud environment, so the SDK cannot be downloaded there); visuals were reviewed only in a browser (390×844), not on a device; Docker image/compose were not executed (no Docker daemon in the cloud environment; CI covers the backend through a PostgreSQL service container); accessibility audit with TalkBack/VoiceOver not done; offline banner not re-checked in the browser.
