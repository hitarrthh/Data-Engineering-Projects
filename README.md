# 1. Data Warehouse Project: Medallion Architecture

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
---
# 2. EDA Project

This project focuses on **Exploratory Data Analysis (EDA)** and business intelligence auditing using the Gold layer of the data warehouse. It aims to uncover patterns, validate data integrity, and identify top-performing entities across the sales, product, and customer dimensions.

---

## 1. Project Architecture
The analysis phase interacts with the final tier of the Medallion architecture:
* **Gold Layer**: Business-ready Dimensions and Fact tables used as the primary source for all analytical queries.



---

## 2. Analysis Stages

### 🔍 Database & Metadata Exploration
* **Purpose**: To audit the structural integrity of the warehouse.
* **Logic**: 
    * Retrieves a comprehensive list of all tables and schemas within the database.
    * Inspects specific column details, including data types and nullability, for key tables like `dim_customers`.

### 🌐 Dimension & Date Exploration
* **Purpose**: To understand the categorical boundaries and temporal scope of the data.
* **Logic**:
    * Identifies unique geographic footprints (countries) and product hierarchies (categories and subcategories).
    * Calculates the business timespan by finding the delta between the first and last order dates.
    * Analyzes customer demographics, specifically identifying the age of the youngest and oldest customers.

### 📈 Measures & Magnitude Analysis
* **Purpose**: To quantify business performance through various aggregations.
* **Logic**:
    * **KPI Tracking**: Consolidates metrics such as Total Sales, Total Orders, Items Sold, and Average Price using `UNION ALL`.
    * **Distribution Analysis**: Groups data to find customer concentrations by country and gender, and product volume by category.
    * **Financial Performance**: Calculates total revenue generated per category and per individual customer.

### 🏆 Ranking & Advanced Analytics
* **Purpose**: To identify outliers and high-value targets.
* **Logic**:
    * **Window Functions**: Employs `DENSE_RANK()` to rank products and customers by revenue without gaps in ranking.
    * **Performance Extremes**: Identifies the "Top 5" and "Worst 5" products based on revenue to guide inventory decisions.

---

## 3. SQL File Inventory (EDA)

| Category | File Name | Description |
| :--- | :--- | :--- |
| **Metadata** | `database_exploration.sql` | Audits the database structure, tables, and column properties. |
| **Exploration** | `dimension_exploration.sql` | Explores unique values in the country, category, and product hierarchies. |
| **Exploration** | `date_exploration.sql` | Analyzes order timespans and customer age distributions. |
| **Metrics** | `measures_exploration.sql` | Aggregates high-level business KPIs such as total sales and customer counts. |
| **Analysis** | `magnitude_analysis.sql` | Performs distribution analysis using `GROUP BY` across various dimensions. |
| **Ranking** | `ranking_analysis.sql` | Uses ranking functions to find top-performing products and customers. |

---

## 4. Execution Order
1.  **Metadata Audit**: Run `database_exploration.sql` to verify the environment.
2.  **General Exploration**: Run `dimension_exploration.sql` and `date_exploration.sql` to understand data distributions.
3.  **KPI Baseline**: Run `measures_exploration.sql` to establish core business metrics.
4.  **Deep Dive**: Run `magnitude_analysis.sql` and `ranking_analysis.sql` for actionable business insights.
---
# 3. Advanced Data Analytics

This project marks the final analytical phase, focusing on **Advanced Data Analytics** and **Business Reporting**. It utilizes the Gold layer to perform complex time-series analysis, customer segmentation, and the creation of comprehensive performance reports.

---

## 1. Project Architecture
The advanced analytics phase serves as the intelligence layer, providing deep insights for strategic decision-making:
* **Gold Layer**: Serves as the high-integrity data source for complex window functions, CTEs (Common Table Expressions), and final reporting views.


---

## 2. Analytical Components

### 📈 Time-Series & Trend Analysis
* **Purpose**: To understand business momentum and growth patterns over time. * **Logic**: 
    * **Cumulative Analysis**: Calculates running totals and moving averages for sales to smooth out seasonal fluctuations.
    * **Change Over Time**: Aggregates monthly metrics for total sales, unique customer counts, and total quantity sold.
    * **Performance Trends**: Compares yearly product sales against the lifetime average and the previous year's performance (Year-over-Year analysis).

### 🎯 Data Segmentation & Behavioral Analysis
* **Purpose**: To categorize customers and products into actionable cohorts.
* **Logic**:
    * **Customer Segmentation**: Classifies customers into categories such as **VIP**, **Regular**, or **New** based on their total spend and relationship lifespan.
    * **Product Segmentation**: Segments the inventory based on cost ranges (e.g., Below 100, 100-500) to understand catalog distribution.
    * **Part-to-Whole Analysis**: Calculates the percentage contribution of each product category to the overall business revenue.

### 📜 Strategic Reporting Views
* **Purpose**: To provide consolidated, one-stop views for stakeholder reporting.
* **Logic**:
    * **Customer Report (`gold.report_customers`)**: Merges demographics with behavioral KPIs like Average Order Value (AOV), recency, and monthly spend.
    * **Product Report (`gold.report_products`)**: Aggregates product-level metrics including total customers per product, monthly revenue, and performance tiering (High/Medium/Low Performer).

---

## 3. SQL File Inventory (Advanced Analytics)

| Category | File Name | Description |
| :--- | :--- | :--- |
| **Trend** | `change_over_time_analysis.sql` | Tracks monthly shifts in sales, customer base, and volume. |
| **Trend** | `cumulative_analysis.sql` | Calculates rolling totals and moving averages for revenue. |
| **Performance** | `performance_analysis.sql` | Conducts Year-over-Year (YoY) comparisons and average benchmarking. |
| **Segmentation**| `data_segmentation.sql` | Segments products based on cost ranges. |
| **Segmentation**| `data_segmentation_2.sql` | Groups customers by loyalty and spending power. |
| **Analysis** | `part_to_whole_analysis.sql` | Measures category-level contribution to total sales percentage. |
| **Reporting** | `report_customers.sql` | Final view consolidating customer KPIs and age-group segmentation. |
| **Reporting** | `report_products.sql` | Final view consolidating product performance, lifespan, and recency. |

---

## 4. Execution Order
1.  **Metric Baselining**: Run `change_over_time_analysis.sql` and `cumulative_analysis.sql` for initial trends.
2.  **Comparative Analysis**: Execute `performance_analysis.sql` to identify growth or decline.
3.  **Customer Profiling**: Run `data_segmentation_2.sql` to identify high-value cohorts.
4.  **Final Deployment**: Execute `report_customers.sql` and `report_products.sql` to create permanent reporting views in the Gold layer.
