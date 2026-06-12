/* Debugging after Data Ingestion*/

-- Detecting hidden carriage return characters in feedback_text column after data ingestion
-- and converting them into proper NULL values

SELECT 
    feedback_text,
    HEX(feedback_text)
FROM churn_events
WHERE LENGTH(feedback_text) = 1;


UPDATE churn_events
SET feedback_text = NULL
WHERE feedback_text = CHAR(13);

-------------------------------------------------------------------------------------------------------------------

-- Detecting hidden carriage return characters in is_beta_feature column after data ingestion
-- and converting them into proper NULL values

SELECT 
    is_beta_feature,
    HEX(is_beta_feature)
FROM feature_usage
WHERE LENGTH(is_beta_feature) = 1;


UPDATE feature_usage
SET is_beta_feature = NULL
WHERE is_beta_feature = CHAR(13);

-------------------------------------------------------------------------------------------------------------------

-- Detecting hidden carriage return characters in ticket_escalation column after data ingestion 
-- and converting them into proper NULL values

SELECT 
    ticket_escalation,
    HEX(ticket_escalation)
FROM support_tickets
WHERE LENGTH(ticket_escalation) = 1;


UPDATE support_tickets
SET ticket_escalation = NULL
WHERE ticket_escalation = CHAR(13);

-------------------------------------------------------------------------------------------------------------------

/*
====================================================================
DATA VALIDATION CHECKS LEGEND
====================================================================

1. Primary Key Validation
2. Foreign Key Validation
3. Null and Missing Value Checks
4. Whitespace and Formatting Checks
5. Business Logic Validation

====================================================================
PRIMARY KEY VALIDATION
Objective:
Ensure that each primary key contains unique values only.
Expected Result:
All queries should return 0 rows.
====================================================================
*/


-- Validate uniqueness of PRIMARY KEY: account_id
SELECT account_id, COUNT(*) AS duplicates
FROM accounts
GROUP BY account_id
HAVING COUNT(*) > 1;


-- Validate uniqueness of PRIMARY KEY: subscription_id
SELECT subscription_id, COUNT(*) AS duplicates
FROM subscriptions_status_history
GROUP BY subscription_id
HAVING COUNT(*) > 1;


-- Validate uniqueness of PRIMARY KEY: sub_event_id
SELECT sub_event_id, COUNT(*) AS duplicates
FROM subscriptions_details
GROUP BY sub_event_id
HAVING COUNT(*) > 1;


-- Validate uniqueness of PRIMARY KEY: churn_event_id
SELECT churn_event_id, COUNT(*) AS duplicates
FROM churn_events
GROUP BY churn_event_id
HAVING COUNT(*) > 1;


-- Validate uniqueness of PRIMARY KEY: feature_usage_pk
SELECT feature_usage_pk, COUNT(*) AS duplicates
FROM feature_usage
GROUP BY feature_usage_pk
HAVING COUNT(*) > 1;


-- Validate uniqueness of PRIMARY KEY: ticket_id
SELECT ticket_id, COUNT(*) AS duplicates
FROM support_tickets
GROUP BY ticket_id
HAVING COUNT(*) > 1;

-------------------------------------------------------------------------------------------------------------------

/*
====================================================================
FOREIGN KEY VALIDATION
Objective:
Ensure referential integrity across all related tables by identifying
orphan foreign key values.

Expected Result:
All queries should return 0 rows, indicating that every foreign key
correctly references an existing parent record.
====================================================================
*/


-- Validate account_id references in subscriptions_status_history
SELECT t1.subscription_id, t1.account_id
FROM subscriptions_status_history t1
LEFT JOIN accounts t2
	ON t1.account_id = t2.account_id
WHERE t2.account_id IS NULL;


-- Validate subscription_id references in subscriptions_details
SELECT t1.sub_event_id, t1.subscription_id
FROM subscriptions_details t1
LEFT JOIN subscriptions_status_history t2
	ON t1.subscription_id = t2.subscription_id
WHERE t2.subscription_id IS NULL;


-- Validate account_id references in churn_events
SELECT t1.churn_event_id, t1.account_id 
FROM churn_events t1
LEFT JOIN accounts t2
	ON t1.account_id = t2.account_id
WHERE t2.account_id IS NULL;


-- Validate subscription_id references in feature_usage
SELECT t1.feature_usage_pk, t1.subscription_id
FROM feature_usage t1
LEFT JOIN subscriptions_status_history t2
	ON t1.subscription_id = t2.subscription_id
WHERE t2.subscription_id IS NULL;


-- Validate account_id references in support_tickets
SELECT t1.ticket_id, t1.account_id
FROM support_tickets t1
LEFT JOIN accounts t2
	ON t1.account_id = t2.account_id
WHERE t2.account_id IS NULL;

