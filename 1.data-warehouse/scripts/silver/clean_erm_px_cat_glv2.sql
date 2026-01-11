--silver.erm_px_cat_g1v2
INSERT INTO silver.erm_px_cat_g1v2(
	id,
	cat,
	subcat,
	maintenance
)

SELECT
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erm_px_cat_g1v2


