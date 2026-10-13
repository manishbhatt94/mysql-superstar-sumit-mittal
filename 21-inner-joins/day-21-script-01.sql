CREATE DATABASE trendytech_joins_practice;

USE trendytech_joins_practice;
SHOW TABLES;

TABLE categories;
TABLE customers;
TABLE departments;
TABLE order_items;
TABLE orders;
TABLE products;

SELECT * FROM categories;
SELECT * FROM customers;
SELECT * FROM departments;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM products;

SHOW CREATE TABLE customers;
SHOW CREATE TABLE orders;

/* Tables:

1. categories
2. customers
3. departments
4. order_items
5. orders
6. products

*/

-- ==== What is the name of the customer who placed order with order_id=1 ======

SELECT * FROM customers WHERE customer_id = (
	SELECT customer_id FROM orders WHERE order_id = 1
); -- Result: Mary Malone (customer_id=11599)

SELECT c.customer_id, c.customer_fname, c.customer_lname
	FROM customers c INNER JOIN orders o
	ON c.customer_id = o.customer_id
    WHERE o.order_id = 1;


-- ==== Show customer names along with each order placed: =====

SELECT o.order_id, o.order_date, o.order_status,
	c.customer_id, c.customer_fname, c.customer_lname
	FROM customers c INNER JOIN orders o
	ON c.customer_id = o.customer_id;


-- ======= Find the customers who have never placed any orders: =============

SELECT c1.customer_id, c1.customer_fname, c1.customer_lname
	FROM customers c1 LEFT OUTER JOIN orders o1
	ON c1.customer_id = o1.customer_id
EXCEPT
SELECT c.customer_id, c.customer_fname, c.customer_lname
	FROM customers c INNER JOIN orders o
	ON c.customer_id = o.customer_id
ORDER BY customer_id;
-- Returns 30 customers (ID's such as 219, 469, 4555, 6072, 7552, 8575, etc.)
-- So, these 30 customers have never placed an order yet.

-- Verifying:
SELECT * FROM orders WHERE customer_id IN (219, 469, 4555, 6072, 7552, 8575);

-- Total number of customers is 12,435 (out of which 30 - have placed no orders yet)
SELECT COUNT(*) FROM customers; -- Result: 12,435

-- Or better alternatives:
-- (1) Don't use LEFT JOIN in the first query of the EXCEPT set operator:
SELECT customer_id, customer_fname, customer_lname
	FROM customers
 EXCEPT
 SELECT c.customer_id, c.customer_fname, c.customer_lname
 	FROM customers c INNER JOIN orders o
 	ON c.customer_id = o.customer_id
ORDER BY customer_id;
-- Or, can use ORDER BY after parenthesis:
(SELECT customer_id, customer_fname, customer_lname
	FROM customers
 EXCEPT
 SELECT c.customer_id, c.customer_fname, c.customer_lname
 	FROM customers c INNER JOIN orders o
 	ON c.customer_id = o.customer_id)
ORDER BY customer_id;

-- (2) Don't use JOIN at all: Do EXCEPT set operator on all customer_id's and
-- except customer_id's that appear in the `orders` table:
SELECT customer_id FROM customers
EXCEPT
SELECT customer_id FROM orders
ORDER BY customer_id;

-- (3) Classic Anti-Join (LEFT JOIN + IS NULL):
SELECT c.customer_id, c.customer_fname, c.customer_lname
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL          -- (or o.customer_id IS NULL)
ORDER BY c.customer_id;

-- (4) NOT EXISTS
SELECT c.customer_id, c.customer_fname, c.customer_lname
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
)
ORDER BY c.customer_id;



-- ===== Find out the customers who have placed at-least one order: ========

SELECT COUNT(DISTINCT c.customer_id)
	FROM customers c INNER JOIN orders o
	ON c.customer_id = o.customer_id;
-- Result: 12,405. (So, 12405 unique customers have placed an order,
-- out of a total of 12,435 customers, and across 68,883 total orders.)

-- Total number of customers is 12,435
SELECT COUNT(*) FROM customers; -- Result: 12,435

-- Total number of orders is 68,883
SELECT COUNT(*) FROM orders; -- Result: 68,883

-- Or, without JOIN, just count distinct no. of customer_id column values
-- appearing in the `orders` table:
SELECT COUNT(DISTINCT customer_id) FROM orders; -- Result: 12,435

-- Using INTERSECT set operator:
SELECT customer_id FROM customers
INTERSECT
SELECT customer_id FROM orders;
-- Gives: 12,405 records.

-- And to count them:
SELECT COUNT(*) FROM (
	SELECT customer_id FROM customers
	INTERSECT
	SELECT customer_id FROM orders
) AS c;
-- Result: 12405. (12,405 is the no. of customers who placed at least one order).
-- (Total no. of customers in the system is 12,435).
-- Note: Provide the alias for the subquery table, else below error:
-- Error: Error Code: 1248. Every derived table must have its own alias.


-- ===== Find out the customers who have placed at-least 10 orders: =========

SELECT c.customer_id, c.customer_fname, c.customer_lname, COUNT(*)
	FROM customers c INNER JOIN orders o
	ON c.customer_id = o.customer_id
    GROUP BY c.customer_id HAVING COUNT(*) >= 10
    ORDER BY c.customer_id;
-- Result: 699 records.
-- Customer with IDs like 71, 172, 174, 197, 221, 222, 254, etc.

-- Verifying:
SELECT c.customer_id, c.customer_fname, c.customer_lname, o.*
	FROM customers c INNER JOIN orders o
	ON c.customer_id = o.customer_id
    WHERE c.customer_id = 71;
