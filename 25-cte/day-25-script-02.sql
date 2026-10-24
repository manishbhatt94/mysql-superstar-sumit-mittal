USE trendytech_joins_practice;
SHOW TABLES;

SELECT * FROM categories;
SELECT * FROM customers;
SELECT * FROM departments;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM products;


-- ==== Performance comparison: Select an order with given order_id =====

-- Approach 1: With no CTEs used, instead written with subqueries as needed:
SELECT * FROM orders WHERE order_id = 10000;

-- Approach 2: With a CTE:
WITH cte_orders AS (
  SELECT * FROM orders
)
SELECT * FROM cte_orders WHERE order_id = 10000;

/*
For Approach 1, MySQL does a simple index scan, which takes logarithmic time,
and is really fast.

For Approach 2, if MySQL server decides to materialize the CTE (i.e. load it's
result set in memory), then the loading will take extra time - i.e. a full
sequential scan, plus the indexes may not work as expected, so another full
sequential scan.

That said, modern databases, may skip materialization if they find more optimal
approach, and may even inline the query of the CTE into the main query, if that
approach seems suitable to the database engine.
*/


-- ###########################    RECURSIVE CTE    #############################

-- Borrowing the `employees` table & data created in "day-23-script-01.sql" file
DROP TABLE IF EXISTS employees;
CREATE TABLE IF NOT EXISTS employees (
	employee_id INT PRIMARY KEY,
	employee_name VARCHAR(100),
	department_id INT,
	manager_id INT,
	salary DECIMAL(10, 2),
	designation VARCHAR(50)
);
INSERT INTO employees (employee_id, employee_name, department_id, manager_id, salary, designation) VALUES
(1,   'Rajesh Kumar',     1,    NULL,   200000.00,   'CEO'                  ),  -- manager_id: NULL. Reports to: No manager.
(2,   'Sonal Gupta',      2,    1,      150000.00,   'VP IT'                ),  -- manager_id:    1. Reports to: Rajesh Kumar.
(3,   'Anita Desai',      2,    2,      120000.00,   'Manager IT'           ),  -- manager_id:    2. Reports to: Sonal Gupta.
(4,   'Vikram Singh',     3,    1,      110000.00,   'VP HR'                ),  -- manager_id:    1. Reports to: Rajesh Kumar.
(5,   'Priya Nair',       2,    3,      130000.00,   'Developer IT'         ),  -- manager_id:    3. Reports to: Anita Desai.
(6,   'Amit Sharma',      3,    4,      100000.00,   'HR Manager'           ),  -- manager_id:    4. Reports to: Vikram Singh.
(7,   'Neha Patil',       4,    1,      140000.00,   'VP Finance'           ),  -- manager_id:    1. Reports to: Rajesh Kumar.
(8,   'Rohit Verma',      4,    7,      90000.00,    'Finance Analyst'      ),  -- manager_id:    7. Reports to: Neha Patil.
(9,   'Kavita Joshi',     2,    3,      125000.00,   'Developer IT'         ),  -- manager_id:    3. Reports to: Anita Desai.
(10,  'Manish Kulkarni',  5,    1,      145000.00,   'VP Marketing'         ),  -- manager_id:    1. Reports to: Rajesh Kumar.
(11,  'Nidhi Agarwal',    5,    10,     95000.00,    'Marketing Manager'    ),  -- manager_id:   10. Reports to: Manish Kulkarni.
(12,  'Suresh Iyer',      4,    7,      85000.00,    'Accountant'           ),  -- manager_id:    7. Reports to: Neha Patil.
(13,  'Ravi Menon',       6,    1,      135000.00,   'VP Operations'        ),  -- manager_id:    1. Reports to: Rajesh Kumar.
(14,  'Anjali Sinha',     6,    13,     105000.00,   'Operations Manager'   ),  -- manager_id:   13. Reports to: Ravi Menon.
(15,  'Tarun Mehta',      2,    2,      115000.00,   'IT Support'           ),  -- manager_id:    2. Reports to: Sonal Gupta.
(16,  'Deepika Rao',      3,    4,      98000.00,    'HR Assistant'         ),  -- manager_id:    4. Reports to: Vikram Singh.
(17,  'Karan Chawla',     5,    10,     92000.00,    'Marketing Analyst'    ),  -- manager_id:   10. Reports to: Manish Kulkarni.
(18,  'Meena Kapoor',     4,    7,      102000.00,   'Finance Manager'      ),  -- manager_id:    7. Reports to: Neha Patil.
(19,  'Sanjay Reddy',     6,    13,     108000.00,   'Logistics Coordinator'),  -- manager_id:   13. Reports to: Ravi Menon.
(20,  'Shweta Tiwari',    2,    3,      127000.00,   'Developer IT'         );  -- manager_id:    3. Reports to: Anita Desa.

