INSERT INTO silver.crm_prd_info(
	prd_id,
	prd_key,
	cat_id,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,

)

SELECT
	prd_id,
	SUBSTRING(prd_key,7,LEN(prd_key)) AS 'prd_key',
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS 'cat_id',
	prd_nm,
	COALESCE(prd_cost,0) AS 'prd_cost',
	CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
		 WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Roads'
		 WHEN UPPER(TRIM(prd_line)) = 'S' THEN  'Other Sales'
		 WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Toruing'
		 ELSE 'n/a'
	END AS 'prd_line',
	CAST(prd_start_dt AS DATE) AS 'prd_start_dt',
	--prd_end_dt
	CAST(DATEADD(DAY,-1,LEAD(prd_start_dt)OVER(PARTITION BY prd_key ORDER BY prd_start_dt))AS DATE)  AS 'prd_end_date'
FROM bronze.crm_prd_info

