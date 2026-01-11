/*
	This script analysis the changes in various aspect with respect to time.
*/

--Aggregating data based on date
SELECT 
	FORMAT(order_date,'yyyy-MM') AS 'date',
	SUM(sales) AS 'total_sales',
	COUNT(DISTINCT customer_key) AS 'total_customers',
	SUM(quantity) AS 'total_quantitiy'
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date,'yyyy-MM')
ORDER BY date