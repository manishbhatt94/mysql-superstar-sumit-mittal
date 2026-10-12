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

-- What is the name of the customer who placed order with order_id=1

SELECT * FROM customers WHERE customer_id = (
	SELECT customer_id FROM orders WHERE order_id = 1
); -- Result: Mary Malone (customer_id=11599)

SELECT c.customer_id, c.customer_fname, c.customer_lname
	FROM customers c INNER JOIN orders o
	ON c.customer_id = o.customer_id
    WHERE o.order_id = 1;

-- Show customer names along with each order placed:
SELECT o.order_id, o.order_date, o.order_status,
	c.customer_id, c.customer_fname, c.customer_lname
	FROM customers c INNER JOIN orders o
	ON c.customer_id = o.customer_id;

-- Find the customers who have never placed any orders:
SELECT c1.customer_id, c1.customer_fname, c1.customer_lname
	FROM customers c1 LEFT OUTER JOIN orders o1
	ON c1.customer_id = o1.customer_id
EXCEPT
SELECT c.customer_id, c.customer_fname, c.customer_lname
	FROM customers c INNER JOIN orders o
	ON c.customer_id = o.customer_id;
-- Returns 30 customers (ID's such as 219, 469, 4555, 6072, 7552, 8575, etc.)

-- Verifying:
SELECT * FROM orders WHERE customer_id IN (219, 469, 4555, 6072, 7552, 8575);


-- Find out the customers who have placed at-least one order:
SELECT COUNT(DISTINCT c.customer_id)
	FROM customers c INNER JOIN orders o
	ON c.customer_id = o.customer_id;
-- Result: 12,405. (So, 12405 unique customers have placed an order,
-- out of a total of 68,883 orders.)

-- Total number of orders is 68,883
SELECT COUNT(*) FROM orders; -- Result: 68,883

-- Find out the customers who have placed at-least 10 orders:
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
