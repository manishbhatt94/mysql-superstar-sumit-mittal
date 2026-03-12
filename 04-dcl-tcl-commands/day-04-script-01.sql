-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
-- ===================== DCL (Data Control Language) ===================
-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

SELECT * FROM customers;
SELECT * FROM customers LIMIT 10;
SELECT COUNT(*) FROM customers;

-- ################# Defining new VIEW #################

-- Define a view `customers_v` that selects all columns of `customers` table
-- except 3 columns - email, phone & street:
CREATE VIEW customers_v AS
    SELECT 
        customer_id, customer_fname, customer_lname,
        customer_city, customer_state, customer_zipcode
    FROM
        customers;

-- Selects data from the view (Note - VIEW itself doesn't have any data):
SELECT * FROM customers_v LIMIT 5;

-- ################# Create/Drop a MySQL Database User #################

-- Create a MySQL Database User
CREATE USER 'analyticsx'@'localhost' IDENTIFIED BY 'mypasswd123';

-- Drop an existing MySQL Database User:
-- DROP USER 'analyticsx'@'localhost';

-- ################# Login as a MySQL User (non-root) #################

-- Login as this user from another terminal window:
-- mysql -u analyticsx -h localhost -p
-- mysql -u analyticsx -h localhost -p -D retail_db
-- mysql --user analyticsx --host localhost --password --database retail_db
-- mysqlsh -u analyticsx -h localhost -p --sql
-- mysqlsh -u analyticsx -h localhost -p -D retail_db --sql
-- mysqlsh --user analyticsx --host localhost --password --database retail_db --sql

-- OR mysqlsh only - Using Connection String variant:
-- mysqlsh analyticsx@localhost:3306/retail_db --sql

-- ################# Grant/Revoke permissions to/from a MySQL user #################

-- Grant only SELECT priviledge on the `customers_v` VIEW, to this user:
GRANT SELECT ON retail_db.customers_v TO 'analyticsx'@'localhost';

-- Revoke SELECT priviledge on the `customers_v` VIEW, from this user:
REVOKE SELECT ON retail_db.customers_v FROM 'analyticsx'@'localhost';

-- Grant only SELECT priviledge on the `employees` TABLE, to this user:
-- GRANT SELECT ON retail_db.employees TO 'analyticsx'@'localhost';

-- Grant INSERT priviledge on the `employees` TABLE, to this user:
-- GRANT INSERT ON retail_db.employees TO 'analyticsx'@'localhost';

-- Grant SELECT & INSERT priviledge (both) on the `employees` TABLE, to this user:
GRANT SELECT, INSERT ON retail_db.employees TO 'analyticsx'@'localhost';

-- Drop an existing MySQL Database User:
DROP USER 'analyticsx'@'localhost';

-- ################# Get to know `information_schema` #################
-- information_schema - A sort of system catalog which has info about our data

-- How to know whether any particular entry you see in SHOW TABLES;
-- is a TABLE or a VIEW?
-- We switch to `information_schema` database.
USE information_schema;
-- And check the records in table `information_schema.tables` where
-- table_schema column has value `retail_db`:
SELECT * FROM information_schema.tables WHERE table_schema = 'retail_db';
-- Here we have the table_type column, whose value is
-- 'BASE TABLE' if that record refers to a table, or
-- 'VIEW' if that record refers to a view.

-- Info about all columns in all tables stored in MySQL is present
-- under `information_schema.columns` table

-- E.g.: Info about columns of all tables in retail_db database:
SELECT * FROM information_schema.columns WHERE table_schema = 'retail_db';


-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
-- ================= TCL (Transaction Control Language) ===============
-- #=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

USE retail_db;
-- ################# Commit/Rollback #################
-- Switch to Manual Commit Mode (turn off auto-commit option)
SET autocommit = OFF;

SELECT * FROM employees LIMIT 10;
DELETE FROM employees WHERE employee_id = 1; -- DML Operation (a)
-- Rollback after a DML operation
-- (with no commits performed after that particular DML operation)
ROLLBACK;

DELETE FROM employees WHERE employee_id > 95; -- DML Operation (b)
SELECT * FROM employees ORDER BY employee_id DESC LIMIT 10; -- DQL
COMMIT; -- Here, we commit after DML Operation (b). So it can't be rolled-back!

-- Trying to execute ROLLBACK after DML Op (b) has been committed
-- explicitly (above) - This will have no effect.
ROLLBACK;

-- DDL commands are implicitly auto-committed internally.
-- When a DDL command is executed, a commit happens automatically
-- regardless of the autocommit option.

-- Only DML commands can be rolled back.

-- So, we cannot rollback a DDL command, since it is committed always.
DROP TABLE employees; -- DDL Operation - Can't be rolled back.

-- Another thing is: if we run a DDL command, after running a DML.
-- That is:
-- First: DML-Operation-X;
-- Then:  DDL-Operation-A; -- This DDL causes an automatic commit!
-- Now, DML-Op-X can't be rolled back, since the automatic commit
-- which occurred when running DDL-Op-A, also commit all previous
-- non-committed changes, i.e. DML-Op-X also got committed.
-- Therefore it cannot be rolled back now.

-- DML-Op-X:
INSERT INTO employees VALUES (701, 'Goku', 'goku.dbz@gmail.com', '921-192-912', 'Tokyo', 50000.00);

-- DDL-Op-A:
CREATE TABLE anime ( show_name VARCHAR(100), pilot_date date ); -- Committed automatically

-- Can't rollback now:
ROLLBACK; -- No effect!


-- Switch back to Auto Commit Mode (turn auto-commit option back on)
SET autocommit = ON;
