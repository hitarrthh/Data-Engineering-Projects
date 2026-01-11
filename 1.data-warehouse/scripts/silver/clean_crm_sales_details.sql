INSERT INTO silver.crm_sales_details(
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
)

SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN LEN(sls_order_dt) !=8 OR sls_order_dt<=0 THEN NULL
		 ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
	END AS 'sls_order_dt',
	CASE WHEN LEN(sls_ship_dt) !=8 OR sls_ship_dt<=0 THEN NULL
		 ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE)
	END AS 'sls_ship_dt',
	CASE WHEN LEN(sls_due_dt) !=8 OR sls_due_dt<=0 THEN NULL
		 ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE)
	END AS 'sls_due_dt',
	CASE WHEN  sls_sales IS NULL OR sls_sales !=ABS(sls_price)*sls_quantity OR sls_sales <0 
		 THEN ABS(sls_price)*sls_quantity
		 ELSE sls_sales
	END AS 'sls_sales',
	sls_quantity,
	CASE WHEN  sls_price IS NULL OR sls_sales <0 
		 THEN sls_sales/NULLIF(sls_quantity,0)
		 ELSE sls_price
	END AS 'sls_price'
FROM bronze.crm_sales_details