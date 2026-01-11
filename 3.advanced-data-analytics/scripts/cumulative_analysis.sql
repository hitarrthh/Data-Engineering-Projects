/*
	This script is used to perform cumulative analysis to find the
	total sales and average price trend over the months
*/

--Calculating total sales per month and rolling total
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER( ORDER BY order_date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 'running_total' ,
	AVG(avg_price) OVER( ORDER BY order_date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 'moving_average' 
FROM(SELECT
	DATETRUNC(MONTH,order_date) AS 'order_date',
	SUM(sales) AS 'total_sales',
	AVG(price) AS 'avg_price'
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH,order_date)
)t