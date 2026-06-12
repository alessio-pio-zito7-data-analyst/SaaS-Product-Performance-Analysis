# SaaS Product Usage & Retention Analysis

## Project Overview

This Business Intelligence project analyses product adoption, engagement, retention, and churn across a SaaS platform using SQL, data modelling, and Power BI.

## Business Problem

The objective of this project is to help Product and Customer Success stakeholders understand:

- Product Performance
- Feature Adoption
- Customer Retention
- Customer Churn
- Overall Business Trends

## Analytical Approach

The analysis followed a structured Business Intelligence workflow:

Business Context → Data Modeling → Data Validation → Business Questions → KPI Definition → KPI Logic → SQL Development → Dashboard Design

The business questions, KPI definitions, KPI calculation logic, and SQL-based findings were documented before dashboard design.

Supporting documentation is available in the repository:

- [Business Questions and KPI Definition](Business_Questions_and_KPIs_Definition/)

## Dashboard Preview

![Dashboard Preview](Power%20BI/Power_BI_Dashboard_Screenshot.png)

## Key Findings

- Feature adoption remained consistently high across all major product features.

- Customer retention remained low despite strong feature usage and engagement.

- Product usage alone does not appear to fully explain customer retention and churn outcomes, suggesting that additional customer-level factors should be investigated.

## Skills Demonstrated

- SQL
- Data Modelling
- Power BI
- KPI Design
- Product Analytics
- Data Storytelling

# Business Understanding

## Stakeholder

Product Manager

## Stakeholder Goal

Understand how customers interact with product features and identify whether specific usage patterns are associated with retention or churn.

## Business Questions & KPI Framework 

### Which product features drive the highest user engagement?

**KPIs**

- Total Feature Usage
- Total Usage Duration Mins

**Business Purpose**

Measures feature engagement.

### How frequently are product features used?

**KPI**

- Feature Usage Frequency | can be calculated Daily, Weekly, Monthly, Yearly

**Business Purpose**

Measures how often features are used in a specific time window.

### How much time do users spend using each feature?

**KPIs**

- Total Usage Duration Mins 
- Average Usage Duration Mins 
- Average Usage Count 

**Business Purpose**

Measures time spent using each feature.

### Which features are associated with higher customer retention?

**KPI**

- Retention Rate By Feature

**Business Purpose**

Measures how many accounts did not cancel.

### Which features are associated with higher customer churn?

**KPI**

- Churn Rate By Feature

**Business Purpose**

Measures how many accounts did cancel.

### Which features show low adoption and may require improvement?

**KPIs**

- Feature Adoption Rate
- Total Feature Usage

**Business Purpose**

Measures how many accounts are effectively using a feature.

## Analytical Findings

Supporting Queries Script is available here:

- [KPIs Calculation MySQL](SQL_Scripts/KPIs_Calculation_MySQL.sql)

The SQL analysis identified several notable patterns before dashboard development:

- Feature adoption remained consistently high across all product features, ranging between 72% and 82%.

- Feature usage was relatively balanced across the product portfolio, with no feature showing critically low engagement.

- The most frequently used features also generated the highest total usage duration, indicating sustained engagement rather than occasional interactions.

- Retention rates remained relatively similar across all features, suggesting that no individual feature emerged as a clear retention driver.

- Churn and retention patterns indicate that additional variables such as customer characteristics, subscription plans, industry segments, or churn reasons should be investigated in future analyses.

# Technical Implementation

## Data Quality & Validation

Before building the analytical model and calculating KPIs, the dataset underwent a structured data ingestion, debugging, and validation process.

A separate project was created to document the complete data preparation workflow, including data ingestion, source-level validation, debugging activities, and data quality checks.

**Previous Project Documentation**

