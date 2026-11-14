USE trendytech_interview_problems;

-- Using the same "employees" table created in "day-29-script-01.sql" file:
-- employees(employee_id, employee_name, department, city, salary, hire_date):
SELECT * FROM employees;

SELECT COUNT(*) FROM employees;  -- 16 records.


-- ==== Find top 2 highest earning employees each department ======
SELECT *
FROM (
	SELECT *,
		RANK() OVER(PARTITION BY department ORDER BY salary DESC) rank_dept_salary
	FROM employees
) t WHERE t.rank_dept_salary <= 2;


-- ==== Find total salary paid under each department (show this alongside each
-- employee record, for their respective department) ======
SELECT
	employee_id, employee_name, salary, department,
	SUM(salary) OVER(PARTITION BY department) AS dept_total_salary
FROM employees;

-- Same thing, but without window functions:
WITH dept_salaries AS (
	SELECT department, SUM(salary) AS dept_total_salary
	FROM employees GROUP BY department
)
SELECT
	e.employee_id, e.employee_name, e.salary, e.department,
	ds.dept_total_salary
FROM employees e LEFT JOIN dept_salaries ds
	ON e.department = ds.department;


-- ==== Find total salary paid in each city (show this alongside each
-- employee record, for their respective city) ======
SELECT
	employee_id, employee_name, salary, department, city,
	SUM(salary) OVER(PARTITION BY city) AS city_total_salary
FROM employees;


-- ==== Find total salary paid for each department in each city
-- (show this alongside each employee record, for their respective
-- department & city) ======
SELECT
	employee_id, employee_name, salary, city, department,
	SUM(salary) OVER(PARTITION BY city, department) AS city_dept_total_salary
FROM employees;
