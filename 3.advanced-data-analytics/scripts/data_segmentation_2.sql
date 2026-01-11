WITH segment AS (
    SELECT
        s.customer_key,
        SUM(s.price) AS total_spend,
        MIN(s.order_date) AS first_order,
        MAX(s.order_date) AS last_order,
        DATEDIFF(MONTH, MIN(s.order_date), MAX(s.order_date)) AS lifespan,
        CASE 
            WHEN DATEDIFF(MONTH, MIN(s.order_date), MAX(s.order_date)) >= 12 
                 AND SUM(s.price) > 5000 THEN 'VIP'
            WHEN DATEDIFF(MONTH, MIN(s.order_date), MAX(s.order_date)) >= 12 
                 AND SUM(s.price) <= 5000 THEN 'Regular'
            WHEN DATEDIFF(MONTH, MIN(s.order_date), MAX(s.order_date)) < 12 THEN 'New'
            ELSE 'None'
        END AS customer_category
    FROM gold.fact_sales s
    GROUP BY s.customer_key
)

SELECT
    customer_category,
    COUNT(customer_key) AS customer_count
FROM segment
GROUP BY customer_category
ORDER BY customer_count DESC;
