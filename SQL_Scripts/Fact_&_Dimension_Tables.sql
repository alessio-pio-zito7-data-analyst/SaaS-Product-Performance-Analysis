-- Creating views fact and dimension tables
-- Views are used to expose a clean star-schema layer for reporting and BI consumption.

--------------------------------------------------------------------------------------------

-- Grain:
-- 1 row = 1 feature usage record for a subscription on a specific date

CREATE VIEW fact_feature_usage AS
SELECT 
feature_usage_pk,
subscription_id,
usage_date,
feature_name,
usage_count, 
usage_duration_mins,
logged_errors_count

FROM feature_usage;

--------------------------------------------------------------------------------------------

-- Grain:
-- 1 row = 1 churn event record for a subscription on a specific date

CREATE VIEW fact_churn_events AS
SELECT 
churn_event_id,
account_id,
churn_date,
reason_code,
reactivation_event,
feedback_text,
refund_amount_usd

FROM churn_events;

--------------------------------------------------------------------------------------------

-- Grain:
-- 1 row = 1 account first signup on a specific date

-- Account dimension containing descriptive business attributes used for segmentation
-- and filtering (country, industry, signup date).

CREATE VIEW dim_accounts AS
SELECT 
account_id, 
account_name,
country, 
industry,
signup_date
FROM accounts;

-----------------------------------------------------------------------------------------------

-- Grain:
-- 1 row = 1 record for a subscription (es. created account on payed subscription or plan uprage/downgrade) on a specific date that belongs to one account only

-- Subscription dimension containing plan information used to analyze product adoption
-- and feature usage across subscription tiers.

CREATE VIEW dim_subscriptions AS 
SELECT 
t1.subscription_id, 
t1.account_id, 
t2.plan_tier, 
t1.start_date, 
t1.end_date, 
t1.status
FROM subscriptions_status_history t1
INNER JOIN subscriptions_details t2
	ON t1.subscription_id = t2.subscription_id;

----------------------------------------------------------------------------------------------

-- Grain:
-- 1 row = 1 full date record on a range of two years (2023-01-01 | 2024-12-31)

-- Date dimension generated using a recursive CTE to support time-based analysis.
-- Includes pre-calculated calendar attributes and sorting fields for BI reporting.

CREATE TABLE dim_date (

    full_date DATE PRIMARY KEY,

    day INT,

    month INT,

    month_name VARCHAR(20),

    quarter VARCHAR(2),

    year INT,

    month_year VARCHAR(20),
    
    year_month_sort INT

);

INSERT INTO dim_date
(
    full_date,
    day,
    month,
    month_name,
    quarter,
    year,
    month_year,
    year_month_sort
)

WITH RECURSIVE date_series AS (

    SELECT DATE('2023-01-01') AS full_date

    UNION ALL

    SELECT DATE_ADD(full_date, INTERVAL 1 DAY)

    FROM date_series

    WHERE full_date < '2024-12-31'

)

SELECT

    full_date,

    DAY(full_date),

    MONTH(full_date),

    MONTHNAME(full_date),

    CONCAT('Q', QUARTER(full_date)),

    YEAR(full_date),

    DATE_FORMAT(full_date, '%b-%Y'), 
    
    DATE_FORMAT(full_date, '%Y%m')

FROM date_series;