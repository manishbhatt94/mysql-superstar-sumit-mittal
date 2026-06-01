-- ############# "customers" <-> "orders" Table (One-To-Many) #################

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



-- ############# "students" <-> "courses" Table (Many-To-Many) #################

DROP TABLE IF EXISTS students;
CREATE TABLE students (
	student_id INT,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	PRIMARY KEY (student_id)
);

DROP TABLE IF EXISTS courses;
CREATE TABLE courses (
	course_id INT,
	course_name VARCHAR(100),
	PRIMARY KEY (course_id)
);

DROP TABLE IF EXISTS enrollments;
CREATE TABLE enrollments (
	student_id INT,
	course_id INT,
	enrollment_date DATE,
	PRIMARY KEY (student_id, course_id),
	CONSTRAINT enrollments_fk_student_id
		FOREIGN KEY (student_id) REFERENCES students (student_id),
	CONSTRAINT enrollments_fk_course_id
		FOREIGN KEY (course_id) REFERENCES courses (course_id)
);

-- ==== Insert records: ======

-- One student; and one course:
INSERT INTO students (student_id, first_name, last_name) VALUES
	(1, 'Alice', 'Johnson');
INSERT INTO courses (course_id, course_name) VALUES
	(61001, 'Set Theory 101');

-- Valid record, since both foreign key values are present in
-- the respective referenced tables:
INSERT INTO enrollments (student_id, course_id, enrollment_date) VALUES
	(1, 61001, '2023-08-29');

TABLE students; -- SELECT * FROM students;
TABLE courses;
TABLE enrollments;

-- INVALID record! since both value for Foreign Key (course_id = 3535)
-- is not present in the referenced "courses" table:
INSERT INTO enrollments (student_id, course_id, enrollment_date) VALUES
	(1, 3535, '2023-08-29');
-- This INSERT fails with below error:
-- Error Code: 1452. Cannot add or update a child row:
--   a foreign key constraint fails
--   (`retail_db`.`enrollments`, CONSTRAINT `enrollments_fk_course_id` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`))


-- ############# Self Referencing Foreign Key #################
-- ==> `manager_id` column (within "employees" table) is an example
-- of a Self Referencing Foreign Key.

DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
	employee_id INT,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
    manager_id INT,
    PRIMARY KEY (employee_id)
);

TABLE employees; -- MySQL specific (non-standard SQL) equivalent to SELECT * FROM employees;

-- Insert the 1st employee record (manager can only be NULL, as of now):
INSERT INTO employees (employee_id, first_name, last_name, manager_id)
	VALUES (1, 'John', 'Doe', NULL);
-- Works fine!

-- Insert the 2nd employee record. Here manager has been specified as
-- the record with (employee_id = 1) which exists in the table:
INSERT INTO employees (employee_id, first_name, last_name, manager_id)
	VALUES (2, 'Jane', 'Smith', 1);
-- Works fine!

-- Invalid row - manager_id is being set to record with (employee_id = 1)
-- which doesn't yet exist. But we haven't yet added Foreign Key constraint
-- so this INSERT will be accepted.
INSERT INTO employees (employee_id, first_name, last_name, manager_id)
	VALUES (3, 'Alice', 'Johnson', 599);
-- Works b'coz we haven't added the FK constraint yet.

-- Let's delete the INVALID record (3, 'Alice', 'Johnson', 599) that
-- got inserted above, before adding the constraint
DELETE FROM employees WHERE employee_id = 3;

ALTER TABLE employees ADD CONSTRAINT employees_fk_manager_id
	FOREIGN KEY (manager_id) REFERENCES employees (employee_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE;
-- Now FK constraint is successfully added!

-- Let's try inserting that invalid (3, 'Alice', 'Johnson', 599) record
-- again, to verify if our new constraint prevents insertion:
INSERT INTO employees (employee_id, first_name, last_name, manager_id)
	VALUES (3, 'Alice', 'Johnson', 599);
-- As expected, above INSERT fails with:
-- Error Code: 1452. Cannot add or update a child row:
--   a foreign key constraint fails
--   (`retail_db`.`employees`, CONSTRAINT `employees_fk_manager_id` FOREIGN KEY (`manager_id`) REFERENCES `employees` (`employee_id`) ON DELETE SET NULL ON UPDATE CASCADE)

