-- ################# Cleanup #################

-- Start with a clean slate:
DROP DATABASE retail_db;
CREATE DATABASE retail_db;
USE retail_db;


-- ################# Initialize data #################

-- Create `orders` table:
CREATE TABLE orders (
    order_id INT,
    order_item_id INT,
    order_date DATE,
    customer_id INT,
    product_id INT,
    quantity INT,
    product_price FLOAT,
    total_price FLOAT
);

DESCRIBE orders;

-- Insert data for five orders in the `orders` table:
INSERT INTO orders VALUES
(1, 1, '2013-07-25', 11599, 957, 1, 299.98, 299.98),
(2, 2, '2013-07-25', 256, 1073, 1, 199.99, 199.99),
(2, 3, '2013-07-25', 256, 502, 5, 50.00, 250.00),
(2, 4, '2013-07-25', 256, 403, 1, 129.99, 129.99),
(4, 5, '2013-07-25', 8827, 897, 2, 24.99, 49.98),
(4, 6, '2013-07-25', 8827, 365, 5, 59.99, 299.95),
(4, 7, '2013-07-25', 8827, 502, 3, 50.00, 150.00),
(4, 8, '2013-07-25', 8827, 1014, 4, 49.98, 199.92),
(5, 9, '2013-07-25', 11318, 957, 1, 299.98, 299.98),
(5, 10, '2013-07-25', 11318, 365, 5, 59.99, 299.95),
(5, 11, '2013-07-25', 11318, 1014, 2, 49.98, 99.96),
(5, 12, '2013-07-25', 11318, 957, 1, 299.98, 299.98),
(5, 13, '2013-07-25', 11318, 403, 1, 129.99, 129.99);


-- ################# ADD COLUMN #################

-- Now, we need to track another data-point "Order Status"
-- for each order.

-- Add a new column `order_status` to the `orders` table:
ALTER TABLE orders ADD COLUMN order_status VARCHAR(20);

SELECT * FROM orders;


-- ################# INSERT Variations #################

-- Below INSERT (without column-list) statement fails, now that
-- we have 9 columns (after addition of 1 extra `order_status` column).
-- Because, Column Count of table does not matches with the
-- Value Count in below INSERT (without column-list) statement:
-- Error Code: 1136. Column count doesn't match value count at row 1
-- INSERT INTO orders
-- VALUES (7, 14, '2013-07-25', 4530, 1073, 1, 199.99, 199.99);

-- Instead, we provide column-names list:
INSERT INTO orders
(order_id, order_item_id, order_date, customer_id,
product_id, quantity, product_price, total_price)
VALUES
(7, 14, '2013-07-25', 4530, 1073, 1, 199.99, 199.99);

-- Delete this recently added order's record(s):
DELETE FROM orders WHERE order_id = 7;

-- To, re-add the order with 3 order-items:
INSERT INTO orders
(order_id, order_item_id, order_date, customer_id, order_status,
product_id, quantity, product_price, total_price) VALUES
(7, 14, '2013-07-25', 4530, 'COMPLETE', 1073, 1, 199.99, 199.99),
(7, 15, '2013-07-25', 4530, 'COMPLETE', 957, 1, 299.98, 299.98),
(7, 16, '2013-07-25', 4530, 'COMPLETE', 926, 5, 15.99, 79.95);

-- Inserting records for order_id=8 (having 4 order-items).
-- Note: we provide NULL as values for order_status column.
-- Equivalently, we could have instead, omitted the order_status
-- column in the column-names list & it's value in the values list.
INSERT INTO orders
(order_id, order_item_id, order_date, customer_id, order_status,
product_id, quantity, product_price, total_price) VALUES
(8, 17, '2013-07-25', 2911, null, 365, 3, 59.99, 179.97),
(8, 18, '2013-07-25', 2911, null, 365, 5, 59.99, 299.95),
(8, 19, '2013-07-25', 2911, null, 1014, 4, 49.98, 199.92),
(8, 20, '2013-07-25', 2911, null, 502, 1, 50.00, 50.00);


-- ################# DROP COLUMN #################

-- Remove (i.e. DROP) the `total_price` column of `orders` table:
ALTER TABLE orders DROP COLUMN total_price;

SELECT * FROM orders;


-- ################# MODIFY COLUMN #################
-- ====== (Change the data-type of a column) ======

-- ======== (DATE to DATETIME and back) ======
-- ========== (column: order_date) ==============

-- Requirement: Change the data-type of `order_date` column
-- from DATE to now having the DATETIME type instead.
-- So, that we are able to capture the order's time as well
-- in addition to just the date.
ALTER TABLE orders MODIFY order_date DATETIME;
-- Now, the order_date column has the time value of midnight '00:00:00'

-- Change type back to DATE (from DATETIME).
-- Executes without errors or warnings.
-- No time data was anyways going to be lost, as it was
-- midnight '00:00:00' for all rows.
ALTER TABLE orders MODIFY COLUMN order_date DATE;
-- (Note: COLUMN keyword is optional to specify after MODIFY)

-- Now, we change the type back to DATETIME. Why?
-- So that, we can insert few records that have a non-midnight
-- time data, i.e. time data which can be lost if we change
-- the column data-type to DATE, when such data exists in the table
ALTER TABLE orders MODIFY order_date DATETIME;

-- Let's check the table structure before going further:
DESCRIBE orders;

-- We now add records that have non-midnight time data:
-- We'll add those records for order_id=7 - so we first delete existing
-- records where order_id=7
DELETE FROM orders WHERE order_id = 7;

-- Insert non-midnight time records for order_id=7
INSERT INTO orders
(order_id, order_item_id, order_date, customer_id, order_status,
product_id, quantity, product_price) VALUES
 -- this below record has non-midnight time data for `order_date`
(7, 14, '2013-07-25 12:42:30', 4530, 'COMPLETE', 1073, 1, 199.99),
(7, 15, '2013-07-25', 4530, 'COMPLETE', 957, 1, 299.98),
(7, 16, '2013-07-25', 4530, 'COMPLETE', 926, 5, 15.99);

SELECT * FROM orders;

-- Now, what if we convert the `order_date` column type to DATE from DATETIME?
-- Now that we have the below record in the table which can be affected
-- from the column type conversion to DATE:
-- Record: (order_id=7, order_item_id=14, order_date='2013-07-25 12:42:30')
ALTER TABLE orders MODIFY order_date DATE;
-- The above ALTER command worked, changing the column type from
-- DATETIME to DATE, and, we just get a warning from MySQL:
/*
20 row(s) affected, 1 warning(s):
1292 Incorrect date value: '2013-07-25 12:42:30' for column 'order_date' at row 18
Records: 20  Duplicates: 0  Warnings: 1
*/

-- Demo done. Change column type back to DATETIME:
ALTER TABLE orders MODIFY COLUMN order_time DATETIME;
