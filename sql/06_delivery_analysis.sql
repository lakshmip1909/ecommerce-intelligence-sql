
USE ecommerce_intelligence;

-- ============================================
-- E-COMMERCE INTELLIGENCE
-- DELIVERY RELIABILITY ANALYSIS
-- ============================================

-- 1. Overall on-time vs late deliveries
-- Compare calendar dates rather than exact times.

SELECT
    COUNT(*) AS total_delivered_orders,

    SUM(
        DATE(order_delivered_customer_date)
        <= DATE(order_estimated_delivery_date)
    ) AS on_time_orders,

    SUM(
        DATE(order_delivered_customer_date)
        > DATE(order_estimated_delivery_date)
    ) AS late_orders,

    ROUND(
        100.0 * SUM(
            DATE(order_delivered_customer_date)
            > DATE(order_estimated_delivery_date)
        ) / COUNT(*),
        2
    ) AS late_delivery_percentage

FROM orders

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;




-- ============================================
-- DELIVERY ANALYSIS 2: Delivery duration and delays
-- ============================================

SELECT
    COUNT(*) AS total_delivered_orders,

    ROUND(
        AVG(DATEDIFF(
            order_delivered_customer_date,
            order_purchase_timestamp
        )), 2
    ) AS average_delivery_days,

    ROUND(
        AVG(
            CASE
                WHEN DATE(order_delivered_customer_date)
                     > DATE(order_estimated_delivery_date)
                THEN DATEDIFF(
                    order_delivered_customer_date,
                    order_estimated_delivery_date
                )
            END
        ), 2
    ) AS average_days_late,

    MAX(
        CASE
            WHEN DATE(order_delivered_customer_date)
                 > DATE(order_estimated_delivery_date)
            THEN DATEDIFF(
                order_delivered_customer_date,
                order_estimated_delivery_date
            )
        END
    ) AS maximum_days_late

FROM orders

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL;




-- ============================================
-- DELIVERY ANALYSIS 3: Delivery vs review scores
-- ============================================

-- First aggregate reviews to one row per order
-- to avoid counting orders multiple times.

WITH order_review_scores AS (
    SELECT
        order_id,
        AVG(review_score) AS average_review_score
    FROM order_reviews
    WHERE review_score IS NOT NULL
    GROUP BY order_id
)

SELECT
    CASE
        WHEN DATE(o.order_delivered_customer_date)
             > DATE(o.order_estimated_delivery_date)
        THEN 'Late'
        ELSE 'On time'
    END AS delivery_status,

    COUNT(*) AS reviewed_orders,

    ROUND(
        AVG(r.average_review_score), 2
    ) AS average_review_score,

    ROUND(
        100.0 * SUM(r.average_review_score <= 2)
        / COUNT(*), 2
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
-- DELIVERY ANALYSIS 4: Delay severity vs reviews
-- ============================================

WITH order_reviews_summary AS (
    SELECT
        order_id,
        AVG(review_score) AS review_score
    FROM order_reviews
    WHERE review_score IS NOT NULL
    GROUP BY order_id
),

delivery_reviews AS (
    SELECT
        o.order_id,
        DATEDIFF(
            o.order_delivered_customer_date,
            o.order_estimated_delivery_date
        ) AS days_late,
        r.review_score
    FROM orders o
    JOIN order_reviews_summary r
        ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)

SELECT
    CASE
        WHEN days_late <= 0 THEN 'On time'
        WHEN days_late BETWEEN 1 AND 3 THEN '1-3 days late'
        WHEN days_late BETWEEN 4 AND 7 THEN '4-7 days late'
        WHEN days_late BETWEEN 8 AND 14 THEN '8-14 days late'
        ELSE '15+ days late'
    END AS delay_category,

    COUNT(*) AS reviewed_orders,

    ROUND(AVG(review_score), 2) AS average_review_score,

    ROUND(
        100.0 * SUM(review_score <= 2) / COUNT(*),
        2
    ) AS low_review_percentage

FROM delivery_reviews

GROUP BY delay_category

ORDER BY
    CASE delay_category
        WHEN 'On time' THEN 1
        WHEN '1-3 days late' THEN 2
        WHEN '4-7 days late' THEN 3
        WHEN '8-14 days late' THEN 4
        ELSE 5
    END;






-- ============================================
-- DELIVERY ANALYSIS 5: Delivery by customer state
-- ============================================

SELECT
    c.customer_state AS state,

    COUNT(*) AS delivered_orders,

    SUM(
        DATE(o.order_delivered_customer_date)
        > DATE(o.order_estimated_delivery_date)
    ) AS late_orders,

    ROUND(
        100.0 * SUM(
            DATE(o.order_delivered_customer_date)
            > DATE(o.order_estimated_delivery_date)
        ) / COUNT(*),
        2
    ) AS late_delivery_percentage,

    ROUND(
        AVG(DATEDIFF(
            o.order_delivered_customer_date,
            o.order_purchase_timestamp
        )), 2
    ) AS average_delivery_days

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
  AND o.order_purchase_timestamp IS NOT NULL

GROUP BY c.customer_state

HAVING COUNT(*) >= 100

ORDER BY late_delivery_percentage DESC;



