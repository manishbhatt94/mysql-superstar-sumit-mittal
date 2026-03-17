-- ################# RENAME COLUMN #################

-- Syntax: ALTER TABLE table_name RENAME COLUMN old_column_name TO new_column_name;

-- Renames column `order_date` to `order_time` in the `orders` table:
ALTER TABLE orders RENAME COLUMN order_date TO order_time;

-- Note: In case of ALTER TABLE ... RENAME COLUMN, the COLUMN keyword is mandatory.
-- MySQL Docs: 
/* 
The word COLUMN is optional and can be omitted, except for RENAME COLUMN
(to distinguish a column-renaming operation from the RENAME table-renaming operation).

We rename a table using below ALTER TABLE .. RENAME statement, or using RENAME statement:

ALTER TABLE old_table RENAME new_table;

RENAME TABLE old_table1 TO new_table1,
             old_table2 TO new_table2,
             old_table3 TO new_table3;
*/


-- ################# MODIFY COLUMN - More Scenarios #################
-- ================== (Change data-type of column) ===============
DESC orders;
SELECT * FROM orders;

-- ============== (FLOAT to INT) ==============
-- ========== (column: product_price) ==============

-- Requirement: Modify the data-type of `product_price` in `orders`
-- table from FLOAT to INT
ALTER TABLE orders MODIFY COLUMN product_price INT; -- WORKS
-- Runs successfully, without even warnings:
-- 20 row(s) affected Records: 20  Duplicates: 0  Warnings: 0

-- ============== (INT to VARCHAR) ==============
-- ============ (column: product_id) ==============

-- Requirement: Modify the data-type of `product_id` in `orders`
-- table from INT to VARCHAR

-- Note: We select a suitable max-length for the VARCHAR, which will be able to
-- accomodate all the product_id's INT values.
-- Here we select VARCHAR(6) - as we are confident that the original INT values
-- of product_id can be at max 6 digit (or lesser digits) integers - which the
-- new type VARCHAR(6) can easily accomodate without data loss.
ALTER TABLE orders MODIFY product_id VARCHAR(6); -- WORKS
-- Runs successfully as well

-- ============ (column: customer_id) ==============

-- Requirement: Modify the data-type of `customer_id` in `orders`
-- table from INT to VARCHAR

SELECT * FROM orders ORDER BY customer_id DESC LIMIT 10; -- Check the 4-5 digits `customer_id` values.

ALTER TABLE orders MODIFY COLUMN customer_id VARCHAR(3); -- FAILS

-- Note: Here we gave a smaller VARCHAR max-length, than what the data actually
-- is, i.e. we have customer_id values in our table, which are 4-5 digits long
-- integers as well, which is more digit length than what our new data-type
-- VARCHAR(3) can accomodate.

-- So, above ALTER statement fails with below error:
-- Error Code: 1406. Data too long for column 'customer_id' at row 1.
-- And so, the data-type of customer_id stays as it was earlier, i.e. INT.

-- ============== (DATETIME to INT) ==============
-- ============= (column: order_time) ==============

-- Requirement: Modify the data-type of `order_time` in `orders`
-- table from DATETIME to INT.
-- Try to see if the conversion from DATETIME to INT, is even permitted.

ALTER TABLE orders MODIFY order_time INT; -- FAILS
-- FAILS with below error:
-- Error Code: 1264. Out of range value for column 'order_time' at row 1.

-- ============= (DATETIME to VARCHAR) ==============
-- ============== (column: order_time) ==============

-- Requirement: Modify the data-type of `order_time` in `orders`
-- table from DATETIME to VARCHAR.

ALTER TABLE orders MODIFY order_time VARCHAR(50); -- WORKS

-- Note: Like previously stated, if we would have used a max-length
-- for VARCHAR that is too short for values of DATETIME, then we
-- would have got a similar "Data too long for column" error as before.
-- But, VARCHAR(50) can accomodate all DATETIME values.

-- ============= (VARCHAR to DATETIME) ==============
-- ============== (column: order_time) ==============

-- Requirement: Modify the data-type of `order_time` in `orders`
-- table, back to DATETIME from VARCHAR (reverse of what we just did).
-- Or, we could convert to DATE as well, instead.

ALTER TABLE orders MODIFY COLUMN order_time DATETIME; -- WORKS


-- ################# RENAME TABLE #################

-- Renames `orders` table (to have new name: `orders_with_status`):
ALTER TABLE orders RENAME TO orders_with_status;

SHOW TABLES; -- Confirm if table has been renamed.
