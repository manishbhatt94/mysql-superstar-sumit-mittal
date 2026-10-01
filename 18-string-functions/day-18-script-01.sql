USE retail_db;
SHOW TABLES;

SHOW CREATE TABLE customers;
/*
CREATE TABLE `customers` (
  `customer_id` int NOT NULL,
  `customer_fname` varchar(45) DEFAULT NULL,
  `customer_lname` varchar(45) DEFAULT NULL,
  `customer_email` varchar(45) DEFAULT NULL,
  `customer_phone` varchar(45) DEFAULT NULL,
  `customer_street` varchar(255) DEFAULT NULL,
  `customer_city` varchar(45) DEFAULT NULL,
  `customer_state` varchar(45) DEFAULT NULL,
  `customer_zipcode` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
*/
SELECT * FROM customers;
SELECT COUNT(*) FROM customers; -- Total 12,435 records.

-- ########################## Concatentation #################################

-- ============== CONCAT() Function ====================
-- ===== CONCAT(string1, string2, string3, ...) ======

-- Show customers records with full_name:
SELECT *, CONCAT(customer_fname, ' ', customer_lname) AS full_name FROM customers;

-- Combine address fields into single column by concatentation:
SELECT *,
CONCAT(customer_street, ', ', customer_city, ', ', customer_state, ', ', customer_zipcode)
AS full_address
FROM customers;

-- CONCAT() with any NULL argument(s) - gives a NULL result:
SELECT CONCAT('hello', NULL) AS concat_value; -- Result: NULL.
SELECT CONCAT(NULL, 'world') AS concat_value; -- Result: NULL.
SELECT CONCAT('How ', NULL, 'you') AS concat_value; -- Result: NULL.

-- ==================== CONCAT_WS() Function =========================
-- ===== CONCAT_WS(separator, string1, string2, string3, ...) ======

/* CONCAT_WS stands for Concatenate With Separator. The CONCAT_WS
function concatenates multiple strings into a single string separated
by a specified separator.

If the separator is NULL, the CONCAT_WS will return NULL.

If any of the string arguments are NULL (i.e. string1, string2, string3, ...),
then CONCAT_WS will skip those NULL strings. So, we can use CONCAT_WS
instead of CONCAT to handle NULL values, as we won't get NULL result.
*/
SELECT CONCAT_WS(' ', 'hello', NULL) AS concat_value; -- Result: 'hello'.
SELECT CONCAT_WS(' ', NULL, 'world') AS concat_value; -- Result: 'world'.
SELECT CONCAT_WS(' ', 'How', NULL, 'you') AS concat_value; -- Result: 'How you'.

-- Combine address fields into single column more easily with CONCAT_WS:
SELECT *,
CONCAT_WS(', ', customer_street, customer_city, customer_state, customer_zipcode)
AS full_address
FROM customers;



-- ########################## String Length #################################

-- ============== LENGTH() Function ====================
-- https://www.mysqltutorial.org/mysql-string-functions/mysql-string-length/

SHOW CHARACTER SET; -- Table showing character sets with below columns:
	-- Columns: Charset, Description, Default collation, Maxlen.
    -- (the Maxlen column shows the maximum number of bytes for each character.)

-- To find the character set that the current database uses, you
-- use the @@character_set_database variable:
SELECT @@character_set_database; -- utf8mb4

SHOW CHARACTER SET LIKE 'utf8mb4';
-- # Charset, Description, Default collation, Maxlen
-- 'utf8mb4', 'UTF-8 Unicode', 'utf8mb4_0900_ai_ci', '4'


SELECT LENGTH('Call') AS str_byte_length; -- Result: 4.
SELECT LENGTH('Café') AS str_byte_length; -- Result: 5.

-- CHAR_LENGTH(string) - returns the number of characters in a string
-- regardless of character set used.
-- https://www.mysqltutorial.org/mysql-string-functions/mysql-char_length/
SELECT CHAR_LENGTH('Call') AS str_char_length; -- Result: 4.
SELECT CHAR_LENGTH('Café') AS str_char_length; -- Result: 4.


