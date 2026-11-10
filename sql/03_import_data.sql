
USE ecommerce_intelligence;

-- =====================================================
-- E-COMMERCE INTELLIGENCE
-- Importing the 9 Olist datasets
--
-- Run using the MySQL command-line client with
-- --local-infile=1.
--
-- Do not rerun against already populated tables.
-- =====================================================


-- 1. Customers
LOAD DATA LOCAL INFILE
'/Users/lakshmi/Desktop/ecommerce-intelligence-sql/data/olist_customers_dataset.csv'
INTO TABLE customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
);


-- 2. Orders
LOAD DATA LOCAL INFILE
'/Users/lakshmi/Desktop/ecommerce-intelligence-sql/data/olist_orders_dataset.csv'
INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    order_id,
    customer_id,
    order_status,
    @purchase_date,
    @approved_date,
    @carrier_date,
    @delivered_date,
    @estimated_date
)
SET
    order_purchase_timestamp = NULLIF(@purchase_date, ''),
    order_approved_at = NULLIF(@approved_date, ''),
    order_delivered_carrier_date = NULLIF(@carrier_date, ''),
    order_delivered_customer_date = NULLIF(@delivered_date, ''),
    order_estimated_delivery_date = NULLIF(@estimated_date, '');


-- 3. Order items
LOAD DATA LOCAL INFILE
'/Users/lakshmi/Desktop/ecommerce-intelligence-sql/data/olist_order_items_dataset.csv'
INTO TABLE order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    order_id,
    order_item_id,
    product_id,
    seller_id,
    @shipping_date,
    @price,
    @freight
)
SET
    shipping_limit_date = NULLIF(@shipping_date, ''),
    price = NULLIF(@price, ''),
    freight_value = NULLIF(@freight, '');


-- 4. Order payments
LOAD DATA LOCAL INFILE
'/Users/lakshmi/Desktop/ecommerce-intelligence-sql/data/olist_order_payments_dataset.csv'
INTO TABLE order_payments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    @payment_value
)
SET
    payment_value = NULLIF(@payment_value, '');


-- 5. Order reviews
-- The clean CSV was prepared to remove embedded line
-- breaks from review comments.
-- Standard CSV doubled quotation marks are preserved.
LOAD DATA LOCAL INFILE
'/Users/lakshmi/Desktop/ecommerce-intelligence-sql/data/olist_order_reviews_clean.csv'
INTO TABLE order_reviews
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
    review_id,
    order_id,
    @review_score,
    @review_title,
    @review_message,
    @creation_date,
    @answer_date
)
SET
    review_score = NULLIF(@review_score, ''),
    review_comment_title = NULLIF(@review_title, ''),
    review_comment_message = NULLIF(@review_message, ''),
    review_creation_date = NULLIF(@creation_date, ''),
    review_answer_timestamp = NULLIF(@answer_date, '');


-- 6. Products
LOAD DATA LOCAL INFILE
'/Users/lakshmi/Desktop/ecommerce-intelligence-sql/data/olist_products_dataset.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    product_id,
    product_category_name,
    @name_length,
    @description_length,
    @photos_qty,
    @weight,
    @length,
    @height,
    @width
)
SET
    product_name_lenght = NULLIF(@name_length, ''),
    product_description_lenght = NULLIF(@description_length, ''),
    product_photos_qty = NULLIF(@photos_qty, ''),
    product_weight_g = NULLIF(@weight, ''),
    product_length_cm = NULLIF(@length, ''),
    product_height_cm = NULLIF(@height, ''),
    product_width_cm = NULLIF(@width, '');


-- 7. Sellers
LOAD DATA LOCAL INFILE
'/Users/lakshmi/Desktop/ecommerce-intelligence-sql/data/olist_sellers_dataset.csv'
INTO TABLE sellers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
);


-- 8. Geolocation
-- Preserve five-digit postcode prefixes.
LOAD DATA LOCAL INFILE
'/Users/lakshmi/Desktop/ecommerce-intelligence-sql/data/olist_geolocation_dataset.csv'
INTO TABLE geolocation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @postcode,
    @latitude,
    @longitude,
    geolocation_city,
    geolocation_state
)
SET
    geolocation_zip_code_prefix = LPAD(@postcode, 5, '0'),
    geolocation_lat = NULLIF(@latitude, ''),
    geolocation_lng = NULLIF(@longitude, '');


-- 9. Product category translations
-- Original CSV contains a UTF-8 BOM in its header.
-- IGNORE 1 LINES skips the header.
LOAD DATA LOCAL INFILE
'/Users/lakshmi/Desktop/ecommerce-intelligence-sql/data/product_category_name_translation.csv'
INTO TABLE product_category_translation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
    product_category_name,
    product_category_name_english
);
