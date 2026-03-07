-- Show logged in MySQL user
SELECT USER(); -- Prints: "root@localhost"

-- Show list of existing databases:
SHOW DATABASES;

-- Show currently active database
SELECT DATABASE();

-- Create a new database with name `retail_db`:
CREATE DATABASE retail_db;

-- Switch to database with name `retail_db`:
USE retail_db;

-- Create table `orders`:
CREATE TABLE orders (
    order_id INT,
    order_date DATETIME,
    order_customer_id INT,
    order_status VARCHAR(40)
);

-- ALTER TABLE orders RENAME COLUMN customer_id TO order_customer_id;

-- List the tables present in the currently selected database:
SHOW TABLES;

-- List more info about the tables in the currently selected database
-- such as engine, rows count, collation, create / update time, etc.
SHOW TABLE STATUS;

-- Describe the structure of a table (DESC / DESCRIBE [table_name]):
DESCRIBE orders;
-- DESC orders;

-- Delete the table named `orders`:
-- DROP TABLE orders;

-- Delete the database named `retail_db`;
-- DROP DATABASE retail_db;

-- Insert a row in `orders` table:
INSERT INTO orders VALUES (1, '2013-07-25 00:00:00', 11599, 'CLOSED');
-- Note: Below we omit specifying the time part of the `order_date` column:
INSERT INTO orders VALUES (2, '2013-07-25', 256, 'PENDING_PAYMENT');

-- Insert a row, while specifying column names:
INSERT INTO orders (order_id, order_date, order_customer_id, order_status)
	VALUES (3, '2013-07-25 00:00:00.0', 12111, 'COMPLETE');

-- Insert multiple rows:
INSERT INTO orders VALUES
	(4, '2013-07-25 00:00:00.0', 8827, 'CLOSED'),
	(5, '2013-07-25 00:00:00.0', 11318, 'COMPLETE');

-- Insert multiple rows, while specifying column names:
INSERT INTO orders
	(order_id, order_date, order_customer_id, order_status)
	VALUES
    (6, '2013-07-25 00:00:00.0', 7130, 'COMPLETE'),
	(7, '2013-07-25 00:00:00.0', 4530, 'COMPLETE'),
	(8, '2013-07-25 00:00:00.0', 2911, 'PROCESSING');

-- Fetch records from `orders` table:
SELECT * FROM orders;
