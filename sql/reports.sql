-- a) Order totals
-- Output:
-- total_orders | total_revenue | avg_order_value
-- 180          | 99860.2       | 554.78
SELECT 
    COUNT(*) AS total_orders,
    ROUND(SUM(quantity * price * (1.0 - COALESCE(discount_pct, 0)/100.0)), 2) AS total_revenue,
    ROUND(SUM(quantity * price * (1.0 - COALESCE(discount_pct, 0)/100.0))/COUNT(*), 2) AS avg_order_value
FROM orders 
JOIN products ON orders.product_id = products.product_id;


-- b) COUNT(*) vs COUNT(column)
-- Output:
-- total_count | rating_count | difference
-- 180         | 165          | 15
SELECT 
    COUNT(*) AS total_count, 
    COUNT(rating) AS rating_count, 
    COUNT(*) - COUNT(rating) AS difference 
FROM orders;


-- c) LEFT JOIN with a genuine zero-match row
-- Output (Query 1 - LEFT JOIN):
-- customer_id | name
-- C045        | Vihaan
SELECT c.customer_id, c.name 
FROM customers c 
LEFT JOIN orders o ON c.customer_id = o.customer_id 
GROUP BY c.customer_id, c.name 
HAVING COUNT(o.order_id) = 0;

-- Output (Query 2 - NOT IN verification):
-- customer_id | name
-- C045        | Vihaan
SELECT customer_id, name 
FROM customers 
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM orders);


-- d) GROUP BY + HAVING
-- Output:
-- city      | total_orders | returned_orders | return_rate_pct
-- Jaipur    | 19           | 8               | 42.1
-- Lucknow   | 49           | 15              | 30.6
-- Bangalore | 33           | 8               | 24.2
SELECT 
    c.city, 
    COUNT(o.order_id) AS total_orders, 
    SUM(o.returned) AS returned_orders, 
    ROUND(SUM(o.returned)*100.0/COUNT(o.order_id), 1) AS return_rate_pct 
FROM orders o 
JOIN customers c ON o.customer_id = c.customer_id 
GROUP BY c.city 
HAVING return_rate_pct > 20 
ORDER BY return_rate_pct DESC;


-- e) Ranking with ORDER BY + LIMIT/OFFSET
-- Tie-break reasoning: If total_spend is identical for two customers, sorting by customer_id ASC explicitly prevents arbitrary ordering, keeping LIMIT/OFFSET pagination deterministic.
-- Output (Query 1 - Top 5):
-- customer_id | name    | total_spend
-- C043        | Reyansh | 12920.0
-- C026        | Isha    | 8371.6
-- C008        | Meera   | 4564.6
-- C011        | Arjun   | 4111.0
-- C042        | Sanya   | 3785.0
SELECT 
    c.customer_id, 
    c.name, 
    ROUND(SUM(o.quantity * p.price * (1.0 - COALESCE(o.discount_pct, 0)/100.0)), 2) AS total_spend
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spend DESC, c.customer_id ASC
LIMIT 5;

-- Output (Query 2 - Ranks 3 to 5):
-- customer_id | name  | total_spend
-- C008        | Meera | 4564.6
-- C011        | Arjun | 4111.0
-- C042        | Sanya | 3785.0
SELECT 
    c.customer_id, 
    c.name, 
    ROUND(SUM(o.quantity * p.price * (1.0 - COALESCE(o.discount_pct, 0)/100.0)), 2) AS total_spend
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spend DESC, c.customer_id ASC
LIMIT 3 OFFSET 2;


-- f) Three-table JOIN with GROUP BY
-- Output:
-- category     | order_count | category_revenue
-- Haircare     | 54          | 44956.1
-- Skincare     | 60          | 27346.0
-- Babycare     | 30          | 16805.0
-- PersonalCare | 36          | 10753.1
SELECT 
    p.category, 
    COUNT(o.order_id) AS order_count, 
    ROUND(SUM(o.quantity * p.price * (1.0 - COALESCE(o.discount_pct, 0)/100.0)), 2) AS category_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY p.category
ORDER BY category_revenue DESC;


-- g) LIKE pattern match
-- Output (10 rows):
-- C001 | Aarav   | Mumbai    | 1 | 2026-01-07 | Organic
-- C003 | Aditi   | Mumbai    | 1 | 2026-06-23 | Organic
-- C004 | Ananya  | Lucknow   | 2 | 2026-01-23 | Organic
-- C011 | Arjun   | Bangalore | 1 | 2026-03-13 | Referral
-- C021 | Aryan   | Bangalore | 1 | 2026-02-11 | Ad
-- C030 | Anika   | Bangalore | 1 | 2026-02-24 | Organic
-- C031 | Aditya  | Jaipur    | 2 | 2026-06-14 | Ad
-- C036 | Aisha   | Delhi     | 1 | 2026-05-11 | Ad
-- C041 | Ayaan   | Lucknow   | 2 | 2026-01-03 | Organic
-- C044 | Aria    | Bangalore | 1 | 2026-04-22 | Referral
SELECT * FROM customers WHERE name LIKE 'A%';


-- h) DISTINCT
-- Output (4 rows):
-- Ad
-- Organic
-- Referral
-- Social
SELECT DISTINCT acquisition_source 
FROM customers 
ORDER BY acquisition_source ASC;


-- i) ALTER TABLE + UPDATE with CASE
-- Output:
-- loyalty_tier | COUNT(*)
-- Gold         | 28
-- Silver       | 17
ALTER TABLE customers ADD COLUMN loyalty_tier VARCHAR(10);

UPDATE customers 
SET loyalty_tier = CASE
    WHEN city_tier = 1 THEN 'Gold'
    ELSE 'Silver' 
END;

-- Verification
SELECT loyalty_tier, COUNT(*) FROM customers GROUP BY loyalty_tier;
