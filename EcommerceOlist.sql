CREATE TABLE customers(

	CUSTOMER_ID VARCHAR(150),
	CUSTOMER_UNIQUE_ID VARCHAR(150),
	CUSTOMER_PREFIX_ZIP_CODE VARCHAR(15),
	CUSTOMER_CITY VARCHAR(100),
	CUSOTMER_STATE CHAR(2)

);	
COPY customers (customer_id, customer_unique_id, customer_zip_code, customer_city, customer_state)
FROM 'C:\Program Files\PostgreSQL\11\data\olist\olist_customers_dataset.csv' DELIMITER ',' CSV HEADER;


create table geolocation(
	geolocation_zip_code_prefix varchar(10),
	geolocation_lat float,
	geolocation_lng float,
	geolocation_city varchar(100),
	geolocation_state char(2)
);
COPY geolocation (geolocation_zip_code_prefix, geolocation_lat, geolocation_Ing, geolocation_city, geolocation_state)
FROM 'C:\Program Files\PostgreSQL\11\data\olist\olist_geolocation_dataset.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE Sellers (
    seller_id CHAR(32),
    seller_zip_code_prefix CHAR(5),
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);
COPY Sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state)
FROM 'C:\Program Files\PostgreSQL\11\data\olist\olist_sellers_dataset.csv' DELIMITER ',' CSV HEADER;


CREATE TABLE OrderItems (
    order_id CHAR(32),
    order_item_id INT,
    product_id CHAR(32),
    seller_id CHAR(32),
    shipping_limit_date TIMESTAMP,
    price FLOAT,
    freight_value FLOAT
);
COPY Order_Items (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price,freight_value)
FROM 'C:\Program Files\PostgreSQL\11\data\olist\olist_order_items_dataset.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE OrderPayments (
    order_id CHAR(32),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value FLOAT
);
COPY Order_Payments (order_id, payment_sequential, payment_type, payment_installments, payment_value)
FROM 'C:\Program Files\PostgreSQL\11\data\olist\olist_order_payments_dataset.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE OrderReviews (
    review_id CHAR(32),
    order_id CHAR(32),
    review_score INT,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);
COPY OrderReviews (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp)
FROM 'C:\Program Files\PostgreSQL\11\data\olist\olist_order_reviews_dataset.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE Orders (
    order_id CHAR(32),
    customer_id CHAR(32),
    order_status VARCHAR(50),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);
COPY Orders (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date,order_estimated_delivery_date)
FROM 'C:\Program Files\PostgreSQL\11\data\olist\olist_orders_dataset.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE Products (
    product_id CHAR(32),
    product_category_name VARCHAR(255),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);
