-- 1. Count the total number of products available in the inventory.
SELECT COUNT(*)
FROM zepto_v2;

-- 2. Display the first 10 products from the dataset.
SELECT *
FROM zepto_v2
LIMIT 5;

-- What is the total estimated inventory value of all products available in the Zepto inventory?
SELECT SUM(inventory_value) AS total_inventory_value
FROM zepto_v2;

-- Which product categories have the highest total inventory value?
SELECT
    category,
    SUM(inventory_value) AS total_inventory_value
FROM zepto_v2
GROUP BY category
ORDER BY total_inventory_value DESC;

-- How many products fall under each stock status (Healthy, Low, Critical, Out of Stock)?
SELECT
    stock_status,
    COUNT(*) AS number_of_products
FROM zepto_v2
GROUP BY stock_status
ORDER BY number_of_products DESC;

-- Which are the top 10 products with the highest inventory value?
SELECT
    product_name,
    category,
    inventory_value
FROM zepto_v2
ORDER BY inventory_value DESC
LIMIT 10;

-- What is the average discount offered in each product category?
SELECT
    category,
    ROUND(AVG(discount_percent),2) AS average_discount
FROM zepto_v2
GROUP BY category
ORDER BY average_discount DESC;

-- Which product categories have the highest number of out-of-stock products?
SELECT
    category,
    COUNT(*) AS out_of_stock_products
FROM zepto_v2
WHERE out_of_stock = TRUE
GROUP BY category
ORDER BY out_of_stock_products DESC;

-- Which products are premium-priced (MRP greater than ₹1000)?
SELECT
    product_name,
    category,
    mrp,
    discounted_price
FROM zepto_v2
WHERE mrp > 1000
ORDER BY mrp DESC;

-- How can products be ranked based on their inventory value using SQL window functions?
SELECT
    product_name,
    category,
    inventory_value,
    RANK() OVER(ORDER BY inventory_value DESC) AS inventory_rank
FROM zepto_v2
LIMIT 20;

-- Which product has the highest inventory value within each category?
SELECT *
FROM (
    SELECT
        category,
        product_name,
        inventory_value,
        ROW_NUMBER() OVER(
            PARTITION BY category
            ORDER BY inventory_value DESC
        ) AS rn
    FROM zepto_v2
) t
WHERE rn = 1;

-- What is the cumulative (running) inventory value when products are ordered from highest to lowest inventory value?
SELECT
    product_name,
    inventory_value,
    SUM(inventory_value) OVER(
        ORDER BY inventory_value DESC
    ) AS running_total
FROM zepto_v2
LIMIT 20;

-- How many products are available in each category?
SELECT
    category,
    COUNT(*) AS total_products
FROM zepto_v2
GROUP BY category
ORDER BY total_products DESC;

-- Which categories have more than 100 products?
SELECT
    category,
    COUNT(*) AS total_products
FROM zepto_v2
GROUP BY category
HAVING COUNT(*) > 100
ORDER BY total_products DESC;

-- What is the highest MRP product in each category?
SELECT
    category,
    MAX(mrp) AS highest_mrp
FROM zepto_v2
GROUP BY category
ORDER BY highest_mrp DESC;

-- What is the minimum discounted price available in each category?
SELECT
    category,
    MIN(discounted_price) AS lowest_price
FROM zepto_v2
GROUP BY category
ORDER BY lowest_price;

-- Which products have a discount greater than the overall average discount?
SELECT
    product_name,
    category,
    discount_percent
FROM zepto_v2
WHERE discount_percent >
(
    SELECT AVG(discount_percent)
    FROM zepto_v2
)
ORDER BY discount_percent DESC;

-- What percentage of products are out of stock?
SELECT
ROUND(
100.0 *
SUM(CASE WHEN out_of_stock = TRUE THEN 1 ELSE 0 END)
/
COUNT(*),2
) AS out_of_stock_percentage
FROM zepto_v2;

-- Which products have an inventory value greater than ₹5000?
SELECT
    product_name,
    category,
    inventory_value
FROM zepto_v2
WHERE inventory_value > 5000
ORDER BY inventory_value DESC;

-- Which categories contribute the most to total inventory value (in percentage)?
SELECT
category,
SUM(inventory_value) AS inventory_value,
ROUND(
100.0 * SUM(inventory_value) /
(SELECT SUM(inventory_value) FROM zepto_v2),2
) AS contribution_percentage
FROM zepto_v2
GROUP BY category
ORDER BY contribution_percentage DESC;

-- What is the average inventory value of products in each category?
SELECT
category,
ROUND(AVG(inventory_value),2) AS average_inventory
FROM zepto_v2
GROUP BY category
ORDER BY average_inventory DESC;

-- Which categories have the highest average MRP?
SELECT
category,
ROUND(AVG(mrp),2) AS average_mrp
FROM zepto_v2
GROUP BY category
ORDER BY average_mrp DESC;

-- Assign a dense rank to products based on inventory value.
SELECT
product_name,
inventory_value,
DENSE_RANK() OVER
(
ORDER BY inventory_value DESC
) AS dense_rank
FROM zepto_v2;

-- Find the top 3 products with the highest inventory value in each category.
SELECT *
FROM
(
SELECT
category,
product_name,
inventory_value,
ROW_NUMBER() OVER
(
PARTITION BY category
ORDER BY inventory_value DESC
) AS rn
FROM zepto_v2
) t
WHERE rn<=3;