- [SaaS Dataset Cleaning & Data Modelling Project](https://github.com/alessio-pio-zito7-data-analyst/SaaS-Dataset-Cleaning-Data-Modelling-Project)

## Issues Identified in the Original Dataset

During the ingestion and exploration process, several inconsistencies were identified, including:

- misleading boolean flags
- duplicated identifiers
- mixed business logic
- formatting and NULL issues
- inconsistent relational modelling
- subscription logic stored in non-normalized structures

These issues would have compromised:
- metric consistency
- relational integrity
- KPI reliability
- downstream analytical accuracy

## Data Ingestion & Source Validation

The raw SaaS dataset was imported into MySQL and validated before analytical modelling.

## Data Model Schema

Final relational dataset model created after the cleaning and restructuring process using Excel and MySQL.
The dataset model was created in Power BI.

![Data Model Schema](Processed_Dataset/Data_Model_Overview.png)

Documented activities included:

- Data ingestion using SQL scripts
- Primary Key validation
- Foreign Key validation
- Null and missing value checks
- Whitespace and formatting checks
- Business logic validation
- Data debugging and correction of identified issues

## SQL Data Ingestion Screenshot Sample 

![Data Ingestion Example](Data_Ingestion_Debug_and_Validation/Data_Ingestion_Example_Screenshot.png)

**Supporting Documentation**

- [Full Data Ingestion SQL](Data_Ingestion_Debug_and_Validation/Data_Ingestion.sql)
- [Full Debugging & Data Validation SQL](Data_Ingestion_Debug_and_Validation/Debugging_&_Data_Validation.sql)

## Data Model

A Star Schema data model was designed to support KPI calculation, trend analysis, customer segmentation, and dashboard performance.

The model separates business events (facts) from descriptive attributes (dimensions), following common Business Intelligence modelling practices.

## Star Schema

The analytical model consists of two fact tables and three dimension tables designed to support product usage, retention, churn, and time-series analysis.

![Star Schema](Star_Schema.png)

## Relationship Validation

After creating the fact and dimension tables, additional validation was performed to verify the integrity of the analytical model.

Validation activities included:

- Dimension Primary Key uniqueness checks
- Orphan record detection
- Referential integrity validation
- Fact-to-dimension relationship validation

**Supporting Documentation**

- [Fact & Dimension Tables Creation Script](SQL_Scripts/Fact_&_Dimension_Tables.sql)
- [Relationship Validation Checks](SQL_Scripts/Relationships_Checks.sql)

These validation steps ensured that KPI calculations and dashboard metrics were built on a reliable and consistent analytical model.

## KPI Calculation Logic

Before SQL development, the calculation logic for each KPI was documented, including formulas, source tables, and required joins.

**Supporting Documentation**

- [KPI Calculation Sheet](Business_Questions_and_KPIs_Definition/KPI_Calculation_Sheet.md)

| KPI | Formula | Source Tables |
|------|------|------|
| Total Feature Usage | SUM(usage_count) | fact_feature_usage |
| Total Usage Duration Mins | SUM(usage_duration_mins) | fact_feature_usage |
| Feature Usage Frequency | SUM(usage_count) by day/week/month/year | fact_feature_usage |
| Average Usage Duration Mins | AVG(usage_duration_mins) | fact_feature_usage |
| Average Usage Count | AVG(usage_count) | fact_feature_usage |
| Retention Rate By Feature | Retained Accounts Using Feature / Total Accounts Using Feature | fact_feature_usage, dim_subscriptions, dim_accounts, fact_churn_events |
| Churn Rate By Feature | Churned Accounts Using Feature / Total Accounts Using Feature | fact_feature_usage, dim_subscriptions, dim_accounts, fact_churn_events |
| Feature Adoption Rate | Accounts Using Feature / Total Active Accounts | fact_feature_usage, dim_subscriptions, dim_accounts |

## SQL Development

SQL was used throughout the project to:

- Create fact and dimension views
- Validate data quality and relationships
- Calculate KPI metrics
- Generate analytical datasets for Power BI

Each KPI was initially developed as a standalone SQL query to validate the calculation logic and answer the corresponding business question.

Where relevant, KPI calculations were structured to support year-over-year and time-series analysis for the 2023–2024 period. Other KPIs were intentionally aggregated across the full analysis period (both 2023 and 2024) to align with the dashboard design and business reporting requirements.

Once validated, the KPI queries were converted into SQL views and used as the primary data source for Power BI reporting.

This approach centralized business logic within the database layer, reducing the need for complex Power BI calculations while improving model simplicity, maintainability, and performance.

**Supporting SQL KPI Calculation Script**

- [SQL Script](SQL_Scripts/KPIs_Calculation_MySQL.sql)

## Example KPI Output

The example below shows the SQL output used to calculate Retention Rate and Churn Rate by Feature for 2023 and 2024.

![Retention and Churn Rate by Feature](SQL_Scripts/Output_Example_Churn_Retention_By_Feature_Screenshot.png)

## Power BI Development

The Power BI dashboard was developed using the validated Star Schema and SQL-based KPI views created during the analytical phase.

Rather than recreating KPI calculations in Power BI, the dashboard consumes pre-calculated SQL views, ensuring consistency between the database layer and the reporting layer.

This approach simplified the Power BI model, reduced calculation complexity, and centralized business logic within the database.

## Power BI Data Model

The Power BI dataset combines fact tables, dimension tables, and SQL-based KPI views generated during the SQL development phase.

![Power BI Data Model](Power%20BI/Power_BI_Data_Model_Screenshot.png)

## Dashboard Design Principles

The dashboard was designed to answer the Product Manager's business questions as quickly as possible.

Visualizations were selected to support:

- KPI monitoring
- Feature-level comparison
- Trend analysis
- Retention and churn evaluation
- Executive-level decision making

## Supporting Documentation

- [Power BI Dashboard File](Power%20BI)

## Advanced SQL Analysis (BONUS)

In addition to the KPI calculations used for dashboard development, exploratory SQL analysis was performed to investigate product usage patterns and demonstrate advanced analytical techniques.

These analyses were not used as dashboard data sources, but were developed to explore the dataset and answer additional business questions.

Techniques demonstrated include:

- Common Table Expressions (CTEs)
- Window Functions
- LAG()
- Year-over-Year (YoY) Analysis
- Trend Analysis
- Multi-step Analytical Queries

### Example: Year-over-Year Feature Engagement Analysis

The example below uses the `LAG()` window function to compare yearly feature engagement metrics and calculate YoY growth percentages.

![Advanced SQL Analysis](Sql_Advanced_Analysis/KPIs_1_&_2_Output.png)

**Supporting Documentation**

- [Advanced SQL Analysis](MySQL_Advanced_Analysis.sql)

## Conclusion

This project demonstrates an end-to-end Business Intelligence workflow, covering data ingestion, data validation, dimensional modelling, KPI design, SQL analysis, and Power BI dashboard development.

The objective was not only to build a dashboard, but to follow a structured BI process that transforms raw data into actionable business insights.

Thank you for reviewing this project

--- 

*Alessio Pio Zito*

*Amsterdam, The Netherlands*

*June 2026*