-- Find length of first name of customers:
SELECT *, LENGTH(customer_fname) AS fname_len FROM customers;

-- Show only customers whose first name length is 8:
SELECT *, LENGTH(customer_fname) AS fname_len FROM customers
	WHERE LENGTH(customer_fname) = 8;

-- Calling LENGTH with a numeric argument, will implicitly type cast
-- the number to a string type and then find its length:
SELECT LENGTH(12345); -- Result: 5. (Integer with 5 digits)
SELECT LENGTH(12.345); -- Result: 6. (Also counts the decimal as one character)

-- Let's say we need to find invalid data records from `customers` table
-- based on that `customer_state` length must be exactly equal to 2,
-- and `customer_zipcode` length must be exactly equal to 5.
-- And below, we find the count of invalid records based on the above
-- validity conditions:
SELECT COUNT(*) AS invalid_records_count FROM customers
WHERE LENGTH(customer_state) != 2 OR LENGTH(customer_zipcode) != 5;
-- Result: 0. (So, zero invalid records)


-- ########################## UPPER / LOWER #################################

SELECT LOWER('Dragon Ball Z');
SELECT UPPER('Dragon Ball Z');


-- ########################## Substring #################################

-- In SQL, string indexes (position) start from 1 (one, and not zero).

-- SUBSTRING(...) and SUBSTR(...) both are aliases for the same function in MySQL.

-- 1) SUBSTRING() Function with position parameter:
--    1.1) MySQL Syntax: SUBSTRING(string, position);
--    1.2) SQL Standard Syntax: SUBSTRING(string FROM position);

SELECT SUBSTRING('HELLO WORLD', 7); -- 'WORLD'
SELECT SUBSTRING('HELLO WORLD' FROM 7); -- 'WORLD'

SELECT SUBSTRING('HELLO WORLD', -2); -- 'LD'
SELECT SUBSTRING('HELLO WORLD' FROM -2); -- 'LD'

SELECT SUBSTRING('HELLO WORLD', -5); -- 'WORLD'
SELECT SUBSTRING('HELLO WORLD' FROM -5); -- 'WORLD'

-- If negative position is out of string's bounds then
-- we get empty string, example:
SELECT SUBSTRING('Raj', -4); -- ''
SELECT SUBSTRING('Raj' FROM -4); -- ''

-- If the position is one (i.e. the 1st starting index - or position
-- of the 1st character), the SUBSTRING() function returns the entire string:
SELECT SUBSTRING('HELLO WORLD', 1); -- 'HELLO WORLD'

-- If the position is zero, the SUBSTRING() function returns an empty string:
SELECT SUBSTRING('HELLO WORLD', 0); -- ''
SELECT SUBSTRING('HELLO WORLD' FROM 0); -- ''

-- 2) SUBSTRING() Function with position & length parameters:
--    2.1) MySQL Syntax: SUBSTRING(string, position, length);
--    2.2) SQL Standard Syntax: SUBSTRING(string FROM position FOR length);

SELECT SUBSTRING('HELLO WORLD', 7, 5); -- 'WORLD'
SELECT SUBSTRING('HELLO WORLD' FROM 7 FOR 5); -- 'WORLD'

SELECT SUBSTRING('HELLO WORLD', -5, 3); -- 'WOR'
SELECT SUBSTRING('HELLO WORLD' FROM -5 FOR 3); -- 'WOR'

-- When negative position is out of string's bounds then
-- we get empty string, example:
SELECT SUBSTRING('Raj', -4, 3); -- ''
SELECT SUBSTRING('Raj' FROM -4 FOR 3); -- ''


-- From `customers` table, show "the last 3 characters" of each person's first
-- name (column: `customer_fname`):
SELECT customer_fname, SUBSTRING(customer_fname, -3) AS fname_end FROM customers;



-- ########################## TRIMMING #################################
-- ######## TRIM(), LTRIM(), RTRIM() #############

SELECT '        SQL    Learners     ' AS str;

SELECT TRIM('        SQL    Learners     ') AS str;
SELECT LTRIM('        SQL    Learners     ') AS str;
SELECT RTRIM('        SQL    Learners     ') AS str;

