# External integrations and production prerequisites

All integrations sit behind small interfaces so demo adapters can never be mistaken for real ones.

## Phone verification (OTP)
- Interface: `kz.darman.identity.OtpProvider`. `DemoOtpProvider` (profile demo) and `HttpSmsOtpProvider` (default).
- `HttpSmsOtpProvider` POSTs `{"to","sender","text"}` with `Authorization: Bearer <key>` to `DARMAN_SMS_GATEWAY_URL`. Adapt the payload to your Kazakhstan SMS
  provider (e.g. an aggregator with Kazakh sender registration). Unconfigured → registration fails with `OTP_PROVIDER_NOT_CONFIGURED` (HTTP 503); a code is never reported as sent unless the gateway returned 2xx.
- Codes are random, hashed at rest, valid 5 min, 5 attempts, 30 s resend cooldown.

## Payments
- Interface: `kz.darman.payments.PaymentProvider` (`initiate`). Implement a bean for your acquirer; card data must be entered on the provider's hosted page / SDK — DARMAN never receives PAN/CVV.
- Outcomes: `SUCCEEDED` (provider confirmed) → `PAID`; `PENDING` → wait for webhook; `FAILED` → order rejected (HTTP 402, stock restored).
- Webhook: `POST /api/v1/payments/webhooks/{provider}`, header `X-Signature` = hex HMAC-SHA256 of the raw body with `DARMAN_PAYMENT_WEBHOOK_SECRET`.
  Body `{eventId,type(payment.succeeded|payment.failed|payment.refunded),providerRef,amount}`. Idempotent on `(provider,eventId)`; amount mismatches and illegal state regressions are ignored.
- With no provider bean, `CARD_ONLINE` is refused (`PAYMENT_PROVIDER_NOT_CONFIGURED`); cash on receipt always works.
- The receipt screen states it is not a fiscal receipt: connect an online cash register / fiscal data operator before launch.

## Private file storage (prescriptions)
- Interface: `kz.darman.storage.FileStorage`. `LocalFileStorage` writes outside any web root (`DARMAN_STORAGE_PATH`). For production implement an S3-compatible **private** bucket with server-side encryption and use a volume with backups.
- Files are only served through `GET /prescriptions/{id}/files/{fileId}` (owner or `PRESCRIPTION_REVIEW`), `Cache-Control: no-store`, every access audited.

## Push / e-mail notifications
In-app inbox exists (`/notifications`). Push (FCM/APNs) and e-mail delivery are **not implemented**; hook them into `NotificationService.notify`, which already honours per-user preferences.

## Maps / courier tracking
No map or GPS provider is integrated. Delivery windows are estimates; the courier shown comes from staff input (or a flagged demo courier).

## Configuration reference
`DARMAN_DB_URL/USER/PASSWORD`, `DARMAN_JWT_SECRET` (≥ 32 chars, required in prod), `DARMAN_PAYMENT_WEBHOOK_SECRET` (required in prod), `DARMAN_SMS_*`,
`DARMAN_STORAGE_PATH`, `DARMAN_CORS_ORIGINS`, `DARMAN_PRIVACY_URL`, `DARMAN_TERMS_URL`, `DARMAN_SUPPORT_PHONE`, `DARMAN_API_DOCS_ENABLED`, `DARMAN_DB_POOL_SIZE`.
