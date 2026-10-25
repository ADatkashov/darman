-- DARMAN core schema. All timestamps are stored in UTC (timestamptz). Money is NUMERIC(12,2) with explicit currency.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ───────────────────────── identity ─────────────────────────
CREATE TABLE permissions (
    code        VARCHAR(64) PRIMARY KEY,
    description VARCHAR(255) NOT NULL
);

CREATE TABLE roles (
    code        VARCHAR(32) PRIMARY KEY,
    description VARCHAR(255) NOT NULL
);

CREATE TABLE role_permissions (
    role_code       VARCHAR(32) NOT NULL REFERENCES roles (code) ON DELETE CASCADE,
    permission_code VARCHAR(64) NOT NULL REFERENCES permissions (code) ON DELETE CASCADE,
    PRIMARY KEY (role_code, permission_code)
);

CREATE TABLE users (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone                 VARCHAR(16)  NOT NULL UNIQUE,
    full_name             VARCHAR(160),
    email                 VARCHAR(160),
    password_hash         VARCHAR(100) NOT NULL,
    role_code             VARCHAR(32)  NOT NULL DEFAULT 'CUSTOMER' REFERENCES roles (code),
    locale                VARCHAR(5)   NOT NULL DEFAULT 'ru',
    status                VARCHAR(32)  NOT NULL DEFAULT 'PENDING_VERIFICATION',
    phone_verified_at     TIMESTAMPTZ,
    notify_orders         BOOLEAN      NOT NULL DEFAULT TRUE,
    notify_promotions     BOOLEAN      NOT NULL DEFAULT FALSE,
    notify_prescriptions  BOOLEAN      NOT NULL DEFAULT TRUE,
    privacy_consent_at    TIMESTAMPTZ,
    deletion_requested_at TIMESTAMPTZ,
    created_at            TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ  NOT NULL DEFAULT now(),
    version               BIGINT       NOT NULL DEFAULT 0
);

