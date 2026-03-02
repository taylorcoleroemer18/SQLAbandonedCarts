-- 01_create_tables.sql
-- This file creates the tables we need for the project.

DROP TABLE IF EXISTS dbo.events;
DROP TABLE IF EXISTS dbo.products;

CREATE TABLE dbo.products (
    product_id   NVARCHAR(50) PRIMARY KEY,
    product_name NVARCHAR(255),
    category     NVARCHAR(100),
    price        DECIMAL(10,2)
);

CREATE TABLE dbo.events (
    event_id   INT IDENTITY(1,1) PRIMARY KEY,
    user_id    NVARCHAR(50) NOT NULL,
    product_id NVARCHAR(50) NOT NULL,
    event_type NVARCHAR(50) NOT NULL,
    event_time DATETIME     NOT NULL
);

ALTER TABLE dbo.events
ADD CONSTRAINT FK_events_products
FOREIGN KEY (product_id) REFERENCES dbo.products(product_id);
