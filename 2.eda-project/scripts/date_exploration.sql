/*
	In this scropt the exploration is done based on date columns only 
*/

--Checking the timespan between first and last order
SELECT
	MIN(order_date) AS 'first_order_date',
	MAX(order_date) AS 'last_order_date',
	DATEDIFF(YEAR,MIN(order_date),MAX(order_date)) AS 'timespan_years'
FROM gold.fact_sales 

--Finding the youngest and oldest customer
SELECT
	MIN(birthdate) AS 'youngest_birthdate',
	MIN(DATEDIFF(YEAR,birthdate,GETDATE())) AS 'youngest_customer_age',
	MAX(birthdate) AS 'oldest_birthdate',
	MAX(DATEDIFF(YEAR,birthdate,GETDATE())) AS 'oldest_customer_age'
FROM gold.dim_customers