CREATE TABLE otp_codes (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone       VARCHAR(16) NOT NULL,
    code_hash   VARCHAR(64) NOT NULL,
    expires_at  TIMESTAMPTZ NOT NULL,
    attempts    INTEGER     NOT NULL DEFAULT 0,
    consumed_at TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_otp_phone_created ON otp_codes (phone, created_at DESC);

CREATE TABLE refresh_tokens (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    token_hash  VARCHAR(64) NOT NULL UNIQUE,
    family_id   UUID        NOT NULL,
    expires_at  TIMESTAMPTZ NOT NULL,
    revoked_at  TIMESTAMPTZ,
    replaced_by UUID,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_refresh_user ON refresh_tokens (user_id);
CREATE INDEX idx_refresh_family ON refresh_tokens (family_id);

CREATE TABLE addresses (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    label      VARCHAR(60),
    city       VARCHAR(80)  NOT NULL,
    street     VARCHAR(160) NOT NULL,
    house      VARCHAR(20)  NOT NULL,
    apartment  VARCHAR(20),
    entrance   VARCHAR(20),
    floor      VARCHAR(20),
    comment    VARCHAR(255),
    latitude   DOUBLE PRECISION,
    longitude  DOUBLE PRECISION,
    is_default BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX idx_addresses_user ON addresses (user_id);

-- ───────────────────────── catalog ─────────────────────────
CREATE TABLE manufacturers (
    id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name    VARCHAR(160) NOT NULL UNIQUE,
    country VARCHAR(80)
);

CREATE TABLE categories (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug       VARCHAR(80)  NOT NULL UNIQUE,
    name_ru    VARCHAR(120) NOT NULL,
    name_kk    VARCHAR(120) NOT NULL,
    name_en    VARCHAR(120) NOT NULL,
    icon       VARCHAR(48)  NOT NULL DEFAULT 'medication',
    sort_order INTEGER      NOT NULL DEFAULT 0,
    parent_id  UUID REFERENCES categories (id) ON DELETE SET NULL,
    active     BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE products (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug              VARCHAR(160) NOT NULL UNIQUE,
    name              VARCHAR(200) NOT NULL,
    brand             VARCHAR(120),
    active_ingredient VARCHAR(200),
    strength          VARCHAR(80),
    dosage_form       VARCHAR(80),
    package_size      VARCHAR(80),
    manufacturer_id   UUID REFERENCES manufacturers (id) ON DELETE SET NULL,
    category_id       UUID         NOT NULL REFERENCES categories (id),
    sale_class        VARCHAR(16)  NOT NULL DEFAULT 'OTC',
    rx_required       BOOLEAN      NOT NULL DEFAULT FALSE,
    description_ru    TEXT,
    description_kk    TEXT,
    description_en    TEXT,
    is_demo           BOOLEAN      NOT NULL DEFAULT FALSE,
    active            BOOLEAN      NOT NULL DEFAULT TRUE,
    popularity        INTEGER      NOT NULL DEFAULT 0,
    search_text       TEXT         NOT NULL,
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ  NOT NULL DEFAULT now(),
    version           BIGINT       NOT NULL DEFAULT 0,
    CONSTRAINT chk_rx_sale_class CHECK ((sale_class = 'RX') = rx_required)
);
CREATE INDEX idx_products_category ON products (category_id) WHERE active;
CREATE INDEX idx_products_popularity ON products (popularity DESC);
CREATE INDEX idx_products_search_trgm ON products USING gin (search_text gin_trgm_ops);

-- Official product information (usage, storage, warnings). Only rows with a stated source are shown to users.
CREATE TABLE product_info (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID         NOT NULL REFERENCES products (id) ON DELETE CASCADE,
    section    VARCHAR(24)  NOT NULL,
    locale     VARCHAR(5)   NOT NULL,
    body       TEXT         NOT NULL,
    source     VARCHAR(255) NOT NULL,
    verified   BOOLEAN      NOT NULL DEFAULT FALSE,
    UNIQUE (product_id, section, locale)
);

CREATE TABLE product_images (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID         NOT NULL REFERENCES products (id) ON DELETE CASCADE,
    url        VARCHAR(500) NOT NULL,
    sort_order INTEGER      NOT NULL DEFAULT 0
);
CREATE INDEX idx_product_images_product ON product_images (product_id, sort_order);

-- ───────────────────────── pharmacies & offers ─────────────────────────
CREATE TABLE pharmacies (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name             VARCHAR(160) NOT NULL,
    description      VARCHAR(500),
    is_demo          BOOLEAN      NOT NULL DEFAULT FALSE,
    license_verified BOOLEAN      NOT NULL DEFAULT FALSE,
    active           BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE pharmacy_branches (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pharmacy_id        UUID           NOT NULL REFERENCES pharmacies (id) ON DELETE CASCADE,
    name               VARCHAR(160)   NOT NULL,
    city               VARCHAR(80)    NOT NULL,
    address            VARCHAR(255)   NOT NULL,
    latitude           DOUBLE PRECISION,
    longitude          DOUBLE PRECISION,
    phone              VARCHAR(32),
    opening_hours      VARCHAR(120),
    pickup_available   BOOLEAN        NOT NULL DEFAULT TRUE,
    delivery_available BOOLEAN        NOT NULL DEFAULT FALSE,
    delivery_fee       NUMERIC(12, 2) NOT NULL DEFAULT 0,
    free_delivery_from NUMERIC(12, 2),
    delivery_eta_min   INTEGER,
    delivery_eta_max   INTEGER,
    active             BOOLEAN        NOT NULL DEFAULT TRUE
);
CREATE INDEX idx_branches_pharmacy ON pharmacy_branches (pharmacy_id);

CREATE TABLE product_offers (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID           NOT NULL REFERENCES products (id) ON DELETE CASCADE,
    branch_id  UUID           NOT NULL REFERENCES pharmacy_branches (id) ON DELETE CASCADE,
    price      NUMERIC(12, 2) NOT NULL CHECK (price >= 0),
    old_price  NUMERIC(12, 2),
    currency   VARCHAR(3)     NOT NULL DEFAULT 'KZT',
    active     BOOLEAN        NOT NULL DEFAULT TRUE,
    updated_at TIMESTAMPTZ    NOT NULL DEFAULT now(),
    version    BIGINT         NOT NULL DEFAULT 0,
    UNIQUE (product_id, branch_id)
);
CREATE INDEX idx_offers_branch ON product_offers (branch_id);

CREATE TABLE inventory (
    offer_id   UUID PRIMARY KEY REFERENCES product_offers (id) ON DELETE CASCADE,
    quantity   INTEGER     NOT NULL CHECK (quantity >= 0),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    version    BIGINT      NOT NULL DEFAULT 0
);

CREATE TABLE favorites (
    user_id    UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    product_id UUID        NOT NULL REFERENCES products (id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, product_id)
);

-- ───────────────────────── cart ─────────────────────────
CREATE TABLE carts (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID        NOT NULL UNIQUE REFERENCES users (id) ON DELETE CASCADE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    version    BIGINT      NOT NULL DEFAULT 0
);

CREATE TABLE cart_items (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id        UUID           NOT NULL REFERENCES carts (id) ON DELETE CASCADE,
    offer_id       UUID           NOT NULL REFERENCES product_offers (id) ON DELETE CASCADE,
    quantity       INTEGER        NOT NULL CHECK (quantity BETWEEN 1 AND 99),
    price_snapshot NUMERIC(12, 2) NOT NULL,
    added_at       TIMESTAMPTZ    NOT NULL DEFAULT now(),
    UNIQUE (cart_id, offer_id)
);

-- ───────────────────────── prescriptions ─────────────────────────
CREATE TABLE prescriptions (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id          UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    status           VARCHAR(24) NOT NULL DEFAULT 'DRAFT',
    note             VARCHAR(500),
    rejection_reason VARCHAR(500),
    reviewed_by      UUID REFERENCES users (id) ON DELETE SET NULL,
    reviewed_at      TIMESTAMPTZ,
    submitted_at     TIMESTAMPTZ,
    expires_at       TIMESTAMPTZ,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    version          BIGINT      NOT NULL DEFAULT 0
);
CREATE INDEX idx_prescriptions_user ON prescriptions (user_id, created_at DESC);
CREATE INDEX idx_prescriptions_status ON prescriptions (status, submitted_at);

-- Prescription files are referenced by private storage key only; they are never exposed via public URLs.
CREATE TABLE prescription_files (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prescription_id UUID         NOT NULL REFERENCES prescriptions (id) ON DELETE CASCADE,
    storage_key     VARCHAR(200) NOT NULL UNIQUE,
    original_name   VARCHAR(255) NOT NULL,
    mime_type       VARCHAR(80)  NOT NULL,
    size_bytes      BIGINT       NOT NULL,
    sha256          VARCHAR(64)  NOT NULL,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX idx_prescription_files_rx ON prescription_files (prescription_id);

CREATE TABLE prescription_review_events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prescription_id UUID        NOT NULL REFERENCES prescriptions (id) ON DELETE CASCADE,
    actor_id        UUID REFERENCES users (id) ON DELETE SET NULL,
    event_type      VARCHAR(32) NOT NULL,
    from_status     VARCHAR(24),
    to_status       VARCHAR(24),
    comment         VARCHAR(500),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_rx_events_rx ON prescription_review_events (prescription_id, created_at);

-- ───────────────────────── orders ─────────────────────────
CREATE TABLE promotions (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kind             VARCHAR(16)  NOT NULL,
    code             VARCHAR(40) UNIQUE,
    title_ru         VARCHAR(160) NOT NULL,
    title_kk         VARCHAR(160) NOT NULL,
    title_en         VARCHAR(160) NOT NULL,
    subtitle_ru      VARCHAR(255),
    subtitle_kk      VARCHAR(255),
    subtitle_en      VARCHAR(255),
    discount_percent INTEGER CHECK (discount_percent BETWEEN 1 AND 90),
    min_order_amount NUMERIC(12, 2),
    starts_at        TIMESTAMPTZ,
    ends_at          TIMESTAMPTZ,
    sort_order       INTEGER      NOT NULL DEFAULT 0,
    active           BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE orders (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    number               VARCHAR(24)    NOT NULL UNIQUE,
    user_id              UUID           NOT NULL REFERENCES users (id),
    branch_id            UUID           NOT NULL REFERENCES pharmacy_branches (id),
    status               VARCHAR(24)    NOT NULL,
    fulfillment          VARCHAR(16)    NOT NULL,
    currency             VARCHAR(3)     NOT NULL DEFAULT 'KZT',
    subtotal             NUMERIC(12, 2) NOT NULL,
    delivery_fee         NUMERIC(12, 2) NOT NULL DEFAULT 0,
    discount             NUMERIC(12, 2) NOT NULL DEFAULT 0,
    total                NUMERIC(12, 2) NOT NULL,
    promo_code           VARCHAR(40),
    contact_name         VARCHAR(160)   NOT NULL,
    contact_phone        VARCHAR(16)    NOT NULL,
    delivery_address     VARCHAR(500),
    delivery_notes       VARCHAR(500),
    slot_start           TIMESTAMPTZ,
    slot_end             TIMESTAMPTZ,
    payment_method       VARCHAR(24)    NOT NULL,
    payment_status       VARCHAR(24)    NOT NULL,
    prescription_id      UUID UNIQUE REFERENCES prescriptions (id),
    idempotency_key      VARCHAR(80),
    consent_accepted_at  TIMESTAMPTZ    NOT NULL,
    created_at           TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ    NOT NULL DEFAULT now(),
    version              BIGINT         NOT NULL DEFAULT 0
);
CREATE UNIQUE INDEX uq_orders_idempotency ON orders (user_id, idempotency_key) WHERE idempotency_key IS NOT NULL;
CREATE INDEX idx_orders_user ON orders (user_id, created_at DESC);
CREATE INDEX idx_orders_status ON orders (status, created_at);

CREATE TABLE order_items (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id         UUID           NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
    product_id       UUID           NOT NULL REFERENCES products (id),
    offer_id         UUID           NOT NULL REFERENCES product_offers (id),
    product_name     VARCHAR(200)   NOT NULL,
    product_brand    VARCHAR(120),
    strength         VARCHAR(80),
    dosage_form      VARCHAR(80),
    package_size     VARCHAR(80),
    pharmacy_name    VARCHAR(160)   NOT NULL,
    branch_name      VARCHAR(160)   NOT NULL,
    rx_required      BOOLEAN        NOT NULL,
    unit_price       NUMERIC(12, 2) NOT NULL,
    quantity         INTEGER        NOT NULL CHECK (quantity > 0),
    line_total       NUMERIC(12, 2) NOT NULL
);
CREATE INDEX idx_order_items_order ON order_items (order_id);

CREATE TABLE order_status_history (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id   UUID        NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
    status     VARCHAR(24) NOT NULL,
    comment    VARCHAR(255),
    actor_id   UUID REFERENCES users (id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_order_history_order ON order_status_history (order_id, created_at);

CREATE TABLE deliveries (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id      UUID        NOT NULL UNIQUE REFERENCES orders (id) ON DELETE CASCADE,
    courier_name  VARCHAR(160),
    courier_phone VARCHAR(32),
    courier_demo  BOOLEAN     NOT NULL DEFAULT FALSE,
    eta_from      TIMESTAMPTZ,
    eta_to        TIMESTAMPTZ,
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE payment_attempts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id        UUID           NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
    provider        VARCHAR(32)    NOT NULL,
    status          VARCHAR(24)    NOT NULL,
    amount          NUMERIC(12, 2) NOT NULL,
    currency        VARCHAR(3)     NOT NULL DEFAULT 'KZT',
    provider_ref    VARCHAR(120),
    idempotency_key VARCHAR(120)   NOT NULL UNIQUE,
    created_at      TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ    NOT NULL DEFAULT now()
);
CREATE INDEX idx_payment_attempts_order ON payment_attempts (order_id);
CREATE UNIQUE INDEX uq_payment_provider_ref ON payment_attempts (provider, provider_ref) WHERE provider_ref IS NOT NULL;

CREATE TABLE payment_webhook_events (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider     VARCHAR(32)  NOT NULL,
    event_id     VARCHAR(120) NOT NULL,
    event_type   VARCHAR(64)  NOT NULL,
    payload      TEXT         NOT NULL,
    received_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    processed_at TIMESTAMPTZ,
    UNIQUE (provider, event_id)
);

-- ───────────────────────── notifications & audit ─────────────────────────
CREATE TABLE notifications (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    type       VARCHAR(32)  NOT NULL,
    title      VARCHAR(160) NOT NULL,
    body       VARCHAR(500) NOT NULL,
    ref_id     UUID,
    read_at    TIMESTAMPTZ,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX idx_notifications_user ON notifications (user_id, created_at DESC);

CREATE TABLE audit_events (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id    UUID,
    actor_role  VARCHAR(32),
    action      VARCHAR(64)  NOT NULL,
    entity_type VARCHAR(48),
    entity_id   VARCHAR(64),
    details     VARCHAR(1000),
    ip_address  VARCHAR(64),
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX idx_audit_created ON audit_events (created_at DESC);
CREATE INDEX idx_audit_entity ON audit_events (entity_type, entity_id);
