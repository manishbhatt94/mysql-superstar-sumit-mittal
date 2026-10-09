USE retail_db;
SHOW TABLES;

/*
Let's say, an ecommerce system has below three (3) tables:
1) `purchases`:                 Records purchases made by customers.
2) `newsletter_subscriptions`:  Records subscriptions to newletter(s) made by customers.
3) `returns`:                   Table storing records for both return of purchases, and
								also for cancellation of subscribed newsletters.

Table Structure (and seed data) as follows:
*/

DROP TABLE IF EXISTS purchases;
CREATE TABLE IF NOT EXISTS purchases (
	customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    purchase_date DATE
);

INSERT INTO purchases (customer_id, first_name, last_name, email, purchase_date) VALUES
( 101, 'Aarav', 'Sharma', 'aarav.sharma@example.com', '2024-07-05' ),
( 102, 'Vihaan', 'Singh', 'vihaan.singh@example.com', '2024-06-25' ),
( 103, 'Aditi', 'Mehta', 'aditi.mehta@example.com', '2024-07-15' ),
( 104, 'Rohan', 'Kumar', 'rohan.kumar@example.com', '2024-07-12' ),
( 105, 'Isha', 'Patel', 'isha.patel@example.com', '2024-07-18' ),
( 106, 'Kavya', 'Verma', 'kavya.verma@example.com', '2024-06-28' ),
( 107, 'Arjun', 'Reddy', 'arjun.reddy@example.com', '2024-07-09' ),
( 108, 'Ananya', 'Nair', 'ananya.nair@example.com', '2024-07-22' ),
( 109, 'Saanvi', 'Gupta', 'saanvi.gupta@example.com', '2024-07-20' ),
( 110, 'Kabir', 'Agarwal', 'kabir.agarwal@example.com', '2024-07-19' ),
( 111, 'Neha', 'Saxena', 'neha.saxena@example.com', '2024-06-24' ),
( 112, 'Tanishq', 'Rana', 'tanishq.rana@example.com', '2024-07-10' ),
( 113, 'Mira', 'Bhatt', 'mira.bhatt@example.com', '2024-07-21' ),
( 114, 'Dev', 'Kapoor', 'dev.kapoor@example.com', '2024-07-17' ),
( 115, 'Riya', 'Joshi', 'riya.joshi@example.com', '2024-07-11' );


DROP TABLE IF EXISTS newsletter_subscriptions;
CREATE TABLE IF NOT EXISTS newsletter_subscriptions (
	customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    subscription_date DATE
);

INSERT INTO newsletter_subscriptions (customer_id, first_name, last_name, email, subscription_date) VALUES
( 101, 'Aarav', 'Sharma', 'aarav.sharma@example.com', '2024-07-01' ),
( 109, 'Saanvi', 'Gupta', 'saanvi.gupta@example.com', '2024-07-05' ),
( 116, 'Lakshay', 'Malhotra', 'lakshay.malhotra@example.com', '2024-06-29' ),
( 112, 'Tanishq', 'Rana', 'tanishq.rana@example.com', '2024-07-03' ),
( 117, 'Sneha', 'Chawla', 'sneha.chawla@example.com', '2024-07-15' ),
( 113, 'Mira', 'Bhatt', 'mira.bhatt@example.com', '2024-06-30' ),
( 118, 'Rahul', 'Pillai', 'rahul.pillai@example.com', '2024-07-06' ),
( 105, 'Isha', 'Patel', 'isha.patel@example.com', '2024-07-18' ),
( 106, 'Kavya', 'Verma', 'kavya.verma@example.com', '2024-07-20' ),
( 115, 'Riya', 'Joshi', 'riya.joshi@example.com', '2024-07-22' ),
( 119, 'Nikhil', 'Chandra', 'nikhil.chandra@example.com', '2024-07-08' ),
( 107, 'Arjun', 'Reddy', 'arjun.reddy@example.com', '2024-07-10' ),
( 108, 'Ananya', 'Nair', 'ananya.nair@example.com', '2024-07-13' ),
( 114, 'Dev', 'Kapoor', 'dev.kapoor@example.com', '2024-07-14' ),
( 104, 'Rohan', 'Kumar', 'rohan.kumar@example.com', '2024-07-11' );


