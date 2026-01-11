/*
	CREATING DATABASE AND SCHEMA

	This script will create a new Database named 'DataWarehouse' and if already exists
	will drop it.
	If DataWarehouse Database already exits in you environment then this script will delete
	the data in it so be careful before running it.
	3 Schema are created named bronze,silver and gold.
*/

USE Master;
GO

--Drop and recreate the DataWarehouse Database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
		ALTER DATABASE DataWarehouse SET SINGLE_USE WITH ROLLBACK IMMEDIATE
		DROP DATABASE DataWarehouse
END;
GO
--Create and Use the new DATABASE
CREATE DATABASE DataWarehouse;
GO
USE DataWarehouse;
GO
--Create Schema
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO