USE retail_db;
SHOW TABLES;


-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
-- #=#=#=#=#=#=#=#=#=#=#=# DATE Related Functions #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

/**
# Current Date (Only Date)
Function: CURDATE()
Synonyms: CURRENT_DATE() & CURRENT_DATE.
Result Format (in string context): 'YYYY-MM-DD' string.
Result Format (in numeric context): YYYYMMDD integer.

# Current Time (Only Time)
Function: CURTIME()
Synonyms: CURRENT_TIME() & CURRENT_TIME.
Result Format (in string context): 'hh:mm:ss' string.
Result Format (in numeric context): hhmmss integer.

# Current Timestamp (Both Date & Time)
Function: NOW()
Synonyms: CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP, LOCALTIME(), LOCALTIMESTAMP().

 */

-- ###################### MySQL CURDATE() function ######################
-- (Get today's date)
-- https://www.mysqltutorial.org/mysql-date-functions/mysql-curdate/

-- The CURDATE() function returns the current date as a value in the
-- 'YYYY-MM-DD' format if it is used in a string context or
-- YYYMMDD format if it is used in a numeric context.

-- Used in a string context:
SELECT CURDATE(); -- '2026-10-03' (3rd October 2026)
SELECT CURDATE() AS todays_date; -- '2026-10-03'

-- Used in a string context:
SELECT CONCAT('Today\'s date is: ', CURDATE()) AS todays_date;
-- (Result: 'Today's date is: 2026-10-03')

-- Used in a numeric context:
SELECT CURDATE() + 0;
-- Returns the integer value: 20261003 (i.e. the number YYYYMMDD)

-- ========= Synonyms for CURDATE(): ==================
-- The CURRENT_DATE and CURRENT_DATE() are synonyms for CURDATE().
SELECT CURRENT_DATE(), 
	CURRENT_DATE, 
	CURDATE();

-- ============ CURDATE vs. NOW =====================
-- The CURDATE() function returns the current date with the date part only.
-- While the NOW() function returns both date and time parts of the current time.
SELECT CURDATE(), NOW();
-- # CURDATE(),   NOW()
--   2026-10-03,  2026-10-03 13:01:18

-- The result of the CURDATE() function is equivalent to the following expression:
SELECT DATE(NOW()), CURDATE();
-- Result of expression DATE(NOW()) is equivalent to result of CURDATE().


-- ###################### MySQL CURTIME() function ######################
-- (Only time part)

SELECT CURTIME(); -- '13:24:49' (in 'hh:mm:ss' format string)

-- In numeric context:
SELECT CURTIME() + 0; -- 132449 integer (in hhmmss format integer)

SELECT CURTIME(), CURRENT_TIME(), CURRENT_TIME;

-- ================= Default current time value ====================
-- ======= CURTIME() Cannot be used as column default value ============
-- Note that you cannot use the CURRENT_TIME, CURRENT_TIME(), or CURTIME()
-- function as a default value for a column in a table.

-- Testing default value as CURTIME(): (Gives error)
/*
CREATE TABLE test(
  started_at TIME DEFAULT CURRENT_TIME
  --                      ^^^^^^^^^^^^
  -- SQL Editor gives red squiggly lines error tooltip:
  -- "CURRENT_TIME" is not valid at this position.
);
*/
-- Error Code: 1064. You have an error in your SQL syntax; check the manual that
-- corresponds to your MySQL server version for the right syntax to use
-- near 'CURRENT_TIME )' at line 2

/*
To use the current time as a default value for a column,
you use the DATETIME or TIMESTAMP as the column’s type
and the NOW() function as the default value.
*/

DROP TABLE IF EXISTS dummy_orders;
CREATE TABLE IF NOT EXISTS dummy_orders (
	order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    order_date DATE,
    total_amount DECIMAL(10, 2)
);
INSERT INTO dummy_orders
(customer_id, product_id, quantity, order_date, total_amount)
VALUES
	(1, 101, 2, CURRENT_DATE, 199.98),
    (2, 102, 1, CURRENT_DATE, 99.99),
    (3, 103, 5, CURRENT_DATE, 499.95),
    (4, 104, 3, CURRENT_DATE, 299.97),
    (5, 105, 4, CURRENT_DATE, 399.96);
-- Used CURDATE() / CURRENT_DATE when inserting records.

SELECT * FROM dummy_orders;

SELECT CURRENT_TIMESTAMP();  -- Or: SELECT NOW();
-- '2026-10-03 14:44:44'

-- ================== Extract parts from a Date/Time type ==============

-- Extract Date part from a DateTime (timestamp) string literal:
SELECT DATE('2026-10-03 14:44:44') AS date_only; -- '2026-10-03'
SELECT TIME('2026-10-03 14:44:44') AS time_only; -- '14:44:44'

SELECT YEAR('2026-10-03 14:44:44') AS year_only; -- Result: 2026.
SELECT MONTH('2026-10-03 14:44:44') AS month_only; -- Result: 10.
SELECT DAY('2026-10-03 14:44:44') AS year_only; -- Result: 3.
SELECT MONTHNAME('2026-10-03 14:44:44') AS month_name; -- Result: 'October'.
SELECT DAYNAME('2026-10-03 14:44:44') AS day_name; -- Result: 'Saturday'.
SELECT DAYOFWEEK('2026-10-03 14:44:44') AS day_of_week; -- Result: 7.

-- Extraction using SQL Standard function EXTRACT(unit FROM date)
-- https://www.w3schools.com/Sql/func_mysql_extract.asp
-- https://www.mysqltutorial.org/mysql-date-functions/mysql-extract/
SELECT EXTRACT(YEAR FROM '2026-10-03 14:44:44') AS year_only; -- Result: 2026.
SELECT EXTRACT(DAY FROM '2026-10-03 14:44:44') AS day_only; -- Result: 3.
SELECT EXTRACT(WEEK FROM '2026-10-03 14:44:44') AS week_only; -- Result: 39.
SELECT EXTRACT(DAY_HOUR FROM '2026-10-03 14:44:44') AS dayhour_only; -- Result: 314.

SELECT
	id, product, category, amount,
    EXTRACT(YEAR FROM sale_date) AS sale_year,
    EXTRACT(MONTH FROM sale_date) AS sale_month,
    EXTRACT(YEAR_MONTH FROM sale_date) AS sale_year_month
    -- `sale_year_month` values like: 202308, 202409, 202208, etc.
FROM sales;

-- Find total sales by month of sale:
SELECT
    EXTRACT(YEAR_MONTH FROM sale_date) AS sale_year_month,
    SUM(amount) AS total_sales
FROM sales
	GROUP BY EXTRACT(YEAR_MONTH FROM sale_date)
    ORDER BY sale_year_month;


-- ============= Date addition / subtraction ======================

SELECT ADDDATE(CURDATE(), INTERVAL 1 DAY) AS tomorrows_date;
-- Result: '2026-10-04'. (Today is '2026-10-03')

SELECT DATE_ADD(CURRENT_DATE, INTERVAL 1 DAY) AS tomorrows_date;
-- Result: '2026-10-04'.

-- Get the date which is 10 years and 2 months after today's date:
SELECT DATE_ADD(CURRENT_DATE, INTERVAL '10-2' YEAR_MONTH) AS future_date;

-- Add 3 days and 5 hours
SELECT DATE_ADD('2024-05-15 10:00:00', INTERVAL '3 5' DAY_HOUR) AS new_datetime;

SELECT SUBDATE('2026-10-03', INTERVAL 3 DAY) AS three_days_back_date;
-- Result: '2026-09-30'.

SELECT DATE_SUB('2024-05-15 10:00:00', INTERVAL 10 DAY) AS new_datetime;
-- Result: '2024-05-15 10:00:00'.

-- Subtract "hours & minutes" interval - subtract interval of 2 hours 15 minutes
-- from a date_time:
SELECT DATE_SUB('2026-10-15 17:45:00', INTERVAL '2:15' HOUR_MINUTE) AS new_datetime;
-- Result: '2026-10-15 15:30:00'.

-- ================= MySQL DATEDIFF() =========================
-- MySQL DATEDIFF() function to calculate the number of days between two date values.
-- Syntax: DATEDIFF(end_date,start_date);

SELECT DATEDIFF('2026-10-15', '2026-10-11') AS days_passed; -- Result: 4.

SELECT DATEDIFF('2026-10-11', '2026-10-15') AS days_passed; -- Result: -4.

-- Find number of days you have lived till now:
-- DATEDIFF( CURDATE(), <Your Birth Date> )

SELECT DATEDIFF(CURRENT_DATE, '1994-05-19') AS manish_days_alive; -- Result: 11825.
SELECT DATEDIFF(CURRENT_DATE, '2000-03-24') AS spoorthy_days_alive; -- Result: 9689.
SELECT DATEDIFF(CURRENT_DATE, '1998-09-15') AS rashmi_days_alive; -- Result: 10245.
SELECT DATEDIFF(CURRENT_DATE, '2004-04-30') AS pragna_days_alive; -- Result: 8191.


-- ====================== DATE_FORMAT() =========================
-- To format a date value to a specific format, you use the DATE_FORMAT()
-- function. The syntax:
-- DATE_FORMAT(date,format)
-- https://dev.mysql.com/doc/refman/8.4/en/date-and-time-functions.html#function_date-format

SELECT DATE_FORMAT('2000-03-24', '%W, %M %D %Y') AS formatted;
-- Result: 'Friday, March 24th 2000'.

SELECT DATE_FORMAT('2000-03-24 17:45:23', '%W, %M %D %Y - %r') AS formatted;
-- Result: 'Friday, March 24th 2000 - 05:45:23 PM'.


-- ============== UNIX Timestamp / Epoch Time ======================
-- Number of seconds elapsed since January 1st 1970.

-- Unix timestamp for the current datetime:
SELECT UNIX_TIMESTAMP(); -- Result currently: 1791026732.
SELECT FROM_UNIXTIME(1791026732); -- Result: '2026-10-03 16:55:32'.

SELECT UNIX_TIMESTAMP('2000-03-24 17:45:23'); -- Result: 953900123.
SELECT FROM_UNIXTIME(953900123); -- Result: '2000-03-24 17:45:23'.
