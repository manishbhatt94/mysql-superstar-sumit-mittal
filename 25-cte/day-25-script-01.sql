USE trendytech_joins_practice;
SHOW TABLES;

SELECT * FROM categories;
SELECT * FROM customers;
SELECT * FROM departments;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM products;


-- Remember our query from "day-24-script-01.sql" file (i.e. "Find the average
-- no. of order items; and the average order amount")
SELECT
	AVG(t.num_order_items) AS avg_order_items,
	AVG(t.order_amount) AS avg_order_amount
FROM ( -- Derived Table / Subquery "t":
	-- Here we used this intermediate result-set (or derived table aliased "t")
	-- of one record of the form (order_id, num_order_items, order_amount) per
	-- each order:
	SELECT order_item_order_id AS order_id,
		COUNT(*) AS num_order_items,
		SUM(total_amount) AS order_amount
	FROM order_items GROUP BY order_item_order_id
) t;

-- CTE Syntax in MySQL (column_list is optional to specify):
/*
WITH cte_name (column_list) AS (
	query
)
SELECT * FROM cte_name;
*/

-- Now we'll use a CTE for the above query, instead of using a Derived Table
-- Subquery, we'll define a CTE expression using the query of that derived table
WITH orders_item_counts_total_amounts AS (
	SELECT order_item_order_id AS order_id,
		COUNT(*) AS num_order_items,
		SUM(total_amount) AS order_amount
	FROM order_items GROUP BY order_item_order_id
)
SELECT
	AVG(t.num_order_items) AS avg_order_items,
	AVG(t.order_amount) AS avg_order_amount
FROM orders_item_counts_total_amounts t;


-- ==== Refactor query for "Big Orders" problem in "day-24-script-01.sql" file ======
-- ==== "Big Orders": orders whose num_order_items > avg_order_items
-- AND whose order_amount > avg_order_amount =======

-- Original query (using subquery / derived tables):
SELECT
	tbl_one.order_id, tbl_one.num_order_items, tbl_one.order_amount,
	tbl_two.avg_order_items, tbl_two.avg_order_amount
FROM (
	SELECT order_item_order_id AS order_id,
		COUNT(*) AS num_order_items,
		SUM(total_amount) AS order_amount
	FROM order_items GROUP BY order_item_order_id
) tbl_one CROSS JOIN (
	SELECT
		AVG(t.num_order_items) AS avg_order_items,
		AVG(t.order_amount) AS avg_order_amount
	FROM (
		SELECT order_item_order_id AS order_id,
			COUNT(*) AS num_order_items,
			SUM(total_amount) AS order_amount
		FROM order_items GROUP BY order_item_order_id
	) t
) tbl_two
WHERE tbl_one.num_order_items > tbl_two.avg_order_items AND
	tbl_one.order_amount > tbl_two.avg_order_amount;
-- Returns: 25,773 records.


-- **** Refactored to use CTE: ****
WITH tbl_one AS ( -- Define first CTE "tbl_one":
	SELECT order_item_order_id AS order_id,
		COUNT(*) AS num_order_items,
		SUM(total_amount) AS order_amount
	FROM order_items GROUP BY order_item_order_id
), tbl_two AS ( -- Define second CTE "tbl_two":
				-- (which uses the former CTE "tbl_one")
	SELECT
		AVG(tbl_one.num_order_items) AS avg_order_items,
		AVG(tbl_one.order_amount) AS avg_order_amount
	FROM tbl_one
)
SELECT -- Now defining the main query (which uses both these CTEs)
	t1.order_id, t1.num_order_items, t1.order_amount,
	t2.avg_order_items, t2.avg_order_amount
FROM tbl_one t1 CROSS JOIN tbl_two t2
WHERE t1.num_order_items > t2.avg_order_items AND
	t1.order_amount > t2.avg_order_amount;
-- Returns: The same 25,773 records.


-- If we also need to show more details about each order record in the
-- above result, instead of just the order_id, we can add an INNER JOIN
-- with `orders` table to the above query:
WITH tbl_one AS ( -- Define first CTE "tbl_one":
	SELECT order_item_order_id AS order_id,
		COUNT(*) AS num_order_items,
		SUM(total_amount) AS order_amount
	FROM order_items GROUP BY order_item_order_id
), tbl_two AS ( -- Define second CTE "tbl_two":
				-- (which uses the former CTE "tbl_one")
	SELECT
		AVG(tbl_one.num_order_items) AS avg_order_items,
		AVG(tbl_one.order_amount) AS avg_order_amount
	FROM tbl_one
)
SELECT -- Now defining the main query (which uses both these CTEs)
	t1.order_id, o.order_date, o.order_status, o.customer_id,
	t1.num_order_items, t1.order_amount,
	t2.avg_order_items, t2.avg_order_amount
FROM tbl_one t1
	CROSS JOIN tbl_two t2
	INNER JOIN orders o ON t1.order_id = o.order_id
WHERE t1.num_order_items > t2.avg_order_items AND
	t1.order_amount > t2.avg_order_amount;
-- Returns: The same 25,773 records. But with more order details per record
-- i.e. Records of these tuples: (order_id, order_date, order_status, customer_id,
-- 			num_order_items, order_amount, avg_order_items, avg_order_amount)


-- ==== Refactor "Big Orders" query from "day-24-script-02.sql" file that
-- didn't use CROSS JOIN, but specified 'big order' conditions in
-- the HAVING clause =====

-- Original query (using HAVING instead of CROSS JOIN which we used above):
SELECT order_item_order_id AS order_id,
	COUNT(*) AS num_order_items,
	SUM(total_amount) AS order_amount
FROM order_items
GROUP BY order_item_order_id
HAVING COUNT(*) > ( -- Subquery 'A'
		SELECT AVG(t.num_order_items) AS avg_order_items
		FROM (
			SELECT order_item_order_id AS order_id,
				COUNT(*) AS num_order_items
			FROM order_items GROUP BY order_item_order_id
		) t
	)
    AND SUM(total_amount) > ( -- Subquery 'B'
		SELECT AVG(t.order_amount) AS avg_order_amount
		FROM (
			SELECT order_item_order_id AS order_id,
				SUM(total_amount) AS order_amount
			FROM order_items GROUP BY order_item_order_id
		) t
    );
-- Returns: The same 25,773 records with (order_id, num_order_items, order_amount) tuples.

-- **** Refactored to use CTE: ****
WITH grouped_orders AS (
	SELECT order_item_order_id AS order_id,
		COUNT(*) AS num_order_items,
		SUM(total_amount) AS order_amount
	FROM order_items GROUP BY order_item_order_id
)
SELECT * FROM grouped_orders
WHERE num_order_items > ( -- Subquery 'A' from prev. query reduced to this:
	SELECT AVG(t.num_order_items) FROM grouped_orders t
) AND order_amount > ( -- Subquery 'B' from prev. query reduced to this:
	SELECT AVG(t.order_amount) FROM grouped_orders t
);
-- Returns: The same 25,773 records with (order_id, num_order_items, order_amount) tuples.

-- OR: Define two more CTEs, one each for avg_order_items, & avg_order_amount:
WITH grouped_orders AS (
	SELECT order_item_order_id AS order_id,
		COUNT(*) AS num_order_items,
		SUM(total_amount) AS order_amount
	FROM order_items GROUP BY order_item_order_id
),
averaged_values AS (
	-- Subquery A & B, from prev. query, reduced to a single CTE "averaged_values" below
	SELECT
		AVG(t.num_order_items) AS avg_order_items,
		AVG(t.order_amount) AS avg_order_amount
	FROM grouped_orders t
)
SELECT * FROM grouped_orders
WHERE num_order_items > (SELECT avg_order_items FROM averaged_values)
AND order_amount > (SELECT avg_order_amount FROM averaged_values);

-- And, if we also need to show more details about each order record, like we
-- did before, we can add an INNER JOIN with `orders` table to the above query:
WITH grouped_orders AS (
	SELECT order_item_order_id AS order_id,
		COUNT(*) AS num_order_items,
		SUM(total_amount) AS order_amount
	FROM order_items GROUP BY order_item_order_id
)
SELECT
	gr.order_id, o.order_date, o.order_status, o.customer_id,
	gr.num_order_items, gr.order_amount
FROM grouped_orders gr
	INNER JOIN orders o ON gr.order_id = o.order_id
WHERE num_order_items > ( -- Subquery 'A' from prev. query reduced to this:
	SELECT AVG(t.num_order_items) FROM grouped_orders t
) AND order_amount > ( -- Subquery 'B' from prev. query reduced to this:
	SELECT AVG(t.order_amount) FROM grouped_orders t
);
-- Returns: The same 25,773 records. But with more order details per record
-- i.e. Records of these tuples: (order_id, order_date, order_status,
-- 			customer_id, num_order_items, order_amount)


-- ===== Find employees who earn more than the average salary in their department ========
-- Refactor this query already covered in "day-24-script-02.sql" file, to use CTE(s).

-- Here's the original query as discussed in "day-24-script-02.sql" file:
SELECT
	e.emp_id, e.emp_name, e.department_id,
    e.emp_salary, t.dept_avg_salary
FROM employees_dummy e INNER JOIN (
	-- We'll convert the below derived table subquery to a CTE:
	SELECT department_id, AVG(emp_salary) AS dept_avg_salary
	FROM employees_dummy GROUP BY department_id
) t ON e.department_id = t.department_id
WHERE e.emp_salary > t.dept_avg_salary;
-- Result: 4 employee records with salary more than their dept_avg_salary.
-- Got employees with emp_id's: 1, 2, 4, 6.


-- **** Refactored to use CTE: ****
WITH avg_salaries_by_dept AS (
	SELECT department_id, AVG(emp_salary) AS dept_avg_salary
	FROM employees_dummy GROUP BY department_id
)
SELECT
	e.emp_id, e.emp_name, t.department_id,
    e.emp_salary, t.dept_avg_salary
FROM employees_dummy e
	INNER JOIN avg_salaries_by_dept t ON e.department_id = t.department_id
WHERE e.emp_salary > t.dept_avg_salary;
-- SAME Result: 4 employee records with salary more than their dept_avg_salary.
-- Got employees with emp_id's: 1, 2, 4, 6.
