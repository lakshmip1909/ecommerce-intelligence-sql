USE ecommerce_intelligence;

-- ============================================
-- E-COMMERCE INTELLIGENCE
-- 09: BUSINESS INSIGHTS
-- ============================================

-- Objective:
-- Summarise the key findings from revenue,
-- delivery reliability and customer retention
-- using SQL queries.

-- ============================================
-- BUSINESS INSIGHT 1: Revenue overview
-- ============================================

-- Business question:
-- How much payment value did the business
-- process, and how many customers contributed?

WITH order_totals AS (
    SELECT
        order_id,
        SUM(payment_value) AS order_payment
    FROM order_payments
    GROUP BY order_id
)

SELECT
    COUNT(*) AS paid_orders,

    ROUND(SUM(p.order_payment), 2)
        AS total_payment_value,

    ROUND(AVG(p.order_payment), 2)
        AS average_payment_per_order,

    COUNT(DISTINCT c.customer_unique_id)
        AS unique_customers

FROM order_totals p
JOIN orders o
    ON p.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id;



-- ============================================
-- BUSINESS INSIGHT 2: Revenue concentration
-- ============================================

-- Business question:
-- How much merchandise value is generated
-- by the five highest-performing categories?

WITH category_sales AS (
    SELECT
        COALESCE(t.product_category_name_english,
                 p.product_category_name,
                 'unknown') AS category,
        SUM(oi.price) AS merchandise_value
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation t
        ON p.product_category_name =
           t.product_category_name
    GROUP BY
        COALESCE(t.product_category_name_english,
                 p.product_category_name,
                 'unknown')
),

ranked_categories AS (
    SELECT
        category,
        merchandise_value,
        ROW_NUMBER() OVER (
            ORDER BY merchandise_value DESC
        ) AS category_rank,
        SUM(merchandise_value) OVER ()
            AS total_merchandise_value
    FROM category_sales
)

SELECT
    category_rank,
    category,
    ROUND(merchandise_value, 2)
        AS merchandise_value,
    ROUND(
        100.0 * merchandise_value /
        NULLIF(total_merchandise_value, 0),
        2
    ) AS percentage_of_total

FROM ranked_categories
WHERE category_rank <= 5
ORDER BY category_rank;






-- ============================================
-- BUSINESS INSIGHT 3: Delivery and satisfaction
-- ============================================

-- Business question:
-- How does late delivery affect review scores?

WITH order_review_scores AS (
    SELECT
        order_id,
        AVG(review_score) AS review_score
    FROM order_reviews
    GROUP BY order_id
)

SELECT
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On time'
    END AS delivery_status,

    COUNT(*) AS reviewed_orders,

    ROUND(AVG(r.review_score), 2)
        AS average_review_score,

    ROUND(
        100.0 * AVG(r.review_score <= 2),
        2
    ) AS low_review_percentage

FROM orders o
JOIN order_review_scores r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY delivery_status
ORDER BY delivery_status;





-- ============================================
-- BUSINESS INSIGHT 4: Customer retention
-- ============================================

-- Business question:
-- What percentage of customers make
-- more than one delivered purchase?

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
    ) AS repeat_customer_percentage

FROM customer_orders;






-- ============================================
-- BUSINESS INSIGHT 5: Key recommendations
-- ============================================

-- RECOMMENDATION 1: Improve delivery reliability
--
-- Late deliveries have an average review
-- score of 2.57 compared with 4.29 for
-- on-time deliveries.
--
-- Prioritise investigation of delivery delays,
-- particularly in regions with high late
-- delivery rates.
--
-- Track:
-- Late delivery percentage
-- Average review score
-- Percentage of low reviews


-- RECOMMENDATION 2: Improve repeat purchasing
--
-- Only 3.00% of customers placed two or more
-- delivered orders during the observation period.
--
-- Test targeted follow-up campaigns,
-- personalised recommendations and
-- customer loyalty initiatives.
--
-- Track:
-- Repeat purchase percentage
-- Monthly cohort retention
-- Average orders per customer


-- RECOMMENDATION 3: Focus on leading categories
--
-- The top five product categories contribute
-- approximately 39.74% of merchandise value.
--
-- Prioritise inventory availability and
-- merchandising analysis for these categories.
-- Evaluate profitability before increasing
-- investment.
--
-- Track:
-- Merchandise value by category
-- Category share of total merchandise value
-- Order volume by category






