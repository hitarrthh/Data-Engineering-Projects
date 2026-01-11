
CREATE VIEW gold.report_products AS
WITH base_quey AS(
SELECT
	f.order_number,
	f.customer_key,
	f.order_date,
	f.price,
	f.quantity,
	f.product_key,
	p.product_name,
	p.category,
	p.subcategory
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
)

, aggregated_query AS (
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	SUM(price) AS 'total_sales',
	sum(quantity) AS 'total_quantitiy',
	count(DISTINCT customer_key) AS 'total_customers',
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS 'lifespan',
	COUNT(DISTINCT order_number) AS 'total_orders',
	MAX(order_date) AS 'recent_order'
FROM base_quey
GROUP BY product_key, product_name, category, subcategory
)
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	CASE WHEN total_sales>50000 THEN 'High-Performer'
		 WHEN total_sales>=10000 THEN 'Medium-Performer'
		 ELSE 'Low-Performer'
	END AS 'product_category',
	recent_order,
	DATEDIFF(MONTH,recent_order,GETDATE()) AS 'recency',
	lifespan,
	total_orders,
	total_sales,
	total_quantitiy,
	ROUND(CAST(total_sales AS FLOAT) / NULLIF(total_orders,0),2) AS 'average_order_revemue',
	ROUND(CAST(total_sales AS FLOAT) / NULLIF(lifespan,0),2) AS 'avg_monthly_revenue'
FROM aggregated_query