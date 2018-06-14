 SELECT * 
 FROM subscriptions LIMIT 100;
 SELECT DISTINCT segment 
 FROM subscriptions;
 SELECT DISTINCT subscription_start 
 FROM subscriptions;
 SELECT MAX(subscription_start) AS first_subscriber,
 	MIN(subscription_start) AS most_recent_subscriber 
 FROM subscriptions;
 WITH months AS (
 	SELECT 
 		'2016-12-01' As first_day,
 		'2016-12-31' AS last_day
 	UNION
 	SELECT 
 		'2017-01-01' AS first_day,
 		'2017-01-31' AS last_day
 	UNION
 	SELECT 
 		'2017-02-01' AS first_day,
 		'2017-02-31' AS last_day
 	UNION
 	SELECT 
 		'2017-03-01' AS first_day,
 		'2017-03-31' AS last_day), 
 cross_join AS (
 	SELECT subscriptions.*, months.*
   FROM subscriptions
   CROSS JOIN months),
 status AS(
 	SELECT cross_join.id,
   cross_join.first_day AS month,
   CASE
   	WHEN ((segment = '87') AND ((subscription_start < first_day) AND (subscription_end > first_day
      OR subscription_end IS NULL))) THEN 1
   ELSE 0 END AS is_active_87,
   CASE
    WHEN ((segment = '30') AND ((subscription_start < first_day) AND (subscription_end > first_day
      	OR subscription_end IS NULL))) THEN 1
   	ELSE 0
	END AS is_active_30,
   CASE
   	WHEN ((segment = '87') AND ((subscription_start < first_day)
    	AND (subscription_end BETWEEN first_day AND last_day))) THEN 1
   	ELSE 0
	END AS is_cancelled_87,
   CASE
   	WHEN ((segment = '30') AND ((subscription_start < first_day) AND (subscription_end BETWEEN first_day AND last_day))) THEN 1
   	ELSE 0 END AS is_cancelled_30
 	FROM cross_join),
 status_aggregate AS (
 	SELECT SUM(is_active_87) AS sum_active_87,
  	SUM(is_active_30) AS sum_active_30,
 		SUM(is_cancelled_87) AS sum_cancelled_87,
   	SUM(is_cancelled_30) AS sum_cancelled_30
 	FROM status GROUP BY month)
 /*SELECT (sum_active_87 +  sum_active_30) AS active_users,
 	(sum_cancelled_87 + sum_cancelled_30) AS cancelled_users,
  100.0 * (sum_cancelled_87 +  sum_cancelled_30) / (sum_active_87 + sum_active_30) AS churn_rate
 FROM status_aggregate;*/
 SELECT
 	sum_active_87,
 	sum_cancelled_87,
  (100.0 * sum_cancelled_87 / sum_active_87) AS churn_rate_87,
  sum_active_30,
  sum_cancelled_30,
  (100.0 * sum_cancelled_30 / sum_active_30) AS churn_rate_30
 FROM status_aggregate;