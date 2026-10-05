USE retail_db;
SHOW TABLES;


-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
-- #=#=#=#=#=#=#=#=#=#=    Numeric / Math Functions    #=#=#=#=#=#=#=#=#=#=#=#=#
-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

-- https://www.mysqltutorial.org/mysql-math-functions/

-- ======== Absolute value of a number =========
SELECT ABS(-11);
SELECT ABS(-2.75);
SELECT ABS(-0);
SELECT ABS(4);

-- ============ CEIL ==============
SELECT CEIL(2.1);     -- Result: 3
SELECT CEIL(2.49);    -- Result: 3
SELECT CEIL(2.5);     -- Result: 3
SELECT CEIL(2.99);    -- Result: 3
SELECT CEIL(0.01);    -- Result: 1
SELECT CEIL(0.2);     -- Result: 1
SELECT CEIL(0.5);     -- Result: 1
SELECT CEIL(0.9);     -- Result: 1
SELECT CEIL(-0.01);   -- Result: 0
SELECT CEIL(-0.2);    -- Result: 0
SELECT CEIL(-0.5);    -- Result: 0
SELECT CEIL(-0.9);    -- Result: 0

-- ============ FLOOR ==============
SELECT FLOOR(2.1);     -- Result: 2
SELECT FLOOR(2.49);    -- Result: 2
SELECT FLOOR(2.5);     -- Result: 2
SELECT FLOOR(2.99);    -- Result: 2
SELECT FLOOR(0.01);    -- Result: 0
SELECT FLOOR(0.2);     -- Result: 0
SELECT FLOOR(0.5);     -- Result: 0
SELECT FLOOR(0.9);     -- Result: 0
SELECT FLOOR(-0.01);   -- Result: -1
SELECT FLOOR(-0.2);    -- Result: -1
SELECT FLOOR(-0.5);    -- Result: -1
SELECT FLOOR(-0.9);    -- Result: -1

-- ============ ROUND ==============
SELECT ROUND(2.1);     -- Result: 2
SELECT ROUND(2.49);    -- Result: 2
SELECT ROUND(2.5);     -- Result: 3
SELECT ROUND(2.99);    -- Result: 3
SELECT ROUND(0.01);    -- Result: 0
SELECT ROUND(0.2);     -- Result: 0
SELECT ROUND(0.5);     -- Result: 1
SELECT ROUND(0.9);     -- Result: 1
SELECT ROUND(-0.01);   -- Result: 0
SELECT ROUND(-0.2);    -- Result: 0
SELECT ROUND(-0.5);    -- Result: -1
SELECT ROUND(-0.9);    -- Result: -1

/* ROUND(n, [d])  -- d - positive */
SELECT ROUND(2.36745, 0);    -- Result: 2
SELECT ROUND(2.36745, 1);    -- Result: 2.4
SELECT ROUND(2.36745, 2);    -- Result: 2.37
SELECT ROUND(2.36745, 3);    -- Result: 2.367
SELECT ROUND(2.36745, 4);    -- Result: 2.3675

/* ROUND(n, [d])  -- d - negative */
SELECT ROUND(364528.5, -1);    -- Result: 364530
SELECT ROUND(364528.5, -2);    -- Result: 364500
SELECT ROUND(364528.5, -3);    -- Result: 365000
SELECT ROUND(364528.5, -4);    -- Result: 360000
SELECT ROUND(364528.5, -5);    -- Result: 400000
SELECT ROUND(364528.5, -6);    -- Result: 0

-- === TRUNCATE(n, [d]) is similar to ROUND(..) except for the rounding ===

-- ==== Modulus =====
SELECT MOD(32, 12);    -- Result: 8
SELECT MOD(563, 10);   -- Result: 3


-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
-- #=#=#=#=#=#=#=#=#=#=##=#=#=#    CASE WHEN     #=#=#=#=#=#=#=#=#=#=#=#=##=#=#=
-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

SELECT * FROM employees;

