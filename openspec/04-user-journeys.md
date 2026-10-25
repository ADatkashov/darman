# 4. Core user journeys

1. **Guest browse → order**: open app (onboarding skippable) → home shelves → search "ибупрофен" → product → compare offers → add to cart → checkout (login/OTP when prompted, returns to checkout) → address, slot, payment → confirmation → tracking.
2. **Prescription medicine**: product shows "По рецепту" → upload photo/PDF → submit → pharmacist reviews in `/admin` (start review → approve/reject with reason) → customer sees status/notification → checkout selects the approved prescription → prescription becomes single-use.
3. **Repeat order**: order history → "Повторить" → items re-validated (price/stock/availability) → added to cart with a summary.
4. **Cancel**: allowed while PLACED/CONFIRMED; otherwise the app explains it cannot be cancelled.
5. **Staff**: login at `/admin` → orders (advance status, assign courier, cancel) · prescriptions · offers/stock · promos · audit · staff roles.
6. **Account**: edit profile, language/theme, addresses, notification preferences, request/cancel account deletion, sign out.
