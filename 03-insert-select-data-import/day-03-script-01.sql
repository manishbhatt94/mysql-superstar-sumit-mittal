CREATE TABLE order_items (
    order_item_id INT,
    order_item_order_id INT,
    order_item_product_id INT,
    order_item_quantity INT,
    order_item_subtotal FLOAT,
    order_item_product_price FLOAT
);

INSERT INTO order_items VALUES (1, 1, 957, 1, 299.98, 299.98);
INSERT INTO order_items VALUES (2, 1, 958, 1, 113.3, 113.3);
-- Rounding and precision errors with FLOAT type, especially with monetary values
INSERT INTO order_items VALUES (3, 1, 959, 1, 339.9878, 339.9856);

-- Use DECIMAL data type: DECIMAL(P, D), where P = Total no. of digits, and
-- D = No. of digits after the decimal point.
-- DECIMAL is a fixed-precision data type that stores exact values, making it
-- ideal for financial data where precision is crucial

-- Modify the column definition (data-type & constraints) of column(s):
ALTER TABLE order_items
    MODIFY COLUMN order_item_subtotal DECIMAL(20, 4),
    MODIFY COLUMN order_item_product_price DECIMAL(20, 4);

SELECT * FROM order_items;

-- Create `customers` table:
CREATE TABLE customers (
    customer_id INT,
    customer_fname VARCHAR(45),
    customer_lname VARCHAR(45),
    customer_email VARCHAR(45),
    customer_phone VARCHAR(45),
    customer_street VARCHAR(255),
    customer_city VARCHAR(45),
    customer_state VARCHAR(45),
    customer_zipcode VARCHAR(45)
);
-- ALTER TABLE customers RENAME COLUMN customer_password TO customer_phone;

-- Inserting record with all columns (with All Column Insert syntax)
INSERT INTO customers VALUES
(1, 'Richard', 'Hernandez', 'richardhernandez@gmail.com', '9191919191', '6303 Heather Plaza', 'Brownsville', 'TX', '78521');

-- Inserting record with NOT all columns (with All Column Insert syntax)
-- Error Code: 1136. Column count doesn't match value count at row 1
-- INSERT INTO customers VALUES
-- (2,'Mary','Barrett','marybarrett@yahoo.com','8181818181','Littleton','CO','80126');

-- Inserting record with Selective Column Insert syntax:
INSERT INTO customers
(customer_id, customer_fname, customer_lname, customer_email, customer_phone, customer_city, customer_state, customer_zipcode)
VALUES
(2,'Mary','Barrett','marybarrett@yahoo.com','8181818181','Littleton','CO','80126');

-- Inserting record with reordered column values with Selective Column Insert syntax:
INSERT INTO customers
(customer_fname, customer_id, customer_lname, customer_email, customer_phone, customer_city, customer_state, customer_zipcode)
VALUES
('John',3,'Cena','johncena9@aol.net','9876543210','Phoenix','AZ','70524');

SELECT * FROM customers;

-- Selecting a few columns / Renaming columns
SELECT customer_fname AS firstname, customer_id, customer_city, customer_state FROM customers;

-- Truncate (delete all records from) `customers` table
-- to import data from CSV file:
-- TRUNCATE TABLE customers;

-- Get count of rows:
SELECT COUNT(*) FROM customers;

-- Limit the number of records returned:
SELECT * FROM customers LIMIT 5;

-- Ordering by a column in ASC (default sort direction, i.e. can omit ASC) order
SELECT * FROM customers ORDER BY customer_fname ASC LIMIT 10;
SELECT * FROM customers ORDER BY customer_fname LIMIT 10;

-- Ordering by a column in DESC (descending) order
SELECT * FROM customers ORDER BY customer_fname DESC LIMIT 10;
