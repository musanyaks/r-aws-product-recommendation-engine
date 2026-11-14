-- Minimal seed data for local development and dashboard testing.
-- Idempotent: safe to re-run.
INSERT INTO customers (customer_id) VALUES
  ('u-demo-1'), ('u-demo-2'), ('u-demo-3')
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO products (product_id, category_id, price) VALUES
  ('p-laptop',     'computers',   999.00),
  ('p-mouse',      'accessories',  29.99),
  ('p-keyboard',   'accessories',  59.99),
  ('p-monitor',    'computers',   249.00),
  ('p-laptop-bag', 'accessories',  49.99),
  ('p-headphones', 'audio',       129.00)
ON CONFLICT (product_id) DO NOTHING;

INSERT INTO interactions (customer_id, product_id, event_type, occurred_at) VALUES
  ('u-demo-1', 'p-laptop',     'view',        NOW() - interval '3 days'),
  ('u-demo-1', 'p-laptop',     'add_to_cart', NOW() - interval '3 days'),
  ('u-demo-1', 'p-laptop',     'purchase',    NOW() - interval '2 days'),
  ('u-demo-1', 'p-mouse',      'view',        NOW() - interval '2 days'),
  ('u-demo-2', 'p-laptop',     'view',        NOW() - interval '2 days'),
  ('u-demo-2', 'p-mouse',      'purchase',    NOW() - interval '1 day'),
  ('u-demo-2', 'p-keyboard',   'view',        NOW() - interval '1 day'),
  ('u-demo-3', 'p-headphones', 'purchase',    NOW() - interval '12 hours'),
  ('u-demo-3', 'p-monitor',    'view',        NOW() - interval '6 hours');

INSERT INTO model_registry (model_id, algorithm, metrics) VALUES
  ('seed-baseline', 'popularity',
   '{"precision_at_k": 0.021, "recall_at_k": 0.048, "map_at_k": 0.026, "ndcg_at_k": 0.039}');