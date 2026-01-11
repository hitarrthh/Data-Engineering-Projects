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