-- 04_funnel_analysis.sql
-- Funnel analysis: overall funnel + product funnel + revenue + 5% uplift.

-- Sanity check: event totals
SELECT event_type, COUNT(*) AS events
FROM dbo.events
GROUP BY event_type
ORDER BY events DESC;

-- 1) Overall funnel (step-to-step conversion)
WITH user_funnel AS (
    SELECT
        user_id,
        MAX(CASE WHEN event_type = 'product_view' THEN 1 ELSE 0 END) AS viewed,
        MAX(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS added_to_cart,
        MAX(CASE WHEN event_type = 'begin_checkout' THEN 1 ELSE 0 END) AS began_checkout,
        MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
    FROM dbo.events
    GROUP BY user_id
),
totals AS (
    SELECT
        SUM(viewed) AS viewed,
        SUM(added_to_cart) AS added_to_cart,
        SUM(began_checkout) AS began_checkout,
        SUM(purchased) AS purchased
    FROM user_funnel
)
SELECT
    viewed,
    added_to_cart,
    began_checkout,
    purchased,
    ROUND(CAST(added_to_cart AS FLOAT) / NULLIF(viewed,0) * 100, 2) AS view_to_cart_rate,
    ROUND(CAST(began_checkout AS FLOAT) / NULLIF(added_to_cart,0) * 100, 2) AS cart_to_checkout_rate,
    ROUND(CAST(purchased AS FLOAT) / NULLIF(began_checkout,0) * 100, 2) AS checkout_to_purchase_rate,
    ROUND(CAST(purchased AS FLOAT) / NULLIF(viewed,0) * 100, 2) AS view_to_purchase_rate
FROM totals;

-- 2) Product performance + revenue
WITH user_product_funnel AS (
    SELECT
        user_id,
        product_id,
        MAX(CASE WHEN event_type = 'product_view' THEN 1 ELSE 0 END) AS viewed,
        MAX(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS added_to_cart,
        MAX(CASE WHEN event_type = 'begin_checkout' THEN 1 ELSE 0 END) AS began_checkout,
        MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
    FROM dbo.events
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
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    s.viewed,
    s.added_to_cart,
    s.began_checkout,
    s.purchased,
    ROUND(CAST(s.added_to_cart AS FLOAT) / NULLIF(s.viewed,0) * 100, 2) AS view_to_cart_rate,
    ROUND(CAST(s.began_checkout AS FLOAT) / NULLIF(s.added_to_cart,0) * 100, 2) AS cart_to_checkout_rate,
    ROUND(CAST(s.purchased AS FLOAT) / NULLIF(s.began_checkout,0) * 100, 2) AS checkout_to_purchase_rate,
    ROUND(CAST(s.purchased AS FLOAT) / NULLIF(s.viewed,0) * 100, 2) AS view_to_purchase_rate,
    CAST(s.purchased * p.price AS DECIMAL(10,2)) AS revenue
FROM product_summary s
JOIN dbo.products p ON p.product_id = s.product_id
ORDER BY revenue DESC;

-- 3) 5% uplift scenario (checkout completion improvement)
WITH user_product_funnel AS (
    SELECT
        user_id,
        product_id,
        MAX(CASE WHEN event_type = 'begin_checkout' THEN 1 ELSE 0 END) AS began_checkout,
        MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
    FROM dbo.events
    GROUP BY user_id, product_id
),
product_summary AS (
    SELECT
        product_id,
        SUM(began_checkout) AS began_checkout,
        SUM(purchased) AS purchased
    FROM user_product_funnel
    GROUP BY product_id
)
SELECT
    p.product_name,
    p.category,
    s.began_checkout,
    s.purchased,
    CAST(s.purchased * p.price AS DECIMAL(10,2)) AS current_revenue,
    CAST((s.began_checkout * 0.05) * p.price AS DECIMAL(10,2)) AS projected_additional_revenue,
    CAST((s.purchased * p.price) + ((s.began_checkout * 0.05) * p.price) AS DECIMAL(10,2)) AS projected_revenue
FROM product_summary s
JOIN dbo.products p ON p.product_id = s.product_id
ORDER BY projected_additional_revenue DESC;
