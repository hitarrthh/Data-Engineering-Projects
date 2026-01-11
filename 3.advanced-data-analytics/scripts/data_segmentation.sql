--Segmenting data based on cost range and counting the number of products
--in that range
WITH product_segment AS (
    SELECT
        product_key,
        product_name,
        product_cost,
        CASE 
            WHEN product_cost < 100 THEN 'Below 100'
            WHEN product_cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN product_cost BETWEEN 501 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)

SELECT
    cost_range,
    COUNT(product_key) AS total_product
FROM product_segment
GROUP BY cost_range
ORDER BY total_product DESC;