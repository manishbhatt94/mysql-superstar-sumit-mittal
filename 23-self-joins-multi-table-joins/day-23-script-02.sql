USE trendytech_joins_practice;
SHOW TABLES;

/* We'll be using the below 6 tables (created during data setup of 21-inner-joins/ directory)
   to demonstrate concepts of multi-table joins. */
SELECT * FROM categories;
SELECT * FROM customers;
SELECT * FROM departments;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM products;

-- #############################################################################
-- #######################    MULTI-TABLE JOINS    #############################
-- #############################################################################

/* Joining more than two (2) tables. */


-- ======= Show details of customers with their orders, and also the items
-- ordered in each order ===============
-- (i.e. Join `customers` table with `orders` table with `order_items` table)
SELECT
	c.customer_id, c.customer_fname, c.customer_lname, c.customer_city,
    o.order_id, o.order_date, o.order_status,
    oi.order_item_id, oi.product_id, oi.quantity, oi.total_amount
FROM
	customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    INNER JOIN order_items oi ON o.order_id = oi.order_item_order_id;


-- ======= Show details of customers with their orders, the items
-- ordered in each order, and also the product info ===============
-- (i.e. Join `customers` table with `orders` table with `order_items` table
-- and the `products` table too)
SELECT
	c.customer_id, c.customer_fname, c.customer_lname, c.customer_city,
    o.order_id, o.order_date, o.order_status,
    oi.order_item_id, oi.product_id, oi.quantity, oi.total_amount,
    p.product_id, p.product_name, p.product_category_id
FROM
	customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    INNER JOIN order_items oi ON o.order_id = oi.order_item_order_id
    INNER JOIN products p ON oi.product_id = p.product_id;


-- ===== Add category info, as well, to above query ===========
SELECT
	c.customer_id, c.customer_fname, c.customer_lname, c.customer_city,
    o.order_id, o.order_date, o.order_status,
    oi.order_item_id, oi.product_id, oi.quantity, oi.total_amount,
    p.product_id, p.product_name, p.product_category_id,
    ct.category_id, ct.category_name
FROM
	customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    INNER JOIN order_items oi ON o.order_id = oi.order_item_order_id
    INNER JOIN products p ON oi.product_id = p.product_id
    INNER JOIN categories ct ON p.product_category_id = ct.category_id;


-- ===== Add department (category's dept.) info, as well, to above query ===========
SELECT
	c.customer_id, c.customer_fname, c.customer_lname, c.customer_city,
    o.order_id, o.order_date, o.order_status,
    oi.order_item_id, oi.product_id, oi.quantity, oi.total_amount,
    p.product_id, p.product_name, p.product_category_id,
    ct.category_id, ct.category_name,
    d.department_id, d.department_name
FROM
	customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    INNER JOIN order_items oi ON o.order_id = oi.order_item_order_id
    INNER JOIN products p ON oi.product_id = p.product_id
    INNER JOIN categories ct ON p.product_category_id = ct.category_id
    INNER JOIN departments d ON ct.category_department_id = d.department_id;
