/*
	Part-to-whole analysis
*/
--Finding categories that contrribute the most to the sales
WITH analysis AS
(
	SELECT
		p.category,
		SUM(s.sales) AS 'total_sales'
	FROM gold.fact_sales AS s
	LEFT jOIN gold.dim_products AS p
	ON p.product_key = s.product_key
	WHERE YEAR(s.order_date) IS NOT NULL
	GROUP BY p.category
)
SELECT
	*,
	SUM(total_sales) OVER() AS 'overall_sales',
	CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER())*100,2),' %')  AS 'contribution'
FROM analysis
ORDER BY total_sales DESC