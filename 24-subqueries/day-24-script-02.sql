USE trendytech_joins_practice;
SHOW TABLES;

SELECT * FROM categories;
SELECT * FROM customers;
SELECT * FROM departments;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM products;


-- === Re-write the last query "Big Orders" from day-24-script-01.sql file
-- but without using any JOINs ============

-- We will try to do this within HAVING clause. Our conditions are
-- the desired order's num_order_items > avg_order_items AND
-- it's order_amount > avg_order_amount

-- We need two individual subqueries that each give us the value for
-- "avg_order_items" and "avg_order_amount" respectively.
-- For this we had a query which gave both values as two columns in
-- a single record. We will now break this query into two, so that
-- each gives us an individual value.

-- First subquery 'A': gives us value for "avg_order_items". This is below:
SELECT AVG(t.num_order_items) AS avg_order_items
FROM (
	SELECT order_item_order_id AS order_id,
		COUNT(*) AS num_order_items
	FROM order_items GROUP BY order_item_order_id
) t;

-- Second subquery 'B': gives us value for "avg_order_amount". This is below:
SELECT AVG(t.order_amount) AS avg_order_amount
FROM (
	SELECT order_item_order_id AS order_id,
		SUM(total_amount) AS order_amount
	FROM order_items GROUP BY order_item_order_id
) t;

-- Final query using the (float) values returned by the above two
-- subqueries 'A' and 'B' (which each returns a float value); and
-- using those inside the condition of HAVING clause:
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
-- Returns: the same no. of records (i.e. 25,773).
-- Returns order records with columns (order_id, num_order_items, order_amount)
-- and only those records whose num_order_items > avg_order_items AND
-- whose order_amount > avg_order_amount



-- ==== Find all "Premium Customers"; where "Premium Customers" are those
-- who have placed more no. of orders than the avg. no. of orders placed
-- by customers ==========

-- First, we need to 'Find avg. no. of orders placed by each customer', which
-- we already did in file day-24-script-01.sql and the query for the same is:
SELECT AVG(t.orders_count) AS avg_num_orders FROM (
	SELECT c.customer_id, COUNT(o.order_id) AS orders_count
	FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
	GROUP BY c.customer_id
) t; -- Returns the avg_num_orders as 5.5394.
-- This subquery yield a single float value as its result; and this value is
-- the average number of orders placed by the customers in the system.
-- Let's call this subquery as: Subquery 'C'.

SELECT
	c1.customer_id, c1.customer_fname, c1.customer_lname, c1.customer_city,
	COUNT(*) AS num_orders_placed
FROM customers c1 INNER JOIN orders o1 ON c1.customer_id = o1.customer_id
GROUP BY c1.customer_id
HAVING COUNT(*) > ( -- Value returned by Subquery 'C' is used here
	SELECT AVG(t.orders_count) AS avg_num_orders FROM (
		SELECT c.customer_id, COUNT(o.order_id) AS orders_count
		FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
		GROUP BY c.customer_id
	) t
)
ORDER BY num_orders_placed DESC, c1.customer_id;
-- Returns: 5,954 records.
-- Each record represents a "premium customer" who has placed more than the
-- average number of orders placed by customers i.e. more than 5.5394 orders.
-- Each record is a tuple of:
-- (customer_id, customer_fname, customer_lname, customer_city, num_orders_placed).
-- NOTE: We're able to select additional customer columns here apart from the
-- grouped column of customer_id or aggregated values, because of the fact that
-- customer_id is PK in customers table and all other customers table columns
-- are functionally dependent on the PK customer_id, using which we grouped by.

-- If we are fine with just getting the `customer_id`'s of these
-- "premium customers", then we need not JOIN the `customers` table with
-- the `orders` table; and instead just work on the `orders` table:
SELECT o1.customer_id, COUNT(*) AS num_orders_placed
FROM orders o1 GROUP BY o1.customer_id
HAVING COUNT(*) > ( -- Value returned by Subquery 'C' is used here
	SELECT AVG(t.orders_count) AS avg_num_orders FROM (
		SELECT c.customer_id, COUNT(o.order_id) AS orders_count
		FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
		GROUP BY c.customer_id
	) t
)
ORDER BY num_orders_placed DESC, o1.customer_id;
-- Same: 5,954 records returned. Each record is just: (customer_id, num_orders_placed).



-- ==== Subquery (which returns a single value) as part of SELECT list ==========
-- We can even place a subquery (which returns a single value) as part of SELECT list.

