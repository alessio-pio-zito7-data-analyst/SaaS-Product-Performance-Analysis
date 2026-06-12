CREATE TABLE accounts (
    account_id VARCHAR(20) PRIMARY KEY,
    
    account_name VARCHAR(20) NOT NULL,
    industry VARCHAR(20) NOT NULL,
    country VARCHAR(20) NOT NULL,
    signup_date DATE NOT NULL,
    
    referral_source VARCHAR(20),
    plan_tier VARCHAR(20), 
    seats INT CHECK(seats >= 0),
    account_status VARCHAR(20)
); 


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/accounts.csv'
INTO TABLE accounts
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(account_id, account_name, industry, country, signup_date, referral_source, plan_tier, seats, account_status);

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE subscriptions_status_history (
	subscription_id VARCHAR(20) PRIMARY KEY,
    
    account_id VARCHAR(20) NOT NULL,
    
    start_date DATE NOT NULL,
    
    end_date DATE,
    status VARCHAR(20), 
    
    CONSTRAINT fk_accounts
    FOREIGN KEY (account_id)
    REFERENCES accounts(account_id)
    
    );
    
    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/subscriptions_status_history.csv'
INTO TABLE subscriptions_status_history
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(subscription_id, account_id, start_date, @end_date, status)
SET end_date = NULLIF(TRIM(@end_date), ''); 

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE subscriptions_details (
	sub_event_id INT PRIMARY KEY, 
	
    subscription_id VARCHAR(20) NOT NULL,
    
	event_date DATE NOT NULL,
    event_type VARCHAR(20),
    event_details VARCHAR(20),
    plan_tier VARCHAR(20) NOT NULL,
    seats INT CHECK(seats >= 0),
    billing_frequency VARCHAR(20),
    auto_renew_status VARCHAR(20),
    mrr_amount INT NOT NULL,
    arr_amount INT NOT NULL,
    
    
    CONSTRAINT fk_subscriptions_id_in_sub_details
    FOREIGN KEY (subscription_id)
    REFERENCES subscriptions_status_history(subscription_id)
    
    );
    
    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/subscriptions_details.csv'
INTO TABLE subscriptions_details
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(sub_event_id, subscription_id, event_date, @event_type, @event_details, plan_tier, seats, billing_frequency, auto_renew_status, mrr_amount, arr_amount)

SET event_type = NULLIF(TRIM(@event_type), ''),
event_details = NULLIF(TRIM(@event_details), '');

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE churn_events (
	churn_event_id VARCHAR(20) PRIMARY KEY,
    
    account_id VARCHAR(20) NOT NULL, 
    
    churn_date DATE NOT NULL,
    reason_code VARCHAR(20) NOT NULL,
    refund_amount_usd INT NOT NULL,
    
    preceding_upgrade VARCHAR(20),
    preceding_downgrade VARCHAR(20),
    reactivation_event VARCHAR(20),
    feedback_text VARCHAR(50),
    
	CONSTRAINT fk_account_id_in_churn_events 
	FOREIGN KEY (account_id)
	REFERENCES accounts(account_id)

	);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/churn_events.csv'
INTO TABLE churn_events
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(churn_event_id, account_id, churn_date, reason_code, refund_amount_usd, @preceding_upgrade, @preceding_downgrade, @reactivation_event, @feedback_text)

SET preceding_upgrade = NULLIF(TRIM(@preceding_upgrade), ''),
preceding_downgrade = NULLIF(TRIM(@preceding_downgrade), ''),
reactivation_event = NULLIF(TRIM(@reactivation_event), ''),
feedback_text = NULLIF(TRIM(@feedback_text), '');

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE feature_usage(
	feature_usage_pk INT AUTO_INCREMENT PRIMARY KEY, 

	usage_id VARCHAR(20) NOT NULL,
    
    subscription_id VARCHAR(20) NOT NULL,
    
    usage_date DATE NOT NULL,
    feature_name VARCHAR(20) NOT NULL,
    usage_count INT NOT NULL CHECK(usage_count >= 0),
    usage_duration_mins DECIMAL(6,1) NOT NULL,
    logged_errors_count INT NOT NULL CHECK(logged_errors_count >= 0),
    is_beta_feature VARCHAR(10),
    
    CONSTRAINT fk_subscription_id_in_feature_usage
    FOREIGN KEY (subscription_id)
    REFERENCES subscriptions_status_history(subscription_id)
    
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/feature_usage.csv'
INTO TABLE feature_usage
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(usage_id, subscription_id, usage_date, feature_name, usage_count, @usage_duration_mins, logged_errors_count, @is_beta_feature)

SET usage_duration_mins = REPLACE(TRIM(@usage_duration_mins), ',','.'),
is_beta_feature = NULLIF(TRIM(@is_beta_feature), '');

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE support_tickets (
ticket_id VARCHAR(20) PRIMARY KEY,

account_id VARCHAR(20) NOT NULL,

submitted_at DATE NOT NULL,
closed_at DATE NOT NULL,
resolution_time_hours INT NOT NULL,
priority VARCHAR(20) NOT NULL,
first_response_time_minutes INT NOT NULL,
satisfaction_score SMALLINT, 
ticket_escalation VARCHAR(20),

CONSTRAINT pk_account_id_in_support_tickets
FOREIGN KEY (account_id)
REFERENCES accounts(account_id)
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/support_tickets.csv'
INTO TABLE support_tickets
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ticket_id, account_id, submitted_at, closed_at, resolution_time_hours, priority, first_response_time_minutes, @satisfaction_score, @ticket_escalation)

SET satisfaction_score = NULLIF(TRIM(@satisfaction_score), ''),
ticket_escalation = NULLIF(TRIM(@ticket_escalation), '');

