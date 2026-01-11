/*
	The purpose of this script is to load the data form the csv files into the SQL server
	Method used is TRUNCATE and BULK INSERT
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME,@end_time DATETIME,@start_time_batch DATETIME,@end_time_batch DATETIME
	BEGIN TRY
		SET @start_time_batch = GETDATE()
		PRINT('Loading The Bronze Layer');
		SET @start_time = GETDATE();
		PRINT('Truncating bronze.crm_cust_info');
		TRUNCATE TABLE bronze.crm_cust_info
		PRINT('Loading bronze.crm_cust_info');
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\Admin\Desktop\Work\SQL\datawarehouse_project\datasets\source_crm\cust_info.csv'
		WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK 
		)
		SET @end_time = GETDATE()
		PRINT('Duration -> '+CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR) +' seconds');
		PRINT('--------------------------------------------------');

		PRINT('Truncating bronze.crm_prd_info');
		SET @start_time = GETDATE()
		TRUNCATE TABLE bronze.crm_prd_info
		PRINT('Loading bronze.crm_prd_info');
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\Admin\Desktop\Work\SQL\datawarehouse_project\datasets\source_crm\prd_info.csv'
		WITH(
				FIRSTROW=2,
				FIELDTERMINATOR = ',',
				TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT('Duration -> '+CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR) +' seconds');
		PRINT('--------------------------------------------------');

		PRINT('Truncating bronze.crm_sales_details');
		SET @start_time = GETDATE()
		TRUNCATE TABLE bronze.crm_sales_details
		PRINT('Loading bronze.crm_sales_details');
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\Admin\Desktop\Work\SQL\datawarehouse_project\datasets\source_crm\sales_details.csv'
		WITH(
				FIRSTROW=2,
				FIELDTERMINATOR = ',',
				TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT('Duration -> '+CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR) +' seconds');
		PRINT('--------------------------------------------------');
		PRINT('Loading erp Data');
		PRINT('Truncating bronze.erm_cust_az12');
		SET @start_time = GETDATE()
		TRUNCATE TABLE bronze.erm_cust_az12
		PRINT('Loading bronze.erm_cust_az12');
		BULK INSERT bronze.erm_cust_az12
		FROM 'C:\Users\Admin\Desktop\Work\SQL\datawarehouse_project\datasets\source_erp\cust_az12.csv'
		WITH(
				FIRSTROW=2,
				FIELDTERMINATOR = ',',
				TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT('Duration -> '+CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR) +' seconds');
		PRINT('--------------------------------------------------');

		PRINT('Truncating bronze.erm_loc_a101');
		SET @start_time = GETDATE()
		TRUNCATE TABLE bronze.erm_loc_a101
		PRINT('Loading bronze.erm_loc_a101');
		BULK INSERT bronze.erm_loc_a101
		FROM 'C:\Users\Admin\Desktop\Work\SQL\datawarehouse_project\datasets\source_erp\loc_a101.csv'
		WITH(
				FIRSTROW=2,
				FIELDTERMINATOR = ',',
				TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT('Duration -> '+CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR) +' seconds');
		PRINT('--------------------------------------------------');

		PRINT('Truncating bronze.erm_px_cat_g1v2');
		SET @start_time = GETDATE()
		TRUNCATE TABLE bronze.erm_px_cat_g1v2
		PRINT('Loading bronze.erm_px_cat_g1v2');
		BULK INSERT bronze.erm_px_cat_g1v2
		FROM 'C:\Users\Admin\Desktop\Work\SQL\datawarehouse_project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH(
				FIRSTROW=2,
				FIELDTERMINATOR = ',',
				TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT('Duration -> '+CAST(DATEDIFF(SECOND,@start_time,@end_time)AS NVARCHAR) +' seconds');
		PRINT('--------------------------------------------------');
		SET @end_time_batch = GETDATE()
		PRINT('--------------------------------------------------');
		PRINT('Duration Of whole Batch-> '+CAST(DATEDIFF(SECOND,@start_time_batch,@end_time_batch)AS NVARCHAR) +' seconds');
		PRINT('--------------------------------------------------');
	END TRY
	BEGIN CATCH
	PRINT('--------------------------------------------------');
	PRINT('ERROR MESSAGE' + ERROR_MESSAGE())
	PRINT('ERROR NUMBER'+CAST(ERROR_NUMBER() AS NVARCHAR));
	PRINT('ERROR STATE'+CAST(ERROR_STATE() AS NVARCHAR));
	PRINT('--------------------------------------------------');
	END CATCH
END

