-- Checking for duplicate primary keys in dimension tables
-- Expected result: 0 rows returned

SELECT full_date, COUNT(*) as duplicates 
FROM dim_date
GROUP BY full_date
HAVING COUNT(*) > 1; 

----------------------------------------------------------

SELECT account_id, COUNT(*) as duplicates 
FROM dim_accounts
GROUP BY account_id
HAVING COUNT(*) > 1; 

----------------------------------------------------------

SELECT subscription_id, COUNT(*) as duplicates 
FROM dim_subscriptions
GROUP BY subscription_id
HAVING COUNT(*) > 1;

----------------------------------------------------------

-- Checking for orphan records between fact and dimension tables
-- Expected result: 0 rows returned

SELECT *
FROM fact_feature_usage t1
LEFT JOIN dim_subscriptions t2
	ON t1.subscription_id = t2.subscription_id
WHERE t2.subscription_id IS NULL;

--------------------------------------------------------

SELECT *
FROM fact_feature_usage t1
LEFT JOIN dim_date t2
	ON t1.usage_date = t2.full_date
WHERE t2.full_date IS NULL;

--------------------------------------------------------

SELECT *
FROM fact_churn_events t1
LEFT JOIN dim_accounts t2
	ON t1.account_id = t2.account_id
WHERE t2.account_id IS NULL;

-------------------------------------------------------

SELECT *
FROM fact_churn_events t1
LEFT JOIN dim_date t2
	ON t1.churn_date = t2.full_date
WHERE t2.full_date IS NULL;

------------------------------------------------------

-- Validating referential integrity by comparing row counts before and after joins
-- Expected result: 25,000 rows returned in both queries

SELECT COUNT(*) AS fact_rows
FROM fact_feature_usage;

SELECT COUNT(*)
FROM fact_feature_usage t1
INNER JOIN dim_subscriptions t2
    ON t1.subscription_id = t2.subscription_id;
    
------------------------------------------------------

-- Validating referential integrity by comparing row counts before and after joins
-- Expected result: 600 rows returned in both queries

SELECT COUNT(*) AS fact_rows
FROM fact_churn_events;

SELECT COUNT(*)
FROM fact_churn_events t1
INNER JOIN dim_accounts t2
	ON t1.account_id = t2.account_id;