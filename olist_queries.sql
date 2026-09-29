-- Olist E-Commerce Analysis: PostgreSQL

-- TABLE SCHEMA (data loaded from olist_master_clean.csv)
CREATE TABLE olist_master (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(50),
    customer_state VARCHAR(5),
    product_category_name_english VARCHAR(50),
    seller_zip_code_prefix VARCHAR(10),
    seller_city VARCHAR(50),
    seller_state VARCHAR(5),
    total_payment DECIMAL(10,2),
    payment_type VARCHAR(20),
    review_score DECIMAL(3,1),
    delivery_delay_days DECIMAL(10,1)
);

-- 1. REVENUE BY STATE (TOP 10)
SELECT customer_state,
       COUNT(DISTINCT order_id) AS total_orders,
       SUM(price) AS total_revenue
FROM olist_master
GROUP BY customer_state
ORDER BY total_revenue DESC
LIMIT 10;

-- 2. TOP PRODUCT CATEGORIES
SELECT product_category_name_english,
       COUNT(*) AS items_sold,
       SUM(price) AS revenue
FROM olist_master
GROUP BY product_category_name_english
ORDER BY revenue DESC
LIMIT 10;

-- 3. DELIVERY DELAY VS REVIEW SCORE
SELECT
    CASE
        WHEN delivery_delay_days IS NULL THEN 'Not Delivered'
        WHEN delivery_delay_days <= 0 THEN 'On Time / Early'
        ELSE 'Late'
    END AS delivery_status,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    COUNT(*) AS order_items
FROM olist_master
GROUP BY delivery_status
ORDER BY avg_review_score DESC;

-- 4. MONTHLY REVENUE TREND
SELECT DATE_TRUNC('month', order_purchase_timestamp) AS month,
       SUM(price) AS revenue
FROM olist_master
GROUP BY month
ORDER BY month;

-- 5. WINDOW FUNCTION: TOP SELLERS WITHIN EACH STATE
SELECT seller_id, seller_state, SUM(price) AS revenue,
       RANK() OVER (PARTITION BY seller_state ORDER BY SUM(price) DESC) AS rank_in_state
FROM olist_master
GROUP BY seller_id, seller_state
ORDER BY seller_state, rank_in_state;

-- 6. CTE: HIGH-VALUE CUSTOMERS
WITH customer_spending AS (
    SELECT customer_unique_id, customer_state, SUM(price) AS total_spent
    FROM olist_master
    GROUP BY customer_unique_id, customer_state
)
SELECT * FROM customer_spending
WHERE total_spent > 1000
ORDER BY total_spent DESC;

-- 7. PAYMENT TYPE ANALYSIS
SELECT payment_type,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(AVG(total_payment), 2) AS avg_payment_value
FROM olist_master
GROUP BY payment_type
ORDER BY orders DESC;
