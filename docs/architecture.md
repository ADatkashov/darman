# Architecture notes

See `openspec/05-architecture.md` for the normative description. Decisions worth knowing:

- **Modular monolith**: packages under `kz.darman` (identity, users, catalog, pharmacies, inventory, pricing, cart, prescriptions, orders, payments, delivery, promotions, notifications, audit, admin, storage, demo). Services call each other in-process; no per-module microservice.
- **Money** is `NUMERIC(12,2)` with an explicit `currency` (KZT). Order items snapshot name, pharmacy, branch, price and quantity.
- **Stock safety**: checkout takes row locks (`SELECT … FOR UPDATE`, ordered by id) on the inventory rows, re-reads prices, then decrements; all inside one transaction. Verified by a 12-way concurrent test.
- **Idempotency**: `Idempotency-Key` header, unique per `(user,key)`; replays return the original order (HTTP 200), lost insert races roll back (including stock) and resolve to the winner.
- **Cart**: the mobile cart is device-local (works offline/for guests) and re-validated by the public `POST /cart/validate`; the server-side cart API (`/cart`) exists for other clients and `POST /orders` can consume it when no items are sent.
- **One branch per order/cart**: an order is fulfilled by a single pharmacy branch; the app asks before replacing a cart from another pharmacy.
- **Mobile persistence**: SharedPreferences JSON instead of Drift (the data is a few small lists). Models are hand-written instead of Freezed/json_serializable to avoid a code-generation toolchain for ~30 small DTOs; revisit if models grow.
- **Errors**: backend returns `{status, code, message, path, correlationId, fieldErrors}`; the app maps `code` to localized text and never shows raw server messages.
- **Time**: UTC everywhere in storage/API; the app formats in the device zone, delivery slots are generated in `Asia/Almaty`.
