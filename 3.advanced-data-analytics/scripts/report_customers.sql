/*
	This report consolidates key product metrics and behaviors.
	1. Gathers essential fields such as customer name, price, age, and order_date.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
*/

CREATE VIEW gold.report_customers AS
    WITH base_query AS(
        SELECT
            f.order_number,
            f.product_key,
            f.order_date,
            f.price,
            f.quantity,
            c.customer_key,
            c.customer_number,
            CONCAT(c.first_name,' ',c.last_name) AS 'customer_name',
            DATEDIFF(YEAR,c.birthdate,GETDATE()) AS 'age'
        FROM gold.fact_sales AS f
        LEFT JOIN gold.dim_customers AS c
        ON f.customer_key = c.customer_key
        WHERE f.order_date IS NOT NULL
    )
    , aggregated_query AS (
        SELECT 
            customer_key,
            customer_number,
            customer_name,
            age,
            COUNT(DISTINCT order_number) AS 'total_orders',
            SUM(price) AS 'total_sales',
            sum(quantity) AS 'total_quantity',
            COUNT(DISTINCT product_key) AS 'total_prodcut',
            MAX(order_date) AS 'recent_order',
            DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS 'lifespan'
        FROM base_query
        GROUP BY customer_key,customer_number,customer_name,age
    )

    SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
        CASE 
             WHEN age<20 THEN 'Under 20'
             WHEN age BETWEEN 20 AND 29  THEN '20-29'
             WHEN age BETWEEN 30 AND 39  THEN '30-39'
             WHEN age BETWEEN 40 AND 49  THEN '40-49'
             ELSE '50 and Above'
        END AS 'age_group',
        CASE 
                WHEN lifespan >= 12 
                     AND total_sales > 5000 THEN 'VIP'
                WHEN lifespan >= 12 
                     AND total_sales <= 5000 THEN 'Regular'
                WHEN lifespan < 12 THEN 'New'
                ELSE 'None'
            END AS 'customer_category',
        recent_order,
        DATEDIFF(MONTH,recent_order,GETDATE()) AS 'recency',
        total_orders,
        total_sales,
        total_quantity,
        total_prodcut,
        lifespan,
        CASE    
             WHEN total_orders =0 THEN 0
             ELSE ROUND(CAST(total_sales AS FLOAT)/CAST(total_orders AS FLOAT),2) 
        END AS 'avg_order_value',
        CASE    
             WHEN lifespan =0 THEN 0
             ELSE total_sales / lifespan
        END AS 'average_monthly_spend'
    FROM aggregated_query
