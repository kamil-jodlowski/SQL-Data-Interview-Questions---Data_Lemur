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

-- Data Science Skills [LinkedIn SQL Interview Question]
SELECT candidate_id
FROM candidates
WHERE skill IN ('Python', 'Tableau', 'PostgreSQL')
GROUP BY candidate_id
HAVING COUNT(skill) = 3
ORDER BY candidate_id;

--Page With No Likes [Facebook SQL Interview Question]
SELECT pages.page_id
FROM pages
LEFT JOIN page_likes ON pages.page_id = page_likes.page_id
WHERE liked_date IS NULL
ORDER BY page_id ASC

--Unfinished Parts [Tesla SQL Interview Question]
SELECT part, assembly_step 
FROM parts_assembly
WHERE finish_date IS NULL;

--Laptop vs. Mobile Viewership [New York Times SQL Interview Question]
WITH laptop AS (SELECT COUNT(device_type) AS laptop_views
FROM viewership
WHERE device_type = 'laptop'
),

mobile AS (SELECT COUNT(device_type) AS mobile_views
FROM viewership
WHERE device_type IN ('tablet', 'phone')
)

SELECT laptop.laptop_views, mobile.mobile_views
FROM laptop, mobile;

--Average Post Hiatus (Part 1) [Facebook SQL Interview Question]
SELECT 
    user_id, 
    MAX(post_date::DATE) - MIN(post_date::DATE) AS days_between
FROM posts
WHERE DATE_PART('year', post_date::DATE) = 2021 
GROUP BY user_id
HAVING COUNT(post_id) > 1;

--Teams Power Users [Microsoft SQL Interview Question]
SELECT 
  sender_id,
  COUNT(message_id) AS count_messages
FROM messages
WHERE EXTRACT(MONTH FROM sent_date) = '8'
  AND EXTRACT(YEAR FROM sent_date) = '2022'
GROUP BY sender_id
ORDER BY count_messages DESC
LIMIT 2;

--Duplicate Job Listings [Linkedin SQL Interview Question]
WITH qwerty AS (SELECT company_id AS duplicate_companies
FROM job_listings
GROUP BY company_id
HAVING COUNT(description) > 1 AND COUNT(company_id) >1)

SELECT COUNT(qwerty.duplicate_companies) AS duplicate_companies
FROM qwerty

--Cities With Completed Trades [Robinhood SQL Interview Question]
WITH completed_orders AS (
    SELECT user_id, COUNT(*) AS total_orders
    FROM trades
    WHERE status = 'Completed'
    GROUP BY user_id
),
city_orders AS (
    SELECT u.city, SUM(co.total_orders) AS total_orders
    FROM completed_orders co
    JOIN users u ON co.user_id = u.user_id
    GROUP BY u.city
)

SELECT city, total_orders
FROM city_orders
ORDER BY total_orders DESC
LIMIT 3;

--Average Review Ratings [Amazon SQL Interview Question]
SELECT EXTRACT (MONTH FROM submit_date) AS mth, product_id AS product, ROUND(AVG(stars),2) AS avg_stars
FROM reviews
GROUP BY mth, product_id
ORDER BY mth ASC;

--App Click-through Rate (CTR) [Facebook SQL Interview Question]
WITH events_aggregated AS (
    SELECT 
        app_id,
        SUM(CASE WHEN event_type = 'click' THEN 1 ELSE 0 END) AS sum_clicks,
        SUM(CASE WHEN event_type = 'impression' THEN 1 ELSE 0 END) AS sum_impressions
    FROM events
    WHERE EXTRACT(YEAR FROM timestamp) = 2022
    GROUP BY app_id
)
SELECT 
    app_id,
    ROUND((sum_clicks::decimal / NULLIF(sum_impressions, 0)) * 100.0, 2) AS ctr
FROM events_aggregated;

--Second Day Confirmation [TikTok SQL Interview Question]
SELECT emails.user_id
FROM emails
JOIN texts ON texts.email_id = emails.email_id
WHERE action_date = signup_date + INTERVAL '1 day';

