-- Histogram of Tweets [Twitter SQL Interview Question]

WITH qwerty AS (SELECT 
user_id AS tweet_bucket,
COUNT(tweet_id) AS users_num 
FROM tweets
WHERE tweet_date BETWEEN '2022-01-01' 
  AND '2022-12-31'
GROUP BY user_id) 

SELECT COUNT(tweet_bucket) AS tweet_bucket, users_num 
FROM qwerty
GROUP BY users_num
ORDER BY tweet_bucket ASC;


