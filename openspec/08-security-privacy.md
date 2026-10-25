# 8. Security and privacy requirements

## Implemented
- Stateless JWT access tokens (15 min) + opaque refresh tokens (30 d) stored hashed (SHA-256); rotation on every refresh; replay of a rotated token revokes the whole family; logout and staff disabling revoke tokens. Mobile stores tokens in the platform keystore (`flutter_secure_storage`).
- Passwords: BCrypt (cost 11), min 8 chars with letters+digits (staff ≥ 12). OTP: random, hashed, expiring, attempt-limited. In-memory rate limit on `/auth/*` POST (20/min/IP, configurable).
- Authorization at URL level (`/admin/**` staff only) and at method level (`@PreAuthorize` by permission); ownership checks in services; foreign resources → 404.
- Prescription files: content sniffing (JPEG/PNG/PDF magic bytes), size/count limits, random storage keys outside web root, authorized streaming only (`no-store`, `nosniff`), SHA-256 recorded, every access/denied attempt/review step audited.
- Audit trail (`audit_events`): actor, role, action, entity, IP; orders, prescriptions, payments, catalog/staff changes, auth failures.
- Idempotent orders and payment webhooks; HMAC-verified webhooks; webhooks rejected when no secret configured.
- No secrets in Git; `.env` ignored; `ProductionGuard` refuses to start `prod` with demo adapters or missing secrets. Swagger/API docs disabled in `prod`.
- Cleartext HTTP is allowed only in the Android **debug** manifest.

## Privacy
Collected: phone, name, optional e-mail, addresses, orders, prescription files (on request). Consent captured at registration (`privacy_consent_at`) and checkout (`consent_accepted_at`). Account deletion is a **request** (`deletion_requested_at`) that staff must process; retention rules (orders, tax records) require legal input. The reviewer queue exposes the patient's name only (no phone/address).

## Must be done before launch (needs local legal / pharmacy professionals)
1. Kazakhstan personal-data law (localization of databases, consent wording, retention, breach process) and e-commerce/medicine-distribution licensing (online sale of medicines, prescription rules, pharmacist licensing, cold-chain/storage, returns).
2. Replace draft privacy/terms texts; configure `DARMAN_PRIVACY_URL`/`TERMS_URL`.
3. Real OTP provider, payment acquirer, fiscal receipts, S3 private storage with encryption/backup, TLS termination, WAF, shared rate limiter, log retention, monitoring.
4. Verify pharmacy licences and product registrations; load official instructions with sources; review the restricted-substances policy.
5. Penetration test; DPIA; account-deletion procedure; backup/restore drills.
