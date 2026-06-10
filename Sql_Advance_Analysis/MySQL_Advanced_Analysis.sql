/*
Year-over-Year (YoY) Feature Engagement Analysis

This query implements KPI #1 (Total Feature Usage) and KPI #2 (Total Usage Duration) as defined in KPIs_Calculation_Sheet.md.

Purpose:
- Aggregate yearly feature usage and usage duration metrics.
- Compare each year's performance against the previous year using LAG().
- Calculate Year-over-Year (YoY) growth percentages to identify engagement trends across product features.

Note:
The analysis is currently limited to 2023-2024.
Because the LAG() function is ordered by year, the comparison logic automatically supports future years if the date filter is expanded or removed.
*/

WITH feature_usage_and_duration_comparison AS
(
    -- Aggregate yearly feature usage metrics
    SELECT
        feature_name,
        YEAR(usage_date) AS year,
        SUM(usage_count) AS total_feature_usage,
        SUM(usage_duration_mins) AS total_usage_duration

    FROM fact_feature_usage

    -- Restrict analysis to the selected time period
    WHERE YEAR(usage_date) BETWEEN 2023 AND 2024

    GROUP BY
        feature_name,
        year
),

	yoy_comparison AS
	(
		SELECT
			*,

			-- Retrieve previous year's total feature usage
			LAG(total_feature_usage)
				OVER (
					PARTITION BY feature_name
					ORDER BY year
				) AS previous_year_usage,

			-- Retrieve previous year's total usage duration
			LAG(total_usage_duration)
				OVER (
					PARTITION BY feature_name
					ORDER BY year
				) AS previous_year_usage_duration

		FROM feature_usage_and_duration_comparison
	)

		SELECT
			*,

			-- Calculate YoY % change in feature usage
			ROUND(
				(total_feature_usage - previous_year_usage)
				/ NULLIF(previous_year_usage, 0) * 100,
				2
			) AS usage_growth_pct,

			-- Calculate YoY % change in usage duration
			ROUND(
				(total_usage_duration - previous_year_usage_duration)
				/ NULLIF(previous_year_usage_duration, 0) * 100,
				2
			) AS duration_growth_pct

		FROM yoy_comparison
        
        WHERE previous_year_usage IS NOT NULL;

---------------------------------------------------------------------------------------------------------------

/*
Feature Usage Frequency (Q4 2024)

This query implements KPI #3 (Feature Usage Frequency) as defined in KPIs_Calculation_Sheet.md.

Purpose:

- Measure how frequently each feature was used during Q4 2024.
- Aggregate usage_count by feature and month.
- Support reporting and dashboard analysis of feature engagement patterns during the selected period.

Method:

- Restrict the analysis to October, November, and December 2024.
- Group results by feature and month.
- Higher values indicate more frequent feature usage.

*/

SELECT
    feature_name,
    MONTH(usage_date) AS month,
    SUM(usage_count) AS feature_usage_frequency_month

FROM fact_feature_usage

-- Filter to Q4 2024
WHERE YEAR(usage_date) = 2024
  AND MONTH(usage_date) BETWEEN 10 AND 12

GROUP BY feature_name, month

ORDER BY feature_name, month;

---------------------------------------------------------------------------------------------------------------

/*
Retention Rate By Feature & Churn Rate By Feature

This query implements KPI #4 (Retention Rate By Feature) and KPI #5 (Churn Rate By Feature) as defined in KPIs_Calculation_Sheet.md.

Purpose:

* Measure the percentage of accounts that used a feature and remained active.
* Measure the percentage of accounts that used a feature and subsequently churned.
* Identify features associated with higher customer retention or churn.
* Support reporting and dashboard analysis of feature retention and churn patterns.

Method:

* Calculate the total number of unique accounts using each feature.

* Calculate the number of unique accounts using each feature that are not present in fact_churn_events.

* Calculate the number of unique accounts using each feature that are present in fact_churn_events.

* Join all populations by feature and year.

* Calculate the retention rate as:

  Retained Accounts Using Feature
  /
  Total Accounts Using Feature

* Calculate the churn rate as:

  Churned Accounts Using Feature
  /
  Total Accounts Using Feature

* Higher retention rates indicate stronger feature retention.

* Higher churn rates indicate features associated with a larger proportion of churned accounts.

*/

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

---------------------------------------------------------------------------------------------------------------

/*
Feature Adoption Rate

This query implements KPI #6 (Feature Adoption Rate) as defined in KPIs_Calculation_Sheet.md.

Purpose:

- Measure the percentage of active accounts that use each feature.
- Identify the most widely adopted features across the customer base.
- Support reporting and dashboard analysis of product adoption patterns.

Method:

- Calculate the number of unique accounts using each feature.
- Identify the latest subscription record for each account.
- Count active accounts based on their latest subscription status.
- Calculate the adoption rate as:

    Accounts Using Feature
    /
    Total Active Accounts

- Higher values indicate broader feature adoption.

*/

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

    ROUND(
        auf.accounts_using_feature
        /
        NULLIF(aa.total_active_accounts, 0)
        * 100,
        2
    ) AS feature_adoption_rate_pct

FROM accounts_using_feature auf

CROSS JOIN active_accounts aa

ORDER BY feature_adoption_rate_pct DESC;