SELECT * FROM employees;

WITH RECURSIVE employee_hierachy AS (
	-- Anchor query:
	SELECT employee_id, employee_name, manager_id,
    designation, 0 AS job_level FROM employees
    WHERE manager_id IS NULL

    UNION ALL

	-- Recursive query:
	-- Find direct reports of the employee(s) found in previous step.
	SELECT e.employee_id, e.employee_name, e.manager_id,
    e.designation, eh.job_level + 1
    FROM employees e INNER JOIN employee_hierachy eh
    ON e.manager_id = eh.employee_id
)
SELECT * FROM employee_hierachy;


-- ==== Powers of 2. Produce n from 0 to 5 and val = 2^n (1, 2, 4, 8, 16, 32). =====
WITH RECURSIVE cte_powers (n, val) AS (
	SELECT 0, 1
    UNION ALL
    SELECT n + 1, val * 2
    FROM cte_powers WHERE n < 5
)
SELECT n, val FROM cte_powers;
-- Prints powers of 2, from 2^0 to 2^5 (i.e. 1, 2, 4, 8, 16, 32).
-- Output records:
--  n  |  val
-- ----|------
--  0  |   1
--  1  |   2
--  2  |   4
--  3  |   8
--  4  |  16
--  5  |  32


-- ==== Show each employee together with their full chain of command as text,
-- such as 'John Doe > Jane Smith > Bob Johnson'. ======
WITH RECURSIVE employee_hierachy_paths AS (
	SELECT employee_id, employee_name, manager_id,
	designation, 0 AS job_level,
    employee_name AS hierarchy
	FROM employees WHERE manager_id IS NULL

	UNION ALL

	SELECT e.employee_id, e.employee_name, e.manager_id,
	e.designation, ehp.job_level + 1,
    CONCAT(ehp.hierarchy, ' > ', e.employee_name)
	FROM employees e
	INNER JOIN employee_hierachy_paths ehp
	ON e.manager_id = ehp.employee_id
)
SELECT * FROM employee_hierachy_paths;


-- ==== Get complete hierarchy of employees for 'Shweta Tiwari' (emp_id=20) in
-- a manner that each employee in hierarchy above is shown as a separate record
-- from top-most hierarchy down to the individual employee themselves =====
WITH RECURSIVE emp_chain (employee_id, employee_name, manager_id, designation, salary, relative_seniority)
AS (
	SELECT employee_id, employee_name, manager_id,
	designation, salary, 0 AS relative_seniority
	FROM employees WHERE employee_id = 20

	UNION ALL

	-- Find manager of the employee found in previous step:
	SELECT e.employee_id, e.employee_name, e.manager_id,
	e.designation, e.salary, ec.relative_seniority + 1
	FROM employees e
	INNER JOIN emp_chain ec
	ON e.employee_id = ec.manager_id
)
SELECT * FROM emp_chain ORDER BY relative_seniority;


-- ==== Generate Fibonacci series upto 30 terms =====
-- n=0 -> 0
-- n=1 -> 1
-- n=2 -> 1
-- n=3 -> 2
-- n=4 -> 3
-- n=5 -> 5
-- n=6 -> 8
-- n=7 -> 13
-- n=8 -> 21
-- n=9 -> 34
WITH RECURSIVE fibonacci_series (n, fibo, next_term) AS (
	-- Anchor query:
	SELECT   0 AS n,      0 AS fibo,     1 AS next_term

	UNION ALL

	-- Recursive query:
	SELECT   fs.n + 1,    fs.next_term,   fs.fibo + fs.next_term
	FROM fibonacci_series fs
	WHERE fs.n < 30
)
SELECT n, fibo FROM fibonacci_series;

/*

|    n    |   fibo   |  next_term  |
|---------|----------|-------------|
|    0    |     0    |      1      |
|    1    |     1    |      1      |
|    2    |     1    |      2      |
|    3    |     2    |      3      |
|    4    |     3    |      5      |
|    5    |     5    |      8      |
|    6    |     8    |     13      |
|    7    |    13    |     21      |
|    8    |    21    |     34      |
|    9    |    34    |     55      |
|   10    |    55    |     89      |
|   11    |    89    |    144      |
|   12    |   144    |    233      |
|   13    |   233    |    377      |
|   14    |   377    |    610      |
|   15    |   610    |    987      |

*/