DROP TABLE IF EXISTS `returns`;
CREATE TABLE IF NOT EXISTS `returns` (
	customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    return_date DATE
);

INSERT INTO `returns` (customer_id, first_name, last_name, email, return_date) VALUES
( 103, 'Aditi', 'Mehta', 'aditi.mehta@example.com', '2024-07-17' ),
( 102, 'Vihaan', 'Singh', 'vihaan.singh@example.com', '2024-07-14' ),
( 104, 'Rohan', 'Kumar', 'rohan.kumar@example.com', '2024-07-19' ),
( 110, 'Kabir', 'Agarwal', 'kabir.agarwal@example.com', '2024-07-08' ),
( 105, 'Isha', 'Patel', 'isha.patel@example.com', '2024-07-21' ),
( 107, 'Arjun', 'Reddy', 'arjun.reddy@example.com', '2024-07-10' ),
( 111, 'Neha', 'Saxena', 'neha.saxena@example.com', '2024-07-16' ),
( 116, 'Lakshay', 'Malhotra', 'lakshay.malhotra@example.com', '2024-07-02' ),
( 117, 'Sneha', 'Chawla', 'sneha.chawla@example.com', '2024-07-18' ),
( 112, 'Tanishq', 'Rana', 'tanishq.rana@example.com', '2024-07-07' ),
( 108, 'Ananya', 'Nair', 'ananya.nair@example.com', '2024-07-09' ),
( 114, 'Dev', 'Kapoor', 'dev.kapoor@example.com', '2024-07-11' ),
( 109, 'Saanvi', 'Gupta', 'saanvi.gupta@example.com', '2024-07-12' ),
( 113, 'Mira', 'Bhatt', 'mira.bhatt@example.com', '2024-07-20' ),
( 101, 'Aarav', 'Sharma', 'aarav.sharma@example.com', '2024-07-22' );


SELECT * FROM purchases;
SELECT * FROM newsletter_subscriptions;
SELECT * FROM `returns`;


-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
-- #=#=#=#=#=#=#=#=#=#=#    UNION [DISTINCT | ALL]    #=#=#=#=#=#=#=#=#=#=#=#=#=
-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

-- MySQL UNION operator allows you to combine two or more result sets of queries
-- into a single result set. The syntax of the UNION operator:
/*
SELECT column_list
UNION [DISTINCT | ALL]
SELECT column_list
UNION [DISTINCT | ALL]
SELECT column_list
...
*/

-- Find the people who interacted with the system in any ways (i.e. either
-- purchased, subscribed, or returned purchase / cancelled subscription)
-- in the specified time period:
SELECT customer_id, first_name, last_name, email FROM purchases
UNION
SELECT customer_id, first_name, last_name, email FROM newsletter_subscriptions
UNION
SELECT customer_id, first_name, last_name, email FROM `returns`;
-- Returns: 19 records.

-- Same as UNION DISTINCT
SELECT customer_id, first_name, last_name, email FROM purchases
UNION DISTINCT
SELECT customer_id, first_name, last_name, email FROM newsletter_subscriptions
UNION DISTINCT
SELECT customer_id, first_name, last_name, email FROM `returns`;
-- Returns: 19 records (Same as UNION).

-- Same as UNION ALL
SELECT customer_id, first_name, last_name, email FROM purchases
UNION ALL
SELECT customer_id, first_name, last_name, email FROM newsletter_subscriptions
UNION ALL
SELECT customer_id, first_name, last_name, email FROM `returns`;
-- Returns: 45 records.


-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
-- #=#=#=#=#=#=#=#=#=#=#=#=#=#    INTERSECT    #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

