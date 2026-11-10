USE ecommerce_intelligence;

-- ============================================
-- E-COMMERCE INTELLIGENCE
-- QUERY OPTIMISATION AND PERFORMANCE
-- ============================================

-- PERFORMANCE CHECK 1:
-- Inspect existing indexes before optimisation

SHOW INDEX FROM orders;


-- ============================================
-- PERFORMANCE CHECK 2:
-- Query performance BEFORE adding an index
-- ============================================

EXPLAIN ANALYZE
SELECT
    order_id,
    customer_id,
    order_purchase_timestamp
FROM orders
WHERE order_purchase_timestamp >= '2018-01-01'
  AND order_purchase_timestamp < '2018-02-01';




-- ============================================
-- PERFORMANCE CHECK 3:
-- Add an index on purchase timestamp
-- ============================================

CREATE INDEX idx_orders_purchase_timestamp
ON orders (order_purchase_timestamp);


-- ============================================
-- PERFORMANCE CHECK 4:
-- Query performance AFTER adding the index
-- ============================================

EXPLAIN ANALYZE
SELECT
    order_id,
    customer_id,
    order_purchase_timestamp
FROM orders
WHERE order_purchase_timestamp >= '2018-01-01'
  AND order_purchase_timestamp < '2018-02-01';



 


-- ============================================
-- PERFORMANCE CHECK 5:
-- Verify the new index
-- ============================================

SHOW INDEX FROM orders;



-- ============================================
-- PERFORMANCE CHECK 6:
-- Analyse JOIN performance before optimisation
-- ============================================

EXPLAIN ANALYZE
SELECT
    o.order_id,
    o.order_purchase_timestamp,
    c.customer_state,
    p.payment_value
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_payments p
    ON o.order_id = p.order_id
WHERE o.order_purchase_timestamp >= '2018-01-01'
  AND o.order_purchase_timestamp < '2018-02-01';







-- ============================================
-- PERFORMANCE FINDINGS
-- ============================================

-- Date-range query:
-- Before indexing: 35.5 ms
-- After indexing:  13.0 ms
-- Initial improvement: 63.4%

-- Three-table JOIN:
-- With date index:    87.9 ms
-- Without date index: 79.5 ms
--
-- The indexed JOIN examined fewer orders,
-- but was slightly slower in this single run.
--
-- Conclusion:
-- Index effectiveness depends on query structure,
-- selectivity and execution overhead.
-- Repeated benchmarks are needed before deciding
-- which execution plan performs better.




-- ============================================
-- PERFORMANCE CHECK 8:
-- Repeated benchmark - WITH date index
-- ============================================

EXPLAIN ANALYZE
SELECT
    o.order_id,
    o.order_purchase_timestamp,
    c.customer_state,
    p.payment_value
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_payments p
    ON o.order_id = p.order_id
WHERE o.order_purchase_timestamp >= '2018-01-01'
  AND o.order_purchase_timestamp < '2018-02-01';









-- ============================================
-- PERFORMANCE BENCHMARK RESULTS
-- ============================================

-- Query: January 2018 orders joined with
-- customers and payments.

-- Without purchase timestamp index:
-- Full table scan on orders.
-- Observed execution time: approximately 79.5 ms
-- (single run, not a median).

-- With purchase timestamp index:
-- Index range scan on orders.
-- Five execution times (ms):
-- 60.5, 86.8, 81.4, 76.9, 81.1

-- Median indexed execution time: 81.1 ms

-- Conclusion:
-- The index changed the access method from
-- a full table scan to an index range scan.
-- However, the observed execution time was
-- similar for this multi-table join.
-- Further benchmarking would be needed
-- to establish a consistent speed improvement.