-- Find all `customers` records in which the `customer_street` column
-- values have leading/trailing spaces:
SELECT * FROM customers
	WHERE customer_street != TRIM(customer_street); -- 97 rows.

SELECT COUNT(*) FROM customers
	WHERE customer_street != TRIM(customer_street); -- Result: 97.



-- ########################## REPLACE #################################
-- Syntax:
-- REPLACE(str,old_string,new_string);

-- The REPLACE function:
-- -> matches & replaces all occurrences,
-- -> is case-sensitive,
-- -> doesn't support regex.

SELECT REPLACE('Details abuot RDBMS', 'abuot', 'about') AS corrected_str;
-- Result: 'Details about RDBMS'

-- REPLACE(str,old_string,new_string) finds all occurrences of "old_string" in
-- "str", and replaces them all by "new_string":
SELECT REPLACE('Heard abuot news in city abuot schools?', 'abuot', 'about')
  AS corrected_str;
-- Result: 'A white-coloured cow looked at the colour of the sky.'

SELECT REPLACE('A white-colored cow looked at the color of the sky.', 'or', 'our')
  AS corrected_str;

-- Note that when searching for text to replace, MySQL uses the case-sensitive
-- match to perform a search for a string to be replaced.
SELECT REPLACE('If you love me & if you respect me, don\'t leave.', 'if', 'when')
  AS corrected_str;
-- Result: 'If you love me & when you respect me, don't leave.'

SELECT COUNT(*) FROM customers WHERE customer_state = 'CA'; -- Result: 2012.
SELECT * FROM customers;

-- Replace `customer_state` values from 'CA' to 'California' in all records of
-- `customers` table:
UPDATE customers SET customer_state = REPLACE(customer_state, 'CA', 'California');
-- Rows affected: 2012.

-- Change it back:
UPDATE customers SET customer_state = REPLACE(customer_state, 'California', 'CA');
-- Rows affected: 2012.



-- ########################## LOCATE / INSTR #################################

-- https://www.mysqltutorial.org/mysql-string-functions/mysql-locate-function/
-- The LOCATE() function returns the position of a substring within a given string.
-- The LOCATE() function has the following syntax:
-- LOCATE(substring, string, position)

SELECT LOCATE('world', 'hello world') AS position; -- Result: 7.

-- Case In-sensitive:
SELECT LOCATE('WORLD', 'hello world') AS position; -- Result: 7.

-- First matching position:
SELECT LOCATE('world', 'hello world & worldly pleasures') AS position; -- Result: 7.

-- No match: Returns 0 (zero).
SELECT LOCATE('world', 'hello officer') AS position; -- Result: 0.

-- If any argument is NULL, the LOCATE() function returns NULL.
SELECT LOCATE(NULL, 'hello world') AS position; -- Result: NULL.
SELECT LOCATE('tion', NULL) AS position; -- Result: NULL.


-- https://www.mysqltutorial.org/mysql-string-functions/mysql-instr/
-- The INSTR function returns the position of the first occurrence of
-- a substring in a string. If the substring is not found in the str,
-- the INSTR function returns zero (0). Syntax:
-- INSTR(str,substr);

SELECT INSTR('hello world', 'world') AS position; -- Result: 7.

-- Case In-sensitive:
SELECT INSTR('hello world', 'WORLD') AS position; -- Result: 7.

-- First matching position:
SELECT INSTR('hello world & worldly pleasures', 'world') AS position; -- Result: 7.

-- No match: Returns 0 (zero).
SELECT INSTR('hello officer', 'world') AS position; -- Result: 0.

-- If any argument is NULL, the INSTR() function returns NULL.
SELECT INSTR('hello world', NULL) AS position; -- Result: NULL.
SELECT INSTR(NULL, 'tion') AS position; -- Result: NULL.

-- Show the 1st word in `customer_street` column of `customers` table:
SELECT customer_id, customer_fname, customer_lname, customer_street,
	SUBSTRING(
		customer_street FROM 1
        FOR  (LOCATE(' ', customer_street) - 1)
	) AS street_num
FROM customers;
