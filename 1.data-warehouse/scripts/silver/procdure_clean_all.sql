/*
	This Stored Procedure will clean the data from Bronze layer and store the 
	data in Silver layer
	use EXEC silver.load_silver to run this Procedure
	Method used: TRUNCATE AND INSERT
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	 BEGIN TRY
		DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME
		--silver.crm_cust_info
		SET @batch_start_time = GETDATE()
		PRINT('TRUNCATE silver.crm_cust_info')
		SET @start_time = GETDATE()
		TRUNCATE TABLE silver.crm_cust_info
		PRINT('INSERTING silver.crm_cust_info')
		INSERT INTO silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
		) 
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS 'cst_firstname',
			TRIM(cst_lastname) AS 'cst_lastname',
			--cst_marital_status,
			CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M'  THEN 'Married'
				 WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				 ELSE 'n/a'
			END AS 'cst_marital_status',
			CASE WHEN UPPER(TRIM(cst_gndr)) = 'M'  THEN 'Male'
				 WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				 ELSE 'n/a'
			END AS 'cst_gndr',
			cst_create_date
		FROM(SELECT
			*,
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS 'flag_last'
		FROM bronze.crm_cust_info)t
		WHERE flag_last =1 AND cst_id IS NOT NULL
		SET @end_time = GETDATE()
		PRINT('Total Time to load this Table: '+CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR)+'Seconds')
		PRINT('------------------------------------');

		--silver.crm_prd_info
		PRINT('TRUNCATE silver.crm_prd_info');
		SET @start_time = GETDATE()
		TRUNCATE TABLE silver.crm_prd_info
		PRINT('INSERTING silver.crm_prd_info');
		INSERT INTO silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
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
		SET @end_time = GETDATE()
		PRINT('Total Time to load this Table: '+CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR)+'Seconds')
		PRINT('------------------------------------');

		--silver.crm_sales_details
		PRINT('TRUNCATE silver.crm_sales_details')
		SET @start_time = GETDATE()
		TRUNCATE TABLE silver.crm_sales_details
		PRINT('INSERTING silver.crm_sales_details')
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
		SET @end_time = GETDATE()
		PRINT('Total Time to load this Table: '+CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR)+'Seconds')
		PRINT('------------------------------------');

		-- silver.erm_cust_az12
		PRINT('TRUNCATE silver.erm_cust_az12')
		SET @start_time = GETDATE()
		TRUNCATE TABLE silver.erm_cust_az12
		PRINT('INSERTING silver.erm_cust_az12')
		INSERT INTO silver.erm_cust_az12(
			cid,
			bdate,
			gen
		)

		SELECT
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
				 ELSE cid
			END AS 'cid',
			CASE WHEN bdate>GETDATE() THEN NULL
				ELSE bdate
			END AS 'bdate',
			CASE WHEN UPPER(TRIM(gen)) IN ('F','Female') THEN 'Female'
				 WHEN UPPER(TRIM(gen)) IN ('M','Male') THEN 'Male'
				 ELSE 'n/a'
			END AS 'gen'
		FROM bronze.erm_cust_az12
		SET @end_time = GETDATE()
		PRINT('Total Time to load this Table: '+CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR)+'Seconds')
		PRINT('------------------------------------');

		--silver.erm_loc_a101
		PRINT('TRUNCATE silver.erm_loc_a101')
		SET @start_time = GETDATE()
		TRUNCATE TABLE silver.erm_loc_a101
		PRINT('INSERTING silver.erm_loc_a101')
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
		SET @end_time = GETDATE()
		PRINT('Total Time to load this Table: '+CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR)+'Seconds')
		PRINT('------------------------------------');

		--silver.erm_px_cat_g1v2
		PRINT('TRUNCATE silver.erm_px_cat_g1v2')
		SET @start_time = GETDATE()
		TRUNCATE TABLE silver.erm_px_cat_g1v2
		PRINT('INSERTING silver.erm_px_cat_g1v2')
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
		SET @end_time = GETDATE()
		PRINT('Total Time to load this Table: '+CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR)+'Seconds')
		PRINT('------------------------------------');
		SET @batch_end_time = GETDATE()
		PRINT('Total Time to load All Table: '+CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time)AS NVARCHAR)+'Seconds')
		PRINT('------------------------------------');
	 END TRY
	 BEGIN CATCH
		PRINT('------------------------------------');
		PRINT('Error Message: '+CAST(ERROR_MESSAGE() AS NVARCHAR));
		PRINT('Error Number: '+CAST(ERROR_NUMBER() AS NVARCHAR));
		PRINT('Error State: '+CAST(ERROR_STATE() AS NVARCHAR));
	 END CATCH
END

