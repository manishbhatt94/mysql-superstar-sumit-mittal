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


