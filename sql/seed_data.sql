-- Import CSV files (skipping header row)
.mode csv
.import --skip 1 data/customers.csv customers
.import --skip 1 data/products.csv products
.import --skip 1 data/orders.csv orders

-- Reset output mode for subsequent queries
.mode column
.headers on

-- Convert blank CSV cells imported as empty strings into genuine SQL NULLs
UPDATE orders SET discount_pct = NULL WHERE discount_pct = '';
UPDATE orders SET rating = NULL WHERE rating = '';

-- Post-load verification checks (Expected: 45, 16, 180)
SELECT COUNT(*) AS customers_count FROM customers;
SELECT COUNT(*) AS products_count FROM products;
SELECT COUNT(*) AS orders_count FROM orders;