-- The INTERSECT operator is a set operator that returns the common rows of
-- two or more queries. Here’s the syntax of the INTERSECT operator:
/*
query1
INTERSECT [ALL | DISTINCT]
query2;
*/

-- Find customers who have made a purchase, AND ALSO, subscribed to newsletter:
SELECT customer_id, first_name, last_name, email FROM purchases
INTERSECT
SELECT customer_id, first_name, last_name, email FROM newsletter_subscriptions;
-- Returns: 11 records.

-- Notice that MySQL supported INTERSECT operator in MySQL 8.0.31.
-- That is why Workbech IDE shows red underline after INSTERSECT, since
-- Workbech is not aware of the newer SQL features.


-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#    EXCEPT    #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

-- The MySQL EXCEPT operator allows you to retrieve rows from one query that
-- do not appear in another query.
-- Here’s the basic syntax of the MySQL EXCEPT operator:
/*
query1
EXCEPT [ALL | DISTINCT]
query2;
*/

-- Find customers who made a purchase, but DID NOT subscribe to newsletter:
SELECT customer_id, first_name, last_name, email FROM purchases
EXCEPT
SELECT customer_id, first_name, last_name, email FROM newsletter_subscriptions;
-- Returns: 4 records.

-- Note that the EXCEPT operator is supported in MySQL starting from version 8.0.31.
-- That is why Workbech IDE shows red underline after EXCEPT, since
-- Workbech is not aware of the newer SQL features.

-- =@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@=@

SELECT * FROM orders;
SELECT * FROM customers;

-- ## Find out all customers, who have not made any orders at all yet:

SELECT customer_id FROM customers
EXCEPT
SELECT customer_id FROM orders;
-- Returns: 30 records.
-- Returns 30 distinct customer_id values who are present in `customers`
-- table but not in `orders` table.
-- This includes customer_id's 219, 339, 469, 1187, 1481, 1808, 2073, etc. (total 30)

-- Let's double check if any of the above customer_id is present in `orders` table,
-- which should not be the case:
SELECT * FROM orders WHERE customer_id IN (219, 339, 469, 1187, 1481, 1808, 2073);
-- No records returned. So, all these customer_id's are indeed of those who haven't
-- made any orders, so far.


-- ## Data quality check: Is there any customer_id present in the `orders` table,
-- and is NOT present in the `customers` table.
-- (Or: Find if there is any customer, who placed atleast one order, but who is
-- not there in the `customers` table)
SELECT customer_id FROM orders
EXCEPT
SELECT customer_id FROM customers;
-- Result: Zero records.
-- So, data quality is validated, and data is consistent & not corrupt.



-- ## Using the `purchases`, `newsletter_subscriptions` tables, find
-- out the customers, who either have made a purchase, or have subscribed
-- to newsletter, BUT NOT BOTH.
-- (i.e. find customers who EITHER have a record in `purchases` table, OR
-- have a record in `newsletter_subscriptions` table, BUT DO NOT have a
-- record in both the tables)

SELECT customer_id, first_name, last_name, email FROM newsletter_subscriptions ORDER BY customer_id;
SELECT customer_id, first_name, last_name, email FROM purchases ORDER BY customer_id;
SELECT customer_id, first_name, last_name, email FROM newsletter_subscriptions;
SELECT customer_id, first_name, last_name, email FROM purchases;

-- (A - B) UNION (B - A)
(
	SELECT customer_id, first_name, last_name, email FROM purchases
	EXCEPT
	SELECT customer_id, first_name, last_name, email FROM newsletter_subscriptions
) UNION ALL (
	SELECT customer_id, first_name, last_name, email FROM newsletter_subscriptions
    EXCEPT
	SELECT customer_id, first_name, last_name, email FROM purchases
);
-- Returned: 8 rows, with customer_id's:
-- 102, 103, 110, 111, 116, 117, 118, 119.
