USE retail_db;
SHOW TABLES;


-- =========== TABLE SETUP / SEED DATA =============

DROP TABLE IF EXISTS `sales`;
CREATE TABLE IF NOT EXISTS `sales` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `product` VARCHAR(50),
  `category` VARCHAR(50),
  `amount` DECIMAL(10, 2),
  `sale_date` DATE,
  `quantity` INT,
  `customer_id` INT,
  `store_location` VARCHAR(50)
);
ALTER TABLE sales
ADD COLUMN unit_price DECIMAL(10,2) AFTER category;

-- Import steps in file: day-16-aggregate-functions/README.md

SELECT COUNT(*) FROM sales;
SELECT * FROM sales LIMIT 15;

-- ======= COUNT / SUM / MIN / MAX / AVG ==========

SELECT
	COUNT(*) AS total_orders_count,
    SUM(amount) AS total_sales_amount,
    MIN(amount) AS min_sales_amount,
    MAX(amount) AS max_sales_amount,
    AVG(amount) AS avg_sales_amount
FROM sales;
-- In one row, we get all aggregated values.

-- If we somehow need these aggregated values in separate rows,
-- we can try using UNION:
SELECT 'total_orders_count' AS data_label, COUNT(*) AS data_value FROM sales
UNION
SELECT 'total_sales_amount' AS data_label, SUM(amount) AS data_value FROM sales
UNION
SELECT 'min_sales_amount' AS data_label, MIN(amount) AS data_value FROM sales
UNION
SELECT 'max_sales_amount' AS data_label, MAX(amount) AS data_value FROM sales
UNION
SELECT 'avg_sales_amount' AS data_label, AVG(amount) AS data_value FROM sales;


-- ========== MIN / MAX on DATE type column =============

-- Find date of the earliest sale and the latest (most recent) sale:
SELECT
	MIN(sale_date) AS earliest_sale_date,
	MAX(sale_date) AS latest_sale_date
FROM sales;
