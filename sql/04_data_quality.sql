
USE ecommerce_intelligence;

SELECT 'Customers' AS dataset, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'Orders', COUNT(*) FROM orders
UNION ALL
SELECT 'Order items', COUNT(*) FROM order_items
UNION ALL
SELECT 'Payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'Reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'Products', COUNT(*) FROM products
UNION ALL
SELECT 'Sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'Geolocation', COUNT(*) FROM geolocation
UNION ALL
SELECT 'Category translations', COUNT(*) FROM product_category_translation;



-- ============================================
-- DATA QUALITY CHECK 2: Missing values
-- ============================================

-- Check missing information in orders
SELECT
    COUNT(*) AS total_orders,
    SUM(customer_id IS NULL) AS missing_customer_ids,
    SUM(order_purchase_timestamp IS NULL) AS missing_purchase_dates,
    SUM(order_approved_at IS NULL) AS missing_approval_dates,
    SUM(order_delivered_customer_date IS NULL) AS missing_delivery_dates,
    SUM(order_estimated_delivery_date IS NULL) AS missing_estimated_dates
FROM orders;



-- ============================================
-- DATA QUALITY CHECK 3: Missing deliveries
-- ============================================

SELECT
    order_status,
    COUNT(*) AS total_orders,
    SUM(order_delivered_customer_date IS NULL) AS missing_delivery_dates
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;



-- ============================================
-- DATA QUALITY CHECK 4: Duplicate IDs
-- ============================================

SELECT
    'Customers' AS dataset,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_ids,
    COUNT(*) - COUNT(DISTINCT customer_id) AS duplicate_ids
FROM customers

UNION ALL

SELECT
    'Orders',
    COUNT(*),
    COUNT(DISTINCT order_id),
    COUNT(*) - COUNT(DISTINCT order_id)
FROM orders

UNION ALL

SELECT
    'Products',
    COUNT(*),
    COUNT(DISTINCT product_id),
    COUNT(*) - COUNT(DISTINCT product_id)
FROM products

UNION ALL

SELECT
    'Sellers',
    COUNT(*),
    COUNT(DISTINCT seller_id),
    COUNT(*) - COUNT(DISTINCT seller_id)
FROM sellers;




-- ============================================
-- DATA QUALITY CHECK 5: Referential integrity
-- ============================================

-- Orders without matching customers
SELECT
    'Orders without customers' AS issue,
    COUNT(*) AS affected_rows
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

-- Order items without matching orders
SELECT
    'Items without orders',
    COUNT(*)
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

-- Order items without matching products
SELECT
    'Items without products',
    COUNT(*)
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

-- Order items without matching sellers
SELECT
    'Items without sellers',
    COUNT(*)
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;







-- ============================================
-- DATA QUALITY CHECK 6: Payments and reviews
-- ============================================

-- Payments without matching orders
SELECT
    'Payments without orders' AS issue,
    COUNT(*) AS affected_rows
FROM order_payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

-- Reviews without matching orders
SELECT
    'Reviews without orders',
    COUNT(*)
FROM order_reviews r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;









-- ============================================
-- DATA QUALITY CHECK 7: Order coverage
-- ============================================

SELECT
    COUNT(*) AS total_orders,

    SUM(
        NOT EXISTS (
            SELECT 1
            FROM order_payments p
            WHERE p.order_id = o.order_id
        )
    ) AS orders_without_payments,

    SUM(
        NOT EXISTS (
            SELECT 1
            FROM order_reviews r
            WHERE r.order_id = o.order_id
        )
    ) AS orders_without_reviews

FROM orders o;






-- ============================================
-- DATA QUALITY CHECK 8: Missing payment details
-- ============================================

SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date
FROM orders o
WHERE NOT EXISTS (
    SELECT 1
    FROM order_payments p
    WHERE p.order_id = o.order_id
);
