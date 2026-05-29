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
