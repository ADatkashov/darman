-- DEMO DATA ONLY (profile "demo"). Every product, brand, manufacturer and pharmacy below is FICTIONAL.
-- No usage, dosage, contraindication or interaction text is invented: such sections stay empty until
-- official, sourced information is loaded into product_info.

INSERT INTO manufacturers (name, country) VALUES
    ('Demo Pharma Almaty (вымышленный)', 'Казахстан'),
    ('Nordic Demo Labs (вымышленный)',   'Финляндия'),
    ('GreenLeaf Demo (вымышленный)',     'Казахстан'),
    ('Sana Demo Health (вымышленный)',   'Казахстан'),
    ('Alpine Demo Care (вымышленный)',   'Швейцария');

CREATE TEMP TABLE _demo_seed (
    slug text, name text, brand text, ingr text, strength text, form text, pack text,
    cat text, rx boolean, mfr text, pop int, price numeric
) ON COMMIT DROP;

INSERT INTO _demo_seed VALUES
 -- pain relief
 ('paradem-500-20',   'ПараДем 500 мг, 20 таблеток',        'ПараДем',   'Парацетамол (paracetamol)', '500 мг', 'таблетки',  '20 шт',  'pain-relief', false, 'Demo Pharma Almaty (вымышленный)', 98, 490),
 ('ibudem-200-20',    'ИбуДем 200 мг, 20 таблеток',          'ИбуДем',    'Ибупрофен (ibuprofen)',     '200 мг', 'таблетки',  '20 шт',  'pain-relief', false, 'Demo Pharma Almaty (вымышленный)', 97, 690),
 ('ibudem-400-10',    'ИбуДем 400 мг, 10 таблеток',          'ИбуДем',    'Ибупрофен (ibuprofen)',     '400 мг', 'таблетки',  '10 шт',  'pain-relief', false, 'Demo Pharma Almaty (вымышленный)', 80, 990),
 ('ibudem-gel-50',    'ИбуДем гель 5%, 50 г',                'ИбуДем',    'Ибупрофен (ibuprofen)',     '5%',     'гель',      '50 г',   'pain-relief', false, 'Nordic Demo Labs (вымышленный)',  70, 1890),
 ('paradem-kids-syr', 'ПараДем детский сироп, 100 мл',       'ПараДем',   'Парацетамол (paracetamol)', '120 мг/5 мл', 'сироп',   '100 мл', 'pain-relief', false, 'Sana Demo Health (вымышленный)',  75, 1490),
 -- cold & flu
 ('throatdem-24',     'ГорлоДем леденцы, 24 шт',             'ГорлоДем',  null,                        null,     'леденцы',   '24 шт',  'cold-flu', false, 'GreenLeaf Demo (вымышленный)',       88, 1290),
 ('nasaldem-saline',  'НазалДем солевой раствор для носа, 15 мл', 'НазалДем', 'Натрия хлорид (sodium chloride)', '0,9%', 'капли назальные', '15 мл', 'cold-flu', false, 'Alpine Demo Care (вымышленный)', 85, 790),
 ('throatdem-spray',  'ГорлоДем спрей, 30 мл',               'ГорлоДем',  null,                        null,     'спрей',     '30 мл',  'cold-flu', false, 'GreenLeaf Demo (вымышленный)',       72, 1790),
 ('coldmix-sachet-10','КолдМикс порошок для раствора, 10 саше', 'КолдМикс', null,                       null,     'порошок',   '10 саше','cold-flu', false, 'Nordic Demo Labs (вымышленный)',     90, 2490),
 ('honeydem-tea-20',  'МедДем травяной чай, 20 пакетиков',   'МедДем',    null,                        null,     'чай',       '20 пак.','cold-flu', false, 'GreenLeaf Demo (вымышленный)',       55, 1190),
 -- vitamins & supplements
 ('vitc-500-30',      'Витамин C 500 мг, 30 таблеток (БАД)', 'ВитаДем',   'Аскорбиновая кислота (ascorbic acid)', '500 мг', 'таблетки', '30 шт', 'vitamins', false, 'Sana Demo Health (вымышленный)', 96, 1590),
 ('vitd3-2000-60',    'Витамин D3 2000 МЕ, 60 капсул (БАД)', 'ВитаДем',   'Колекальциферол (cholecalciferol)', '2000 МЕ', 'капсулы', '60 шт', 'vitamins', false, 'Nordic Demo Labs (вымышленный)', 94, 3290),
 ('magnesium-b6-50',  'Магний B6, 50 таблеток (БАД)',        'ВитаДем',   'Магний, пиридоксин (magnesium, pyridoxine)', null, 'таблетки', '50 шт', 'vitamins', false, 'Alpine Demo Care (вымышленный)', 92, 2190),
 ('omega3-60',        'Омега-3, 60 капсул (БАД)',            'ОмегаДем',  'Омега-3 (omega-3)',         '1000 мг','капсулы',   '60 шт',  'vitamins', false, 'Nordic Demo Labs (вымышленный)',     78, 4590),
 ('zinc-25-30',       'Цинк 25 мг, 30 таблеток (БАД)',       'ВитаДем',   'Цинк (zinc)',               '25 мг',  'таблетки',  '30 шт',  'vitamins', false, 'Sana Demo Health (вымышленный)',     60, 1390),
 -- digestive
 ('charcoal-250-10',  'Активированный уголь 250 мг, 10 таблеток', 'ЭнтеросДем', 'Активированный уголь (activated charcoal)', '250 мг', 'таблетки', '10 шт', 'digestive', false, 'Demo Pharma Almaty (вымышленный)', 86, 190),
 ('probio-20',        'ПроБиоДем, 20 капсул (БАД)',          'ПроБиоДем', null,                        null,     'капсулы',   '20 шт',  'digestive', false, 'Alpine Demo Care (вымышленный)',    68, 3890),
 ('rehydrodem-10',    'РегидроДем порошок для раствора, 10 пакетов', 'РегидроДем', null,                null,     'порошок',   '10 пак.','digestive', false, 'Sana Demo Health (вымышленный)',    74, 1990),
 ('fiberdem-200',     'ФайберДем клетчатка, 200 г (БАД)',    'ФайберДем', null,                        null,     'порошок',   '200 г',  'digestive', false, 'GreenLeaf Demo (вымышленный)',      45, 2290),
 -- first aid
 ('plaster-20',       'Пластырь бактерицидный, 20 шт',       'АптекаДем', null,                        null,     'пластырь',  '20 шт',  'first-aid', false, 'Demo Pharma Almaty (вымышленный)', 91, 390),
 ('bandage-5x10',     'Бинт стерильный 5 м × 10 см',          'АптекаДем', null,                        null,     'бинт',      '1 шт',   'first-aid', false, 'Demo Pharma Almaty (вымышленный)', 66, 290),
 ('peroxide-3-100',   'Перекись водорода 3%, 100 мл',         'АптекаДем', 'Водорода пероксид (hydrogen peroxide)', '3%', 'раствор наружный', '100 мл', 'first-aid', false, 'Demo Pharma Almaty (вымышленный)', 71, 240),
 ('chlorhex-100',     'Хлоргексидин 0,05%, 100 мл',           'АптекаДем', 'Хлоргексидин (chlorhexidine)', '0,05%', 'раствор наружный', '100 мл', 'first-aid', false, 'Demo Pharma Almaty (вымышленный)', 65, 420),
 ('cotton-100',       'Вата медицинская гигиеническая, 100 г', 'АптекаДем', null,                       null,     'вата',      '100 г',  'first-aid', false, 'Demo Pharma Almaty (вымышленный)', 40, 450),
 -- skin care
 ('cream-moist-50',   'Крем увлажняющий для лица, 50 мл',     'ДермаДем',  null,                        null,     'крем',      '50 мл',  'skin-care', false, 'Alpine Demo Care (вымышленный)',    82, 3490),
 ('sun-spf50-50',     'Солнцезащитный крем SPF 50, 50 мл',    'ДермаДем',  null,                        'SPF 50', 'крем',      '50 мл',  'skin-care', false, 'Alpine Demo Care (вымышленный)',    63, 4290),
 ('face-wash-150',    'Гель для умывания, 150 мл',            'ДермаДем',  null,                        null,     'гель',      '150 мл', 'skin-care', false, 'GreenLeaf Demo (вымышленный)',      58, 2790),
 -- baby care
 ('diapers-3-40',     'Подгузники ТихоДем, размер 3, 40 шт',  'ТихоДем',   null,                        null,     'подгузники','40 шт',  'baby-care', false, 'Nordic Demo Labs (вымышленный)',    89, 6490),
 ('baby-wipes-72',    'Влажные салфетки детские, 72 шт',      'ТихоДем',   null,                        null,     'салфетки',  '72 шт',  'baby-care', false, 'Nordic Demo Labs (вымышленный)',    84, 1190),
 ('baby-cream-100',   'Детский крем под подгузник, 100 г',    'ТихоДем',   null,                        null,     'крем',      '100 г',  'baby-care', false, 'GreenLeaf Demo (вымышленный)',      61, 1890),
 ('pacifier-0',       'Пустышка силиконовая 0+',              'ТихоДем',   null,                        null,     'пустышка',  '2 шт',   'baby-care', false, 'Alpine Demo Care (вымышленный)',    35, 1290),
 -- personal care
 ('toothpaste-100',   'Зубная паста, 100 мл',                 'СмайлДем',  null,                        null,     'паста',     '100 мл', 'personal-care', false, 'GreenLeaf Demo (вымышленный)',  77, 990),
 ('sanitizer-100',    'Антисептик для рук, 100 мл',           'СмайлДем',  null,                        null,     'гель',      '100 мл', 'personal-care', false, 'Demo Pharma Almaty (вымышленный)', 69, 590),
 ('shampoo-250',      'Шампунь, 250 мл',                      'СмайлДем',  null,                        null,     'шампунь',   '250 мл', 'personal-care', false, 'GreenLeaf Demo (вымышленный)',  50, 1890),
 ('masks-50',         'Маски медицинские одноразовые, 50 шт', 'АптекаДем', null,                        null,     'маски',     '50 шт',  'personal-care', false, 'Demo Pharma Almaty (вымышленный)', 73, 1290),
 -- medical devices
 ('thermo-digital',   'Термометр электронный',                'МедТехДем', null,                        null,     'прибор',    '1 шт',   'medical-devices', false, 'Sana Demo Health (вымышленный)', 87, 2490),
 ('tonometer-auto',   'Тонометр автоматический на плечо',     'МедТехДем', null,                        null,     'прибор',    '1 шт',   'medical-devices', false, 'Sana Demo Health (вымышленный)', 83, 17900),
 ('oximeter-fingertip','Пульсоксиметр на палец',               'МедТехДем', null,                        null,     'прибор',    '1 шт',   'medical-devices', false, 'Sana Demo Health (вымышленный)', 76, 8900),
 ('inhaler-compressor','Ингалятор компрессорный',              'МедТехДем', null,                        null,     'прибор',    '1 шт',   'medical-devices', false, 'Alpine Demo Care (вымышленный)', 52, 21900),
 -- prescription-only demo examples (non-controlled; require a reviewed prescription)
 ('amoxidem-500-16',  'АмоксиДем 500 мг, 16 капсул (по рецепту)',  'АмоксиДем', 'Амоксициллин (amoxicillin)',  '500 мг', 'капсулы', '16 шт', 'prescription', true, 'Demo Pharma Almaty (вымышленный)', 64, 2890),
 ('amlodem-5-30',     'АмлоДем 5 мг, 30 таблеток (по рецепту)',    'АмлоДем',   'Амлодипин (amlodipine)',      '5 мг',   'таблетки','30 шт', 'prescription', true, 'Sana Demo Health (вымышленный)',     57, 2190),
 ('losardem-50-30',   'ЛозарДем 50 мг, 30 таблеток (по рецепту)',  'ЛозарДем',  'Лозартан (losartan)',         '50 мг',  'таблетки','30 шт', 'prescription', true, 'Sana Demo Health (вымышленный)',     54, 3190),
 ('omepradem-20-14',  'ОмепраДем 20 мг, 14 капсул (по рецепту)',   'ОмепраДем', 'Омепразол (omeprazole)',      '20 мг',  'капсулы', '14 шт', 'prescription', true, 'Nordic Demo Labs (вымышленный)',     59, 1890),
 ('metfordem-500-60', 'МетфорДем 500 мг, 60 таблеток (по рецепту)','МетфорДем', 'Метформин (metformin)',        '500 мг', 'таблетки','60 шт', 'prescription', true, 'Demo Pharma Almaty (вымышленный)',   48, 2490);

