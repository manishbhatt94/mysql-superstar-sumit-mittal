USE retail_db;
SHOW TABLES;

SELECT COUNT(*) FROM sales;
SELECT * FROM sales LIMIT 15;

-- Find all the distinct categories in the `sales` table:
SELECT DISTINCT category FROM sales;

-- Total sales count by each product category:
SELECT category, COUNT(*) AS sales_count FROM sales GROUP BY category;

-- Putting another non-grouped by column in SELECT-list
-- is not logical and will give an SQL Error.
SELECT category, COUNT(*), sale_date FROM sales GROUP BY category;
-- Error:
-- Error Code: 1055. Expression #3 of SELECT list is not in GROUP BY clause
-- and contains nonaggregated column 'retail_db.sales.sale_date' which
-- is not functionally dependent on columns in GROUP BY clause;
-- this is incompatible with sql_mode=only_full_group_by

-- Logically also, above query doesn't make sense, since we
-- need a single value per group, and directly selecting `sale_date`
-- is absurd since in each `category` there are 1000s of records
-- each having its own value for `sale_date` column.

-- Total `amount` money worth of sales made per each `category`:
SELECT category, SUM(amount) AS amount_sold FROM sales GROUP BY category;

-- Find count of products sold under each category:
SELECT category, COUNT(DISTINCT product) AS product_count
FROM sales GROUP BY category;

-- Find all distinct `product`s sold:
SELECT DISTINCT product FROM sales;

-- Find total `quantity` sold for each `product`:
SELECT product, SUM(quantity) AS total_quantity
FROM sales GROUP BY product;

-- Find total `quantity` sold for each `product`
-- (also display total number of sale orders for each product)
SELECT
	product,
    COUNT(*) AS total_orders,
    SUM(quantity) AS total_quantity
FROM sales GROUP BY product;

-- Find the top 3 `product`s with the maximum "sales volume":
-- ("sales volume": Total quantity for each products sold.
-- More quantities of a product sold - means more "sales volume")
SELECT
	product,
    SUM(quantity) AS total_sales
FROM sales
GROUP BY product
ORDER BY SUM(quantity) DESC
LIMIT 3;

-- Find "total sales" (`amount`) and no. of transactions
-- per each `store_location`:
SELECT
	store_location,
	SUM(amount) AS total_sales,
	COUNT(*) AS num_txns
FROM sales GROUP BY store_location;

-- Find number of distinct customers:
SELECT COUNT(DISTINCT customer_id) FROM sales; -- Result: 7661.

-- Find average sale amount by each customer:
SELECT
	customer_id,
	AVG(amount) AS avg_sales
FROM sales GROUP BY customer_id
LIMIT 50000;

-- Find average sale amount by each customer:
-- (also the no. of orders placed by each customer)
-- (also the count of unique products purchased by each customer)
SELECT
	customer_id,
	AVG(amount) AS avg_sales,
    COUNT(*) AS num_orders,
    COUNT(DISTINCT product) AS uniq_products_purchased
FROM sales GROUP BY customer_id
LIMIT 50000;

-- ########## Aggregate Functions with NULL values ############

DROP TABLE IF EXISTS research_scholars;
CREATE TABLE IF NOT EXISTS research_scholars (
	scholar_id INT AUTO_INCREMENT,
    scholar_name VARCHAR(50) NOT NULL,
    stipend INT NULL,
    test_score INT NULL,
    project_due_date DATE NULL,
    PRIMARY KEY (scholar_id)
);

INSERT INTO research_scholars
(scholar_name, stipend, test_score, project_due_date) VALUES
('RK Saurabh',    8000, NULL, '2026-11-25'),
('Manish Bhatt',  NULL,   60, '2026-11-30'),
('Ravi Gupta',    7000,   90, NULL),
('Kamal Chandra', 9000,  100, '2026-12-05'),
('Nitesh Kumar',  NULL,   70, NULL);


SELECT SUM(stipend) FROM research_scholars;
-- Returns: 24000. (Means - SUM ignored NULL values)

SELECT AVG(stipend) FROM research_scholars;
-- Returns 8000. Means 24000 / 3. Takes count of non-null
-- values, when computing average.

SELECT MAX(test_score), MIN(test_score) FROM research_scholars;

SELECT AVG(test_score) FROM research_scholars;

SELECT MIN(project_due_date), MAX(project_due_date) FROM research_scholars;

-- =============#=#=#=#=#=#=#=#=#=##=#=#=##=#=#=##=#=#=#==================

SELECT DATE_FORMAT(sale_date, '%Y-%M') FROM sales; -- Like: 2023-August
SELECT DATE_FORMAT(sale_date, '%y-%M') FROM sales; -- Like: 23-August
SELECT DATE_FORMAT(sale_date, '%Y-%m') FROM sales; -- Like: 2023-08

-- Find all distinct groups of (month, category):
SELECT 
DISTINCT DATE_FORMAT(sale_date, '%Y-%m') AS month_year, category
FROM sales ORDER BY month_year, category;
-- All these distinct groups will only be present in the
-- result set of a "GROUP BY month_year, category"!
-- (There are 720 records in this query, and the same groups
-- and the "GROUP BY month_year, category" query also produces
-- these exact same 720 records).

-- OR: Just using the GROUP BY without any aggregation:
-- (But here we are not really using the GROUP BY's primary
-- features of computing aggregate values for the groups).
SELECT DATE_FORMAT(sale_date, '%Y-%m') AS month_year, category
FROM sales
GROUP BY DATE_FORMAT(sale_date, '%Y-%m'), category
ORDER BY month_year, category;

-- Find count of all distinct groups of (month, category):
SELECT COUNT(
	DISTINCT DATE_FORMAT(sale_date, '%Y-%m'), category
) AS groups_count FROM sales;
-- Result: 720.
-- The same count 720 as the no. of records which a corresponding
-- "GROUP BY month_year, category" query returns.

-- Find total sales (amount) by month, and category:
SELECT
	category,
    DATE_FORMAT(sale_date, '%Y-%m') AS month_year,
    SUM(amount) AS total_sales
FROM sales
GROUP BY category, DATE_FORMAT(sale_date, '%Y-%m');

-- Same query, but ordered:
SELECT
	category,
    DATE_FORMAT(sale_date, '%Y-%m') AS month_year,
    SUM(amount) AS total_sales
FROM sales
GROUP BY category, DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY category, month_year;
