-- a) Order totals
-- Expected: total_orders = 180, total_revenue = 99860.20, avg_order_value = 554.78
SELECT 
    COUNT(*) AS total_orders,
    SUM(quantity * price * (1.0 - COALESCE(discount_pct, 0)/100.0)) AS total_revenue,
    ROUND(SUM(quantity * price * (1.0 - COALESCE(discount_pct, 0)/100.0))/COUNT(*), 2) AS avg_order_value
FROM orders 
JOIN products ON orders.product_id = products.product_id;


-- b) COUNT(*) vs COUNT(column)
-- Expected: (180, 165, 15)
SELECT 
    COUNT(*) AS total_count, 
    COUNT(rating) AS rating_count, 
    COUNT(*) - COUNT(rating) AS difference 
FROM orders;


-- c) LEFT JOIN with a genuine zero-match row
-- Expected both: exactly one row — C045, Vihaan
SELECT c.customer_id, c.name 
FROM customers c 
LEFT JOIN orders o ON c.customer_id = o.customer_id 
GROUP BY c.customer_id, c.name 
HAVING COUNT(o.order_id) = 0;

SELECT customer_id, name 
FROM customers 
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM orders);


-- d) GROUP BY + HAVING
-- Expected exactly 3 rows: Jaipur (19, 8, 42.1), Lucknow (49, 15, 30.6), Bangalore (33, 8, 24.2)
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
-- Tie-break reasoning: If total_spend is identical for two customers, sorting by customer_id explicitly prevents random ordering, keeping pagination stable.
-- Query 1 (Top 5) expected: C043 (12920), C026 (8371.6), C008 (4564.6), C011 (4111), C042 (3785)
SELECT 
    c.customer_id, 
    c.name, 
    SUM(o.quantity * p.price * (1.0 - COALESCE(o.discount_pct, 0)/100.0)) AS total_spend
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spend DESC, c.customer_id ASC
LIMIT 5;


-- Query 2 (Ranks 3-5) expected: C008, C011, C042
SELECT 
    c.customer_id, 
    c.name, 
    SUM(o.quantity * p.price * (1.0 - COALESCE(o.discount_pct, 0)/100.0)) AS total_spend
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spend DESC, c.customer_id ASC
LIMIT 3 OFFSET 2;


-- f) Three-table JOIN with GROUP BY
-- Expected: Haircare (54, 44956.10), Skincare (60, 27346.00), Babycare (30, 16805.00), PersonalCare (36, 10753.10)
SELECT 
    p.category, 
    COUNT(o.order_id) AS order_count, 
    SUM(o.quantity * p.price * (1.0 - COALESCE(o.discount_pct, 0)/100.0)) AS category_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY p.category
ORDER BY category_revenue DESC;


-- g) LIKE pattern match
-- Expected: exactly 10 rows
SELECT * FROM customers WHERE name LIKE 'A%';

-- h) DISTINCT
-- Expected: Ad, Organic, Referral, Social
SELECT DISTINCT acquisition_source FROM customers;

-- i) ALTER TABLE + UPDATE with CASE
ALTER TABLE customers ADD COLUMN loyalty_tier VARCHAR(10);

UPDATE customers SET loyalty_tier = CASE
                               WHEN city_tier = 1 THEN 'Gold'
                               ELSE 'Silver' END;

-- Verification                              
SELECT loyalty_tier, COUNT(*) FROM customers GROUP BY loyalty_tier;
