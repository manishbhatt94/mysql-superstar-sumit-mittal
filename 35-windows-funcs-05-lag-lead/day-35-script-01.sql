USE trendytech_interview_problems;

-- Using the same "employees" table created in "day-29-script-01.sql" file:
-- employees(employee_id, employee_name, department, city, salary, hire_date):
SELECT * FROM employees;

SELECT COUNT(*) FROM employees;  -- 16 records.

/* Syntax for LAG/LEAD:

LAG(expression, offset, default_value)
OVER (
    PARTITION BY partition_expression
    ORDER BY order_expresion ASC|DESC
)
*/


-- ==== When all employee records are ordered by salary in DESC order, alongside each
-- employee record, show the salary of the immediate previous & next employee in
-- that order =====
SELECT *,
	LAG(salary) OVER(ORDER BY salary DESC) AS prev_salary,
	LEAD(salary) OVER(ORDER BY salary DESC) AS next_salary
FROM employees;


-- ==== Find difference of each employee's salary with the next highest
-- paid employee's salary =====
SELECT *,
	t.salary - t.next_salary AS salary_diff_abs,
    ROUND((t.salary - t.next_salary) * 100.0 / t.next_salary, 2) AS salary_diff_percent
FROM (
	SELECT *,
		LEAD(salary) OVER(ORDER BY salary DESC) AS next_salary
	FROM employees
) t;

DROP TABLE IF EXISTS sales;
CREATE TABLE IF NOT EXISTS sales (
	sale_date DATE,
    product_id INT,
    product_name VARCHAR(100),
    units_sold INT
);
INSERT INTO sales (sale_date, product_id, product_name, units_sold) VALUES
('2024-08-15', 1, 'Laptop', 4),
('2024-08-16', 1, 'Laptop', 6),
('2024-08-17', 1, 'Laptop', 5),
('2024-08-18', 1, 'Laptop', 7),
('2024-08-19', 1, 'Laptop', 4),
('2024-08-20', 1, 'Laptop', 5),
('2024-08-21', 1, 'Laptop', 8),
('2024-08-22', 1, 'Laptop', 3),
('2024-08-23', 1, 'Laptop', 7),
('2024-08-24', 1, 'Laptop', 6),
('2024-08-25', 1, 'Laptop', 9),
('2024-08-26', 1, 'Laptop', 7),
('2024-08-15', 2, 'Smartphone', 15),
('2024-08-16', 2, 'Smartphone', 18),
('2024-08-17', 2, 'Smartphone', 12),
('2024-08-18', 2, 'Smartphone', 20),
('2024-08-19', 2, 'Smartphone', 17),
('2024-08-20', 2, 'Smartphone', 14),
('2024-08-21', 2, 'Smartphone', 19),
('2024-08-22', 2, 'Smartphone', 13),
('2024-08-23', 2, 'Smartphone', 21),
('2024-08-24', 2, 'Smartphone', 16),
('2024-08-25', 2, 'Smartphone', 18),
('2024-08-26', 2, 'Smartphone', 20),
('2024-08-15', 3, 'Tablet', 8),
('2024-08-16', 3, 'Tablet', 10),
('2024-08-17', 3, 'Tablet', 7),
('2024-08-18', 3, 'Tablet', 12),
('2024-08-19', 3, 'Tablet', 9),
('2024-08-20', 3, 'Tablet', 8),
('2024-08-21', 3, 'Tablet', 11),
('2024-08-22', 3, 'Tablet', 6),
('2024-08-23', 3, 'Tablet', 9),
('2024-08-24', 3, 'Tablet', 10),
('2024-08-25', 3, 'Tablet', 13),
('2024-08-26', 3, 'Tablet', 12);

SELECT * FROM sales;


SELECT *,
	ROUND((units_sold - prev_day_sales) / prev_day_sales * 100.0, 2) AS DoD_Sales
FROM (
	SELECT *,
		LAG(units_sold) OVER(
			PARTITION BY product_id ORDER BY sale_date
		) AS prev_day_sales
	FROM sales
) t;