INSERT INTO products (slug, name, brand, active_ingredient, strength, dosage_form, package_size,
                      manufacturer_id, category_id, sale_class, rx_required,
                      description_ru, description_kk, description_en, is_demo, popularity, search_text)
SELECT s.slug, s.name, s.brand, s.ingr, s.strength, s.form, s.pack,
       m.id, c.id,
       CASE WHEN s.rx THEN 'RX' ELSE 'OTC' END, s.rx,
       'Демонстрационная позиция каталога (вымышленный товар). Официальная инструкция производителя не загружена — перед применением изучите инструкцию в упаковке и проконсультируйтесь со специалистом.',
       'Каталогтың демонстрациялық позициясы (ойдан шығарылған тауар). Өндірушінің ресми нұсқаулығы жүктелмеген — қолданар алдында қаптамадағы нұсқаулықты оқып, маманмен кеңесіңіз.',
       'Demo catalog entry (fictional product). The official manufacturer instructions are not loaded — read the package leaflet and consult a professional before use.',
       true, s.pop,
       lower(concat_ws(' ', s.name, s.brand, s.ingr, s.strength, s.form, s.pack, m.name, c.name_ru, c.name_kk, c.name_en))
FROM _demo_seed s
JOIN categories c ON c.slug = s.cat
LEFT JOIN manufacturers m ON m.name = s.mfr;