-------------------------------------------------------------------------------------------------------------------

/*
====================================================================
NULL AND MISSING VALUE CHECKS
Objective:
Identify NULL or missing values across all tables and columns,
ensuring they are present only where intentionally allowed by the
data ingestion and business rules.

Expected Result:
Only predefined nullable columns should contain NULL values.
Any unexpected NULL values should be investigated.
====================================================================
*/


-- Validate NULL values in accounts
-- Expected result: no unexpected NULL values

SELECT
	SUM(CASE WHEN account_id IS NULL THEN 1 ELSE 0 END) as acc_id_null,
	SUM(CASE WHEN account_name IS NULL THEN 1 ELSE 0 END) as acc_name_null,
    SUM(CASE WHEN industry IS NULL THEN 1 ELSE 0 END) as industry_null,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) as country_null,
    SUM(CASE WHEN signup_date IS NULL THEN 1 ELSE 0 END) as signup_null,
	SUM(CASE WHEN referral_source IS NULL THEN 1 ELSE 0 END) as referral_null,
    SUM(CASE WHEN plan_tier IS NULL THEN 1 ELSE 0 END) as plan_null,
    SUM(CASE WHEN seats IS NULL THEN 1 ELSE 0 END) as seats_null,
    SUM(CASE WHEN account_status IS NULL THEN 1 ELSE 0 END) as acc_status_null
FROM accounts;


-- Validate NULL values in subscriptions_status_history
-- Expected result: only end_date contains NULL values
-- according to the data ingestion process

SELECT 
	SUM(CASE WHEN subscription_id IS NULL THEN 1 ELSE 0 END) as sub_id_null,
    SUM(CASE WHEN account_id IS NULL THEN 1 ELSE 0 END) as acc_id_null,
    SUM(CASE WHEN start_date IS NULL THEN 1 ELSE 0 END) as start_date_null,
    SUM(CASE WHEN end_date IS NULL THEN 1 ELSE 0 END) as end_date_null,
    SUM(CASE WHEN status IS NULL THEN 1 ELSE 0 END) as status_null
FROM subscriptions_status_history;


-- Validate NULL values in subscriptions_details
-- Expected result: only event_type and event_details contain NULL values
-- according to the data ingestion process

SELECT 
	SUM(CASE WHEN sub_event_id IS NULL THEN 1 ELSE 0 END) as sub_event_id_null,
	SUM(CASE WHEN subscription_id IS NULL THEN 1 ELSE 0 END) as sub_id_null,
    SUM(CASE WHEN event_date IS NULL THEN 1 ELSE 0 END) as event_date_null,
    SUM(CASE WHEN event_type IS NULL THEN 1 ELSE 0 END) as e_type_null,
    SUM(CASE WHEN event_details IS NULL THEN 1 ELSE 0 END) as e_details_null,
    SUM(CASE WHEN plan_tier IS NULL THEN 1 ELSE 0 END) as plan_null,
    SUM(CASE WHEN seats IS NULL THEN 1 ELSE 0 END) as seats_null,
    SUM(CASE WHEN billing_frequency IS NULL THEN 1 ELSE 0 END) as billing_null,
    SUM(CASE WHEN auto_renew_status IS NULL THEN 1 ELSE 0 END) as renew_null,
    SUM(CASE WHEN mrr_amount IS NULL THEN 1 ELSE 0 END) as mrr_null,
    SUM(CASE WHEN arr_amount IS NULL THEN 1 ELSE 0 END) as arr_null
FROM subscriptions_details;


-- Validate NULL values in churn_events
-- Expected result: preceding_upgrade, preceding_downgrade,
-- reactivation_event, and feedback_text contain NULL values
-- according to the data ingestion process

SELECT
    SUM(CASE WHEN churn_event_id IS NULL THEN 1 ELSE 0 END) as churn_event_id_null,
    SUM(CASE WHEN account_id IS NULL THEN 1 ELSE 0 END) as acc_id_null,
    SUM(CASE WHEN churn_date IS NULL THEN 1 ELSE 0 END) as churn_date_null,
    SUM(CASE WHEN reason_code IS NULL THEN 1 ELSE 0 END) as reason_null,
    SUM(CASE WHEN refund_amount_usd IS NULL THEN 1 ELSE 0 END) as refund_null,
    SUM(CASE WHEN preceding_upgrade IS NULL THEN 1 ELSE 0 END) as pre_upgrade_null,
    SUM(CASE WHEN preceding_downgrade IS NULL THEN 1 ELSE 0 END) as pre_downgrade_null,
    SUM(CASE WHEN reactivation_event IS NULL THEN 1 ELSE 0 END) as react_event_null,
    SUM(CASE WHEN feedback_text IS NULL THEN 1 ELSE 0 END) as feedback_null
FROM churn_events;


