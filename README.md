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

## Data Model

A Star Schema data model was designed to support KPI calculation, trend analysis, customer segmentation, and dashboard performance.

The model separates business events (facts) from descriptive attributes (dimensions), following common Business Intelligence modelling practices.

## Star Schema

The analytical model consists of two fact tables and three dimension tables designed to support product usage, retention, churn, and time-series analysis.

![Star Schema](Star_Schema.png)
