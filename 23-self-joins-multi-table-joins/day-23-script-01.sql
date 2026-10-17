USE trendytech_joins_practice;
SHOW TABLES;
SELECT * FROM categories;
SELECT * FROM customers;
SELECT * FROM departments;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM products;

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
(1,    'Rajesh Kumar',     1,    NULL,   200000.00,    'CEO'                  ),    -- No manager.
(2,    'Sonal Gupta',      2,    1,      150000.00,    'VP IT'                ),    -- Reports to Rajesh Kumar.
(3,    'Anita Desai',      2,    2,      120000.00,    'Manager IT'           ),    -- Reports to Sonal Gupta.
(4,    'Vikram Singh',     3,    1,      110000.00,    'VP HR'                ),    -- Reports to Rajesh Kumar.
(5,    'Priya Nair',       2,    3,      130000.00,    'Developer IT'         ),    -- Reports to Anita Desai.
(6,    'Amit Sharma',      3,    4,      100000.00,    'HR Manager'           ),    -- Reports to Vikram Singh.
(7,    'Neha Patil',       4,    1,      140000.00,    'VP Finance'           ),    -- Reports to Rajesh Kumar.
(8,    'Rohit Verma',      4,    7,      90000.00,     'Finance Analyst'      ),    -- Reports to Neha Patil.
(9,    'Kavita Joshi',     2,    3,      125000.00,    'Developer IT'         ),    -- Reports to Anita Desai.
(10,   'Manish Kulkarni',  5,    1,      145000.00,    'VP Marketing'         ),    -- Reports to Rajesh Kumar.
(11,   'Nidhi Agarwal',    5,    10,     95000.00,     'Marketing Manager'    ),    -- Reports to Manish Kulkarni.
(12,   'Suresh Iyer',      4,    7,      85000.00,     'Accountant'           ),    -- Reports to Neha Patil.
(13,   'Ravi Menon',       6,    1,      135000.00,    'VP Operations'        ),    -- Reports to Rajesh Kumar.
(14,   'Anjali Sinha',     6,    13,     105000.00,    'Operations Manager'   ),    -- Reports to Ravi Menon.
(15,   'Tarun Mehta',      2,    2,      115000.00,    'IT Support'           ),    -- Reports to Sonal Gupta.
(16,   'Deepika Rao',      3,    4,      98000.00,     'HR Assistant'         ),    -- Reports to Vikram Singh.
(17,   'Karan Chawla',     5,    10,     92000.00,     'Marketing Analyst'    ),    -- Reports to Manish Kulkarni.
(18,   'Meena Kapoor',     4,    7,      102000.00,    'Finance Manager'      ),    -- Reports to Neha Patil.
(19,   'Sanjay Reddy',     6,    13,     108000.00,    'Logistics Coordinator'),    -- Reports to Ravi Menon.
(20,   'Shweta Tiwari',    2,    3,      127000.00,    'Developer IT'         );    -- Reports to Anita Desa.

-- #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%

-- ############################# SELF JOIN #############################

SELECT * FROM employees;
SELECT * FROM employees;

-- For simplicity & ease of understanding, we will treat the:
-- a) Left side `employees` table  - to be representing Employees, and the..
-- a) Right side `employees` table - to be representing Managers.


-- ====== Display details of employees, along with their manager's name & salary,
-- for each employee ========
SELECT e.*, m.employee_name AS manager_name, m.salary AS manager_salary
FROM employees e LEFT OUTER JOIN employees m ON e.manager_id = m.employee_id;


-- ====== Find all employees who have no manager ========

-- Approach 1: With LEFT JOIN plus IS NULL on right table:
SELECT e.*, m.employee_name AS manager_name, m.salary AS manager_salary
FROM employees e LEFT OUTER JOIN employees m ON e.manager_id = m.employee_id
WHERE m.employee_id IS NULL;

-- Approach 1: Simpler - just use `employees` table & check if `manager_id` is NULL:
SELECT * FROM employees WHERE manager_id IS NULL;


-- ====== Find all employees who DO NOT manage anyone (i.e. who don't
-- have any reportees) ========

SELECT
	m.employee_id, m.employee_name, m.designation, m.salary, m.department_id
FROM employees e RIGHT JOIN employees m ON e.manager_id = m.employee_id
WHERE e.employee_id IS NULL;
-- Result: 13 records returned.
-- So, 13 (out of total 20) employees do not manage anyone.
-- These include employee_id's:
-- 5, 6, 8, 9, 11, 12, 14, 15, 16, 17, 18, 19, 20.
-- These above are employee_id's of employees who have no reportees.

-- Verify by cross-checking whether any of these employee_id's is
-- present as the manager_id of any employee
SELECT * FROM employees WHERE manager_id IN
	(5, 6, 8, 9, 11, 12, 14, 15, 16, 17, 18, 19, 20);
-- Result: No records. Hence verified.