--IBM db2 Product Analytics [IBM SQL Interview Question]
WITH employee_queries AS (
  SELECT 
    employees.employee_id,
    COALESCE(COUNT(DISTINCT queries.query_id), 0) AS unique_queries
  FROM employees 
  LEFT JOIN queries
    ON employees.employee_id = queries.employee_id
      AND queries.query_starttime >= '2023-07-01T00:00:00Z'
      AND queries.query_starttime < '2023-10-01T00:00:00Z'
  GROUP BY employees.employee_id
)

SELECT
  unique_queries,
  COUNT(employee_id) AS employee_count
FROM employee_queries
GROUP BY unique_queries
ORDER BY unique_queries

--Cards Issued Difference [JPMorgan Chase SQL Interview Question]
SELECT card_name, MAX(issued_amount) - MIN(issued_amount) AS difference  
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY difference DESC;

--Compressed Mean [Alibaba SQL Interview Question]
WITH summ AS (
    SELECT SUM(item_count * order_occurrences) AS qwerty
    FROM items_per_order
),
sum2 AS (
    SELECT SUM(order_occurrences) AS qw
    FROM items_per_order
)
SELECT ROUND((summ.qwerty / sum2.qw)::numeric, 1) AS mean
FROM summ, sum2;

--Pharmacy Analytics (Part 1) [CVS Health SQL Interview Question]
SELECT drug, total_sales - cogs AS total_profit
FROM pharmacy_sales
ORDER BY total_profit DESC
LIMIT 3;

--Pharmacy Analytics (Part 2) [CVS Health SQL Interview Question]
SELECT manufacturer, COUNT(drug)  AS drug_count , SUM(cogs - total_sales) AS total_loss
FROM pharmacy_sales
WHERE cogs > total_sales
GROUP BY manufacturer 
ORDER BY total_loss DESC;

--Pharmacy Analytics (Part 3) [CVS Health SQL Interview Question]
SELECT 
  manufacturer, 
  CONCAT( '$', ROUND(SUM(total_sales) / 1000000), ' million') AS sales_mil 
FROM pharmacy_sales 
GROUP BY manufacturer 
ORDER BY SUM(total_sales) DESC, manufacturer;

--Patient Support Analysis (Part 1) [UnitedHealth SQL Interview Question]
WITH smth AS (SELECT policy_holder_id, COUNT(case_id)
FROM callers
GROUP BY policy_holder_id 
HAVING COUNT(case_id) >= 3 
ORDER BY COUNT(case_id) ASC) 

SELECT COUNT(smth.policy_holder_id) AS policy_holder_count
FROM smth

--User's Third Transaction [Uber SQL Interview Question]
WITH ranked_transactions AS (SELECT 
user_id, 
spend, 
transaction_date, 
ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY transaction_date ASC) AS trees
FROM transactions),

max_trees AS (SELECT user_id, MAX(trees) AS maxi_trees
              FROM ranked_transactions
              GROUP BY user_id
              )
              
SELECT ranked_transactions.user_id, 
ranked_transactions.spend, 
ranked_transactions.transaction_date
FROM ranked_transactions
JOIN max_trees ON ranked_transactions.user_id = max_trees.user_id
AND max_trees.maxi_trees = ranked_transactions.trees
WHERE maxi_trees >= 3

--Second Highest Salary [FAANG SQL Interview Question]

SELECT MIN(salary) AS second_highest_salary
FROM (
    SELECT DISTINCT salary
    FROM employee
    ORDER BY salary DESC
    LIMIT 2
) AS subquery;

--Sending vs. Opening Snaps [Snapchat SQL Interview Question]
WITH snap_costam AS (SELECT
                     age_bucket,
                     SUM(CASE WHEN activity_type = 'open' THEN time_spent ELSE 0 END) AS total_open_time,
                     SUM(CASE WHEN activity_type = 'send' THEN time_spent ELSE 0 END) AS total_spent_time,
                     SUM(time_spent) AS total_time
                     FROM activities
                     JOIN age_breakdown ON activities.user_id = age_breakdown.user_id
                     WHERE activity_type IN ('open' , 'send')
                     GROUP BY age_bucket)
