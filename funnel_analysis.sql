-- Query to count how many distinct users completed each event type 
SELECT event_type, COUNT(DISTINCT user_id) AS user_count FROM events
GROUP BY event_type;

-- Calculate conversion rates
SELECT
	SUM(viewed) AS viewed,
	SUM(added_to_cart) AS added_to_cart,
	SUM(began_checkout) AS began_checkout,
	SUM(purchased) AS purchased
FROM (
	SELECT 
		user_id, 
		MAX(CASE WHEN event_type = 'product_view' THEN 1 ELSE 0 END) AS viewed,
		MAX(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS added_to_cart,
		MAX(CASE WHEN event_type = 'begin_to_checkout' THEN 1 ELSE 0 END) AS began_checkout,
		MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
	FROM events
	GROUP BY user_id
) funnel;

WITH funnel_data AS (
	SELECT
	SUM(viewed) AS viewed,
	SUM(added_to_cart) AS added_to_cart,
	SUM(began_checkout) AS began_checkout,
	SUM(purchased) AS purchased
	FROM (
		SELECT 
			user_id, 
			MAX(CASE WHEN event_type = 'product_view' THEN 1 ELSE 0 END) AS viewed,
			MAX(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS added_to_cart,
			MAX(CASE WHEN event_type = 'begin_to_checkout' THEN 1 ELSE 0 END) AS began_checkout,
			MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
		FROM events
		GROUP BY user_id
	) base
)
SELECT 
	viewed,
	added_to_cart,
	began_checkout,
	purchased, 
	ROUND(CAST(added_to_cart AS FLOAT) / viewed * 100.00, 2) AS add_to_cart_rate,
	ROUND(CAST(began_checkout AS FLOAT) / viewed * 100.00, 2) AS began_checkout_rate,
	ROUND(CAST(purchased AS FLOAT) / viewed * 100.00, 2) AS purchased_rate
FROM funnel_data;

-- Out of 3 users who viewed products, 100% added to cart, but only 33% completed a purchase
-- We're losing users in checkout, so we will investigate that step based on products
-- Which products are converting well, and which are losing users along the way?

-- Query to track which steps each user completed for each product
SELECT 
	user_id, 
	product_id,
	MAX(CASE WHEN event_type = 'product_view' THEN 1 ELSE 0 END) AS viewed,
	MAX(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS added_to_cart,
	MAX(CASE WHEN event_type = 'begin_to_checkout' THEN 1 ELSE 0 END) AS began_checkout,
	MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
FROM events
GROUP BY user_id, product_id;

-- Query to total how many users completed each step, grouped by product
WITH user_product_funnel AS (
	SELECT 
		user_id,
		product_id,
		MAX(CASE WHEN event_type = 'product_view' THEN 1 ELSE 0 END) AS viewed,
		MAX(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS added_to_cart,
		MAX(CASE WHEN event_type = 'begin_to_checkout' THEN 1 ELSE 0 END) AS began_checkout,
		MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
	FROM events
	GROUP BY user_id, product_id
)
SELECT 
	product_id,
	COUNT(*) AS users,
	SUM(viewed) AS viewed,
	SUM(added_to_cart) AS added_to_cart,
	SUM(began_checkout) AS began_checkout,
	SUM(purchased) AS purchased
FROM user_product_funnel
GROUP BY product_id;

-- Let's convert it into rates to see product performance
WITH user_product_funnel AS (
	SELECT 
		user_id,
		product_id,
		MAX(CASE WHEN event_type = 'product_view' THEN 1 ELSE 0 END) AS viewed,
		MAX(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS added_to_cart,
		MAX(CASE WHEN event_type = 'begin_to_checkout' THEN 1 ELSE 0 END) AS began_checkout,
		MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
	FROM events
	GROUP BY user_id, product_id
),
product_summary AS (
	SELECT 
		product_id,
		SUM(viewed) AS viewed,
		SUM(added_to_cart) AS added_to_cart,
		SUM(began_checkout) AS began_checkout,
		SUM(purchased) AS purchased
	FROM user_product_funnel
	GROUP BY product_id
)
SELECT
	product_id,
	viewed,
	added_to_cart,
	began_checkout,
	purchased, 
	ROUND(CAST(added_to_cart AS FLOAT) / NULLIF(viewed, 0) * 100, 2) AS add_to_cart_rate,
	ROUND(CAST(began_checkout AS FLOAT) / NULLIF(viewed, 0) * 100, 2) AS began_checkout_rate,
	ROUND(CAST(purchased AS FLOAT) / NULLIF(viewed, 0) * 100, 2) AS purchased_rate
FROM product_summary
ORDER BY purchased_rate DESC;

-- Join the tables
WITH user_product_funnel AS (
	SELECT 
		user_id,
		product_id,
		MAX(CASE WHEN event_type = 'product_view' THEN 1 ELSE 0 END) AS viewed,
		MAX(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS added_to_cart,
		MAX(CASE WHEN event_type = 'begin_to_checkout' THEN 1 ELSE 0 END) AS began_checkout,
		MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
	FROM events
	GROUP BY user_id, product_id
),
product_summary AS (
	SELECT 
		product_id,
		SUM(viewed) AS viewed,
		SUM(added_to_cart) AS added_to_cart,
		SUM(began_checkout) AS began_checkout,
		SUM(purchased) AS purchased
	FROM user_product_funnel
	GROUP BY product_id
)
SELECT
	p.product_name,
	p.price,
	s.product_id,
	s.viewed,
	s.added_to_cart,
	s.began_checkout,
	s.purchased,
	ROUND(CAST(s.added_to_cart AS FLOAT) / NULLIF(viewed, 0) * 100, 2) AS add_to_cart_rate,
	ROUND(CAST(s.began_checkout AS FLOAT) / NULLIF(viewed, 0) * 100, 2) AS began_checkout_rate,
	ROUND(CAST(s.purchased AS FLOAT) / NULLIF(viewed, 0) * 100, 2) AS purchased_rate
FROM product_summary s
JOIN products p ON s.product_id = p.product_id
ORDER BY purchased_rate DESC;

-- From this data, we see products that are most likely to be purchased/not purchased, which can help influence business decisions in the future