USE trendytech_joins_practice;
SHOW TABLES;

SELECT * FROM categories;
SELECT * FROM customers;
SELECT * FROM departments;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM products;


-- ====== Find all the customers who have not placed even a single order =======


-- 1) Approach: With (independent) subquery (using a NOT IN)
SELECT * FROM customers c WHERE c.customer_id NOT IN (
	SELECT customer_id FROM orders   -- Note: this subquery is independent of outer query & we
									 -- can run it independently as one individual separate query
);
-- Returns 30 customers (ID's such as 219, 339, 469, 1187, 1481,
-- 1808, 2073, 2096, 2450, 4555, 4927, 6072, 6613, 7011, 7552,
-- 8243, 8343, 8575, etc.)
-- So, these 30 customers have never placed an order yet.

-- Detour: Problem with using IN operator on list of values that might contain
-- some NULLs. Important: we must guard against usage of IN operator on values
-- that may be NULL.

-- **** Checking NOT IN operator:
SELECT 5 NOT IN (1, 2, 3) AS bool_result; -- Returns: 1 (true). Expected.
SELECT 5 NOT IN (1, 2, 3, 4, 5) AS bool_result; -- Returns: 0 (false). Expected.

SELECT 5 NOT IN (1, 2, 3, NULL) AS bool_result; -- Returns: NULL. Unexpected.
-- We expected a true (i.e. 1); instead got NULL - this is problem with
-- using IN operator on values list that might contain NULLs.

SELECT 5 NOT IN (1, 2, 3, 4, 5, NULL) AS bool_result; -- Returns: 0 (false). Expected.
SELECT 5 NOT IN (NULL, 4, 5, NULL) AS bool_result; -- Returns: 0 (false). Expected.

-- **** Checking IN operator:
SELECT 5 IN (1, 2, 3) AS bool_result; -- Returns: 0 (false). Expected.
SELECT 5 IN (1, 2, 3, 4, 5) AS bool_result; -- Returns: 1 (true). Expected.

SELECT 5 IN (1, 2, 3, NULL) AS bool_result; -- Returns: NULL. Unexpected.
-- We expected a false (i.e. 0); instead got NULL - this is problem with
-- using IN operator on values list that might contain NULLs.

SELECT 5 IN (1, 2, 3, 4, 5, NULL) AS bool_result; -- Returns: 1 (true). Expected.
SELECT 5 IN (NULL, 4, 5, NULL) AS bool_result; -- Returns: 1 (true). Expected.


-- Therefore, we need to add the "IS NOT NULL" guard on the customer_id's selected
-- from the `orders` table in the subquery, so that any NULL values are not supplied
-- to the outer query's NOT IN operator, which will make it behave unexpectedly.
-- So the query changes to:
SELECT * FROM customers c WHERE c.customer_id NOT IN (
	SELECT customer_id FROM orders WHERE customer_id IS NOT NULL
);

-- 2) Approach: With LEFT JOIN b/w `customers` & `orders` tables
SELECT c.customer_id, c.customer_fname, c.customer_lname, c.customer_city
FROM customers c LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 3) Approach: With EXCEPT / MINUS set operator
SELECT customer_id FROM customers
EXCEPT
SELECT customer_id FROM orders;
-- Same 30 customer_id's are returned.

-- To see customer info columns, we'll need to use the customer_id's
-- obtained from the above query, in a subquery like this:
SELECT c.customer_id, c.customer_fname, c.customer_lname, c.customer_city
FROM customers c WHERE c.customer_id IN (
	SELECT customer_id FROM customers
	EXCEPT
	SELECT customer_id FROM orders
);
-- Tip: don't run above query - it takes more than 30 secs.
-- B'coz MySQL computes the inner query for every row of the outer query.

-- 4) Approach: Using "NOT EXISTS" (Correlated subquery):
SELECT * FROM customers c WHERE NOT EXISTS (
	SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
    -- Here, this subquery is dependent on the outer query.
);
-- The subquery used here (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id)
-- depends on outer query. This is a dependent subquery.
-- Such a query is also called as "Correlated Subquery".

-- For each row of the outer query, this dependent (correlated) subquery runs everytime.



-- ====== Find all the customers who have placed at least one order =======

-- 1) Approach: With (independent) subquery (using an IN)
SELECT * FROM customers c WHERE c.customer_id IN (
	SELECT customer_id FROM orders
);
-- 12,405 customer records returned - only those who have placed atleast one order.
-- Note: total customer records is 12,435; out of which 30 customers didn't place
-- any order yet; and so the remainder 12,405 must be the no. of customers who have
-- placed atleast one order.

-- 2) Approach: With INNER JOIN
-- SELECT c.customer_id, c.customer_fname, c.customer_lname, c.customer_city,
-- 	o.order_id, o.order_date, o.order_status
SELECT DISTINCT c.customer_id
FROM customers c INNER JOIN orders o ON c.customer_id = o.customer_id;
-- Returns: 12,405 customer_id's (as expected).
-- Note: had to use "DISTINCT customer_id" here because INNER JOIN will
-- match customers with orders, and some customers would have placed
-- multiple orders, so those customer_id's will appear multiple time
-- in the post join result.


-- 3) Approach: Using INTERSECT
SELECT customer_id FROM customers
INTERSECT
SELECT customer_id FROM orders;

