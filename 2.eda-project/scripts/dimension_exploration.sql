/*
	This script is used to Explore the dimenstions in the different tables.
	Feel free to explore different columns in tables and do not limit to this
*/

--Exploring different countries in the table
SELECT
	DISTINCT country 
FROM gold.dim_customers;

--Exploring different types of category
SELECT DISTINCT 
	category
FROM gold.dim_products

--Exploring category and subcategory 
SELECT DISTINCT	
	category,
	subcategory
FROM gold.dim_products

--Exploring thr product names too
SELECT DISTINCT	
	category,
	subcategory,
	product_name
FROM gold.dim_products
