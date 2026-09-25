USE retail_db;
SHOW TABLES;

SELECT COUNT(*) FROM sales;
SELECT * FROM sales LIMIT 15;


-- Find "total sales" (total `amount`) by `store_location` where
-- total sales exceed 15 Lakh Rupees:
SELECT
	store_location,
	SUM(amount) AS total_sales
FROM sales
GROUP BY store_location HAVING SUM(amount) >= 1500000;

-- Find highest and lowest order amount (i.e. `amount`) in
-- each category:
SELECT
	category,
	MAX(amount) AS highest_order_amount,
	MIN(amount) AS lowest_order_amount
FROM sales GROUP BY category;

-- Find "total sales amount" and "average quantity sold per order"
-- for each `product` sold in 'Davangere' store:
SELECT
	product,
	SUM(amount) AS total_sales_amount,
	AVG(quantity) AS avg_qty_sold_per_order
FROM sales
WHERE store_location = 'Davangere'
GROUP BY product ORDER BY product;
-- .. and WHERE clause is executed and filters records
-- before GROUP BY is executed.

SELECT
	product,
	SUM(amount) AS total_sales_amount,
	AVG(quantity) AS avg_qty_sold_per_order
FROM sales
GROUP BY product HAVING store_location = 'Davangere';
-- Using HAVING with simple column value `store_location`
-- and no aggregation gives below error, b'coz HAVING
-- works on GROUPed data, and each group of sales orders
-- by a product, will have multiple sales records with
-- different `store_location` column values in each record.
-- So, we can logically only filter by aggregate values of
-- a group, in the HAVING clause. Error below:
-- Error Code: 1054. Unknown column 'store_location' in 'having clause'


-- Find distinct months (of each year) for which data is present:
SELECT
DISTINCT DATE_FORMAT(sale_date, '%Y-%m') AS month_year
FROM sales ORDER BY month_year; -- 60 records.

-- Find count of distinct months for which data is present:
SELECT COUNT(
	DISTINCT DATE_FORMAT(sale_date, '%Y-%m')
) AS sale_months_count FROM sales
ORDER BY DATE_FORMAT(sale_date, '%Y-%m');
-- Result: 60.
-- (Since we have data for each month in the 5 year
-- period from 2021-01 to 2025-12).

-- Find "total sales amount" and "total quantity sold" by each month:
SELECT
    DATE_FORMAT(sale_date, '%Y-%m') AS month_year,
    SUM(amount) AS total_sales,
    SUM(quantity) AS total_units_sold
FROM sales
GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY month_year;


-- From each store, find the count of unique customers
-- who made a purchase at that store:
SELECT
	store_location,
    COUNT(DISTINCT customer_id) AS customer_count,
    COUNT(*) AS total_orders
FROM sales
GROUP BY store_location;


-- Find monthly total sales (total amount spent shopping) by
-- each customer - who has made atleast 10 purchases:
SELECT
	DATE_FORMAT(sale_date, '%Y-%m') AS sale_month_year,
    customer_id,
    SUM(amount) AS total_purchase_amount,
    COUNT(*) AS num_purchases
FROM sales
GROUP BY DATE_FORMAT(sale_date, '%Y-%m'), customer_id
HAVING COUNT(*) >= 10
ORDER BY sale_month_year, customer_id; -- Returned 67 records.


-- Find monthly total sales (total amount spent shopping) per
-- each customer - and only for customers whose average spend
-- on purchasing in that month is atleast 3000 Rupees
-- over atleast 2 orders:
SELECT
	DATE_FORMAT(sale_date, '%Y-%m') AS sale_month_year,
    customer_id,
    SUM(amount) AS total_purchase_amount,
    AVG(amount) AS months_average_spend,
    COUNT(*) AS num_orders
FROM sales
GROUP BY DATE_FORMAT(sale_date, '%Y-%m'), customer_id
HAVING AVG(amount) >= 3000 AND COUNT(*) >= 2
ORDER BY sale_month_year, customer_id LIMIT 50000;


-- Find "total sales amount" by `category` for orders placed
-- in December 2024:
SELECT category, SUM(amount) AS sales_amount
FROM sales
WHERE sale_date BETWEEN '2024-12-01' AND '2024-12-31'
GROUP BY category ORDER BY category;
-- Date comparison done using BETWEEN.

-- Or, same query, but date comparison with MONTH(..) & YEAR(..)
-- date functions:
SELECT category, SUM(amount) AS sales_amount
FROM sales
WHERE YEAR(sale_date) = 2024 AND MONTH(sale_date) = 12
GROUP BY category ORDER BY category;


-- Find "total sales" (made on weekdays) by customers whose
-- total weekday spends are greater than 15,000 Rupees:
SELECT customer_id, SUM(amount) AS total_sales
FROM sales
WHERE DAYOFWEEK(sale_date) BETWEEN 2 AND 6
GROUP BY customer_id HAVING SUM(amount) >= 15000
ORDER BY total_sales DESC;
-- DAYOFWEEK(..) date function gives number 1 to 7
-- (1=Sunday, 2=Monday, .., 6=Friday, 7=Saturday)
-- https://www.mysqltutorial.org/mysql-date-functions/mysql-dayofweek-function/


-- Find "total sales amount" and "no. of orders" per
-- `store_location` for sales happening in the month of
-- January 2023 only, ordered by "no. of orders"
SELECT
	store_location,
    SUM(amount) AS total_sales,
    COUNT(*) AS num_orders
FROM sales
WHERE YEAR(sale_date) = 2023 AND MONTH(sale_date) = 1
GROUP BY store_location
ORDER BY num_orders DESC;

