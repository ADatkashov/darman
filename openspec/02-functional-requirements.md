# 2. Functional requirements (as built)

| ID | Requirement | Where |
|---|---|---|
| F-CAT-1 | Browse 10 localized categories with product counts | `GET /categories` |
| F-CAT-2 | Search by name/ingredient/brand/strength/form; every token must match (no unrelated substitutes); wildcard characters are literal | `GET /search`, `/products` |
| F-CAT-3 | Filters: category, manufacturer, in-stock, price range, Rx, on-sale; sorts: relevance, price asc/desc, popularity; pagination (max 50) | same |
| F-CAT-4 | Suggestions (product/brand/ingredient), recent searches (device) | `/search/suggestions` |
| F-PRD-1 | Product details with sourced information sections; absence is stated explicitly | `GET /products/{id}` |
| F-PRD-2 | Offers per branch: price, availability (IN/LOW/OUT), pickup, delivery fee & free threshold, **estimated** ETA, updated-at | `/products/{id}/offers` |
| F-RX-1 | Upload up to 6 JPEG/PNG/PDF files ≤ 10 MB (content-sniffed), submit, track status and review events | `/prescriptions` |
| F-RX-2 | Prescription-only items can only be ordered with an APPROVED, unexpired, unused prescription of the same user | `POST /orders` |
| F-CART-1 | Device cart persisted; one pharmacy branch per cart; quantity ≤ min(99, stock); price/stock changes explained | mobile + `POST /cart/validate` |
| F-CHK-1 | Server re-validates stock, prices, rules, promo, slot; idempotent; `expectedTotal` mismatch → 409 `PRICE_CHANGED` | `POST /orders` |
| F-ORD-1 | Timeline PLACED→CONFIRMED→PREPARING→(READY_FOR_PICKUP \| IN_TRANSIT)→DELIVERED, or CANCELLED | `orders` |
| F-ORD-2 | Customer cancel only in PLACED/CONFIRMED; stock restored; prescription released | `POST /orders/{id}/cancel` |
| F-ORD-3 | Reorder re-validates availability/prices/rx/eligibility | `POST /orders/{id}/reorder` |
| F-USR-1 | Registration with OTP, login, refresh rotation with reuse detection, logout, profile, addresses, favorites, notification prefs, deletion request | `/auth`, `/users/me` |
| F-ADM-1 | Staff API and panel with permission-gated operations and audit trail | `/admin/**`, `/admin` |
| F-I18N-1 | ru/kk/en for all UI strings, plurals, KZT format, persisted locale | ARB files |
