-- Calculating the KPIs present in the document "KPIs_calculation_sheet.md" in Mysql

-- 1) Total Feature Usage
SELECT 
DISTINCT feature_name,
	SUM(usage_count) AS total_feature_usage
    
	FROM fact_feature_usage 
GROUP BY feature_name, YEAR(usage_date)
ORDER BY total_feature_usage DESC;

------------------------------------------------------------------------------

-- 2) Total Usage Duaration Mins

SELECT 
DISTINCT feature_name,
	SUM(usage_duration_mins) AS total_usage_duration_mins
    
	FROM fact_feature_usage 
GROUP BY feature_name, YEAR(usage_date)
ORDER BY total_usage_duration_mins DESC;

------------------------------------------------------------------------------

-- 3) Feature Usage Frequency (by 2023-2024)  
 
SELECT
    feature_name,
    YEAR(usage_date) AS year,
    MONTH(usage_date) AS month,
    SUM(usage_count) AS feature_usage_frequency

	FROM fact_feature_usage
GROUP BY feature_name, YEAR(usage_date), MONTH(usage_date)
ORDER BY year, month;

------------------------------------------------------------------------------

-- 4) Average Usage Duaration Mins and Average Usage Count
CREATE OR REPLACE VIEW view_tot_avg_usage_duration_mins AS
SELECT 
DISTINCT feature_name,
	YEAR(usage_date) AS year,
    MONTH(usage_date) AS month,
	ROUND(AVG(usage_duration_mins), 2) AS avg_usage_duration_mins,
    ROUND(AVG(usage_count), 2) AS avg_usage_count
    
	FROM fact_feature_usage 
GROUP BY feature_name, YEAR(usage_date), MONTH(usage_date) 
ORDER BY year, month;

------------------------------------------------------------------------------

-- 5,6) Retention Rate By Feature Usage and Churn Rate by Feature Usage 

WITH total_accounts AS
(
    -- Total unique accounts that used each feature
    SELECT
        t1.feature_name,
        YEAR(t1.usage_date) AS year,
        COUNT(DISTINCT t3.account_id) AS total_accounts_using_feature

    FROM fact_feature_usage t1

    INNER JOIN dim_subscriptions t2
        ON t1.subscription_id = t2.subscription_id

		INNER JOIN dim_accounts t3
			ON t2.account_id = t3.account_id

    WHERE YEAR(t1.usage_date) BETWEEN 2023 AND 2024

    GROUP BY t1.feature_name, YEAR(t1.usage_date)
),

	retained_accounts AS
	(
		-- Total unique accounts that used each feature and did not churn
		SELECT
			t1.feature_name,
			YEAR(t1.usage_date) AS year,
			COUNT(DISTINCT t3.account_id) AS retained_accounts_using_feature

		FROM fact_feature_usage t1

		INNER JOIN dim_subscriptions t2
			ON t1.subscription_id = t2.subscription_id

			INNER JOIN dim_accounts t3
				ON t2.account_id = t3.account_id

			LEFT JOIN fact_churn_events t4
				ON t3.account_id = t4.account_id

		WHERE YEAR(t1.usage_date) BETWEEN 2023 AND 2024
		  AND t4.account_id IS NULL

		GROUP BY t1.feature_name, YEAR(t1.usage_date)
	), 
    
		churned_accounts AS 
		(
		-- Total unique accounts that used each feature and did churn
		SELECT
			t1.feature_name,
			YEAR(t1.usage_date) AS year,
			COUNT(DISTINCT t3.account_id) AS churned_accounts_using_feature

		FROM fact_feature_usage t1

		INNER JOIN dim_subscriptions t2
			ON t1.subscription_id = t2.subscription_id

			INNER JOIN dim_accounts t3
				ON t2.account_id = t3.account_id

			INNER JOIN fact_churn_events t4
				ON t3.account_id = t4.account_id

		WHERE YEAR(t1.usage_date) BETWEEN 2023 AND 2024

		GROUP BY t1.feature_name, YEAR(t1.usage_date)
		)

SELECT
    t.feature_name, t.year,

    r.retained_accounts_using_feature, c.churned_accounts_using_feature, t.total_accounts_using_feature,

    -- Retention rate percentage by feature and year
    ROUND( r.retained_accounts_using_feature / 
    NULLIF(t.total_accounts_using_feature, 0) * 100, 2 ) AS retention_rate_pct,
    
    -- Churn rate percentage by feature and year
    ROUND( c.churned_accounts_using_feature / 
    NULLIF(t.total_accounts_using_feature, 0) * 100, 2 ) AS churn_rate_pct

FROM total_accounts t

-- Combine numerator and denominator for KPIs calculation
INNER JOIN retained_accounts r
    ON t.feature_name = r.feature_name
    AND t.year = r.year

	INNER JOIN churned_accounts c
		ON t.feature_name = c.feature_name
		AND t.year = c.year

ORDER BY t.feature_name, t.year;

-- Observation:
-- Across most features, retention rates ranged between 25% and 32%, while churn rates ranged between 68% and 75%.

-- This suggests that feature usage alone may not be sufficient to explain customer retention and that additional factors such as subscription tier, industry, or account lifecycle should be investigated.

-- these are tests 
SELECT
    COUNT(DISTINCT account_id) AS total_accounts
FROM dim_accounts;

SELECT
    COUNT(DISTINCT account_id) AS churned_accounts
FROM fact_churn_events;

----------------------------------------------------------------------------------------------------------------------------------------------

-- 7) Feature Adoption Rate

WITH accounts_using_feature AS
(
    -- Total unique accounts using each feature
    SELECT
        t1.feature_name,
        COUNT(DISTINCT t3.account_id) AS accounts_using_feature

    FROM fact_feature_usage t1

    INNER JOIN dim_subscriptions t2
        ON t1.subscription_id = t2.subscription_id

    INNER JOIN dim_accounts t3
        ON t2.account_id = t3.account_id

    WHERE YEAR(t1.usage_date) BETWEEN 2023 AND 2024

    GROUP BY t1.feature_name
),

	latest_subscription AS
	(
		-- Identify the latest subscription record for each account
		SELECT
			account_id,
			end_date,

			ROW_NUMBER() OVER(
				PARTITION BY account_id
				ORDER BY start_date DESC
			) AS subscription_rank

		FROM dim_subscriptions
	),

		active_accounts AS
		(
			-- Count currently active accounts
			SELECT
			COUNT(DISTINCT account_id) AS total_active_accounts

			FROM latest_subscription

			WHERE subscription_rank = 1
			  AND end_date IS NULL
		)

SELECT
    auf.feature_name,
	auf.accounts_using_feature,
    aa.total_active_accounts,

    ROUND(auf.accounts_using_feature /
        NULLIF(aa.total_active_accounts, 0) * 100, 2) AS feature_adoption_rate_pct

FROM accounts_using_feature auf

CROSS JOIN active_accounts aa

ORDER BY feature_adoption_rate_pct DESC;

-- Key Finding

-- Feature adoption rates were generally high, with the most adopted features being used by over 80% of active accounts.

-- Despite strong adoption, retention rates remained relatively low across the customer base, suggesting that feature usage alone may not be sufficient to explain customer retention.

-- Further analysis should investigate other factors such as subscription plans, account lifecycle, customer segments, and feature combinations.
    
    
    
    