-- Classify products into Low, Medium, and High price segments.
SELECT
product_name,
mrp,
CASE
WHEN mrp < 200 THEN 'Low Price'
WHEN mrp BETWEEN 200 AND 500 THEN 'Medium Price'
ELSE 'High Price'
END AS price_segment
FROM zepto_v2;

-- How many products belong to each price segment?
SELECT
CASE
WHEN mrp < 200 THEN 'Low Price'
WHEN mrp BETWEEN 200 AND 500 THEN 'Medium Price'
ELSE 'High Price'
END AS price_segment,
COUNT(*) AS total_products
FROM zepto_v2
GROUP BY price_segment;

-- Display the top 5 categories with the highest average discount.
SELECT
category,
ROUND(AVG(discount_percent),2) AS avg_discount
FROM zepto_v2
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Create a view containing premium products (MRP > ₹1000).
CREATE VIEW premium_products AS
SELECT
product_name,
category,
mrp,
discounted_price
FROM zepto_v2
WHERE mrp>1000;
SELECT * FROM premium_products;

-- Create a view for products that are currently out of stock.
CREATE VIEW out_of_stock_products AS
SELECT *
FROM zepto_v2
WHERE out_of_stock = TRUE;
SELECT * FROM out_of_stock_products;

-- Using a CTE, find products whose inventory value is above the average inventory value.
WITH avg_inventory AS
(
SELECT AVG(inventory_value) AS avg_value
FROM zepto_v2
)

SELECT
product_name,
inventory_value
FROM zepto_v2,avg_inventory
WHERE inventory_value>avg_value;

-- Using a CTE, calculate the total inventory value for each category.
WITH category_inventory AS
(
SELECT
category,
SUM(inventory_value) AS total_inventory
FROM zepto_v2
GROUP BY category
)

SELECT *
FROM category_inventory
ORDER BY total_inventory DESC;

-- Find the longest product names in the dataset.
SELECT
product_name,
LENGTH(product_name) AS name_length
FROM zepto_v2
ORDER BY name_length DESC
LIMIT 10

DROP TABLE IF EXISTS zepto_sales;

CREATE TABLE zepto_sales (
    category VARCHAR(120),
    product_name VARCHAR(200),
    mrp NUMERIC(10,2),
    discount_percent NUMERIC(5,2),
    available_quantity INT,
    discounted_price NUMERIC(10,2),
    weight_gms INT,
    out_of_stock BOOLEAN,
    quantity INT,
    inventory_value NUMERIC(12,2),
    discount_amount NUMERIC(10,2),
    stock_status VARCHAR(20),
    date DATE,
    base_demand INT,
    random_factor NUMERIC(5,2),
    day VARCHAR(20),
    year INT,
    weekend_factor NUMERIC(5,2),
    month INT,
    season_factor NUMERIC(5,2),
    price_factor NUMERIC(5,2),
    units_sold INT,
    daily_revenue NUMERIC(12,2),
    potential_revenue NUMERIC(12,2),
    discount_loss NUMERIC(12,2)
);

-- Top 10 Revenue Generating Products
SELECT
    product_name,
    SUM(daily_revenue) AS total_revenue
FROM zepto_sales
GROUP BY product_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Calculate the total revenue generated in each month to analyze monthly sales trends.
SELECT
    EXTRACT(MONTH FROM date) AS month,
    ROUND(SUM(daily_revenue), 2) AS total_revenue
FROM zepto_sales
GROUP BY EXTRACT(MONTH FROM date)
ORDER BY EXTRACT(MONTH FROM date);

-- Determine the total revenue contributed by each product category.
SELECT
    category,
    ROUND(SUM(daily_revenue),2) AS total_revenue
FROM zepto_sales
GROUP BY category
ORDER BY total_revenue DESC;

-- Find the top 10 products with the highest number of units sold.
SELECT
    product_name,
    SUM(units_sold) AS total_units_sold
FROM zepto_sales
GROUP BY product_name
ORDER BY total_units_sold DESC
LIMIT 10;

-- Analyze the total revenue lost due to discounts across different product categories.
SELECT
    category,
    ROUND(SUM(discount_loss),2) AS total_discount_loss
FROM zepto_sales
GROUP BY category
ORDER BY total_discount_loss DESC;

-- Compare revenue generated on weekends and weekdays.
SELECT
    CASE
        WHEN day IN ('Saturday','Sunday')
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    ROUND(SUM(daily_revenue),2) AS total_revenue
FROM zepto_sales
GROUP BY day_type;

-- Calculate the average number of units sold per day for each category.
SELECT
    category,
    ROUND(AVG(units_sold),2) AS avg_daily_sales
FROM zepto_sales
GROUP BY category
ORDER BY avg_daily_sales DESC;

-- Identify products that have the highest potential revenue before discounts.
SELECT
    product_name,
    ROUND(SUM(potential_revenue),2) AS total_potential_revenue
FROM zepto_sales
GROUP BY product_name
ORDER BY total_potential_revenue DESC
LIMIT 10;

-- Analyze the monthly demand by calculating total units sold in each month.
SELECT
    EXTRACT(MONTH FROM date) AS month,
    SUM(units_sold) AS total_units_sold
FROM zepto_sales
GROUP BY EXTRACT(MONTH FROM date)
ORDER BY EXTRACT(MONTH FROM date);

-- Identify the best-performing categories based on average daily revenue.
SELECT
    category,
    ROUND(AVG(daily_revenue),2) AS avg_daily_revenue
FROM zepto_sales
GROUP BY category
ORDER BY avg_daily_revenue DESC;










