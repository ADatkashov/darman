# 3. Roles and permissions

Authorities in the JWT-authenticated principal = `ROLE_<role>` + permission codes from `role_permissions`. `/api/v1/admin/**` additionally requires a staff role at URL level (customers get 403 before request binding).

| Permission | CUSTOMER | PHARMACIST | OPERATOR | CATALOG_MANAGER | ADMIN |
|---|---|---|---|---|---|
| ORDERS_PROCESS | – | ✔ | ✔ | – | ✔ |
| PRESCRIPTION_REVIEW | – | ✔ | – | – | ✔ |
| INVENTORY_WRITE | – | – | ✔ | – | ✔ |
| CATALOG_WRITE | – | – | – | ✔ | ✔ |
| PROMOTIONS_WRITE | – | – | – | ✔ | ✔ |
| PHARMACY_WRITE | – | – | – | – | ✔ |
| AUDIT_READ | – | – | – | – | ✔ |
| STAFF_MANAGE | – | – | – | – | ✔ |

Rules: staff cannot review their own prescription; admins cannot change their own role/status; disabling a staff user revokes their refresh tokens; customers only reach their own orders, addresses, prescriptions, notifications (others → 404, so existence is not leaked).
Roles are data (`roles`, `permissions`, `role_permissions`) and can be adjusted by migration.
