# Demo mode guide

Activated with Spring profile `demo` (the default in `docker-compose.yml`). It is **blocked at startup when the `prod` profile is also active**
(`ProductionGuard`), and `application-prod.yml` forces every demo switch off.

| Capability | Demo behaviour | Real integration |
|---|---|---|
| Catalog / pharmacies | 44 fictional products, 6 fictional branches (`db/demo/V100__demo_catalog.sql`), flagged `is_demo`, `license_verified = false` | Load verified data through the admin API; set pharmacy licences only after verification |
| Product information | No usage/dosage/warning text is invented. Sections stay empty → the app says "official instructions unavailable" | Add sourced sections via `PUT /admin/products/{id}/info` (`source` is mandatory) |
| Phone verification | `darman.otp.provider=demo`: random 6-digit code logged and returned as `devOtp` | `sms` adapter (generic HTTP gateway) — see integrations.md |
| Payments | `CARD_ONLINE` handled by `DemoPaymentProvider`; order shows **DEMO_PAID**, never PAID. No card data is collected | Implement `PaymentProvider` + signed webhook |
| Delivery | `DemoProgressionJob` advances orders every `step-seconds` (45 s); courier is fictional and flagged `demo` | Staff set status/courier in the admin panel; add a courier-tracking integration |
| Prescription review | Manual by the demo pharmacist in `/admin`. Optional `DARMAN_DEMO_AUTO_REVIEW=true` auto-approves after a delay, labelled "DEMO … NOT a verification by a licensed pharmacist" in the event log and app | Licensed pharmacist review only |
| Accounts | Seeded staff + customer accounts with one shared demo password (env or random, printed once) | Staff are created via `POST /admin/staff` |

Tips: set `DARMAN_DEMO_PASSWORD` to a value you know before the first start (accounts are only seeded when absent); the mobile app shows a
"Demo mode" banner whenever the server reports `demoMode=true`.
