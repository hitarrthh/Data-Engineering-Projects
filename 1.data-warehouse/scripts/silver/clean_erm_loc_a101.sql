--silver.erm_loc_a101
INSERT INTO silver.erm_loc_a101(
	cid,
	cntry
)

SELECT  
	REPLACE(cid,'-','') as 'cid',
	--cntry
	CASE WHEN TRIM(cntry) IN ('DE','Germany') THEN 'Germany'
		 WHEN TRIM(cntry) IN ('USA','US','United States') THEN 'United States'
		 WHEN TRIM(cntry) IN ('') THEN 'n/a'
		 when TRIM(cntry) IS NULL THEN 'n/a'
		 ELSE TRIM(cntry)
	END AS 'cntry'
FROM bronze.erm_loc_a101