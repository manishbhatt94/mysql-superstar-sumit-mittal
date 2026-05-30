-- #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#
-- ##################### DEFAULT Constraint ########################
-- #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#

-- ===== SPECIFY DEFAULT using CREATE TABLE =======

DROP TABLE IF EXISTS `employees`;
CREATE TABLE `employees` (
    `employee_id` INT PRIMARY KEY,
    `first_name` VARCHAR(50),
    `last_name` VARCHAR(50),
    `hire_date` DATE,
    `status` VARCHAR(20) DEFAULT 'active'
);

-- ============ VERIFY IF DEFAULT VALUE IS BEING INSERTED ================

-- ****** Omit the column having a DEFAULT constraint *******

INSERT INTO `employees` (`employee_id`, `first_name`, `last_name`, `hire_date`)
    VALUES (1, 'Kapil', 'Raj', '2023-07-01');
-- This INSERT is successful, and in new record's `status` column, the default
-- value 'active' is present.

SELECT * FROM `employees`;

-- ****** Using DEFAULT keyword instead of providing a value *******

INSERT INTO `employees`
    VALUES (2, 'Shweta', 'Tiwari', '2021-05-12', DEFAULT);

-- ***** Using DEFAULT keyword to update value back to the Default Value *****

-- Let's say we mistakenly updated `status` column to 'EMP_ACTIVATED'
-- which is not a valid status value according to our business:
UPDATE `employees` SET `status` = 'EMP_ACTIVATED';

SELECT * FROM `employees`;
-- All records' `status` field wrongly updated to 'EMP_ACTIVATED'!

-- Now how to reset value of `status` column back to its Default
-- Value, for all records?

-- We can use the DEFAULT Keyword in UPDATE query:
UPDATE `employees` SET `status` = DEFAULT;
-- This updates the table & sets the value of `status` field to
-- its Default Value!

-- ~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~

-- #### Provide EXPRESSIONS (e.g. CURDATE) as Default Value ######

DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
	`order_id` INT PRIMARY KEY,
    `customer_id` INT,
    `product_id` INT,
    `quantity` INT,
    `order_date` DATE DEFAULT (CURRENT_DATE())
    -- ⬆️ <<-- Expressions provided must be enclosed within parentheses!
);

SELECT CURRENT_DATE; -- 2026-05-29 (Date in YYYY-MM-DD).

-- Insert records to see if default value of current date is being applied:

INSERT INTO orders (order_id, customer_id, product_id, quantity)
	VALUES (1, 1101, 502001, 2), (2, 1101, 502002, 3);

INSERT INTO orders VALUES
	(3, 1102, 502001, 4, '2026-03-24'),
    (4, 1102, 502092, 1, DEFAULT),
    (5, 1102, 502007, 2, DEFAULT);

SELECT * FROM orders;


-- ~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~

-- ######## Try inserting all defaults ##############
-- === Using: INSERT INTO orders () VALUES (); =====

-- First, drop primary key:
ALTER TABLE orders DROP PRIMARY KEY;

-- Also drop the NOT NULL on `order_id` column
-- (automatically present since it was Primary Key column):
ALTER TABLE orders MODIFY COLUMN order_id INT NULL; -- Specify that NULL is allowed.

-- Add default value for `order_id` column:
-- (Won't be required after removing NOT NULL constraint)
ALTER TABLE orders ALTER COLUMN order_id SET DEFAULT 111;

DESCRIBE orders;

-- Insert record with all fields as their default value:
INSERT INTO orders () VALUES ();



-- #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#
-- ##################### AUTO_INCREMENT ############################
-- #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#

-- Create `animals` table with the integer type `id` (MEDIUMINT)
-- column having AUTO_INCREMENT attribute:
DROP TABLE IF EXISTS `animals`;
CREATE TABLE `animals` (
    `id` MEDIUMINT NOT NULL AUTO_INCREMENT,
    `name` CHAR(30) NOT NULL,
    PRIMARY KEY (`id`)
);

-- Insert two (2) records with two separate INSERTs:
INSERT INTO animals (name) VALUES ('cow');
INSERT INTO animals (name) VALUES ('rabbit');

SELECT * FROM animals;
/*
+----+--------+
| id | name   |
+----+--------+
|  1 | cow    |
|  2 | rabbit |
+----+--------+
*/

-- You can retrieve the most recent automatically generated AUTO_INCREMENT
-- value with the LAST_INSERT_ID() SQL function:
SELECT LAST_INSERT_ID(); -- Returns 2.

-- Insert six (6) records in the table in a single INSERT,
-- without specify values for `id` column:
INSERT INTO animals (name) VALUES
    ('dog'),('cat'),('penguin'),
    ('lax'),('whale'),('ostrich');

-- For a multiple-row insert, LAST_INSERT_ID() actually return the
-- AUTO_INCREMENT key from the first of the inserted rows.
-- This enables multiple-row inserts to be reproduced correctly
-- on other servers in a replication setup. 
SELECT LAST_INSERT_ID(); -- Returns 3.

-- Verify if all records had their `id` column populated:
SELECT * FROM animals;


-- Create `employees` table with the integer `employee_id` (INT)
-- column having AUTO_INCREMENT attribute:
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
	employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    hire_date DATE
);

INSERT INTO employees (first_name, last_name, hire_date)
	VALUES ('John', 'Doe', '2024-10-08');
INSERT INTO employees (first_name, last_name, hire_date)
	VALUES ('Jane', 'Smith', '2024-11-01');

SELECT LAST_INSERT_ID(); -- Returns 2.

-- Verify if all records had their `employee_id` column populated:
SELECT * FROM employees;

-- ############ Choose custom value for AUTO_INCREMENT ##############

-- ======== Using CREATE TABLE with Table Option ===========
DROP TABLE IF EXISTS animals;

CREATE TABLE `animals` (
    `id` MEDIUMINT NOT NULL AUTO_INCREMENT,
    `name` CHAR(30) NOT NULL,
    PRIMARY KEY (`id`)
) AUTO_INCREMENT=3001; -- Note: Here we supply the 'AUTO_INCREMENT' Table Option.
-- Above we set desired initial AUTO_INCREMENT starting value.

INSERT INTO animals (name) VALUES ('dog');
INSERT INTO animals (name) VALUES ('cat');
INSERT INTO animals (name) VALUES ('penguin');

-- Verify if auto increment column starts at 3001:
SELECT * FROM animals;
SELECT LAST_INSERT_ID();