SELECT snap_costam.age_bucket, 
      ROUND(((snap_costam.total_spent_time/snap_costam.total_time) * 100.00),2) AS send_perc,
      ROUND(((snap_costam.total_open_time/snap_costam.total_time) * 100.00),2) AS open_perc
FROM snap_costam

--Tweets' Rolling Averages [Twitter SQL Interview Question]
SELECT    
  user_id,    
  tweet_date,   
  ROUND(AVG(tweet_count) OVER (
    PARTITION BY user_id     
    ORDER BY tweet_date     
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
  ,2) AS rolling_avg_3d
FROM tweets;

-- Highest-Grossing Items [Amazon SQL Interview Question]
WITH tab1 AS (SELECT
              category,
              product,
              SUM(spend) AS spend
              FROM product_spend
              WHERE EXTRACT(YEAR FROM transaction_date) = 2022
              GROUP BY category,product),
              
almost AS (SELECT tab1.category, 
        tab1.product, tab1.spend, 
        ROW_NUMBER() OVER (PARTITION BY tab1.category ORDER BY tab1.spend DESC) AS total_spend
FROM tab1)

SELECT category , product , spend AS total_spend
FROM almost
WHERE total_spend <= 2

--Top Three Salaries [FAANG SQL Interview Question]
WITH combine AS (SELECT 
                  employee.employee_id, employee.name , employee.salary, employee.department_id, employee.manager_id, department.department_name
                  FROM employee
                  JOIN department ON department.department_id = employee.department_id),
numerki_row AS (SELECT combine.department_name ,
                combine.name ,
                combine.salary,
                DENSE_RANK() OVER (PARTITION BY department_name ORDER BY salary DESC) AS numerowanie_wierszy
                FROM combine)
SELECT department_name , name , salary
FROM numerki_row
WHERE salary IN (SELECT salary
                  FROM numerki_row
                  WHERE numerowanie_wierszy <=3)
ORDER BY department_name ASC,  salary DESC, name ASC


--Top 5 Artists [Spotify SQL Interview Question]
WITH top10 AS (
    SELECT *
    FROM global_song_rank 
    WHERE rank <= 10
    ORDER BY rank ASC
),
count_number_of_songs AS (SELECT 
       artists.artist_name, COUNT(top10.song_id) AS number_of_songs_in_top10
FROM top10
JOIN songs ON top10.song_id = songs.song_id
JOIN artists ON artists.artist_id = songs.artist_id
GROUP BY artists.artist_name
ORDER BY number_of_songs_in_top10 DESC),

almost_ready AS (SELECT count_number_of_songs.artist_name, 
        DENSE_RANK() OVER (ORDER BY number_of_songs_in_top10 DESC) AS artist_rank
FROM count_number_of_songs)

SELECT almost_ready.artist_name , almost_ready.artist_rank
FROM almost_ready
WHERE almost_ready.artist_rank <= 5

--Signup Activation Rate [TikTok SQL Interview Question]
WITH joined AS (SELECT * 
FROM emails 
LEFT JOIN texts ON emails.email_id = texts.email_id),


podsumowanie AS (SELECT SUM(CASE WHEN signup_action = 'Confirmed' THEN 1 ELSE 0 END) AS liczba_confirmed, 
SUM(CASE WHEN signup_action = 'Not Confirmed' THEN 1 ELSE 0 END) AS suma_notconfirmed,
SUM(CASE WHEN signup_action IS NOT NULL THEN 1 ELSE 0 END) AS liczba_wszystkich
FROM joined)


SELECT ROUND((liczba_confirmed* 1.0)/(liczba_wszystkich* 1.0),2) confirm_rate
FROM podsumowanie

--Supercloud Customer [Microsoft SQL Interview Question]
WITH joined AS (SELECT * 
FROM customer_contracts 
JOIN products ON customer_contracts.product_id = products.product_id),

ext AS (SELECT customer_id , 
product_category ,
DENSE_RANK() OVER (ORDER BY product_category) AS przypisanie
FROM joined),

category_count AS (
    SELECT COUNT(DISTINCT product_category) AS total_categories
    FROM ext
    ),

customer_category_count AS (
    SELECT customer_id, COUNT(DISTINCT product_category) AS category_count
    FROM ext
    GROUP BY customer_id
)

SELECT customer_id 
FROM customer_category_count
JOIN category_count ON category_count.total_categories = customer_category_count.category_count

-- Odd and Even Measurements [Google SQL Interview Question]
WITH przypis AS (SELECT 
    measurement_id,
    measurement_value,
    measurement_time,
    ROW_NUMBER() OVER (PARTITION BY EXTRACT(DAY FROM measurement_time) ORDER BY EXTRACT(HOUR FROM measurement_time)) AS przypisanie
FROM 
    measurements)
    
SELECT 
CAST(measurement_time AS DATE) AS measurement_day, 
SUM(CASE WHEN przypisanie % 2 <> 0 THEN measurement_value ELSE 0 END) AS odd_sum,
SUM(CASE WHEN przypisanie % 2 = 0 THEN measurement_value ELSE 0 END) AS  even_sum 
FROM przypis
GROUP BY measurement_day
ORDER BY odd_sum ASC, even_sum ASC

--Histogram of Users and Purchases [Walmart SQL Interview Question]
WITH abc AS (SELECT transaction_date , user_id , product_id , spend
FROM user_transactions
ORDER BY user_id ASC, transaction_date ASC),

ranking AS (SELECT transaction_date , user_id , product_id , spend,
DENSE_RANK() OVER (PARTITION BY user_id ORDER BY transaction_date DESC) AS hwdp
FROM abc)

SELECT transaction_date, user_id , COUNT(product_id) AS purchase_count
FROM ranking
WHERE hwdp = 1
GROUP BY transaction_date, user_id 

--Compressed Mode [Alibaba SQL Interview Question]
WITH maksy AS (SELECT item_count , order_occurrences 
FROM items_per_order
ORDER BY order_occurrences DESC),


ranke AS (SELECT item_count , order_occurrences , 
DENSE_RANK() OVER (ORDER BY order_occurrences DESC) AS hwdp
FROM maksy)

SELECT item_count AS mode
FROM ranke
WHERE hwdp = 1
ORDER BY item_count ASC

--Card Launch Success [JPMorgan Chase SQL Interview Question]
WITH karty AS (SELECT card_name , issued_amount , issue_month,
ROW_NUMBER() OVER (PARTITION BY card_name ORDER BY issue_year ASC, issue_month ASC) AS numeracja
FROM monthly_cards_issued) 

SELECT card_name , issued_amount 
FROM karty
WHERE numeracja = 1 
ORDER BY issued_amount DESC

-- International Call Percentage [Verizon SQL Interview Question]
WITH call_details AS (
    SELECT 
        phone_calls.caller_id,
        phone_calls.receiver_id,
        phone_calls.call_time,
        a.country_id AS caller_country,
        b.country_id AS receiver_country
    FROM 
        phone_calls
    JOIN 
        phone_info a ON phone_calls.caller_id = a.caller_id
    JOIN 
        phone_info b ON phone_calls.receiver_id = b.caller_id
)

SELECT ROUND(SUM (CASE WHEN caller_country <> receiver_country THEN 1 ELSE 0 END) *1.0/COUNT(*) * 1.0 *100.00 , 1) AS international_calls_pct
FROM call_details

--Patient Support Analysis (Part 2) [UnitedHealth SQL Interview Question]
SELECT ROUND(COUNT(call_category) * 1.0/ COUNT(*) * 100.0/10,1) AS uncategorised_call_pct
FROM callers
WHERE call_category = 'n/a' OR call_category IS NULL 

--Active User Retention [Facebook SQL Interview Question]
WITH segregacja AS (SELECT user_actions.user_id, user_actions.event_id, user_actions.event_type, CASE WHEN user_actions.event_date IS NOT NULL THEN EXTRACT(MONTH FROM event_date) ELSE NULL END AS event_date, user_actions.month
FROM user_actions
WHERE user_actions.event_type IN ( 'sign-in', 'like', 'comment')
AND user_actions.event_date IN (SELECT user_actions.event_date
                 FROM user_actions
                 WHERE EXTRACT(MONTH FROM event_date) = 06 OR EXTRACT(MONTH FROM event_date) = 07 )
ORDER BY user_id ASC), 

densed AS (SELECT user_id , event_id , event_type , event_date, month, 
DENSE_RANK() OVER (PARTITION BY user_id ORDER BY event_date) as numerki
FROM segregacja)

SELECT month , COUNT (DISTINCT user_id) AS monthly_active_users
FROM densed
WHERE numerki = 2
GROUP BY month
                 
;

--Y-on-Y Growth Rate [Wayfair SQL Interview Question]
WITH ranking AS (SELECT transaction_id , product_id , spend , transaction_date, 
DENSE_RANK() OVER (PARTITION BY product_id ORDER BY transaction_date ASC) AS ranked
FROM user_transactions),

prev_year AS (SELECT a.transaction_id , a.product_id , a.spend, a.transaction_date, b.spend AS prev_year_spend
FROM ranking a
LEFT JOIN ranking b ON a.product_id = b.product_id AND a.ranked = b.ranked +1)

SELECT EXTRACT(YEAR FROM prev_year.transaction_date) AS year , prev_year.product_id, prev_year.spend AS curr_year_spend, prev_year.prev_year_spend,
ROUND((prev_year.spend - prev_year.prev_year_spend)/ prev_year.prev_year_spend	* 100.0,2) AS yoy_rate
FROM prev_year 

--Maximize Prime Item Inventory [Amazon SQL Interview Question]
WITH summary AS (  
  SELECT  
    item_type,  
    SUM(square_footage) AS total_sqft,  
    COUNT(*) AS item_count  
  FROM inventory  
  GROUP BY item_type
),
prime_occupied_area AS (  
  SELECT  
    item_type,
    total_sqft,
    FLOOR(500000/total_sqft) AS prime_item_batch_count,
    (FLOOR(500000/total_sqft) * item_count) AS prime_item_count
  FROM summary  
  WHERE item_type = 'prime_eligible'
)

SELECT
  item_type,
  CASE 
    WHEN item_type = 'prime_eligible' 
      THEN (FLOOR(500000/total_sqft) * item_count)
    WHEN item_type = 'not_prime' 
      THEN FLOOR((500000 - (SELECT FLOOR(500000/total_sqft) * total_sqft FROM prime_occupied_area)) / total_sqft) * item_count
  END AS item_count
FROM summary
ORDER BY item_type DESC;

--Median Google Search Frequency [Google SQL Interview Question]
WITH searches_expanded AS (
  SELECT searches
  FROM search_frequency
  GROUP BY 
    searches, 
    GENERATE_SERIES(1, num_users)
    ORDER BY searches ASC),
    
calculated AS (SELECT searches , ROW_NUMBER() OVER (ORDER BY searches) , COUNT(*) OVER ()
FROM searches_expanded)


SELECT ROUND(AVG(searches),1) AS median

FROM calculated 

WHERE row_number IN ((count + 1)/2, (count +2)/2)

--Who Made Quota? [Oracle SQL Interview Question]
WITH tot_deals AS (SELECT employee_id , SUM(deal_size) AS deal_size
                    FROM deals
                    GROUP BY employee_id)
                    
SELECT tot_deals.employee_id , CASE WHEN tot_deals.deal_size >= sales_quotas.quota THEN 'yes' ELSE 'no' END AS made_quota
FROM tot_deals
JOIN sales_quotas ON tot_deals.employee_id = sales_quotas.employee_id
ORDER BY employee_id ASC

--Well Paid Employees [FAANG SQL Interview Question]
WITH salary_cal AS (SELECT e.employee_id ,
e.name , 
e.salary , 
e.department_id, 
e.manager_id , 
b.salary AS manager_salary
FROM employee e
LEFT JOIN employee b ON e.manager_id = b.employee_id
ORDER BY employee_id ASC),

almost_done AS (SELECT salary_cal.employee_id,
CASE WHEN salary_cal.manager_salary < salary_cal.salary THEN salary_cal.name ELSE NULL END AS employee_name 
FROM salary_cal)

SELECT * FROM almost_done
WHERE employee_name IS NOT NULL

