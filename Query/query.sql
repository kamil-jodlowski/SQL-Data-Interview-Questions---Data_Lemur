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

  
--Advertiser Status [Facebook SQL Interview Question]

  
WITH mar AS (SELECT COALESCE(ad.user_id, dp.user_id) AS user_idd , ad.status , dp.paid , dp.status AS statuss
FROM advertiser ad
FULL OUTER JOIN daily_pay dp ON ad.user_id = dp.user_id)


SELECT user_idd, 
CASE 
  WHEN paid IS NULL THEN 'CHURN'
  WHEN paid IS NOT NULL AND status IN ('NEW', 'EXISTING', 'RESURRECT') THEN 'EXISTING'
  WHEN paid IS NOT NULL AND status = 'CHURN' THEN 'RESURRECT'
  WHEN paid IS NOT NULL AND status IS NULL THEN 'NEW'
  END AS new_status 
  FROM mar
  ORDER BY user_idd ASC


-- 3-Topping Pizzas [McKinsey SQL Interview Question]

--1) 

WITH combinations AS (SELECT pizza_toppings.topping_name , pizza_toppings.ingredient_cost , a.topping_name AS atopping_name  , a.ingredient_cost AS aingredient_cost, b.topping_name AS btopping_name , b.ingredient_cost AS bingredient_cost
FROM pizza_toppings 
JOIN pizza_toppings a ON pizza_toppings .topping_name < a.topping_name
JOIN pizza_toppings b ON a.topping_name < b.topping_name
)



SELECT CONCAT(topping_name, ',', atopping_name, ',' , btopping_name) AS pizza,
ingredient_cost + aingredient_cost + bingredient_cost AS total_cost
FROM combinations
ORDER BY total_cost DESC ,pizza;

--2)

SELECT 
  CONCAT(p1.topping_name, ',', p2.topping_name, ',', p3.topping_name) AS pizza,
  p1.ingredient_cost + p2.ingredient_cost + p3.ingredient_cost AS total_cost
FROM pizza_toppings AS p1
INNER JOIN pizza_toppings AS p2
  ON p1.topping_name < p2.topping_name 
INNER JOIN pizza_toppings AS p3
  ON p2.topping_name < p3.topping_name 
ORDER BY total_cost DESC, pizza;

--Repeated Payments [Stripe SQL Interview Question]
WITH agregate AS (SELECT transaction_id , merchant_id , credit_card_id	, transaction_timestamp , amount , 
DENSE_RANK() OVER (PARTITION BY merchant_id ORDER BY amount ASC) AS segregacja_merchant
FROM transactions), 

Segreg AS (SELECT transaction_id, merchant_id, credit_card_id, transaction_timestamp, amount, segregacja_merchant
FROM agregate
WHERE segregacja_merchant = 1), 
 

dupa AS (SELECT transaction_id, merchant_id, credit_card_id, transaction_timestamp, amount, 
ROW_NUMBER() OVER (PARTITION BY credit_card_id ORDER BY merchant_id ASC) AS seg_card
FROM Segreg ), 

godz AS (SELECT transaction_id, merchant_id, credit_card_id, transaction_timestamp, amount, 
LAG(transaction_timestamp) OVER () AS transaction_timestamp2,
DENSE_RANK() OVER (ORDER BY merchant_id) AS merchanty
FROM dupa 
WHERE seg_card <> 1 
ORDER BY transaction_timestamp ASC),

mer AS (SELECT transaction_id, merchant_id, credit_card_id, transaction_timestamp, amount, transaction_timestamp2, 
merchanty, LAG(merchanty) OVER () AS merchanty2
FROM godz),

ostateczna_selekcja AS (SELECT transaction_id, merchant_id, credit_card_id, transaction_timestamp, amount, transaction_timestamp2, merchanty,merchanty2,
CASE WHEN EXTRACT(EPOCH FROM (transaction_timestamp2 - transaction_timestamp)) / 60 <= 10 THEN 'Duplicate' 
        ELSE 'OK' 
    END AS status
    FROM mer
WHERE transaction_timestamp2 IS NOT NULL AND merchanty - merchanty2 = 0 
)

SELECT COUNT(*) AS payment_count
FROM ostateczna_selekcja

--Server Utilization Time [Amazon SQL Interview Question]

WITH servers AS (SELECT server_id , session_status, status_time, 
DENSE_RANK() OVER (PARTITION BY server_id ORDER BY status_time) AS start_stop
FROM server_utilization), 

time_difference AS (SELECT server_id , session_status, status_time, start_stop,
LAG(status_time) OVER (ORDER BY server_id) AS status_time_2
FROM servers), 

ready AS (SELECT server_id, session_status, status_time, start_stop, status_time_2,
ABS(EXTRACT(DAY FROM (status_time - status_time_2))) AS roznica,
DENSE_RANK() OVER (ORDER BY server_id) AS costam
FROM time_difference), 

sumka AS (SELECT server_id,session_status,status_time	start_stop, status_time_2, roznica, costam, 
LAG(costam) OVER () AS costam2, 
LAG(session_status) OVER () AS session_status_2
FROM ready)

