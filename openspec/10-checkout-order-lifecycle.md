# 10. Checkout and order lifecycle

## Placement (`POST /orders`, one DB transaction)
1. Idempotency lookup. 2. Consent required. 3. Lines from request or server cart. 4. **Lock** inventory rows (ordered) → re-check idempotency. 5. Load current offer views; reject missing/inactive/other-branch lines. 6. Fulfillment rules (delivery enabled & address owned & valid slot; pickup enabled). 7. Prescription gate. 8. Totals from server prices: subtotal − promo + delivery fee (0 for pickup or above the branch's free threshold). 9. `expectedTotal` mismatch → 409. 10. Decrement stock, persist order + item snapshots + history + delivery record. 11. Payment: cash → `UNPAID`; card → provider (`PAID`/`PENDING`/`DEMO_PAID`; failure aborts the transaction). 12. Clear server cart, audit, notification.

## Statuses
`PLACED → CONFIRMED → PREPARING →` delivery: `IN_TRANSIT → DELIVERED`; pickup: `READY_FOR_PICKUP → DELIVERED`. `CANCELLED` terminal. Customers may cancel in PLACED/CONFIRMED; staff may cancel until READY_FOR_PICKUP (not IN_TRANSIT). Only the next forward step is accepted from staff (`INVALID_TRANSITION` otherwise). Cash orders become `PAID` at DELIVERED. Cancelling: stock returned, prescription released, `PAID → REFUND_PENDING`, `DEMO_PAID → REFUNDED`.
Courier name/phone are visible only to the order owner while `IN_TRANSIT` (always flagged when demo). Delivery windows are slots generated in `Asia/Almaty` (09–21, 2 h) or an ETA range explicitly labelled as an estimate.
Demo: `DemoProgressionJob` advances statuses every 45 s; real deployments use staff actions.
Payment states: `UNPAID, PENDING, PAID, DEMO_PAID, FAILED, REFUND_PENDING, REFUNDED`; webhook transitions allowed: PENDING/FAILED→PAID, PENDING→FAILED, PAID/REFUND_PENDING→REFUNDED.
