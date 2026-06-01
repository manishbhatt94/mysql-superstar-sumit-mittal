-- ====== "customers" <-> "orders" Table (One-To-Many) ========

-- "Parent" / "Referenced" table `customers`:
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
	customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    PRIMARY KEY (customer_id)
);

-- "Child" / "Referencing" table `orders`:
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
	order_id INT,
    order_date DATE,
    customer_id INT,
    PRIMARY KEY (order_id)
);

-- Insert a "customers" table record (customer_id = 1):
INSERT INTO customers (customer_id, first_name, last_name)
	VALUES (1, 'John', 'Doe');
-- Inserted!

SELECT * FROM customers;

-- Insert a "orders" table record (made by customer_id=1):
-- Referential Integrity wise: This is a valid "orders" record
-- as (customer_id=1) record does exists in "customers" table.
INSERT INTO orders (order_id, order_date, customer_id)
	VALUES (3001, '2023-07-14', 1);
-- This INSERT is allowed by MySQL, as expected.

-- Insert a "orders" table record (made by customer_id=57):
-- Referential Integrity wise: This is a INVALID "orders" record
-- as (customer_id=57) record DOES NOT EXIST in "customers" table.
INSERT INTO orders (order_id, order_date, customer_id)
	VALUES (3002, '2023-07-14', 57);
-- This INSERT was ALSO allowed by MySQL - Since we haven't yet
-- specified a Foreign Key Constraint using which MySQL
-- can know about the relationship b/w the tables, and can
-- then enforce Referential Integrity!

SELECT * FROM orders;

ALTER TABLE `orders`
	ADD FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`);
-- Error Code: 1452. Cannot add or update a child row:
--   a foreign key constraint fails
--   (`retail_db`.`#sql-1560_26b`, CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`))


ALTER TABLE `orders`
	ADD CONSTRAINT `orders_fk_customer_id`
	FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`);
-- Error Code: 1452. Cannot add or update a child row:
--   a foreign key constraint fails
--   (`retail_db`.`#sql-1560_26b`, CONSTRAINT `orders_fk_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`))

-- The errors happen coz on attempting to add the foreign key constraint, MySQL
-- will first, try to validate whether the existing data in these tables is
-- satisfying the constraint or not (i.e. the values of the foreign key column
-- in the "child" table, must be present in the referenced column of the
-- "parent" table).
-- Which is not the case, as according to the existing data in our tables, the
-- the "orders" table contains a foreign key column value of (customer_id = 57),
-- that is not present in the referenced column of the "customers" table.


-- ===== Drop both tables - Recreate with constraint =======

-- "Parent" / "Referenced" table `customers`:
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
	customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    PRIMARY KEY (customer_id)
);

-- "Child" / "Referencing" table `orders`:
-- (This time, "Child" table definition includes the Foreign Key constraint)
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
	order_id INT,
    order_date DATE,
    customer_id INT,
    PRIMARY KEY (order_id),
    -- Un-named constraint:
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
);

-- Insert a "customers" table record (customer_id = 1):
INSERT INTO customers (customer_id, first_name, last_name)
	VALUES (1, 'John', 'Doe');
-- Inserted!

SELECT * FROM customers;

-- Insert a "orders" table record (made by customer_id=1):
-- Referential Integrity wise: This is a valid "orders" record
-- as (customer_id=1) record does exists in "customers" table.
INSERT INTO orders (order_id, order_date, customer_id)
	VALUES (3001, '2023-07-14', 1);
-- This INSERT is allowed by MySQL, as expected.

-- Insert a "orders" table record (made by customer_id=57):
-- Referential Integrity wise: This is a INVALID "orders" record
-- as (customer_id=57) record DOES NOT EXIST in "customers" table.
INSERT INTO orders (order_id, order_date, customer_id)
	VALUES (3002, '2023-07-14', 57);
