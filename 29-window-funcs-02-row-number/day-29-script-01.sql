USE trendytech_interview_problems;

-- Using the same "employees" table created in "day-27-script-01.sql" file:
SELECT * FROM employees;

-- List all employee records, with an additional column `row_num` which is a
-- sequential counter from 1 onwards, such that for each department, the numbers
-- start from 1 onwards for records in descending order of their `salary`.
-- This means, in 'HR' department, the record with highest `salary` value among
-- 'HR' dept. will be assigned the number 1, the record with the second highest
-- `salary` value will be assigned the number 2, and so on, and this is done
-- similarly for each department.
SELECT
	employee_id, employee_name, department, salary, hire_date,
	ROW_NUMBER() OVER(PARTITION BY department ORDER BY salary DESC) AS row_num
FROM employees;

-- ==== Find average salary overall, and also average salary per department =====
-- Use a single query (without UNIONs):
SELECT department, AVG(salary),
	CASE
	WHEN GROUPING(department) = 0 THEN 'YES'
	ELSE 'NO'
	END AS grouped_by_dept
FROM employees
GROUP BY department WITH ROLLUP;
-- PostgreSQL syntax: GROUP BY ROLLUP(department)
/* Result:
# department,   AVG(salary),    grouped_by_dept
   Finance,     60250.000000,   YES       -- Avg. Salary of 'Finance' dept.
   HR,          51250.000000,   YES       -- Avg. Salary of 'HR' dept.
   IT,          69200.000000,   YES       -- Avg. Salary of 'IT' dept.
   NULL,        60923.076923,   NO        -- Avg. Salary overall.
*/

-- Print all employee records along with the overall average salary
-- with each record:
SELECT
	employee_id, employee_name, department, salary, hire_date,
	AVG(salary) OVER() AS avg_salary
FROM employees;

-- Print all employee records, along with the difference b/w
-- their salary with the overall average salary:
SELECT
	employee_id, employee_name, department, salary, hire_date,
	AVG(salary) OVER() AS avg_salary,
	salary - (AVG(salary) OVER()) AS salary_deviation
FROM employees;

-- Print all employee records along with the average salary
-- of the department to which the employee belongs:
SELECT
	employee_id, employee_name, department, salary, hire_date,
	AVG(salary) OVER(PARTITION BY department) AS avg_dept_salary
FROM employees;


-- ======= New seed data for forthcoming examples ============

DROP TABLE IF EXISTS employees;
CREATE TABLE IF NOT EXISTS employees (
	employee_id    INT PRIMARY KEY,
	employee_name  VARCHAR(50),
	department     VARCHAR(50),
	city           VARCHAR(50),
	salary         DECIMAL(10, 2),
	hire_date      DATE
);
TRUNCATE TABLE employees;
INSERT INTO employees
(employee_id, employee_name, department, city, salary, hire_date) VALUES
(1,   'Amit',      'HR',       'Mumbai',  50000,  '2022-01-15'),
(2,   'Neha',      'HR',       'Mumbai',  55000,  '2023-03-10'),
(3,   'Suresh',    'HR',       'Delhi',   48000,  '2021-11-20'),
(4,   'Rohit',     'HR',       'Delhi',   52000,  '2022-09-05'),
(5,   'Pragna',    'HR',       'Delhi',   52000,  '2021-04-30'),
(6,   'Raj',       'Finance',  'Mumbai',  60000,  '2021-07-23'),
(7,   'Ravi',      'Finance',  'Delhi',   62000,  '2022-09-01'),
(8,   'Kiran',     'Finance',  'Mumbai',  58000,  '2021-02-14'),
(9,   'Sunita',    'Finance',  'Delhi',   61000,  '2023-01-11'),
(10,  'Vidya',     'Finance',  'Mumbai',  60000,  '2021-05-29'),
(11,  'Priya',     'IT',       'Mumbai',  70000,  '2020-12-02'),
(12,  'Anjali',    'IT',       'Delhi',   67000,  '2021-11-19'),
(13,  'Vikas',     'IT',       'Mumbai',  69000,  '2022-05-20'),
(14,  'Sanjay',    'IT',       'Delhi',   72000,  '2023-04-30'),
(15,  'Meena',     'IT',       'Delhi',   68000,  '2021-03-15'),
(16,  'Spoorthy',  'IT',       'Mumbai',  70000,  '2020-03-24');

