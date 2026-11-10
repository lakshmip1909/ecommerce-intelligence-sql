
USE ecommerce_intelligence;

-- ============================================
-- E-COMMERCE INTELLIGENCE
-- CUSTOMER RETENTION AND REPEAT PURCHASES
-- ============================================

-- 1. Customer purchase frequency
-- Count distinct delivered orders per customer.

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
      AND c.customer_unique_id IS NOT NULL
    GROUP BY c.customer_unique_id
)

SELECT
    COUNT(*) AS total_customers,

    SUM(total_orders = 1) AS one_time_customers,

    SUM(total_orders >= 2) AS repeat_customers,

    ROUND(
        100.0 * SUM(total_orders >= 2) / COUNT(*),
        2
    ) AS repeat_customer_percentage,

    ROUND(AVG(total_orders), 2)
        AS average_orders_per_customer

FROM customer_orders;
