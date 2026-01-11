/*
	This script is used to explore different ways to prform aggregation 
	functions.
*/

--Findning the total sales
-- This gives the total revenue of the business
SELECT
	'total_sales' as 'measure_name',
	SUM(sales) AS 'measure'
FROM gold.fact_sales
UNION ALL
--Finding how many items were sold
SELECT 
	'items_sold',
	COUNT(quantity) 
FROM gold.fact_sales
UNION ALL
--Finding the Average selling price
SELECT
	'avg_price',
	AVG(price)  
FROM gold.fact_sales
UNION ALL
--Finding the total number of orders
SELECT
	'total_orders',
	COUNT(DISTINCT order_number) 
FROM gold.fact_sales
UNION ALL
--Finding total number of products
SELECT
	'total_products',
	COUNT(DISTINCT product_key)
FROM gold.dim_products
UNION ALL
--Finding the total number of customers
SELECT
	'total_customers',
	COUNT(DISTINCT customer_key) 
FROM gold.dim_customers
UNION ALL
--Finding all customers that have placed a order
SELECT
	'customers_placed_orders',
	COUNT(DISTINCT customer_key)
FROM gold.fact_sales