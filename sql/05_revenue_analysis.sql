
USE ecommerce_intelligence;

-- ============================================
-- E-COMMERCE INTELLIGENCE
-- REVENUE ANALYSIS
-- ============================================

-- 1. Overall payment-based revenue
-- Revenue proxy: sum of recorded payment values.
-- Includes freight and potentially non-delivered orders.

SELECT
    COUNT(DISTINCT order_id) AS orders_with_payments,
    COUNT(*) AS payment_records,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(SUM(payment_value) / COUNT(DISTINCT order_id), 2)
        AS average_payment_per_order
FROM order_payments;



-- ============================================
-- REVENUE ANALYSIS 2: Monthly payment trends
-- ============================================

-- Aggregate payments by order purchase month.
-- Join payments to orders to obtain purchase dates.

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS paid_orders,
    ROUND(SUM(p.payment_value), 2) AS total_payment_value,
    ROUND(
        SUM(p.payment_value) / COUNT(DISTINCT o.order_id),
        2
    ) AS average_payment_per_order
FROM orders o
JOIN order_payments p
    ON o.order_id = p.order_id
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;






-- ============================================
-- REVENUE ANALYSIS 3: Month-on-month growth
-- ============================================

WITH monthly_payments AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        COUNT(DISTINCT o.order_id) AS paid_orders,
        SUM(p.payment_value) AS total_payment_value
    FROM orders o
    JOIN order_payments p
        ON o.order_id = p.order_id
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
),

monthly_growth AS (
    SELECT
        order_month,
        paid_orders,
        total_payment_value,
        LAG(total_payment_value) OVER (
            ORDER BY order_month
        ) AS previous_month_value
    FROM monthly_payments
)

SELECT
    order_month,
    paid_orders,
    ROUND(total_payment_value, 2) AS total_payment_value,
    ROUND(previous_month_value, 2) AS previous_month_value,
    ROUND(
        100.0 * (total_payment_value - previous_month_value)
        / NULLIF(previous_month_value, 0),
        2
    ) AS growth_percentage
FROM monthly_growth
ORDER BY order_month;





-- ============================================
-- REVENUE ANALYSIS 4: Order growth vs payment growth
-- ============================================

WITH monthly_summary AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        COUNT(DISTINCT o.order_id) AS paid_orders,
        SUM(p.payment_value) AS payment_value,
        SUM(p.payment_value) / COUNT(DISTINCT o.order_id)
            AS average_payment
    FROM orders o
    JOIN order_payments p
        ON o.order_id = p.order_id
    WHERE o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
),

monthly_comparison AS (
    SELECT
        *,
        LAG(paid_orders) OVER (ORDER BY order_month)
            AS previous_orders,
        LAG(payment_value) OVER (ORDER BY order_month)
            AS previous_payment,
        LAG(average_payment) OVER (ORDER BY order_month)
            AS previous_average
    FROM monthly_summary
)

SELECT
    order_month,
    paid_orders,
    ROUND(payment_value, 2) AS payment_value,

    ROUND(
        100.0 * (paid_orders - previous_orders)
        / NULLIF(previous_orders, 0), 2
    ) AS order_growth_pct,

    ROUND(
        100.0 * (payment_value - previous_payment)
        / NULLIF(previous_payment, 0), 2
    ) AS payment_growth_pct,

    ROUND(
        100.0 * (average_payment - previous_average)
        / NULLIF(previous_average, 0), 2
    ) AS average_payment_growth_pct

FROM monthly_comparison
ORDER BY order_month;







-- ============================================
-- REVENUE ANALYSIS 5: Top product categories
-- ============================================

SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS category,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    SUM(1) AS items_sold,

    ROUND(SUM(oi.price), 2) AS merchandise_value,

    ROUND(AVG(oi.price), 2) AS average_item_price

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name

WHERE o.order_status = 'delivered'

GROUP BY
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )

ORDER BY merchandise_value DESC

LIMIT 15;



-- ============================================
-- REVENUE ANALYSIS 6: Category contribution
-- ============================================

WITH category_sales AS (
    SELECT
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS category,
        SUM(oi.price) AS merchandise_value
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation t
        ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'Unknown'
        )
)

SELECT
    category,
    ROUND(merchandise_value, 2) AS merchandise_value,
    ROUND(
        100.0 * merchandise_value
        / SUM(merchandise_value) OVER (),
        2
    ) AS percentage_of_total
FROM category_sales
ORDER BY merchandise_value DESC
LIMIT 15;






-- ============================================
-- REVENUE ANALYSIS 7: Cumulative category share
-- ============================================

WITH category_sales AS (
    SELECT
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS category,
        SUM(oi.price) AS merchandise_value
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation t
        ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'Unknown'
        )
),

ranked_categories AS (
    SELECT
        category,
        merchandise_value,
        ROW_NUMBER() OVER (
            ORDER BY merchandise_value DESC, category
        ) AS category_rank,
        SUM(merchandise_value) OVER (
            ORDER BY merchandise_value DESC, category
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS cumulative_value,
        SUM(merchandise_value) OVER ()
            AS overall_value
    FROM category_sales
)

SELECT
    category_rank,
    category,
    ROUND(merchandise_value, 2) AS merchandise_value,
    ROUND(
        100.0 * merchandise_value / overall_value,
        2
    ) AS category_share_pct,
    ROUND(
        100.0 * cumulative_value / overall_value,
        2
    ) AS cumulative_share_pct
FROM ranked_categories
WHERE category_rank <= 15
ORDER BY category_rank;

