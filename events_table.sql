-- Create the events table
CREATE TABLE events (
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id NVARCHAR(50),
    product_id NVARCHAR(50),
    event_type NVARCHAR(50),
    event_time DATETIME
);

-- Insert sample events
INSERT INTO events (user_id, product_id, event_type, event_time) VALUES
-- User 1 interacting with Hoodie
('U001', 'P001', 'product_view', '2025-05-01 09:15'),
('U001', 'P001', 'add_to_cart', '2025-05-01 09:17'),
('U001', 'P001', 'begin_to_checkout', '2025-05-01 09:18'),
('U001', 'P001', 'purchase', '2025-05-01 09:20'),

-- User 2 drops off after add_to_cart
('U002', 'P001', 'product_view', '2025-05-02 14:10'),
('U002', 'P001', 'add_to_cart', '2025-05-02 14:12'),

-- User 3 never purchases
('U003', 'P001', 'product_view', '2025-05-03 11:30'),

-- Users 4 and 5 for Bluetooth Speaker
('U004', 'P002', 'product_view', '2025-05-01 10:00'),
('U004', 'P002', 'add_to_cart', '2025-05-01 10:05'),
('U004', 'P002', 'begin_to_checkout', '2025-05-01 10:06'),

('U005', 'P002', 'product_view', '2025-05-02 13:00'),
('U005', 'P002', 'add_to_cart', '2025-05-02 13:02'),
('U005', 'P002', 'begin_to_checkout', '2025-05-02 13:03'),
('U005', 'P002', 'purchase', '2025-05-02 13:05'),

-- User 6 for Smartwatch
('U006', 'P007', 'product_view', '2025-05-04 09:00'),
('U006', 'P007', 'add_to_cart', '2025-05-04 09:02'),
('U006', 'P007', 'begin_to_checkout', '2025-05-04 09:03'),
('U006', 'P007', 'purchase', '2025-05-04 09:04'),

-- More views but no follow-up
('U007', 'P007', 'product_view', '2025-05-05 08:15'),
('U008', 'P007', 'product_view', '2025-05-05 08:20'),
('U009', 'P007', 'product_view', '2025-05-05 08:30');