-- OR, we can just look at the customer_id's in the `orders` table:
SELECT DISTINCT customer_id FROM orders;


-- 4) Approach: Using "EXISTS" (Correlated subquery):
SELECT * FROM customers c WHERE EXISTS (
	SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
);



-- ====== Find avg. no. of order items in each order, & also avg. amount per order ========

-- First, we construct an intermediate table, where we keep the per order
-- "num_order_items" and "order_amount":
SELECT
	oi.order_item_order_id AS order_id,
    COUNT(*) AS num_order_items,
    SUM(oi.total_amount) AS order_amount
FROM order_items oi
GROUP BY oi.order_item_order_id;

-- Then we use the above, to calculate avg. no. of order items, and avg. order amount
-- across all orders:
SELECT
AVG(t.num_order_items) AS avg_order_items,
AVG(t.order_amount) AS avg_order_amount
FROM (
	SELECT
		oi.order_item_order_id AS order_id,
		COUNT(*) AS num_order_items,
		SUM(oi.total_amount) AS order_amount
	FROM order_items oi
	GROUP BY oi.order_item_order_id
) t;
-- Result:
-- # avg_order_items,   avg_order_amount
--   2.9983,            597.632288



-- ======= Find avg. no. of orders placed by each customer =========

-- First, we need to find how many orders are placed by every customer:
SELECT c.customer_id, COUNT(o.order_id) AS orders_count
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY c.customer_id;  -- ORDER BY is just for easy reading by eyes
						 -- (will be removed when used as subquery)
-- Confirm that, all the 30 customers (like customer_id's: 219, 339, 469, 1187, 1481, etc.)
-- who haven't placed any orders, have their "orders_count" value as zero (0).
-- For this, we used "COUNT(o.order_id)" instead of "COUNT(*)".

-- Now, we can use above as a subquery (without ORDER BY obviously), to find
-- out the average number of orders placed by a customer:
SELECT AVG(orders_count) AS avg_num_orders FROM (
	SELECT c.customer_id, COUNT(o.order_id) AS orders_count
	FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
	GROUP BY c.customer_id
) t;
-- Result: avg_num_orders = 5.5394


-- ====== Find all "big orders" ==============
-- == "Big Orders": orders whose num_order_items > avg_order_items
-- AND whose order_amount > avg_order_amount =======

-- We'll use two intermediate queries we have previously used in this script file,
-- and then use both to get our final result.

-- First intermediate result set: (order_id, num_order_items, order_amount):
SELECT order_item_order_id AS order_id,
	COUNT(*) AS num_order_items,
    SUM(total_amount) AS order_amount
FROM order_items GROUP BY order_item_order_id;
-- Contains: one row per order. And from this we will only be choosing the
-- "big orders" in the final result.
-- We will alias this table as `tbl_one` for use in the final query.
-- (This table contains one row for each order).

-- Second intermediate result: Just a single record containing two columns
-- (avg_order_items, avg_order_amount):
SELECT AVG(t.num_order_items) AS avg_order_items, AVG(t.order_amount) AS avg_order_amount
FROM (
	SELECT order_item_order_id AS order_id,
		COUNT(*) AS num_order_items,
		SUM(total_amount) AS order_amount
	FROM order_items GROUP BY order_item_order_id
) t;
-- Result (one single row only):
-- # avg_order_items,   avg_order_amount
--   2.9983,            597.632288
-- We will alias this table as `tbl_two` for use in the final query.
-- (Remember this table contains just a single row)

-- Final query (build-up). Here to make the `avg_order_items` & `avg_order_amount`
-- value available to all order records in `tbl_one`, we will take a
-- CROSS JOIN b/w `tbl_one` and `tbl_two`
SELECT
	tbl_one.order_id, tbl_one.num_order_items, tbl_one.order_amount,
	tbl_two.avg_order_items, tbl_two.avg_order_amount
FROM (
	SELECT order_item_order_id AS order_id,
		COUNT(*) AS num_order_items,
		SUM(total_amount) AS order_amount
	FROM order_items GROUP BY order_item_order_id
) tbl_one CROSS JOIN (
	SELECT AVG(t.num_order_items) AS avg_order_items, AVG(t.order_amount) AS avg_order_amount
	FROM (
		SELECT order_item_order_id AS order_id,
			COUNT(*) AS num_order_items,
			SUM(total_amount) AS order_amount
		FROM order_items GROUP BY order_item_order_id
	) t
) tbl_two;
-- This results in a table containing all orders (and same no. of
-- records as in tbl_one) with these columns (note that the values
-- of avg_order_items & avg_order_amount is the same in each row):
-- (order_id, num_order_items, order_amount, avg_order_items, avg_order_amount).
-- And this result is not yet filtered, which we will do next, so
-- that only the "big orders" remain.

-- Final result query:
SELECT
	tbl_one.order_id, tbl_one.num_order_items, tbl_one.order_amount,
	tbl_two.avg_order_items, tbl_two.avg_order_amount
FROM (
	SELECT order_item_order_id AS order_id,
		COUNT(*) AS num_order_items,
		SUM(total_amount) AS order_amount
	FROM order_items GROUP BY order_item_order_id
) tbl_one CROSS JOIN (
	SELECT AVG(t.num_order_items) AS avg_order_items, AVG(t.order_amount) AS avg_order_amount
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