-- E.g. in below `orders` table plain SELECT statement, we need to show an additional
-- value as a column, with the same value for all orders records, which is equal
-- to the average number of orders placed by any customer on our system.
-- Plain SELECT statement:
SELECT * FROM orders;

-- We will be using the same Subquery 'C' as before which gives a single float
-- value equal to the average number of orders placed by any customer.

-- SELECT statement, with a subquery as an additional "column / value" in the SELECT List:
SELECT *, (
	SELECT AVG(t.orders_count) AS avg_num_orders FROM (
		SELECT c.customer_id, COUNT(o.order_id) AS orders_count
		FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
		GROUP BY c.customer_id
	) t
) AS avg_orders_placed
FROM orders;


-- ***** Data Seeding *****
DROP TABLE IF EXISTS employees_dummy;
CREATE TABLE IF NOT EXISTS employees_dummy (
	emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    emp_salary DECIMAL(10, 2)
);
INSERT INTO employees_dummy (emp_id, emp_name, emp_salary) VALUES
(1,   'Amit',   60000.00),
(2,   'Sneha',  75000.00),
(3,   'Raj',    50000.00),
(4,   'Priya',  80000.00),
(5,   'Vijay',  45000.00);

SELECT * FROM employees_dummy;

-- ====== Find employees with above average salary ========
SELECT *,
	(SELECT AVG(e.emp_salary) FROM employees_dummy e) AS avg_salary
FROM employees_dummy
WHERE emp_salary > (SELECT AVG(e.emp_salary) FROM employees_dummy e);
-- Returns: employee records of 'Sneha' (salary=75k) & 'Priya' (salary=80k)
-- since avg_salary=62k.


-- ***** Data Seeding *****
DROP TABLE IF EXISTS employees_dummy;
CREATE TABLE IF NOT EXISTS employees_dummy (
	emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    emp_salary DECIMAL(10, 2),
    department_id INT
);
INSERT INTO employees_dummy (emp_id, emp_name, emp_salary, department_id) VALUES
(1,   'Amit',   60000.00,   1),
(2,   'Sneha',  75000.00,   2),
(3,   'Raj',    50000.00,   1),
(4,   'Priya',  80000.00,   2),
(5,   'Vijay',  45000.00,   1),
(6,   'Anita',  70000.00,   3),
(7,   'Sunil',  65000.00,   3),
(8,   'Pooja',  55000.00,   2);


-- ===== Find employees who earn more than the average salary in their department ========

-- First, let's find the average salary for each department:
SELECT department_id, AVG(emp_salary) AS dept_avg_salary
FROM employees_dummy GROUP BY department_id;
-- Result: (department_id, dept_avg_salary) as follows:
-- department_id,    dept_avg_salary
--   1,                51666.666667
--   2,                70000.000000
--   3,                67500.000000


-- Now, to visualize, we just print the respective dept_avg_salary
-- with each employee record, according to their department
SELECT
	e.emp_id, e.emp_name, e.department_id,
    e.emp_salary, t.dept_avg_salary
FROM employees_dummy e INNER JOIN (
	SELECT department_id, AVG(emp_salary) AS dept_avg_salary
	FROM employees_dummy GROUP BY department_id
) t ON e.department_id = t.department_id;

-- Now, for the final resultant query, we just need to add the
-- filter condition in WHERE clause which only keeps employee
-- records whose salary is more than their dept_avg_salary:
SELECT
	e.emp_id, e.emp_name, e.department_id,
    e.emp_salary, t.dept_avg_salary
FROM employees_dummy e INNER JOIN (
	SELECT department_id, AVG(emp_salary) AS dept_avg_salary
	FROM employees_dummy GROUP BY department_id
) t ON e.department_id = t.department_id
WHERE e.emp_salary > t.dept_avg_salary;
-- Result: 4 employee records with salary more than their dept_avg_salary.
-- Got employees with emp_id's: 1, 2, 4, 6.


-- Now, we try the same query BUT with using a Correlated Subquery
-- which will be less efficient than the above join approach:
SELECT * FROM employees_dummy e WHERE e.emp_salary > (
	-- Correlated (dependent) Subquery: Depends on e.department_id
    -- value from each record of the outer query.
	SELECT AVG(emp_salary) FROM employees_dummy
    WHERE department_id = e.department_id
	-- GROUP BY department_id   -- Note: GROUP BY not needed here as we are
								-- already filtering down to records of a dept
);
-- Result: Same as previous more efficient join query.
-- Got employees with emp_id's: 1, 2, 4, 6.
-- But this approach's query (which uses a correlated subquery)
-- is less efficient than previous approach which used a join.
