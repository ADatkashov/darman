# 9. Prescription workflow

States: `DRAFT → SUBMITTED → UNDER_REVIEW → APPROVED | REJECTED`; `APPROVED → EXPIRED` (validity 1–90 days, default 30; scheduler + effective-status on read).

| Step | Actor | Rule |
|---|---|---|
| Create + attach files | customer | JPEG/PNG/PDF by content, ≤ 10 MB, ≤ 6 files; edits allowed only in DRAFT |
| Submit | customer | ≥ 1 file; sets SUBMITTED |
| Start review | `PRESCRIPTION_REVIEW` | only from SUBMITTED; not for own prescription |
| Approve | same | only from UNDER_REVIEW; sets `expires_at`; notification sent |
| Reject | same | reason mandatory; notification sent |
| Use | customer at checkout | APPROVED, not expired, owned, not linked to another order (`orders.prescription_id` unique); released when the order is cancelled |

Uploading never approves anything. Staff access to files requires the permission and is audited; a customer's prescriptions are invisible to other customers and to staff without the permission (404).
**Demo review**: manual via `/admin`; optional auto-review (`DARMAN_DEMO_AUTO_REVIEW`) is demo-only, labelled "DEMO … NOT a verification by a licensed pharmacist" and blocked in `prod`.
Not implemented: integration with a state e-prescription registry, per-item prescription matching (a single approved prescription authorises the whole cart), pharmacist licence verification.