SELECT SUM(roznica) AS total_uptime_days
FROM sumka
WHERE costam - costam2 = 0 AND session_status <> session_status_2

--Department vs. Company Salary [FAANG SQL Interview Question]

WITH joined AS (SELECT e.employee_id , e.name, e.department_id, s.payment_date, s.amount
FROM employee AS e 
JOIN salary AS s 
ON e.employee_id = s.employee_id),

company_total AS (SELECT employee_id, name, department_id,	payment_date, amount,
DENSE_RANK() OVER (ORDER BY EXTRACT(MONTH FROM payment_date)) AS num1
FROM joined),

company_summary_for_march AS (SELECT AVG(amount) AS sumka, TO_CHAR(payment_date, 'MM-YYYY') AS payment_date
FROM company_total
WHERE num1 = 3
GROUP BY payment_date ),


for_each_departament AS (SELECT employee_id,	name,	department_id,	payment_date, amount,
DENSE_RANK() OVER (PARTITION BY department_id ORDER BY payment_date) AS costam
FROM joined),

total_march_for_each_depart AS (SELECT department_id, TO_CHAR(payment_date, 'MM-YYYY') AS payment_date, AVG(amount) AS tot_amount
FROM for_each_departament 
WHERE costam = 3
GROUP BY department_id, payment_date),

comp AS (SELECT tmfed.department_id , tmfed.payment_date , tmfed.tot_amount, csfm.sumka
FROM total_march_for_each_depart AS tmfed
CROSS JOIN company_summary_for_march AS csfm) 

SELECT department_id , payment_date , 
CASE WHEN tot_amount < sumka THEN 'lower'
WHEN tot_amount = sumka THEN 'same' ELSE 'higher' END AS comparison
FROM comp

--Swapped Food Delivery [Zomato SQL Interview Question]

WITH selekcja AS (SELECT order_id , item , CASE WHEN order_id % 2 = 0 THEN order_id - 1 ELSE order_id END AS inne 
FROM orders),

numbered AS (SELECT order_id , item , inne , DENSE_RANK() OVER (PARTITION BY inne ORDER BY order_id DESC) AS segregacja
FROM selekcja)

SELECT ROW_NUMBER() OVER () AS corrected_order_id, CASE WHEN segregacja = 1 THEN item ELSE item END AS item
FROM numbered

--FAANG Stock Min-Max (Part 1) [Bloomberg SQL Interview Question]

WITH najwieksze AS (SELECT date , ticker , open, 
ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY open DESC ) AS numeracja
FROM stock_prices),

wyciagniete1 AS (SELECT * 
FROM najwieksze 
WHERE numeracja = 1), 

najmniejsze AS (SELECT date , ticker , open, 
ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY open ASC ) AS numeracja2
FROM stock_prices), 

wyciagniete2 AS (SELECT * 
FROM najmniejsze
WHERE numeracja2 = 1),

posegregowane AS (SELECT wyciagniete1.date AS date1, wyciagniete1.ticker AS ticker1 , wyciagniete1.open AS highest_open, wyciagniete1.numeracja, wyciagniete2.date AS date2, wyciagniete2.ticker AS ticker2, wyciagniete2.open AS lowest_open, wyciagniete2.numeracja2 
FROM wyciagniete1
JOIN wyciagniete2 ON wyciagniete1.ticker = wyciagniete2.ticker)

SELECT posegregowane.ticker1, TO_CHAR(date1, 'Mon-YYYY') AS highest_mth , posegregowane.highest_open, TO_CHAR(date2, 'Mon-YYYY') AS lowest_mth , posegregowane.lowest_open
FROM posegregowane

--Final Account Balance [Paypal SQL Interview Question]
SELECT account_id , SUM(CASE WHEN transaction_type = 'Deposit' THEN amount ELSE -amount END) AS final_balance
FROM transactions
GROUP BY account_id

--Fill Missing Client Data [Accenture SQL Interview Question]

WITH numbered_category AS (SELECT product_id, category , name , 
COUNT(category) OVER (ORDER BY product_id) AS x
FROM products)

SELECT product_id, 
COALESCE(category, MAX(category) OVER (PARTITION BY x)) AS category , name 
FROM numbered_category

--Spotify Streaming History [Spotify SQL Interview Question]
WITH polaczenia AS (SELECT user_id , song_id , COUNT(listen_time) AS do_czwartego
FROM songs_weekly
WHERE EXTRACT(DAY FROM listen_time) <= 4
GROUP BY user_id, song_id), 

wszystko AS (SELECT * FROM polaczenia
UNION ALL
SELECT user_id , song_id, song_plays FROM songs_history)

SELECT user_id , song_id , SUM(do_czwartego) AS song_plays
FROM wszystko 
GROUP BY user_id, song_id
ORDER BY song_plays DESC


-- Most Expensive Purchase [Amazon SQL Interview Question]

SELECT customer_id , MAX(purchase_amount)
FROM transactions 
GROUP BY customer_id
ORDER BY MAX(purchase_amount) DESC




