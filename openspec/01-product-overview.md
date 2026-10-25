# 1. Product overview and scope

**DARMAN — Здоровье рядом.** Pharmacy marketplace and delivery app for Kazakhstan; first city Almaty; locales ru (default), kk, en; currency KZT.

## In scope (implemented)
Catalog and search (name, active ingredient, brand, strength/form), product details, multi-pharmacy price comparison, availability, delivery/pickup eligibility,
prescription upload with pharmacist review, cart, checkout (delivery/pickup, slots, cash or demo card), order tracking/history/reorder, favorites, profile & addresses,
notifications inbox, staff web panel (orders, prescriptions, offers/stock, catalog, promotions, audit, staff).

## Explicitly not claimed
- No real pharmacy, licence, product registration or legal availability is verified: the seeded data is fictional (`is_demo`, `license_verified=false`).
- No medical advice, interactions, dosages or contraindications are generated. Product instruction sections exist only when loaded with a cited source.
- Demo payments never count as real payments (`DEMO_PAID`). Demo courier is fictional. No GPS/map.
- Controlled/restricted substances are not seeded. The prescription-only examples are ordinary demo items.

## Out of scope / not implemented
Push/e-mail delivery, real SMS/payment/fiscal integrations, S3 storage adapter, map/GPS tracking, product photos from a licensed source, pharmacy-side mobile app, loyalty, multi-city, refunds workflow beyond status flags.