INSERT INTO product_images (product_id, url, sort_order)
SELECT p.id, 'placeholder:' || c.slug, 0
FROM products p JOIN categories c ON c.id = p.category_id WHERE p.is_demo;

-- Fictional pharmacies. license_verified stays FALSE: no licence has been verified for demo data.
INSERT INTO pharmacies (name, description, is_demo, license_verified) VALUES
    ('Аптека «Тау» (демо)',        'Вымышленная сеть для демонстрации приложения', true, false),
    ('Аптека «Алатау Фарм» (демо)','Вымышленная сеть для демонстрации приложения', true, false),
    ('Аптека «Нұр» (демо)',        'Вымышленная сеть для демонстрации приложения', true, false);

INSERT INTO pharmacy_branches (pharmacy_id, name, city, address, latitude, longitude, phone, opening_hours,
                               pickup_available, delivery_available, delivery_fee, free_delivery_from, delivery_eta_min, delivery_eta_max)
SELECT p.id, v.name, 'Алматы', v.addr, v.lat, v.lon, v.phone, v.hours, v.pickup, v.deliv, v.fee, v.free_from, v.eta_min, v.eta_max
FROM (VALUES
    ('Аптека «Тау» (демо)',         'Тау — Достык',      'пр. Достык, 100 (демо-адрес)',      43.2380, 76.9570, '+7 700 000 00 01', '08:00–22:00', true, true,  500, 8000, 40, 70),
    ('Аптека «Тау» (демо)',         'Тау — Самал',       'мкр. Самал-2, 55 (демо-адрес)',     43.2330, 76.9560, '+7 700 000 00 02', '09:00–21:00', true, true,  600, 8000, 45, 80),
    ('Аптека «Алатау Фарм» (демо)', 'Алатау Фарм — Абая','пр. Абая, 150 (демо-адрес)',        43.2410, 76.9150, '+7 700 000 00 03', '08:00–23:00', true, true,  500, 10000, 35, 60),
    ('Аптека «Алатау Фарм» (демо)', 'Алатау Фарм — Сатпаева','ул. Сатпаева, 30 (демо-адрес)', 43.2350, 76.9290, '+7 700 000 00 04', '09:00–20:00', true, false, 0,   null, null, null),
    ('Аптека «Нұр» (демо)',         'Нұр — Алмалы',      'ул. Толе би, 200 (демо-адрес)',     43.2500, 76.9420, '+7 700 000 00 05', '08:00–22:00', true, true,  700, 12000, 50, 90),
    ('Аптека «Нұр» (демо)',         'Нұр — Аэропорт',    'ул. Майлина, 10 (демо-адрес)',      43.3220, 76.9990, '+7 700 000 00 06', '24 часа',     true, false, 0,   null, null, null)
) AS v(pharm, name, addr, lat, lon, phone, hours, pickup, deliv, fee, free_from, eta_min, eta_max)
JOIN pharmacies p ON p.name = v.pharm;

