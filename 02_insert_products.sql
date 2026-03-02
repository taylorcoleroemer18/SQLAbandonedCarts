
-- 02_insert_products.sql
-- This file inserts product metadata used for analysis.

INSERT INTO dbo.products (product_id, product_name, category, price) VALUES
('P001', 'Cozy Hoodie', 'Apparel', 49.99),
('P002', 'Bluetooth Speaker', 'Electronics', 89.99),
('P003', 'Insulated Water Bottle', 'Outdoors', 25.00),
('P004', 'LED Desk Lamp', 'Home', 39.99),
('P005', 'Running Shoes', 'Apparel', 69.99),
('P006', 'Noise Cancelling Headphones', 'Electronics', 129.99),
('P007', 'Smartwatch', 'Electronics', 199.99),
('P008', 'Yoga Mat', 'Fitness', 24.99),
('P009', 'Fleece Blanket', 'Home', 35.00),
('P010', 'Graphic T-Shirt', 'Apparel', 19.99);
