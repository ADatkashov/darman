# 6. Database and API contracts

**Schema** (`backend/src/main/resources/db/migration`): `V1__schema.sql` (all tables, FKs, checks, indexes incl. trigram search index), `V2__reference_data.sql` (roles, permissions, categories), demo-only `db/demo/V100__demo_catalog.sql`.
Tables: users, roles, permissions, role_permissions, otp_codes, refresh_tokens, addresses, manufacturers, categories, products, product_info, product_images, pharmacies, pharmacy_branches, product_offers, inventory, favorites, carts, cart_items, prescriptions, prescription_files, prescription_review_events, promotions, orders, order_items, order_status_history, deliveries, payment_attempts, payment_webhook_events, notifications, audit_events.
Conventions: UUID keys, `timestamptz` (UTC), money `NUMERIC(12,2)` + currency, optimistic `version` columns, unique `(user_id, idempotency_key)`, unique `orders.prescription_id`, `CHECK (sale_class='RX') = rx_required`.

**API** (`/api/v1`, JSON; OpenAPI at `/v3/api-docs`). Error envelope: `{timestamp,status,code,message,path,correlationId,fieldErrors?}`.

| Area | Endpoints |
|---|---|
| Auth | `POST /auth/register` (202 + OTP challenge) · `/auth/resend-otp` · `/auth/verify-otp` · `/auth/login` · `/auth/refresh` · `/auth/logout` |
| Catalog | `GET /categories` · `/products` · `/products/by-ids` · `/products/{id}` · `/products/{id}/offers` · `/search` · `/search/suggestions` · `/promotions` · `POST /promotions/validate` · `GET /config` |
| Pharmacies | `GET /pharmacies` · `/pharmacies/{id}` · `/pharmacies/{id}/products` · `/delivery/slots?branchId=` |
| Cart | `GET/DELETE /cart` · `POST /cart/items` · `PATCH/DELETE /cart/items/{id}` · public `POST /cart/validate` |
| Prescriptions | `POST /prescriptions` (multipart) · `GET /prescriptions` · `/{id}` · `POST /{id}/submit` · `POST /{id}/files` · `DELETE /{id}/files/{fileId}` · `DELETE /{id}` · `GET /{id}/files/{fileId}` |
| Orders | `POST /orders` (+`Idempotency-Key`) · `GET /orders?scope=` · `/orders/{id}` · `POST /{id}/cancel` · `GET /{id}/receipt` · `POST /{id}/reorder` |
| Profile | `GET/PATCH /users/me` · `POST/DELETE /users/me/deletion-request` · `/users/me/addresses[/{id}]` · `/users/me/favorites[/{productId}]` · `/notifications` |
| Payments | `POST /payments/webhooks/{provider}` (HMAC signed) |
| Admin | `/admin/me, categories, manufacturers, products(+/info), pharmacies(+/branches), offers(+/stock,/enable,/disable), orders(+/status,/courier), promotions, prescriptions(+/start-review,/approve,/reject), audit, staff, roles` |

Order creation errors (stable codes): `CONSENT_REQUIRED, EMPTY_CART, OFFER_UNAVAILABLE, MIXED_BRANCHES, DELIVERY_NOT_AVAILABLE, PICKUP_NOT_AVAILABLE, ADDRESS_REQUIRED, INVALID_DELIVERY_SLOT, PRESCRIPTION_REQUIRED, PRESCRIPTION_NOT_APPROVED, PRESCRIPTION_ALREADY_USED, PROMO_INVALID, PRICE_CHANGED, INSUFFICIENT_STOCK, PAYMENT_PROVIDER_NOT_CONFIGURED, PAYMENT_FAILED`.