-- Deterministic pseudo-random offers: the first two branches carry every product with stock; the rest ~55%.
CREATE TEMP TABLE _demo_offers ON COMMIT DROP AS
SELECT p.id AS product_id, b.id AS branch_id, s.price AS base_price,
       (('x' || substr(md5(p.slug || b.name), 1, 7))::bit(28)::int) AS h,
       (b.name IN ('Тау — Достык', 'Алатау Фарм — Абая')) AS forced
FROM products p
JOIN _demo_seed s ON s.slug = p.slug
CROSS JOIN pharmacy_branches b;

INSERT INTO product_offers (product_id, branch_id, price, old_price)
SELECT product_id, branch_id,
       round(base_price * (0.93 + (h % 15) / 100.0) / 10) * 10,
       CASE WHEN h % 6 = 0 THEN round(base_price * 1.2 / 10) * 10 ELSE NULL END
FROM _demo_offers
WHERE forced OR h % 100 < 55;

INSERT INTO inventory (offer_id, quantity)
SELECT o.id,
       CASE WHEN d.forced THEN 8 + d.h % 40
            WHEN d.h % 9 = 0 THEN 0
            ELSE 3 + d.h % 35 END
FROM product_offers o
JOIN _demo_offers d ON d.product_id = o.product_id AND d.branch_id = o.branch_id;

