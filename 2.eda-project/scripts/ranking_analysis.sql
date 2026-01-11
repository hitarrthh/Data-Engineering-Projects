/*
	This script shows how to use the TOP function and Rank function
*/

--Finding top 5 revenue products
SELECT TOP 5
	p.product_name,
	SUM(f.price) AS 'revenue'
FROM gold.dim_products AS p
LEFT JOIN gold.fact_sales AS f
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY revenue DESC

--solving using window function
SELECT
	product_name,
	revenue
FROM(SELECT 
	p.product_name,
	SUM(f.price) AS 'revenue',
	DENSE_RANK() OVER(ORDER BY sum(f.price) DESC) AS 'rnk'
FROM gold.dim_products AS p
LEFT JOIN gold.fact_sales AS f
ON p.product_key = f.product_key
GROUP BY p.product_name)t
WHERE rnk<=5

--Finding worst 5 products
SELECT TOP 5
	p.product_name,
	SUM(f.price) AS 'revenue'
FROM gold.fact_sales AS f
LEFT JOIN  gold.dim_products AS p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY revenue ASC

--Finding top 10 customers with highest revenue generated
SELECT
	customer_key,
	first_name,
	last_name,
	revenue
FROM(SELECT 
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.price) AS 'revenue',
	DENSE_RANK() OVER(ORDER BY sum(f.price) DESC) AS 'rnk'
FROM gold.fact_sales AS f 
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_key
GROUP BY c.customer_key,c.first_name,c.last_name)t
WHERE rnk<10

--Finding 3 worst performing customer
SELECT TOP 3
	c.customer_key,
	c.first_name,
	c.last_name,
	COUNT(DISTINCT order_number) AS 'total_orders'
FROM gold.fact_sales AS f 
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_key
GROUP BY c.customer_key,c.first_name,c.last_name
ORDER BY total_orders ASC