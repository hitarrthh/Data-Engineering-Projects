# Data Warehouse Project: Medallion Architecture

This project implements a three-tier data warehousing solution (Bronze, Silver, Gold) using SQL Server to transform raw CRM and ERP data into an analytical Star Schema.

---

## 1. Project Architecture
The pipeline follows the Medallion architecture to ensure data quality and traceability:
* **Bronze**: Raw data ingestion from source CSV files.
* **Silver**: Data cleansing, standardization, and integration.
* **Gold**: Business-ready Dimensions and Fact tables for reporting.



---

## 2. Pipeline Stages

### 🥉 Bronze Layer (Ingestion)
* **Purpose**: To land raw data into the SQL environment with no transformations.
* **Source Data**: CRM (Customers, Products, Sales) and ERP (Customers, Locations, Categories).
* **Automation**: The stored procedure `bronze.load_bronze` handles the `TRUNCATE` and `BULK INSERT` process, including error handling and execution logging.

### 🥈 Silver Layer (Transformation & Cleansing)
The Silver layer serves as the "Curated" zone. Data is pulled from the Bronze staging tables and undergoes significant cleansing and validation.
* **Data Architecture**: Defines the DDL with an added `dwh_create_date` audit column using `DATETIME2`.
* **Automation**: The stored procedure `silver.load_silver` manages the entire "Truncate and Insert" ETL process for this layer.
* **Customer Logic**: Deduplicates records using `ROW_NUMBER()`, standardizes marital status/gender, and cleanses names with `TRIM`.
* **Product Logic**: Parses keys, handles null costs via `COALESCE`, and emulates SCD logic by calculating `prd_end_dt` using the `LEAD()` function.
* **Sales Logic**: Converts integer dates to `DATE` types and recalculates sales/price for data integrity.
* **Geography Logic**: Standardizes country names (e.g., 'US' → 'United States') and removes hyphens from location IDs.

### 🥇 Gold Layer (Presentation)
* **Purpose**: Provides a Star Schema for reporting.
* **Dimensions**: 
    * `gold.dim_customers`: Unified profile joining CRM and ERP data with a surrogate key.
    * `gold.dim_products`: Cleaned catalog filtering out historical records where `prd_end_dt` is not null.
* **Fact Table**: 
    * `gold.fact_sales`: Central transaction table linking sales to Gold dimensions via surrogate keys.



---

## 3. SQL File Inventory

| Layer | File Name | Description |
| :--- | :--- | :--- |
| **Bronze** | `bronze_tables.sql` | Defines the DDL for the raw staging area for CRM and ERP data. |
| **Bronze** | `procedure_load_bronze.sql` | Stored procedure for automated bulk loading from CSV files. |
| **Silver** | `table_silver.sql` | Defines the DDL for Silver tables including audit columns. |
| **Silver** | `procdure_clean_all.sql` | Master procedure (`silver.load_silver`) to execute the full Silver ETL. |
| **Silver** | `clean_crm_cust_info.sql` | Deduplication and standardization logic for CRM customers. |
| **Silver** | `clean_crm_prd_info.sql` | Logic for parsing product keys and calculating validity dates. |
| **Silver** | `clean_crm_sales_details.sql` | Logic for date casting and financial metric validation. |
| **Silver** | `clean_erm_cust_az12.sql` | Cleansing for ERP demographics and birthdates. |
| **Silver** | `clean_erm_loc_a101.sql` | Standardization for geographic names and IDs. |
| **Silver** | `clean_erm_px_cat_glv2.sql` | Migration for product category metadata. |
| **Gold** | `dim_customer_table.sql` | View joining Silver tables for a unified customer profile. |
| **Gold** | `dim_product_table.sql` | View for products including category metadata. |
| **Gold** | `fact_sales_table.sql` | Logic for the central Sales fact view. |
| **Gold** | `gold_all.sql` | Consolidated script for all Gold layer views. |

---

## 4. Execution Order
1. Run `bronze_tables.sql` to establish the raw schema.
2. Execute the `bronze.load_bronze` procedure to ingest CSV data.
3. Run `table_silver.sql` to establish the cleansed schema.
4. Execute the `silver.load_silver` procedure to transform and load Silver data.
5. Deploy Gold views using `gold_all.sql` to enable analytics.
