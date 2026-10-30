CREATE DATABASE trendytech_interview_problems;
USE trendytech_interview_problems;

-- #### Data setup ######

DROP TABLE IF EXISTS employees;
CREATE TABLE IF NOT EXISTS employees (
	employee_id    INT PRIMARY KEY,
	employee_name  VARCHAR(50),
	department     VARCHAR(50),
	salary         DECIMAL(10, 2),
	hire_date      DATE
);
INSERT INTO employees (employee_id, employee_name, department, salary, hire_date) VALUES
(1,   'Amit',    'HR',       50000,  '2022-01-15'),
(2,   'Neha',    'HR',       55000,  '2023-03-10'),
(3,   'Suresh',  'HR',       48000,  '2021-11-20'),
(4,   'Rohit',   'HR',       52000,  '2022-09-05'),
(5,   'Raj',     'Finance',  60000,  '2021-07-23'),
(6,   'Ravi',    'Finance',  62000,  '2022-09-01'),
(7,   'Kiran',   'Finance',  58000,  '2021-02-14'),
(8,   'Sunita',  'Finance',  61000,  '2023-01-11'),
(9,   'Priya',   'IT',       70000,  '2020-12-02'),
(10,  'Anjali',  'IT',       67000,  '2021-11-19'),
(11,  'Vikas',   'IT',       69000,  '2022-05-20'),
(12,  'Sanjay',  'IT',       72000,  '2023-04-30'),
(13,  'Meena',   'IT',       68000,  '2021-03-15');


-- ===== Find the employees who are earning equal to the maximum salary in their
-- respective departments ======

-- As usual, we construct an intermediate result-set containing the
-- department name, along with the maximum salary recorded in that department:
SELECT department, MAX(salary) AS dept_max_sal
FROM employees GROUP BY department;

-- Then, we JOIN the employees table, with the above intermediate result-set,
-- so that we can get the dept_max_sal against each employee record for their
-- respective department:
SELECT
e.employee_id, e.employee_name, e.department,
e.salary, d.dept_max_sal
FROM employees e
INNER JOIN (
	SELECT department, MAX(salary) AS dept_max_sal
	FROM employees GROUP BY department
) d ON e.department = d.department;
-- Result: we just get all employee records along with the
-- max salary recorded in their respective department.

-- Then we just apply the filter on above query:
SELECT
e.employee_id, e.employee_name, e.department,
e.salary, d.dept_max_sal
FROM employees e
INNER JOIN (
	SELECT department, MAX(salary) AS dept_max_sal
	FROM employees GROUP BY department
) d ON e.department = d.department
WHERE e.salary = d.dept_max_sal;
-- Result: 3 records with details like (among other columns)
-- (employee_id, employee_name, department, salary):
-- ( 2,  'Neha',    'HR',       55000.00),
-- ( 6,  'Ravi',    'Finance',  62000.00),
-- (12,  'Sanjay',  'IT',       72000.00);


/*
This was somewhat complex to get to the desired result, but
we got to it, nonetheless.

But, what happens if the requirements are made more complex?

Let's say now, instead of finding the top employees who earn
equal to their department's highest salary; we instead want
to find the top two (2) employees who earn the highest with
respect to the salaries recorded in their respective dept.

Now this requirement is not easy to solve, at least not with
the approach we used for the previous scenario.
*/

-- ==== Find the top 2 earning employees w.r.t. the salaries recorded in their
-- respective departments (Note: Previous question asked for the highest paid
-- employees in their department) ======

-- Highest salaries by department:
SELECT department, MAX(salary) AS dept_max_sal
FROM employees GROUP BY department;

-- To find the second-highest salaries:
SELECT
	e.department, MAX(e.salary) AS dept_max2_sal,
    d.dept_max_sal
FROM employees e
INNER JOIN (
	SELECT department, MAX(salary) AS dept_max_sal
	FROM employees GROUP BY department
) d ON e.department = d.department
WHERE e.salary < d.dept_max_sal
GROUP BY e.department;
-- Returns records for each dept with tuples:
-- (department, dept_max2_sal, dept_max_sal), where:
-- `dept_max2_sal` - Second highest salary recorded for particular department.
-- `dept_max_sal`  - Highest salary recorded for particular department.

-- Using this information of 2nd-highest salaries per dept. in the above
-- result set, we can write the below query to achieve our requirement:
WITH dept_top2_salaries AS (
	SELECT
	e.department, MAX(e.salary) AS dept_max2_sal,
    d.dept_max_sal
	FROM employees e
	INNER JOIN (
		SELECT department, MAX(salary) AS dept_max_sal
		FROM employees GROUP BY department
	) d ON e.department = d.department
	WHERE e.salary < d.dept_max_sal
	GROUP BY e.department
)
SELECT
	e1.employee_id, e1.employee_name, e1.department,
	e1.salary, e1.hire_date
FROM employees e1 INNER JOIN dept_top2_salaries dt2
ON e1.department = dt2.department
WHERE e1.salary >= dt2.dept_max2_sal;
-- Returns: 6 records with details like (among other columns)
-- (employee_id, employee_name, department, salary):
-- ( 2,  'Neha',      'HR',       55000.00),
-- ( 4,  'Rohit',     'HR',       52000.00),
-- ( 6,  'Ravi',      'Finance',  62000.00),
-- ( 8,  'Sunita',    'Finance',  61000.00),
-- ( 9,  'Priya',     'IT',       70000.00),
-- (12,  'Sanjay',    'IT',       72000.00);


/*
The above solution although working, is not scalable at all, and is too complex
and prone to errors. And what if we need top 3 or top 5 highest earning employee
records in their department?

Can we just put a LIMIT 2 or LIMIT 5 at the end to get our desired output?
NO. LIMIT is to return a fixed number of records from the final output. Limit
cannot be used to dictate the number of records returned from a group.

For such problems, we need to use Window Functions.
*/
