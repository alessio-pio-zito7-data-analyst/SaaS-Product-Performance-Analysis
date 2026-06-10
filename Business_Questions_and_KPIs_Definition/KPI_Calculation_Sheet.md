##### KPI Calculation Sheet





**1) Total Feature Usage:**



Formula:

SUM(usage\_count)



Source:

fact\_feature\_usage



Joins:

None

###### 

\-------------------------------------



**2) Total Usage Duration Mins**



Formula:

SUM(usage\_duration\_mins)



Source:

fact\_feature\_usage



Joins:

None



\-------------------------------------



**3) Feature Usage Frequency**



Formula:

SUM(usage\_count)

GROUP BY week/month/year



Source:

fact\_feature\_usage



Joins:

None



\-------------------------------------



**4) Average Usage Duration and Average Usage Count** 



Formula:

AVG(usage\_duration\_mins)

AVG(usage\_count)



Source:

fact\_feature\_usage



Joins:

None



\-------------------------------------



**5) Retention Rate By Feature**



Formula:

Retained Accounts Using Feature

/

Total Accounts Using Feature



WHERE



Retained Accounts

=

Accounts NOT present in fact\_churn\_events



Source:

fact\_feature\_usage

dim\_subscriptions

dim\_accounts

fact\_churn\_events



Joins:

fact\_feature\_usage joins dim\_subsription that joins dim\_accounts that joins fact\_churn\_events



\-----------------------------------------------------------------------------------------------------



**6) Churn Rate By Feature (verificare i joins)**



Formula:

Churned Accounts Using Feature

/

Total Accounts Using Feature



WHERE



Churned Accounts

=

Accounts present in fact\_churn\_events



Source:

fact\_feature\_usage

dim\_subscriptions

dim\_accounts

fact\_churn\_events



Joins:

fact\_feature\_usage joins dim\_subsription that joins dim\_accounts that joins fact\_churn\_events



\-----------------------------------------------------------------------------------------------------



**7) Feature Adoption Rate**



Formula:

Accounts Using Feature

/

Total Active Accounts



Source:

fact\_feature\_usage

dim\_subscriptions

dim\_accounts



Joins:

fact\_feature\_usage joins dim\_subsription that joins dim\_accounts

