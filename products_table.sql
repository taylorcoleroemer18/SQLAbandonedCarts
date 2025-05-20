-- Create the products table
CREATE TABLE products (
    product_id NVARCHAR(50) PRIMARY KEY,
    product_name NVARCHAR(255),
    price DECIMAL(10,2)
);

-- Insert sample products
INSERT INTO products (product_id, product_name, price) VALUES
('P001', 'Cozy Hoodie', 49.99),
('P002', 'Bluetooth Speaker', 89.99),
('P003', 'Insulated Water Bottle', 25.00),
('P004', 'LED Desk Lamp', 39.99),
('P005', 'Running Shoes', 69.99),
('P006', 'Noise Cancelling Headphones', 129.99),
('P007', 'Smartwatch', 199.99),
('P008', 'Yoga Mat', 24.99),
('P009', 'Fleece Blanket', 35.00),
('P010', 'Graphic T-Shirt', 19.99);