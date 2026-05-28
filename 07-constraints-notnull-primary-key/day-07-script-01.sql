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


-- ############ DEFINE PRIMARY KEY: By ALTER'ing existing table ##############

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


-- ###### MySQL ignores Custom Constraint Name for Primary Key: ########

-- Run the ALTER TABLE to add PRIMARY KEY again:
-- (Add a named PRIMARY KEY this time using CONSTRAINT clause)
ALTER TABLE `customers`
	ADD CONSTRAINT `PK_customers` PRIMARY KEY (customer_id);
-- This worked! (But keep in mind, MySQL has ignored the custom
-- name for the constraint that we provided, and instead MySQL
-- always goes the constraint name 'PRIMARY' for Primary Key!)

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
-- (Below command doesn't work coz. MySQL ignores custom constraint
-- name that we provide for Primary Key, and instead MySQL uses the
-- default constraint name of 'PRIMARY' for the Primary Key)
ALTER TABLE `customers` DROP CONSTRAINT `PK_customers`;
-- Above command fails since MySQL didn't save this name for any constraint.
-- Error received:
-- Error Code: 3940. Constraint 'PK_customers' does not exist.

-- How to DROP the PRIMARY KEY then?:
ALTER TABLE `customers` DROP PRIMARY KEY;
-- This works fine, & drops the Primary Key.
-- Above command gives this response (Table currently has 2 Records in total):
-- 2 row(s) affected Records: 2  Duplicates: 0  Warnings: 0

-- Re-add the PRIMARY KEY:
ALTER TABLE `customers`
	ADD CONSTRAINT `PK_customers` PRIMARY KEY (customer_id);

-- Show INDEX'es from the `customers` table:
-- (Notice the `key_name` column value is 'PRIMARY')
SHOW INDEX FROM `retail_db`.`customers`;

-- Show contents of `information_schema`.`table_constraints` table:
-- (Notice the `constraint_name` column value is 'PRIMARY')
SELECT * FROM `information_schema`.`table_constraints` WHERE
	table_schema = 'retail_db' AND table_name = 'customers';


-- ###### Error when Primary Key constraint violation occurs ########

-- Tables for Error Demo:
DROP TABLE IF EXISTS `temp_order_item`;
CREATE TABLE `temp_order_item` (
  `order_id` INT,
  `product_id` INT,
  `quantity` INT,
  PRIMARY KEY (`order_id`, `product_id`)
);
DROP TABLE IF EXISTS `temp_delivery_address`;
CREATE TABLE `temp_delivery_address` (
  `address_id` INT,
  `user_id` INT,
  `full_address` VARCHAR(255),
  PRIMARY KEY (`address_id`)
);

-- >>> Attempt NULL Value based Violation:

INSERT INTO `temp_order_item` (`order_id`, `product_id`, `quantity`)
  VALUES (1, 50100, 2);
-- Above INSERT: Valid Record. Works fine!
SELECT * FROM `temp_order_item`;

INSERT INTO `temp_order_item` (`order_id`, `product_id`, `quantity`)
  VALUES (NULL, 50100, 2);
-- Above INSERT: Invalid Record. Fails with error:
-- Error Code: 1048. Column 'order_id' cannot be null

INSERT INTO `temp_order_item` (`order_id`, `product_id`, `quantity`)
  VALUES (1, NULL, 2);
-- Above INSERT: Invalid Record. Fails with error:
-- Error Code: 1048. Column 'product_id' cannot be null

INSERT INTO `temp_order_item` (`order_id`, `product_id`, `quantity`)
  VALUES (NULL, NULL, 2);
-- Above INSERT: Invalid Record. Fails with error:
-- Error Code: 1048. Column 'order_id' cannot be null

INSERT INTO `temp_delivery_address` (`address_id`, `user_id`, `full_address`)
  VALUES (1, 11200, 'Vidyarthi Bhavan, Gandhi Bazaar, Bengaluru');
-- Above INSERT: Valid Record. Works fine!
SELECT * FROM `temp_delivery_address`;

INSERT INTO `temp_delivery_address` (`address_id`, `user_id`, `full_address`)
  VALUES (NULL, 11200, 'By2 Coffee, Basavanagudi, Bengaluru');
-- Above INSERT: Invalid Record. Fails with error:
-- Error Code: 1048. Column 'address_id' cannot be null


-- >>> Attempt duplicate based Violation:

INSERT INTO `temp_order_item` (`order_id`, `product_id`, `quantity`) VALUES
  (1, 50125, 4),
  (1, 50179, 3),
  (2, 50134, 1),
  (2, 50179, 6),
  (1, 50125, 3); -- Here (1, 50125) Primary Key column-set values are duplicate!
-- Fails with below error:
-- Error Code: 1062. Duplicate entry '1-50125' for key 'temp_order_item.PRIMARY'

INSERT INTO `temp_delivery_address` (`address_id`, `user_id`, `full_address`) VALUES
  (2, 11200, 'By2 Coffee, Basavanagudi, Bengaluru'),
  (3, 11200, 'Vasantha Vallabharaya Devasthana, Vasanthapura, Bengaluru'),
  (2, 11307, 'CTR Malleshwaram'); -- Here (2) Primary Key column-set values are duplicate!
-- Fails with below error:
-- Error Code: 1062. Duplicate entry '2' for key 'temp_delivery_address.PRIMARY'

