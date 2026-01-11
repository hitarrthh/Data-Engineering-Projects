/*
	This scropt checks how the business performs year-over-year.
	Good for trend analysis.
*/

WITH yearly_product_sales AS (
	SELECT
		YEAR(s.order_date) AS 'year',
		p.product_name,
		SUM(sales) AS 'total_sales'
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_products AS p
	ON p.product_key = s.product_key
	WHERE YEAR(s.order_date) IS NOT NULL
	GROUP BY YEAR(s.order_date),p.product_name
)
SELECT
	year,
	product_name,
	total_sales,
	AVG(total_sales) OVER(PARTITION BY product_name) AS 'avg_sales',
	total_sales - AVG(total_sales) OVER(PARTITION BY product_name) AS 'diff_avg',
	CASE 
		WHEN total_sales - AVG(total_sales) OVER(PARTITION BY product_name)>0 THEN 'Above Average'
		WHEN total_sales - AVG(total_sales) OVER(PARTITION BY product_name)<0 THEN 'Below Average'
		ELSE 'Same as Average'
	END AS 'avg_flag',
	LAG(total_sales,1) OVER(PARTITION BY product_name ORDER BY year ASC) AS 'prev_year_sales',
	total_sales - LAG(total_sales,1) OVER(PARTITION BY product_name ORDER BY year ASC) AS 'diff_prev_year',
	CASE 
		WHEN total_sales - LAG(total_sales,1) OVER(PARTITION BY product_name ORDER BY year ASC)>0 THEN 'Better Performance'
		WHEN total_sales - LAG(total_sales,1) OVER(PARTITION BY product_name ORDER BY year ASC)<0 THEN 'Worse Performance'
		ELSE 'Same Performance'
	END AS 'prev_year_flag'
FROM yearly_product_sales
ORDER BY product_name,year