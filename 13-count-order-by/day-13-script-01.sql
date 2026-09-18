-- # TOPIC: COUNT Function. ORDER BY.

USE retail_db;
SHOW TABLES;

SELECT * FROM employees;
SELECT * FROM customers;

/* `employees` Table Structure (CREATE TABLE script):
CREATE TABLE `employees` (
  `employee_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `department_id` int DEFAULT NULL,
  `salary` decimal(10,2) DEFAULT NULL,
  `hire_date` date DEFAULT NULL,
  `manager_id` int DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `job_title` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
*/

/* `customers` Table Structure (CREATE TABLE script):
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
*/


-- #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#
-- #@#@##@#@##@#@##@#@#@# COUNT() Function #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#
-- #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#

-- Get count of all records in `customers` table:
SELECT COUNT(*) FROM customers; -- Returns 12,435.

-- Count of `customers` who are from California ('CA') state:
SELECT COUNT(*) FROM customers WHERE customer_state = 'CA'; -- Returns 2,012.

-- Returns 2,012 rows containing a single column, with
-- string 'manish' in all the 2,012 rows!
SELECT 'manish' FROM customers WHERE customer_state = 'CA';

-- Returns 2,012
SELECT COUNT('manish') FROM customers WHERE customer_state = 'CA';

-- Returns 2,012 rows containing a single column, with
-- integer 1 in all the 2,012 rows!
SELECT 1 FROM customers WHERE customer_state = 'CA';

-- Returns 2,012
SELECT COUNT(1) FROM customers WHERE customer_state = 'CA';

-- Get count of records in `employees` table:
SELECT COUNT(*) FROM employees; -- Returns 32 (Total count of all records).

-- Get count of employees who have `salary`> 50000
SELECT COUNT(*) FROM employees WHERE salary > 50000; -- Returns 15.

-- ========= COUNT(expression) ===================

-- Get count of `employees` table records who report to a manager, i.e.
-- count all records for whom value of `manager_id` IS NOT NULL.
SELECT COUNT(*) FROM employees WHERE manager_id IS NOT NULL;
-- Returns 29. (Remember that total count of all records is 32).

-- Same can be achieved by passing the column name `manager_id` as an
-- argument to the COUNT(...) Function.
-- So, using COUNT(manager_id) will count all records in the table
-- where the value of that column is not null.

SELECT COUNT(manager_id) FROM employees;
-- Note: Above COUNT(manager_id) ==> Returns 29 - which is less than
-- the total count of all records in the `employees` table, which is 32.

-- ========= COUNT(DISTINCT expression) ===================

-- Select all DISTINCT states in `customers` table:
SELECT DISTINCT customer_state FROM customers; -- Total 44 records.

-- Get count of all DISTINCT states present in `customers` table's
-- `customer_state` column:
SELECT COUNT(DISTINCT customer_state) FROM customers; -- Returns 44.

-- ========= COUNT(*) with GROUP BY ===================

-- Get count of customers per state:
SELECT customer_state, COUNT(*) FROM customers
	GROUP BY customer_state
    ORDER BY COUNT(*) DESC;

-- Select states from which there are more than 300 customers:
SELECT customer_state, COUNT(*) FROM customers
	GROUP BY customer_state HAVING COUNT(*) > 300
    ORDER BY COUNT(*) DESC;


-- #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#
-- #@#@##@#@##@#@##@#@#@# ORDER BY Clause #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#@
-- #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#


-- Create "orders" table and import data into it from CSV file "orders.csv"!

-- Read file cli-fast-csv-import.md at this repository's root folder, to recall data import
-- procedure using CLI.

CREATE TABLE `retail_db`.`orders` (
  `order_id` INT NOT NULL AUTO_INCREMENT,
  `order_date` DATE NOT NULL,
  `customer_id` INT NULL,
  `order_status` VARCHAR(40) NULL,
  PRIMARY KEY (`order_id`),
  INDEX `fk_customer_id_idx` (`customer_id` ASC) VISIBLE,
  CONSTRAINT `fk_customer_id`
    FOREIGN KEY (`customer_id`)
    REFERENCES `retail_db`.`customers` (`customer_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


/*
LOAD DATA LOCAL INFILE 'C:/Users/Manish/Dev/SQL/mysql-superstar/datasets/Extracted-01/orders.csv'
INTO TABLE retail_db.orders
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'    -- Use '\r\n' when CSV file has Windows style line endings.
IGNORE 1 LINES
(order_id, order_date, customer_id, order_status);
*/

/*
LOAD DATA LOCAL INFILE 'C:/Users/Manish/Dev/SQL/mysql-superstar/datasets/Extracted-01/orders.csv'
INTO TABLE retail_db.orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'    -- Use '\n' when CSV file has Unix style line endings.
IGNORE 1 LINES
(order_id, order_date, customer_id, order_status);
*/
