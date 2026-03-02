-- 03_generate_events.sql
-- Generates realistic funnel event data using a temp table (works in SQL Server)

-- 1) Start clean
TRUNCATE TABLE dbo.events;

-- 2) Create a temp table to hold our simulated sessions
DROP TABLE IF EXISTS #sessions;

CREATE TABLE #sessions (
    user_id     NVARCHAR(50),
    product_id  NVARCHAR(50),
    base_time   DATETIME,
    r_cart      FLOAT,
    r_checkout  FLOAT,
    r_purchase  FLOAT
);

-- 3) Insert 800 simulated sessions into the temp table
INSERT INTO #sessions (user_id, product_id, base_time, r_cart, r_checkout, r_purchase)
SELECT TOP (800)
    CONCAT('U', FORMAT(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), '00000')) AS user_id,
    CONCAT('P', FORMAT(ABS(CHECKSUM(NEWID())) % 10 + 1, '000')) AS product_id,
    DATEADD(MINUTE, ABS(CHECKSUM(NEWID())) % 43200, '2025-05-01') AS base_time, -- within 30 days
    CAST(RAND(CHECKSUM(NEWID())) AS FLOAT) AS r_cart,
    CAST(RAND(CHECKSUM(NEWID())) AS FLOAT) AS r_checkout,
    CAST(RAND(CHECKSUM(NEWID())) AS FLOAT) AS r_purchase
FROM sys.objects;

-- 4) Everyone views
INSERT INTO dbo.events (user_id, product_id, event_type, event_time)
SELECT user_id, product_id, 'product_view', base_time
FROM #sessions;

-- 5) ~55% add to cart
INSERT INTO dbo.events (user_id, product_id, event_type, event_time)
SELECT user_id, product_id, 'add_to_cart', DATEADD(MINUTE, 2, base_time)
FROM #sessions
WHERE r_cart < 0.55;

-- 6) ~35% begin checkout
INSERT INTO dbo.events (user_id, product_id, event_type, event_time)
SELECT user_id, product_id, 'begin_checkout', DATEADD(MINUTE, 5, base_time)
FROM #sessions
WHERE r_checkout < 0.35;

-- 7) ~18% purchase
INSERT INTO dbo.events (user_id, product_id, event_type, event_time)
SELECT user_id, product_id, 'purchase', DATEADD(MINUTE, 9, base_time)
FROM #sessions
WHERE r_purchase < 0.18;