-- Find if `salary` is low / medium / high, using below criteria:
-- If salary < 45000 Then 'LOW'
-- Else If salary < 55000 Then 'MEDIUM'
-- Else 'HIGH' (i.e. salary >= 55000)

SELECT *,
CASE
    WHEN salary < 45000 THEN 'LOW'
    WHEN salary < 55000 THEN 'MEDIUM'
    ELSE 'HIGH'
END AS salary_band
FROM employees;

SELECT * FROM students;

-- Print "experience_level" for each `students` table row:
SELECT *,
CASE
    WHEN years_of_exp < 5 THEN 'Junior'
    WHEN years_of_exp < 9 THEN 'Mid'
    WHEN years_of_exp < 13 THEN 'Senior'
    ELSE 'Staff'
END AS experience_level
FROM students;


-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
-- #=#=#=#=#=#=#=#=#=#=##=#=#=##=#=#    CAST    #=#=##=#=#=#=#=#=#=#=#=#=#=#=#=#
-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

-- Cast values of one data type to another (compatible) data type

SHOW CREATE TABLE employees;
SELECT * FROM employees WHERE hire_date BETWEEN '2020-01-01' AND '2020-12-31';

-- Creating a new table `employees_cast_demo` with same structure of `employees`
-- table, but with two DECIMAL / DATE columns types changed to VARCHAR.
-- Data types of `hire_date` and `salary` columns changed.

CREATE TABLE `employees_cast_demo` (
  `employee_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `department_id` int DEFAULT NULL,
  `salary` varchar(50) DEFAULT NULL,    -- Type changed to VARCHAR(50) from DECIMAL(10,2).
  `hire_date` varchar(50) DEFAULT NULL, -- Type changed to VARCHAR(50) from DATE.
  `manager_id` int DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `job_title` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert all data of `employees` table into the new `employees_cast_demo` table
-- using INSERT INTO ... SELECT statement:
INSERT INTO employees_cast_demo SELECT * FROM employees;

SELECT * FROM employees_cast_demo;

-- Try to use DATE functions on the VARCHAR column `hire_date`:
SELECT YEAR(hire_date) FROM employees_cast_demo;
-- Works due to implicit type-casting happening from VARCHAR to DATE as the
-- YEAR function excepts a DATE type.

-- Using explicit casting:
SELECT CAST(hire_date AS DATE) FROM employees_cast_demo;

-- Here as well implicit casting happens when BETWEEN is used
SELECT * FROM employees_cast_demo WHERE hire_date BETWEEN '2018-01-01' AND '2020-12-31';

-- With implicit casting:
SELECT
	salary AS old_salary,
	salary * 1.1 AS revised_salary
FROM employees_cast_demo;

-- With explicit casting:
SELECT
	salary AS old_salary,
	CAST(salary AS DECIMAL(10, 2)) * 1.1 AS revised_salary
FROM employees_cast_demo;


-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#    COALESCE    #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

-- The COALESCE function takes a number of arguments and returns the first
-- non-NULL argument. In case all arguments are NULL, the COALESCE function
-- returns NULL. Syntax:
-- COALESCE(value1,value2,...);

DROP TABLE IF EXISTS products_dummy;
CREATE TABLE IF NOT EXISTS products_dummy (
	product_id INT AUTO_INCREMENT PRIMARY KEY,
	product_name VARCHAR(50),
	discount_price DECIMAL(10, 2),
	regular_price DECIMAL(10, 2)
);

INSERT INTO products_dummy (product_name, discount_price, regular_price) VALUES
	('Asus Vivobook 3 - Laptop', NULL, 1500.00),
	('Redmi Note 3 Pro - Smartphone', 700.00, 850.00),
	('Lenovo Idea - Tablet', NULL, 1100.00),
	('Apple SmartWatch 5 - PreLaunch', NULL, NULL);

SELECT * FROM products_dummy;

SELECT *,
    COALESCE(discount_price, regular_price, 'N/A') AS display_price
FROM products_dummy;
