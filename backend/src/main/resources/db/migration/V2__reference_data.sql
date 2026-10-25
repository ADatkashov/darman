-- Reference data required by every environment (no demo content here).
INSERT INTO permissions (code, description) VALUES
    ('CATALOG_WRITE',      'Manage categories, products and manufacturers'),
    ('PHARMACY_WRITE',     'Manage pharmacies and branches'),
    ('INVENTORY_WRITE',    'Manage offers, prices and stock'),
    ('ORDERS_PROCESS',     'View and process customer orders'),
    ('PROMOTIONS_WRITE',   'Manage promotions and promo codes'),
    ('PRESCRIPTION_REVIEW','Review prescription submissions (licensed pharmacist)'),
    ('AUDIT_READ',         'Read audit events'),
    ('STAFF_MANAGE',       'Manage staff accounts and roles');

INSERT INTO roles (code, description) VALUES
    ('CUSTOMER',        'Application customer'),
    ('PHARMACIST',      'Licensed pharmacist: prescription review and order processing'),
    ('OPERATOR',        'Operations: orders, offers and inventory'),
    ('CATALOG_MANAGER', 'Catalog and promotions content manager'),
    ('ADMIN',           'Administrator');

INSERT INTO role_permissions (role_code, permission_code) VALUES
    ('PHARMACIST', 'PRESCRIPTION_REVIEW'),
    ('PHARMACIST', 'ORDERS_PROCESS'),
    ('OPERATOR', 'ORDERS_PROCESS'),
    ('OPERATOR', 'INVENTORY_WRITE'),
    ('CATALOG_MANAGER', 'CATALOG_WRITE'),
    ('CATALOG_MANAGER', 'PROMOTIONS_WRITE'),
    ('ADMIN', 'CATALOG_WRITE'),
    ('ADMIN', 'PHARMACY_WRITE'),
    ('ADMIN', 'INVENTORY_WRITE'),
    ('ADMIN', 'ORDERS_PROCESS'),
    ('ADMIN', 'PROMOTIONS_WRITE'),
    ('ADMIN', 'PRESCRIPTION_REVIEW'),
    ('ADMIN', 'AUDIT_READ'),
    ('ADMIN', 'STAFF_MANAGE');

INSERT INTO categories (slug, name_ru, name_kk, name_en, icon, sort_order) VALUES
    ('pain-relief',    'Обезболивающие',          'Ауырсынуды басатын',        'Pain relief',            'pain',       10),
    ('cold-flu',       'Простуда и грипп',        'Тұмау және суық тию',       'Cold and flu',           'cold',       20),
    ('vitamins',       'Витамины и БАДы',         'Дәрумендер және БАД',       'Vitamins and supplements','vitamins',  30),
    ('digestive',      'Пищеварение',             'Ас қорыту',                 'Digestive health',       'digestive',  40),
    ('first-aid',      'Первая помощь',           'Алғашқы көмек',             'First aid',              'first_aid',  50),
    ('skin-care',      'Уход за кожей',           'Теріні күту',               'Skin care',              'skin',       60),
    ('baby-care',      'Для малышей',             'Нәрестелерге арналған',     'Baby care',              'baby',       70),
    ('personal-care',  'Личная гигиена',          'Жеке гигиена',              'Personal care',          'personal',   80),
    ('medical-devices','Медтехника',              'Медициналық құралдар',      'Medical devices',        'devices',    90),
    ('prescription',   'По рецепту',              'Рецепт бойынша',            'Prescription medicines', 'rx',        100);
