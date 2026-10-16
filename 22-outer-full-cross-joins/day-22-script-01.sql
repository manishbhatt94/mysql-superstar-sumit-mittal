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
