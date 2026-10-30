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
# department,  AVG(salary),   grouped_by_dept
  Finance,     60250.000000,  YES       -- Avg. Salary of 'Finance' dept.
  HR,          51250.000000,  YES       -- Avg. Salary of 'HR' dept.
  IT,          69200.000000,  YES       -- Avg. Salary of 'IT' dept.
  NULL,        60923.076923,  NO        -- Avg. Salary overall.
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