COPY Products (product_id, product_category_name, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
FROM 'C:\Program Files\PostgreSQL\11\data\olist\olist_products_dataset.csv' DELIMITER ',' CSV HEADER;


/* 

	Now that I have all the tables correctly defined and populated, 
I will perform queries to address specific business inquiries. 
These queries pertain to sales, logistics, and business quality processes.
	The results will be utilized in the generation of the final dashboard, 
where we will present the most important insights using the 
Power BI visualization tool."
*/ 

-- Total delivered orders and total sales

SELECT
    COUNT(DISTINCT o.order_id) AS TotalDeliveredOrders,
    SUM(op.payment_value) AS TotalSales
FROM ecommerce.orders AS o
INNER JOIN ecommerce.orderpayments AS op
ON o.order_id = op.order_id
WHERE o.order_delivered_customer_date IS NOT NULL;

-- 5 categories that sell the most

SELECT 
    COUNT(DISTINCT oi.order_id) AS QuantityOfOrders,
    p.product_category_name AS Category
FROM ecommerce.orderitems AS oi
INNER JOIN ecommerce.products AS p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY QuantityOfOrders DESC
LIMIT 5;

-- 5 products that sell the most

SELECT 
    COUNT(DISTINCT oi.order_id) AS QuantityOfOrders,
    p.product_id AS Product
FROM ecommerce.orderitems AS oi
INNER JOIN ecommerce.products AS p
ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY QuantityOfOrders DESC
LIMIT 5;

-- 5 highest-rated categories

SELECT 
    AVG(rev.review_score) AS AverageRating,
    p.product_category_name AS Category
FROM ecommerce.orderitems AS oi
INNER JOIN ecommerce.products AS p
ON oi.product_id = p.product_id
INNER JOIN ecommerce.orderreviews AS rev
ON oi.order_id = rev.order_id
GROUP BY p.product_category_name
ORDER BY AverageRating DESC
LIMIT 5;

-- Sales per month (time series...)

SELECT
    DATE_TRUNC('month', o.order_approved_at) AS Month,
    SUM(op.payment_value) AS SalesPerMonth
FROM ecommerce.orders AS o
INNER JOIN ecommerce.orderpayments AS op
ON o.order_id = op.order_id
GROUP BY Month
ORDER BY Month;

-- Orders by day of the week

SELECT EXTRACT(DOW FROM o.order_approved_at) + 1 AS DayOfWeek,
    CASE
        WHEN EXTRACT(DOW FROM o.order_approved_at) = 0 THEN 'Sunday'
        WHEN EXTRACT(DOW FROM o.order_approved_at) = 1 THEN 'Monday'
        WHEN EXTRACT(DOW FROM o.order_approved_at) = 2 THEN 'Tuesday'
        WHEN EXTRACT(DOW FROM o.order_approved_at) = 3 THEN 'Wednesday'
        WHEN EXTRACT(DOW FROM o.order_approved_at) = 4 THEN 'Thursday'
        WHEN EXTRACT(DOW FROM o.order_approved_at) = 5 THEN 'Friday'
        WHEN EXTRACT(DOW FROM o.order_approved_at) = 6 THEN 'Saturday'
        ELSE 'Other'
    END AS DayOfWeekName,
    COUNT(o.order_id) AS QuantityOfOrders
FROM ecommerce.orders AS o
GROUP BY DayOfWeekName, DayOfWeek
ORDER BY DayOfWeek
LIMIT 7;

-- Average delivery time by state

SELECT
    c.customer_state AS State,
    DATE_TRUNC('day', AVG(o.order_delivered_customer_date - o.order_approved_at)) AS AverageDeliveryTime
FROM ecommerce.orders AS o
INNER JOIN ecommerce.customers AS c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY AverageDeliveryTime DESC;

-- Percentage of orders delivered before the estimated date

WITH DeliveryTime AS (
    SELECT
        EXTRACT(day FROM (o.order_delivered_customer_date - o.order_approved_at)) AS DeliveryTime,
        EXTRACT(day FROM (o.order_estimated_delivery_date - o.order_approved_at)) AS EstimatedDeliveryTime
    FROM ecommerce.orders AS o
    WHERE o.order_delivered_customer_date IS NOT NULL AND o.order_approved_at IS NOT NULL
)
SELECT
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN EstimatedDeliveryTime > DeliveryTime THEN 1 ELSE 0 END) AS OrdersDeliveredBeforeEstimate,
    (SUM(CASE WHEN EstimatedDeliveryTime > DeliveryTime THEN 1 ELSE 0 END)::Decimal * 100 / COUNT(*)) AS Percentage
FROM DeliveryTime;

-- Sales in 2016, 2017, 2018 with monthly grouping

SELECT
    EXTRACT(month FROM order_approved_at) AS Month,
    TO_CHAR(order_approved_at, 'Month') AS MonthName,
    SUM(CASE WHEN EXTRACT(year FROM order_approved_at) = 2016 THEN 1 ELSE 0 END) AS Year2016,
    SUM(CASE WHEN EXTRACT(year FROM order_approved_at) = 2017 THEN 1 ELSE 0 END) AS Year2017,
    SUM(CASE WHEN EXTRACT(year FROM order_approved_at) = 2018 THEN 1 ELSE 0 END) AS Year2018
FROM ecommerce.orders
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY Month, MonthName
ORDER BY Month
LIMIT 12;