-- In case of tie in salary for records within a dept partition,
-- break the tie by checking `hire_date` giving preference to
-- employees who have been working since earlier in the company:
-- (Add `hire_date ASC` to ORDER BY in OVER(...), and also note
-- that ASC is implicitly implied, so we may omit ASC)
SELECT
	employee_id, employee_name, department, salary, hire_date,
	ROW_NUMBER() OVER(PARTITION BY department ORDER BY salary DESC, hire_date)
		AS row_num
FROM employees;


-- ==== Find the top earning employee from each department =======
-- First let's derive an intermediate result-set with `row_num` ordered from
-- 1, 2, 3.. in descending order of `salary`, for each partition by `department`:
SELECT
	employee_id, employee_name, department, salary, hire_date,
	ROW_NUMBER() OVER(PARTITION BY department ORDER BY salary DESC, hire_date) AS row_num
FROM employees;

-- Note that, we can't just add a "WHERE row_num = 1" on the above query. That would fail b'coz
-- in SQL Logical Query Execution Order, the order goes like:
/* SQL Logical Query Execution Order:
  FROM -> JOIN/ON -> WHERE -> GROUP BY -> Aggregate Funcs -> HAVING -> Window Funcs
    -> SELECT -> DISTINCT -> ORDER BY -> LIMIT / OFFSET.
*/
-- And, we can see that WHERE is evaluated much before SELECT, and so WHERE doesn't have access
-- to the aliases defined in the SELECT List.
-- So, below will NOT WORK, and result in the undermentioned error:
SELECT
	employee_id, employee_name, department, salary, hire_date,
	ROW_NUMBER() OVER(PARTITION BY department ORDER BY salary DESC, hire_date) AS row_num
FROM employees WHERE row_num = 1; -- ERROR Below:
-- Error Code: 1054. Unknown column 'row_num' in 'where clause'

-- Instead, we use the result-set in FROM clause, like below:

-- So, we just need to use the above result-set as subquery / derived table
-- and filter based on value of `row_num` column:
-- (So, query for the top earning employees from each department, using window funcs. is:)
SELECT t.* FROM (
	SELECT
		employee_id, employee_name, department, salary, hire_date,
		ROW_NUMBER() OVER(PARTITION BY department ORDER BY salary DESC, hire_date) AS row_num
	FROM employees
) t WHERE t.row_num = 1;


-- ==== Find the top 3 earning employee from each department =======
-- Again, we used the intermediate result-set having the ordered row_num values,
-- and use that as a derived table, and filter on "row_num <= 3" to get the
-- Final query (Top 3 earning employees from each dept.):
SELECT t.* FROM (
	SELECT
		employee_id, employee_name, department, salary, hire_date,
		ROW_NUMBER() OVER(PARTITION BY department ORDER BY salary DESC, hire_date) AS row_num
	FROM employees
) t WHERE t.row_num <= 3;


-- ==== Find the Top 2 earning employees from each department in each city =======
SELECT
	employee_id, employee_name, department, city, salary, hire_date,
	ROW_NUMBER() OVER(PARTITION BY department, city ORDER BY salary DESC) AS row_num
FROM employees;

-- In case of tie in salary for a dept-city combo, break the tie
-- by checking `hire_date` giving preference to older serving
-- employees: (Add `hire_date ASC` to ORDER BY in OVER(...))
SELECT
	employee_id, employee_name, department, city, salary, hire_date,
	ROW_NUMBER() OVER(PARTITION BY department, city ORDER BY salary DESC, hire_date)
		AS row_num
FROM employees;

-- Final query:
SELECT t.* FROM (
	SELECT
		employee_id, employee_name, department, city, salary, hire_date,
		ROW_NUMBER() OVER(PARTITION BY department, city ORDER BY salary DESC, hire_date)
			AS row_num
	FROM employees
) t WHERE t.row_num <= 2;

-- Or, if we want, we can use a CTE to hold the derived table:
WITH emp_dept_city_wise AS (
	SELECT
		employee_id, employee_name, department, city, salary, hire_date,
		ROW_NUMBER() OVER(PARTITION BY department, city ORDER BY salary DESC, hire_date)
			AS row_num
	FROM employees
)
SELECT * FROM emp_dept_city_wise WHERE row_num <= 2;