-- Validate NULL values in feature_usage
-- Expected result: only is_beta_feature contains NULL values
-- according to the data ingestion process

SELECT
    SUM(CASE WHEN feature_usage_pk IS NULL THEN 1 ELSE 0 END) as feature_usage_pk_null,
    SUM(CASE WHEN usage_id IS NULL THEN 1 ELSE 0 END) as usage_id_null,
    SUM(CASE WHEN subscription_id IS NULL THEN 1 ELSE 0 END) as sub_id_null,
    SUM(CASE WHEN usage_date IS NULL THEN 1 ELSE 0 END) as usage_date_null,
    SUM(CASE WHEN feature_name IS NULL THEN 1 ELSE 0 END) as feature_name_null,
    SUM(CASE WHEN usage_count IS NULL THEN 1 ELSE 0 END) as usage_count_null,
    SUM(CASE WHEN usage_duration_mins IS NULL THEN 1 ELSE 0 END) as usage_duration_null,
    SUM(CASE WHEN logged_errors_count IS NULL THEN 1 ELSE 0 END) as logged_errors_null,
    SUM(CASE WHEN is_beta_feature IS NULL THEN 1 ELSE 0 END) as beta_feature_null
FROM feature_usage;


-- Validate NULL values in support_tickets
-- Expected result: satisfaction_score and ticket_escalation
-- contain NULL values according to the data ingestion process

SELECT
    SUM(CASE WHEN ticket_id IS NULL THEN 1 ELSE 0 END) as ticket_id_null,
    SUM(CASE WHEN account_id IS NULL THEN 1 ELSE 0 END) as acc_id_null,
    SUM(CASE WHEN submitted_at IS NULL THEN 1 ELSE 0 END) as submitted_null,
    SUM(CASE WHEN closed_at IS NULL THEN 1 ELSE 0 END) as closed_null,
    SUM(CASE WHEN resolution_time_hours IS NULL THEN 1 ELSE 0 END) as resolution_null,
    SUM(CASE WHEN priority IS NULL THEN 1 ELSE 0 END) as priority_null,
    SUM(CASE WHEN first_response_time_minutes IS NULL THEN 1 ELSE 0 END) as response_time_null,
    SUM(CASE WHEN satisfaction_score IS NULL THEN 1 ELSE 0 END) as satisfaction_null,
    SUM(CASE WHEN ticket_escalation IS NULL THEN 1 ELSE 0 END) as escalation_null
FROM support_tickets;

-------------------------------------------------------------------------------------------------------------------

/*
====================================================================
WHITESPACE AND FORMATTING CHECKS
Objective:
Identify records containing empty strings or whitespace-only values
in columns previously affected by carriage return or formatting issues.

Expected Result:
All queries should return 0 rows.
====================================================================
*/


-- Validate empty or whitespace-only values in feedback_text

SELECT *
FROM churn_events
WHERE TRIM(feedback_text) = '';


-- Validate empty or whitespace-only values in is_beta_feature

SELECT *
FROM feature_usage
WHERE TRIM(is_beta_feature) = '';


-- Validate empty or whitespace-only values in ticket_escalation

SELECT *
FROM support_tickets
WHERE TRIM(ticket_escalation) = '';

-------------------------------------------------------------------------------------------------------------------

/*
====================================================================
BUSINESS LOGIC VALIDATION
Objective:
Validate critical business rules and numerical constraints to ensure
data consistency, integrity, and analytical reliability.

Expected Result:
All queries should return 0 rows.
====================================================================
*/


-- Validate that seats are not negative in accounts

SELECT *
FROM accounts
WHERE seats < 0;


-- Validate chronological consistency between start_date and end_date 
-- in subscriptions_status_history

SELECT *
FROM subscriptions_status_history
WHERE end_date < start_date; 


-- Validate non-negative values in subscriptions_details
-- Critical validation for revenue-related metrics (MRR and ARR)

SELECT *
FROM subscriptions_details
WHERE seats < 0
	OR mrr_amount < 0
    OR arr_amount < 0;


-- Validate non-negative usage metrics in feature_usage

SELECT *
FROM feature_usage
WHERE usage_count < 0
	OR usage_duration_mins < 0
    OR logged_errors_count < 0;
    

-- Validate supports_ticket metrics and satisfaction score range

SELECT *
FROM support_tickets
WHERE resolution_time_hours < 0
	OR first_response_time_minutes < 0
    OR satisfaction_score NOT BETWEEN 1 AND 5;
    

-- Validate non-negative refund amounts in churn_events

SELECT *
FROM churn_events
WHERE refund_amount_usd < 0;


 /*
====================================================================
VALIDATION SUMMARY
====================================================================

All validation checks passed successfully.
The dataset is considered cleaned, validated, and ready for
analytical and reporting purposes.

====================================================================
*/