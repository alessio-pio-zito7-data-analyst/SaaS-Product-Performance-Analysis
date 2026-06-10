SaaS Dataset Documentation



\## Overview



This dataset represents a SaaS business environment and contains information related to:



\- Customer accounts

\- Subscription lifecycle events

\- Subscription status history

\- Revenue metrics (MRR / ARR)

\- Churn events

\- Product feature usage

\- Customer support tickets



The dataset is structured into multiple relational tables connected mainly through:



\- `account\_id`

\- `subscription\_id`

\- `sub\_event\_id`



\---



\# Entity Relationship Overview



| Table Name | Description | Primary Key |



|---|---|---|

| `accounts` | Master table containing customer account information | `account\_id` **PK** |

| `subscriptions\_status\_history` | Historical subscription status tracking | `subscription\_id` **PK** |

| `subscriptions\_details` | Detailed subscription event records | `sub\_event\_id` **PK** |

| `churn\_events` | Customer churn and cancellation information | `churn\_event\_id` **PK** |

| `feature\_usage` | Product feature usage metrics | `feature\_usage\_id` **AUTO INCREMENT** **PK** |

| `support\_tickets` | Customer support interactions | `ticket\_id` **PK** |



\---



\# 1. accounts



\## Description



Contains master data for SaaS customer accounts.



\## Grain



One row per customer account.



\## Primary Key



`account\_id`



\## Columns



| Column Name | Data Type | Description |

|---|---|---|

| `account\_id` | string (PK) | Unique identifier for each customer account |

| `account\_name` | string | Name of the company/customer |

| `industry` | string | Industry sector of the customer |

| `country` | string | Country where the customer is located |

| `signup\_date` | date | Date when the account signed up |

| `referral\_source` | string | Acquisition channel/source of the customer |

| `plan\_tier` | string | Current subscription plan tier |

| `seats` | integer | Number of licensed seats/users |

| `account\_status` | string | Current status of the account |



\## In Details



\### `plan\_tier`



\- Basic (19$/month)

\- Pro (49$/month)

\- Enterprise (199$/month)



\### `account\_status`



\- Paid Sub

\- Trial



\### `referral\_source`



\- ads (User discovered the service through publicity)

\- organic (User discovered the service through Web research)

\- partner (User discovered the service through collaborations) 

\- event (User discovered the service through webinars, workshops or bootcamps)

\- other 

\---



\# 2. subscriptions\_status\_history



\## Description



Tracks historical subscription status changes over time.



\## Grain



One row per subscription status period



IMPORTANT NOTE: 



\## Primary Key



`subscription\_id`



\## Foreign Keys



| Column | References |

|---|---|

| `account\_id` | `accounts.account\_id` |



\## Columns



| Column Name | Data Type | Description |

|---|---|---|

| `subscription\_id` | string (PK) | Unique identifier for a subscription |

| `account\_id` | string (FK) | Associated customer account |

| `start\_date` | date | Subscription status start date |

| `end\_date` | date | Subscription status end date |

| `status` | string | Subscription status during the period |



\## In Details



\### `status`



\- Active Sub

\- Active Trial

\- Ended Sub

\- Ended Trial



\## Notes



\- `end\_date` can be NULL for currently active subscriptions.

\- Used for subscription lifecycle analysis and retention tracking.



\--- 



\# 3. subscriptions\_details



\## Description



Detailed subscription event table containing billing and commercial information.

Can be joined with subscriptions\_status\_history to retrieve full subscriptions status overtime.



\## Grain



One row per subscription event detail.



\## Primary Key



`sub\_event\_id`



\## Foreign Keys



| Column | References |

|---|---|

| `subscription\_id` | `subscriptions\_status\_history.subscription\_id` |



\## Columns



| Column Name | Data Type | Description |

|---|---|---|

| `sub\_event\_id` | integer (PK) | Unique identifier of the event |

| `subscription\_id` | string (FK) | Related subscription |

| `event\_date` | date | Event occurrence date |

| `event\_type` | string | Type of subscription event |

| `event\_details` | string | Detailed business description of the event |

| `plan\_tier` | string | Plan tier after the event |

| `seats` | integer | Number of licensed seats |

| `billing\_frequency` | string | Billing cycle frequency |

| `auto\_renew\_status` | string | Subscription auto-renewal state |

| `mrr\_amount` | integer | Monthly recurring revenue |

| `arr\_amount` | integer | Annual recurring revenue |



\## In Details



\### `event\_type`



\- Create (First account appearance)

\- Conversion (Account goes from Trial to paid Sub)

\- Update (Seats or Plan changes)

\- Cancel (subscription cancelled)

\- NULL (Can be NULL if account has 'Active Trial' status in subscriptions\_status\_history)



