CREATE TABLE IF NOT EXISTS customers (
  customer_id TEXT PRIMARY KEY,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS products (
  product_id  TEXT PRIMARY KEY,
  category_id TEXT,
  price       NUMERIC(10,2),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS interactions (
  id          BIGSERIAL PRIMARY KEY,
  customer_id TEXT NOT NULL,
  product_id  TEXT NOT NULL,
  event_type  TEXT NOT NULL
              CHECK (event_type IN ('view','click','add_to_cart','purchase','rating')),
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_interactions_customer
  ON interactions (customer_id, occurred_at DESC);
CREATE INDEX IF NOT EXISTS idx_interactions_product ON interactions (product_id);

CREATE TABLE IF NOT EXISTS recommendations (
  customer_id  TEXT NOT NULL,
  product_id   TEXT NOT NULL,
  score        DOUBLE PRECISION NOT NULL,
  model_id     TEXT NOT NULL,
  generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (customer_id, product_id)
);

CREATE TABLE IF NOT EXISTS model_registry (
  id         BIGSERIAL PRIMARY KEY,
  model_id   TEXT NOT NULL,
  algorithm  TEXT NOT NULL,
  metrics    JSONB,
  trained_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);