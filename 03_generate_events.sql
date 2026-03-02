-- 03_generate_events.sql
-- This file generates realistic funnel event data.

;WITH n AS (
    SELECT TOP (800)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS session_id
    FROM sys.objects
),
sessions AS (
    SELECT
        CONCAT('U', FORMAT(session_id, '00000')) AS user_id,
        CONCAT('P', FORMAT(ABS(CHECKSUM(NEWID())) % 10 + 1, '000')) AS product_id,
        DATEADD(MINUTE, ABS(CHECKSUM(NEWID())) % 43200, '2025-05-01') AS base_time,
        CAST(RAND(CHECKSUM(NEWID())) AS FLOAT) AS r_cart,
        CAST(RAND(CHECKSUM(NEWID())) AS FLOAT) AS r_checkout,
        CAST(RAND(CHECKSUM(NEWID())) AS FLOAT) AS r_purchase
    FROM n
)
-- Everyone views
INSERT INTO dbo.events (user_id, product_id, event_type, event_time)
SELECT user_id, product_id, 'product_view', base_time
FROM sessions;

-- ~55% add to cart
INSERT INTO dbo.events (user_id, product_id, event_type, event_time)
SELECT user_id, product_id, 'add_to_cart', DATEADD(MINUTE, 2, base_time)
FROM sessions
WHERE r_cart < 0.55;

-- ~35% begin checkout
INSERT INTO dbo.events (user_id, product_id, event_type, event_time)
SELECT user_id, product_id, 'begin_checkout', DATEADD(MINUTE, 5, base_time)
FROM sessions
WHERE r_checkout < 0.35;

-- ~18% purchase
INSERT INTO dbo.events (user_id, product_id, event_type, event_time)
SELECT user_id, product_id, 'purchase', DATEADD(MINUTE, 9, base_time)
FROM sessions
WHERE r_purchase < 0.18;
