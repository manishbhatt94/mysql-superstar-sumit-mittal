USE trendytech_joins_practice;
SHOW TABLES;
SELECT * FROM categories;
SELECT * FROM customers;
SELECT * FROM departments;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM products;


-- ##################### LEFT (OUTER) JOIN ######################

SELECT c.*, o.* FROM
customers c LEFT OUTER JOIN orders o
ON c.customer_id = o.customer_id
ORDER BY c.customer_id;
-- Note that customer_id's such as 219, 339, 469 haven't placed
-- any orders, so we can verify if `orders` related columns are
-- NULL for those customer_id's

SELECT COUNT(*) FROM
customers c LEFT OUTER JOIN orders o
ON c.customer_id = o.customer_id;
-- Result: 68,913.
-- This is the total no. of orders (68,883) plus the no. of customers
-- who didn't place any orders at all yet (which is 30).
-- Note: the total no. of customers is 12,435 which is much smaller,
-- than the number in this result - it is because a lot of customers
-- have placed multiple orders.


-- ======= Find the customers who have never placed any orders: =============

-- Approach: Classic Anti-Join (LEFT JOIN + IS NULL):
SELECT c.customer_id, c.customer_fname, c.customer_lname
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL          -- (or o.customer_id IS NULL)
ORDER BY c.customer_id;
-- Returns: 30 records.


-- ##################### RIGHT (OUTER) JOIN ######################

-- Same as LEFT OUTER JOIN - with the table orders changed
SELECT c.*, o.* FROM
orders o RIGHT OUTER JOIN customers c
ON c.customer_id = o.customer_id
ORDER BY c.customer_id;
-- Same result as the first query


-- ##################### FULL (OUTER) JOIN ######################

-- Note: MySQL does not have a direct FULL (OUTER) JOIN clause
-- (other RDBMS like Postgres etc. do)

-- But we can easily recreate the results of FULL (OUTER) JOIN in
-- MySQL using UNION set operation:
SELECT
	c.customer_id, c.customer_fname, c.customer_lname,
    c.customer_city, o.order_id, o.order_date, o.order_status
FROM customers c LEFT OUTER JOIN orders o
ON c.customer_id = o.customer_id
UNION
SELECT
	c.customer_id, c.customer_fname, c.customer_lname,
    c.customer_city, o.order_id, o.order_date, o.order_status
FROM customers c RIGHT OUTER JOIN orders o
ON c.customer_id = o.customer_id
ORDER BY customer_id;


-- ##################### CROSS JOIN ######################

SELECT
	c.customer_id, c.customer_fname, c.customer_lname,
    c.customer_city, o.order_id, o.order_date, o.order_status
FROM customers c CROSS JOIN orders o;

SELECT COUNT(*)
FROM customers c CROSS JOIN orders o;
-- Result: 856,560,105 records (856.56 Million).
-- 12,435 * 68,883 is equal to 856,560,105.

-- Note: Specifying bare JOIN (with ON join condition) implies INNER JOIN.
-- BUT, a bare JOIN without ON clause (without join condition) is treated
-- as a CROSS JOIN query. We verify this statement below, by getting a
-- COUNT(*) with a Bare JOIN without ON clause:
SELECT COUNT(*)
FROM customers c JOIN orders o;
-- Result: 856,560,105 records (856.56 Million). Same as CROSS JOIN.


-- #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%

-- ===== Find top 5 states from where maximum no. of orders are placed =======
SELECT c.customer_state, COUNT(*) AS num_orders
FROM customers c INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY COUNT(*) DESC
LIMIT 5;

-- ===== Find top 5 customers with maximum no. of orders in 'CLOSED' status =======
SELECT
	c.customer_id, c.customer_fname, c.customer_lname,
    COUNT(*) AS num_closed_orders
FROM customers c INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'CLOSED'
GROUP BY c.customer_id
ORDER BY COUNT(*) DESC, c.customer_id
LIMIT 5;
-- Results: (customer_id, customer_fname, num_closed_orders):
-- [(1833, 'Ronald', 6), (1363, 'Kathy', 5), (1687, 'Jerry', 5), (5493, 'Mary', 5), (145, 'Joan', 4)]

-- Alternate: No join needed (`customers` table not required at all) if we only
-- need customer_id's which are available in the `orders` table. We need to join
-- with `customers` table only if we need additional info about the customer
-- other than just `customer_id`. Have a look:
SELECT customer_id, COUNT(*) AS num_closed_orders
FROM orders
WHERE order_status = 'CLOSED'
GROUP BY customer_id
ORDER BY COUNT(*) DESC, customer_id
LIMIT 5;
-- Results: (customer_id, num_closed_orders):
-- [(1833, 6), (1363, 5), (1687, 5), (5493, 5), (145, 4)]


-- ===== List the `customer_street` from where we have orders with all
-- possible order_status's ==========

-- First, let's see how many unique values for `customer_street` exists in dataset:
SELECT COUNT(DISTINCT customer_street) FROM customers;
-- Result: 6,943 count.

-- Second, let's see what all unique value of `order_status` exists in dataset:
SELECT DISTINCT order_status FROM orders;
-- Result: 9 records with values like 'CLOSED', 'COMPLETE', 'ON_HOLD' etc.

SELECT COUNT(DISTINCT order_status) FROM orders; -- Result: 9 (distinct `order_status` values exist).

-- Let's extract all `order_status` values as a comma-separated string:
-- Consult syntax for GROUP_CONCAT function from below link:
-- https://www.mysqltutorial.org/mysql-aggregate-functions/mysql-group_concat-function/
SELECT
	GROUP_CONCAT(
		DISTINCT order_status
        ORDER BY order_status 
        SEPARATOR ', '
	) AS order_status_values
FROM orders;
-- Result:
-- 'CANCELED, CLOSED, COMPLETE, ON_HOLD, PAYMENT_REVIEW, PENDING, PENDING_PAYMENT, PROCESSING, SUSPECTED_FRAUD'

-- Finally, let's attempt to write the query for the original requirement:
-- """List the `customer_street`s from where we have orders with all
-- possible order_status's"""
SELECT c.customer_street, COUNT(*) AS num_orders_street,
	COUNT(DISTINCT o.order_status) AS uniq_order_statuses
FROM customers c INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_street
HAVING COUNT(DISTINCT o.order_status) = 9   -- 9 is the no. of unique `order_status` values.
ORDER BY COUNT(*) DESC;
-- Returns: 17 records.
-- Contains values of `customer_street` such as: '6312 Noble Apple Woods',
-- '9739 Round Spring Expressway', '6324 Jagged Orchard', '599 Sleepy Townline', etc.

-- Or, if we need to removed the hard-coded value 9 (count of distinct order_status):
SELECT c.customer_street, COUNT(*) AS num_orders_street,
	COUNT(DISTINCT o.order_status) AS uniq_order_statuses
FROM customers c INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_street
HAVING COUNT(DISTINCT o.order_status) = (SELECT COUNT(DISTINCT order_status) FROM orders)
ORDER BY COUNT(*) DESC;

-- Simple INNER JOIN b/w `customers` & `orders`, grouped by on `customer_street`
-- column. Let's see how many records are returned from this:
SELECT COUNT(*) FROM
(SELECT 1 FROM customers c INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_street) AS derived_table;
-- This returns 6,936 records. This is slightly short of the total no. of
-- unique `customer_street` values available in the dataset which is 6,943.
-- That means, the difference of 6943-6936 = 7 records -- this signifies
-- that there were no orders at all from 7 distinct `customer_street` addresses.

