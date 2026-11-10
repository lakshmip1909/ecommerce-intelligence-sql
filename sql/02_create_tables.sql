
USE ecommerce_intelligence;

-- 1. Customers
CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

-- 2. Orders
CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(32) PRIMARY KEY,
    customer_id VARCHAR(32),
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME NULL,
    order_approved_at DATETIME NULL,
    order_delivered_carrier_date DATETIME NULL,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATETIME NULL
);

-- 3. Order items
CREATE TABLE IF NOT EXISTS order_items (
    order_id VARCHAR(32),
    order_item_id INT,
    product_id VARCHAR(32),
    seller_id VARCHAR(32),
    shipping_limit_date DATETIME NULL,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

-- 4. Order payments
CREATE TABLE IF NOT EXISTS order_payments (
    order_id VARCHAR(32),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);

-- 5. Reviews
CREATE TABLE IF NOT EXISTS order_reviews (
    review_pk INT AUTO_INCREMENT PRIMARY KEY,
    review_id VARCHAR(32),
    order_id VARCHAR(32),
    review_score TINYINT,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date DATETIME NULL,
    review_answer_timestamp DATETIME NULL
);

-- 6. Products
CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(32) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- 7. Sellers
CREATE TABLE IF NOT EXISTS sellers (
    seller_id VARCHAR(32) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);

-- 8. Geolocation
-- CHAR(5) preserves leading zeros in postcodes.
-- DOUBLE accommodates coordinate precision.
CREATE TABLE IF NOT EXISTS geolocation (
    geo_pk INT AUTO_INCREMENT PRIMARY KEY,
    geolocation_zip_code_prefix CHAR(5),
    geolocation_lat DOUBLE,
    geolocation_lng DOUBLE,
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);

-- 9. Category translations
CREATE TABLE IF NOT EXISTS product_category_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);

-- Verify all tables
SHOW TABLES;
