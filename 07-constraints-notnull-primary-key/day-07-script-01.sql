-- #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#
-- ##################### NOT NULL Constraint #######################
-- #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#

-- ==== CLEAN-UP ====
DROP TABLE IF EXISTS `orders`;
CREATE TABLE orders (
    order_id INT,
    order_item_id INT,
    order_date DATE,
    customer_id INT,
    order_status VARCHAR(30),
    product_id INT,
    quantity INT,
    product_price FLOAT,
    total_price FLOAT
);


-- ######## Add NOT NULL Constraint to `order_status` Column #########

-- Without this constraint, NULL values are permitted in this column.
-- Below INSERT statement confirms this:
INSERT INTO orders
    (order_id, order_item_id, order_date, customer_id, order_status,
    product_id, quantity, product_price, total_price)
    VALUES
    (1, 1, '2013-07-25', 11599, NULL, 957, 1, 299.98, 299.98);
-- Above INSERT is allowed right now, since there's not any NOT NULL
-- constraints present on the table's columns.

SELECT * FROM orders;

-- Use ALTER TABLE...MODIFY COLUMN to add the NOT NULL Constraint:
ALTER TABLE orders MODIFY COLUMN order_status VARCHAR(30) NOT NULL;
-- This fails since we have a record for which "order_status"
-- column value is NULL.
--  Error received:
-- "Error Code: 1138. Invalid use of NULL value"

-- Let's first sanitize that record (update it's value to some non-null value):
UPDATE orders SET order_status = 'PENDING' WHERE order_status IS NULL;

-- Now, let's try again to add the NOT NULL constraint:
ALTER TABLE orders MODIFY COLUMN order_status VARCHAR(30) NOT NULL;
-- This time, the ALTER statement works fine!

-- Verify if constraint is working, by trying to INSERT an invalid
-- record (having NULL value in "order_status" column):
INSERT INTO orders
    (order_id, order_item_id, order_date, customer_id, order_status,
    product_id, quantity, product_price, total_price)
    VALUES
    (1, 2, '2013-07-25', 11599, NULL, 814, 2, 50.00, 100.00);
-- Above INSERT fails with error:
-- Error Code: 1048. Column 'order_status' cannot be null


-- ###### Remove NOT NULL Constraint from `order_status` Column #######

-- Just specify the constraint as: NULL.
-- In the same ALTER TABLE..MODIFY COLUMN statement:
ALTER TABLE orders MODIFY COLUMN order_status VARCHAR(30) NULL;
-- Worked fine!

-- Verify if constraint has been removed properly:
INSERT INTO orders
    (order_id, order_item_id, order_date, customer_id, order_status,
    product_id, quantity, product_price, total_price)
    VALUES
    (1, 3, '2013-07-25', 11599, NULL, 981, 4, 12.25, 49.00);
-- Worked fine! Allowed to insert NULL value in column "order_status".

-- ==== Re-create "orders" table with NOT NULL constraints ====
DROP TABLE IF EXISTS `orders`;
CREATE TABLE orders (
    order_id INT NOT NULL,
    order_item_id INT NOT NULL,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    product_price FLOAT NOT NULL,
    total_price FLOAT NOT NULL
);
-- Now, every column has the NOT NULL constraint!

-- === Try INSERT statement column-list syntax & omit some columns ===
INSERT INTO orders (order_id, order_item_id) VALUES (1, 1);
-- Fails with error:
-- Error Code: 1364. Field 'order_date' doesn't have a default value


-- #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#
-- ################### PRIMARY KEY Constraint ######################
-- #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#


-- ######### `customers` Table ###########

DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers` (
    `customer_id` INT NOT NULL,
    `customer_fname` VARCHAR(50) NOT NULL,
    `customer_lname` VARCHAR(50) NOT NULL,
    `customer_email` VARCHAR(100) NOT NULL,
    `customer_phone` VARCHAR(30),
    `customer_street` VARCHAR(255),
    `customer_city` VARCHAR(50) NOT NULL,
    `customer_state` VARCHAR(50) NOT NULL,
    `customer_zipcode` VARCHAR(10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Primary Key hasn't been specified as of now. But, we have planned to specify
-- the column set (`customer_id`) as this table's Primary Key, later on.

-- Right now, let's try to INSERT two (2) records, that have the same duplicate
-- value for the "customer_id" column, which should be allowed as of now:
INSERT INTO customers VALUES
    (1, 'Richard', 'Hernandez', 'richardhernandez@gmail.com', NULL,
        '6303 Heather Plaza', 'Brownsville', 'TX', '78521'),
    (1, 'Mary', 'Barrett', 'marybarrett@yahoo.com', NULL,
        '9526 New Commercial Avenue', 'Littleton','CO','80126');
-- As expected, above INSERT statement has worked fine.

SELECT * FROM customers;

-- #### DEFINE PRIMARY KEY: By ALTER'ing existing table ####

-- Adds an un-named PRIMARY KEY Constraint:
ALTER TABLE customers ADD PRIMARY KEY (customer_id);
-- Fails with error below:
-- Error Code: 1062. Duplicate entry '1' for key 'customers.PRIMARY'

-- Let's fix the duplicate entry by updating "customer_id"
-- column value for record: customer_fname='Mary'
UPDATE customers SET customer_id = 2 WHERE customer_fname='Mary';

-- Run the ALTER TABLE to add PRIMARY KEY again:
ALTER TABLE customers ADD PRIMARY KEY (customer_id);
-- This worked!

-- Here is our CREATE TABLE script:
-- (Notice the PRIMARY KEY Constraint is not named)
SHOW CREATE TABLE customers;
/**
CREATE TABLE `customers` (
  `customer_id` int NOT NULL,
  `customer_fname` varchar(50) NOT NULL,
  `customer_lname` varchar(50) NOT NULL,
  `customer_email` varchar(100) NOT NULL,
  `customer_phone` varchar(30) DEFAULT NULL,
  `customer_street` varchar(255) DEFAULT NULL,
  `customer_city` varchar(50) NOT NULL,
  `customer_state` varchar(50) NOT NULL,
  `customer_zipcode` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
 */

-- Drop the PRIMARY KEY:
ALTER TABLE `customers` DROP PRIMARY KEY;

-- Run the ALTER TABLE to add PRIMARY KEY again:
-- (Add a named PRIMARY KEY this time using CONSTRAINT clause)
ALTER TABLE `customers`
	ADD CONSTRAINT `PK_customers` PRIMARY KEY (customer_id);
-- This worked!

-- Here is our CREATE TABLE script:
-- (Notice the PRIMARY KEY Constraint is not named)
SHOW CREATE TABLE customers;
/**
CREATE TABLE `customers` (
  `customer_id` int NOT NULL,
  `customer_fname` varchar(50) NOT NULL,
  `customer_lname` varchar(50) NOT NULL,
  `customer_email` varchar(100) NOT NULL,
  `customer_phone` varchar(30) DEFAULT NULL,
  `customer_street` varchar(255) DEFAULT NULL,
  `customer_city` varchar(50) NOT NULL,
  `customer_state` varchar(50) NOT NULL,
  `customer_zipcode` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
 */

-- Drop the PRIMARY KEY:
ALTER TABLE `customers` DROP CONSTRAINT `PK_customers`;

-- Show INDEX'es from the `customers` table:
SHOW INDEX FROM `customers`;
