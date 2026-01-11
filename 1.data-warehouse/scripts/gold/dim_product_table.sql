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
