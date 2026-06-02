-- Drop child "orders" table first: To break the Foreign
-- Key constraint's restriction of not allowing parent
-- table dropping:
DROP TABLE IF EXISTS orders;
-- Now, we can drop the parent "customers" table:
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_id INT,
    customer_fname VARCHAR(45),
    customer_lname VARCHAR(45),
    customer_email VARCHAR(45),
    customer_phone VARCHAR(45),
    customer_street VARCHAR(255),
    customer_city VARCHAR(45),
    customer_state VARCHAR(45),
    customer_zipcode VARCHAR(45)
);

-- Now, import data into above table from the 'customers.csv' CSV file in the
-- `datasets/` directory!

/* Steps to import data into MySQL Table from CSV file:
1. Create the MySQL table using CREATE TABLE statement
   having roughly matching data types as in the CSV data.
2. In MySQL Workbench - Left Sidebar - Navigator - SCHEMAS view GUI tree,
   expand your database (`retail_db`) -> Tables, then right click & select
   the "Refresh All" option. Your newly created table should appear now.
3. Right click the "customers" table entry in the Navigator - SCHEMAS
   GUI tree, and select the "Table Data Import Wizard" context menu option.
4. Browse the path to the CSV file (customers.csv) containing the data.
*/

SELECT * FROM customers;
-- Or: TABLE customers;
TABLE customers;

SELECT COUNT(*) FROM customers; -- 12435 records.

-- ##### UPDATE statement ##########

UPDATE customers SET
	customer_street = '7869 Crystal View Villas',
    customer_city = 'Brooklyn',
    customer_state = 'NY'
    WHERE customer_id = 2;

SELECT * FROM customers WHERE customer_id = 2;

-- ===== Demo UPDATE without WHERE clause (Updates ALL records) ======

-- Doing this inside a manual-commit transaction, to allow rolling back:
SET autocommit = OFF;

UPDATE customers SET customer_state = 'NY'; -- Updated all 12435 records!
SELECT * FROM customers LIMIT 10; -- Yes, every record got updated!

ROLLBACK;
SELECT * FROM customers LIMIT 10; -- Successfully rolled-back!

SET autocommit = ON; -- Transaction done!

SELECT * FROM customers LIMIT 10;

-- ####### DELETE statement ###########

DELETE FROM customers WHERE customer_id = 7;