\### `event\_details`



\- Plan Upgrade

\- Plan Downgrade

\- Seat Upgrade

\- Seat Downgrade

\- NULL (Can be NULL if event\_type is 'Create', 'Conversion', 'Cancel', 'NULL')



\### `billing\_frequency`



\- monthly

\- annual



\## Business Logic



\- `ARR = MRR \* 12`

\- Used for detailed subscription movement analysis.

\- Supports expansion/contraction revenue tracking.



\---



\# 4. churn\_events



\## Description



Contains customer churn and cancellation information.



\## Grain



One row per churn event.



\## Primary Key



`churn\_event\_id`



\## Foreign Keys



| Column | References |

|---|---|

| `account\_id` | `accounts.account\_id` |



\## Columns



| Column Name | Data Type | Description |

|---|---|---|

| `churn\_event\_id` | string (PK) | Unique identifier for the churn event |

| `account\_id` | string (FK) | Customer account that churned |

| `churn\_date` | date | Date of churn |

| `reason\_code` | string | Categorized churn reason |

| `refund\_amount\_usd` | integer | Refund amount issued to customer |

| `preceding\_upgrade` | string | Indicates if an upgrade happened before churn |

| `preceding\_downgrade` | string | Indicates if a downgrade happened before churn |

| `reactivation\_event` | string | Indicates if the customer later reactivated |

| `feedback\_text` | string | Optional customer feedback/comment |



\## In Details



\### `reason\_code`



\- competitor

\- unknown

\- pricing 

\- features

\- support

\- budget



\### `feedback\_text`



\- switched to competitor

\- too expensive

\- missing feature

\- NULL (If no feedback)



\## Notes



\- NULL values indicate unavailable churn context.

\- Useful for churn analysis and retention studies.



\---



\# 5. feature\_usage



\## Description



Tracks customer interaction with product features.



\## Grain



One row per feature usage event.



\## Primary Key



`feature\_usage\_pk` AUTO INCREMENT PK



\## Foreign Keys



| Column | References |

|---|---|

| `subscription\_id` | `subscriptions\_status\_history.subscription\_id` |



\## Columns



| Column Name | Data Type | Description |

|---|---|---|

| `feature\_usage\_pk` | string (AI PK) | Unique identifier for the usage event (substitutes usage\_id as real AI PK) |

| `usage\_id` | string | NON-Unique usage id |

| `subscription\_id` | string (FK) | Associated subscription |

| `usage\_date` | date | Date of feature usage |

| `feature\_name` | string | Name of the feature used |

| `usage\_count` | integer | Number of feature interactions |

| `usage\_duration\_mins` | float | Duration of feature usage in minutes |

| `logged\_errors\_count` | integer | Number of errors logged during usage |

| `is\_beta\_feature` | string | Indicates if feature is in beta |



\## In Details



\### `is\_beta\_feature`



\- Beta

\- NULL



\## Notes



\- Useful for product analytics and engagement scoring.

\- Can support churn prediction models and adoption analysis.



\---



\# 6. support\_tickets



\## Description



Contains customer support ticket interactions and resolution metrics.



\## Grain



One row per support ticket.



\## Primary Key



`ticket\_id`



\## Foreign Keys



| Column | References |

|---|---|

| `account\_id` | `accounts.account\_id` |



\## Columns



| Column Name | Data Type | Description |

|---|---|---|

| `ticket\_id` | string (PK) | Unique support ticket identifier |

| `account\_id` | string (FK) | Related customer account |

| `submitted\_at` | date | Ticket submission timestamp |

| `closed\_at` | date | Ticket closure timestamp |

| `resolution\_time\_hours` | integer | Total resolution time in hours |

| `priority` | string | Ticket priority level |

| `first\_response\_time\_minutes` | integer | Time until first support response |

| `satisfaction\_score` | float | Customer satisfaction score |

| `ticket\_escalation` | string | Indicates if ticket was escalated |



\## In Details 



\### `priority`



\- low

\- medium

\- high

\- urgent



\## Notes



\- NULL satisfaction scores may indicate unanswered surveys.

\- Used for customer support KPI monitoring.



\---



\# Data Quality Recommendations



\## Primary Key Validation



Ensure uniqueness for:



\- `account\_id`

\- `subscription\_id`

\- `sub\_event\_id`

\- `usage\_id`

\- `ticket\_id`

\- `churn\_event\_id`



\---



\# Dataset Size Summary



| Table | Approximate Rows |

|---|---|

| accounts | 500 |

| subscriptions\_status\_history | 5,000 |

| subscriptions\_details | 5,000 |

| churn\_events | 600 |

| feature\_usage | 25,000 |

| support\_tickets | 2,000 |



\---