-- MySQL is able to enforce Referential Integrity now that our
-- Foreign Key constraint is present. Above INSERT fails with:
-- Error Code: 1452. Cannot add or update a child row:
--   a foreign key constraint fails
--   (`retail_db`.`orders`, CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`))

SELECT * FROM orders;

-- ======= Table Dropping Ordering ============

-- If we try to first DROP the parent ("customers") table,
-- then we are not allowed to do so by MySQL, even when there
-- are no records in both tables at all, so no records exist
-- that link orders with customers.
-- This might be coz MySQL knows that the child ("orders") table is
-- dependent on the parent ("customers") table to exist, as it references
-- the latter, so if the parent is allowed to be dropped first, then
-- the foreign key in the child table would not make sense.

-- Attempting to DROP the parent table first:
DROP TABLE customers;
-- Gives below error:
-- Error Code: 3730. Cannot drop table 'customers' referenced by
--   a foreign key constraint 'orders_ibfk_1' on table 'orders'.

-- So, we drop them in order: child, and then parent table:
DROP TABLE orders;
DROP TABLE customers;

-- ############### REFERENTIAL ACTIONS ####################

-- ====== Demo for CASCADE (ON DELETE) ===========

CREATE TABLE customers (
	customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    PRIMARY KEY (customer_id)
);

-- Note: The ON DELETE CASCADE sub-clause in the FOREIGN KEY constraint defintion
CREATE TABLE orders (
	order_id INT,
    order_date DATE,
    customer_id INT,
    PRIMARY KEY (order_id),
    -- Named constraint:
    CONSTRAINT orders_fk_customer_id
    	FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
    	ON DELETE CASCADE
);

-- Insert demo data:

INSERT INTO customers (customer_id, first_name, last_name) VALUES
	(1, 'John', 'Doe'), -- Has 3 orders: 3001, 3002, 3003.
    (2, 'Jane', 'Smith'); -- Has 2 orders: 3004, 3005.
INSERT INTO orders (order_id, order_date, customer_id) VALUES
	(3001, '2023-07-14', 1),
    (3002, '2023-07-14', 1),
    (3003, '2023-07-14', 1),
    (3004, '2023-07-17', 2),
    (3005, '2023-07-17', 2);

-- Now verify if ON DELETE CASCADE works, by deleting a "customers"
-- parent table record (customer_id = 1):
DELETE FROM customers WHERE customer_id = 1;
SELECT * FROM customers;

-- Check the "orders" table to see if the DELETE on parent table
-- record, has been 'cascaded' to the linked child table records:
SELECT * FROM orders;
-- And, we see that orders linked with (customer_id = 1) are also
-- automatically deleted.

-- === What if the CASCADE referential action is Not Provide for ON DELETE? ========

-- By default, both ON UPDATE and ON DELETE have the Referential Action
-- set to "RESTRICT" (which is the same behaviour as "NO ACTION").
-- This means, updates / deletes to parent table records (which have
-- linked records in child table) - WILL BE REJECTED!

-- First check the constraint name:
SELECT
	`constraint_name`, `table_schema`, `table_name`, `column_name`,
    `referenced_table_name`, `referenced_column_name`
	FROM `information_schema`.`key_column_usage`
	WHERE `table_schema` = 'retail_db' AND `table_name` = 'orders';
-- Got the constraint name: 'orders_fk_customer_id'!

-- Drop the Foreign Key constrait, and re-add it with RESTRICT or NO ACTION
-- or Not Specify it:
ALTER TABLE orders DROP CONSTRAINT orders_fk_customer_id;

-- Either: Don't specify ON DELETE <referential_action>:
ALTER TABLE orders ADD CONSTRAINT orders_fk_customer_id
	FOREIGN KEY (customer_id) REFERENCES customers (customer_id);
-- Either: OR specify ON DELETE RESTRICT:
ALTER TABLE orders ADD CONSTRAINT orders_fk_customer_id
	FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
    ON DELETE RESTRICT;
-- Either: OR specify ON DELETE NO ACTION:
ALTER TABLE orders ADD CONSTRAINT orders_fk_customer_id
	FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
    ON DELETE NO ACTION;

-- Clean up data:
DELETE FROM orders;
DELETE FROM customers;

-- Re-insert the data:
INSERT INTO customers (customer_id, first_name, last_name) VALUES
	(1, 'John', 'Doe'), -- Has 3 orders: 3001, 3002, 3003.
    (2, 'Jane', 'Smith'); -- Has 2 orders: 3004, 3005.
INSERT INTO orders (order_id, order_date, customer_id) VALUES
	(3001, '2023-07-14', 1),
    (3002, '2023-07-14', 1),
    (3003, '2023-07-14', 1),
    (3004, '2023-07-17', 2),
    (3005, '2023-07-17', 2);

-- Try deleting parent table record, now:
DELETE FROM customers WHERE customer_id = 1;
-- ====>>
-- Above DELETE statement fails with (when ON DELETE is not specified in the constraint):
-- Error Code: 1451. Cannot delete or update a parent row:
--   a foreign key constraint fails
--   (`retail_db`.`orders`, CONSTRAINT `orders_fk_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`))

-- ====>>
-- Above DELETE statement fails with (when ON DELETE is not specified in the constraint):
-- Error Code: 1451. Cannot delete or update a parent row:
--   a foreign key constraint fails
--   (`retail_db`.`orders`, CONSTRAINT `orders_fk_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE RESTRICT)

-- ====>>
-- Above DELETE statement fails with (when ON DELETE is not specified in the constraint):
-- Error Code: 1451. Cannot delete or update a parent row:
--   a foreign key constraint fails
--   (`retail_db`.`orders`, CONSTRAINT `orders_fk_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`))
