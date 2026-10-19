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
		COUNT(*) AS num_order_items,
		SUM(total_amount) AS order_amount
	FROM order_items GROUP BY order_item_order_id
) t;

-- Second subquery 'B': gives us value for "avg_order_amount". This is below:
SELECT AVG(t.order_amount) AS avg_order_amount
FROM (
	SELECT order_item_order_id AS order_id,
		COUNT(*) AS num_order_items,
		SUM(total_amount) AS order_amount
	FROM order_items GROUP BY order_item_order_id
) t;


SELECT order_item_order_id AS order_id,
	COUNT(*) AS num_order_items,
	SUM(total_amount) AS order_amount
FROM order_items
GROUP BY order_item_order_id
HAVING COUNT(*) > ( -- Subquery 'A'
		SELECT AVG(t.num_order_items) AS avg_order_items
		FROM (
			SELECT order_item_order_id AS order_id,
				COUNT(*) AS num_order_items,
				SUM(total_amount) AS order_amount
			FROM order_items GROUP BY order_item_order_id
		) t
	)
    AND SUM(total_amount) > ( -- Subquery 'B'
		SELECT AVG(t.order_amount) AS avg_order_amount
		FROM (
			SELECT order_item_order_id AS order_id,
				COUNT(*) AS num_order_items,
				SUM(total_amount) AS order_amount
			FROM order_items GROUP BY order_item_order_id
		) t
    );
-- Returns: the same no. of records (i.e. 25,773)