INSERT INTO promotions (kind, code, title_ru, title_kk, title_en, subtitle_ru, subtitle_kk, subtitle_en, discount_percent, min_order_amount, sort_order) VALUES
    ('BANNER', NULL, 'Забота о здоровье каждый день', 'Денсаулыққа күн сайын қамқорлық', 'Everyday health care',
     'Скидки на витамины и товары для ухода (демо)', 'Дәрумендер мен күтім тауарларына жеңілдіктер (демо)', 'Discounts on vitamins and care products (demo)', NULL, NULL, 1),
    ('BANNER', NULL, 'Доставка из аптек Алматы', 'Алматы дәріханаларынан жеткізу', 'Delivery from Almaty pharmacies',
     'Бесплатная доставка при заказе от суммы, указанной в аптеке', 'Дәріхана белгілеген соммадан тегін жеткізу', 'Free delivery above the threshold set by the pharmacy', NULL, NULL, 2),
    ('PROMO_CODE', 'WELCOME10', 'Скидка 10% на первый заказ', 'Алғашқы тапсырысқа 10% жеңілдік', '10% off your first order',
     'Промокод WELCOME10, заказ от 3000 ₸ (демо)', 'WELCOME10 промокоды, 3000 ₸ бастап (демо)', 'Promo code WELCOME10, orders from 3000 KZT (demo)', 10, 3000, 3);
