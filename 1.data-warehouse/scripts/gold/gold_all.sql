/*
	This script contains all the views created for Gold layer.
	This is the final layer that will be used by the end users.
*/
--View-1 (Dim Table-1 Customers)
CREATE VIEW gold.dim_customers AS
(SELECT  
	ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS 'customer_key',
	ci.cst_id AS 'customer_id',
	ci.cst_key AS 'customer_number',
	ci.cst_firstname AS 'first_name',
	ci.cst_lastname AS 'last_name',
	ca.bdate AS 'birthdate',
	la.cntry AS 'country',
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		 ELSE COALESCE(ca.gen,'n/a')
	END AS 'gender',
	ci.cst_marital_status 'marital_status',
	ci.cst_create_date AS 'create_date'
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erm_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erm_loc_a101 AS la
ON ci.cst_key = la.cid
)

--View-2 (Dim Table-2 products)
CREATE VIEW gold.dim_products AS(
SELECT
	ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt,pn.prd_key) AS 'product_key',
	pn.prd_id AS 'product_id',
	pn.cat_id AS 'product_number',
	pn.prd_nm AS 'product_name',
	pn.prd_key AS 'category_id',
	pc.cat AS 'category',
	pc.subcat AS 'subcategory',
	pc.maintenance AS 'maintenance',
	pn.prd_line AS 'product_line',
	pn.prd_cost AS 'product_cost',
	pn.prd_start_dt AS 'start_date'
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erm_px_cat_g1v2 AS pc
ON pn.prd_key = pc.id
WHERE pn.prd_end_dt IS  NULL
--Removing Historical data (depends on business need)
)

--View-3 (Fact Table)
CREATE VIEW gold.fact_sales AS
(SELECT
	sd.sls_ord_num AS 'order_number',
	pr.product_key AS 'product_key',
	cs.customer_key AS 'customer_key',
	sd.sls_order_dt AS 'order_date',
	sd.sls_ship_dt AS 'shipping_date',
	sd.sls_due_dt AS 'due_date',
	sd.sls_sales AS 'sales',
	sd.sls_quantity AS 'quantity',
	sd.sls_price AS 'price'
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers AS cs
ON sd.sls_cust_id = cs.customer_id
)
