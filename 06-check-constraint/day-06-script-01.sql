-- ################# Cleanup #################

-- Start with a clean slate:
DROP DATABASE retail_db;
CREATE DATABASE retail_db;
USE retail_db;

-- Create `orders` table:
CREATE TABLE orders (
    order_id INT,
    order_item_id INT,
    order_date DATE,
    customer_id INT,
    order_status VARCHAR(30),
    product_id INT,
    quantity INT,
    product_price FLOAT,
    total_price FLOAT
);

-- ################# Insert Invalid Record #################

-- Valid values of `order_status`:
-- CLOSED, PENDING_PAYMENT, COMPLETE, PROCESSING, ON_HOLD, SUSPECTED_FRAUD, PENDING

-- Insert record with 'CLOSE' as order_status (which is NOT a valid status
-- according to our business):
INSERT INTO orders VALUES
(1, 1, '2013-07-25', 11599, 'CLOSE', 957, 1, 299.98, 299.98);
-- Above INSERT statement works, because we haven't yet added any constraint
-- that validates the value of order_status.

SELECT * FROM orders;

-- ################# Add (un-named) Constraint #################

ALTER TABLE orders
	ADD CHECK(order_status IN
		('CLOSED', 'PENDING_PAYMENT', 'COMPLETE', 'PROCESSING',
        'ON_HOLD', 'SUSPECTED_FRAUD', 'PENDING')
	);
-- Above statement to add the constraint FAILS - since existing data in the
-- table has record(s) that are invalid according to this new constraint we're
-- trying to add.
-- Error Code: 3819. Check constraint 'orders_chk_1' is violated.

-- Delete invalid record(s) first - before adding the constraint:
DELETE FROM orders WHERE order_status = 'CLOSE';

-- Try to add the constraint again now, after deleting / rectifying
-- the invalid records:
ALTER TABLE orders
    ADD CHECK(order_status IN
        ('CLOSED', 'PENDING_PAYMENT', 'COMPLETE', 'PROCESSING',
        'ON_HOLD', 'SUSPECTED_FRAUD', 'PENDING')
    );
-- This works now!

-- ################# Test if constraint works #################

-- NOW Test if constraint is working (i.e. validating data)

-- Check if the new constraint works & validates data, by inserting
-- an invalid record:
INSERT INTO orders VALUES
(1, 1, '2013-07-25', 11599, 'CLOSE', 957, 1, 299.98, 299.98);
-- As expected above INSERT fails due to *CHECK constraint violation*
-- and gives below error:
-- Error Code: 3819. Check constraint 'orders_chk_1' is violated.

-- Try to insert a valid record:
INSERT INTO orders VALUES
(1, 1, '2013-07-25', 11599, 'CLOSED', 957, 1, 299.98, 299.98);

-- ######### Find constraint name (from SHOW CREATE TABLE) #############

SHOW CREATE TABLE orders;

/*
CREATE TABLE `orders` (
    `order_id` int DEFAULT NULL,
    `order_item_id` int DEFAULT NULL,
    `order_date` date DEFAULT NULL,
    `customer_id` int DEFAULT NULL,
    `order_status` varchar(30) DEFAULT NULL,
    `product_id` int DEFAULT NULL,
    `quantity` int DEFAULT NULL,
    `product_price` float DEFAULT NULL,
    `total_price` float DEFAULT NULL,
    CONSTRAINT `orders_chk_1` CHECK (
        (`order_status` in (_utf8mb4'CLOSED', _utf8mb4'PENDING_PAYMENT',
            _utf8mb4'COMPLETE', _utf8mb4'PROCESSING', _utf8mb4'ON_HOLD',
            _utf8mb4'SUSPECTED_FRAUD', _utf8mb4'PENDING')
        )
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
*/

-- ################ Column-Level Constraints ###############
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT, -- Primary Key
    username VARCHAR(50) NOT NULL UNIQUE, -- Not Null & Unique

    status VARCHAR(10) DEFAULT 'active', -- Default value

    -- Below we define an UN-NAMED constraint for the `age` column:
    -- (Since we don't use the CONSTRAINT keyword)
    age INT CHECK (age >= 18), -- Check constraint (MySQL 8.0.16+)

    -- Below we define a NAMED constraint called `users_chk_wallet_balance`
    -- for the `wallet_balance` column:
    -- (Note: usage of CONSTRAINT keyword)
    wallet_balance INT CONSTRAINT users_chk_wallet_balance
        CHECK (wallet_balance >= 0)
);

SHOW CREATE TABLE users;

DROP TABLE orders;

-- Specify constraints on two columns: `order_status` & `quantity`:
CREATE TABLE orders (
    order_id INT,
    order_item_id INT,
    order_date DATE,
    customer_id INT,
    order_status VARCHAR(30) CHECK (
        order_status IN ('CLOSED', 'PENDING_PAYMENT',
                'COMPLETE', 'PROCESSING', 'ON_HOLD',
                'SUSPECTED_FRAUD', 'PENDING'
            )
        ),
    product_id INT,
    quantity INT CONSTRAINT orders_chk_quantity CHECK (quantity <= 50),
    product_price FLOAT,
    total_price FLOAT
);
SHOW CREATE TABLE orders;

-- Test if constraint works:
INSERT INTO orders VALUES (1, 1, '2013-07-25', 11599, 'CLOSED', 957, 52,
299.98, null);
-- Error Code: 3819. Check constraint 'orders_chk_quantity' is violated.

-- ################# Drop Constraint #################

-- Drop the CHECK constraint called `orders_chk_1` from the `orders` table:
ALTER TABLE orders
DROP CHECK orders_chk_1;

-- ################# Add (named) constraint #################

-- Add the same constraint back again to the "orders.order_status" column,
-- but give the constraint the name "CHK_OrderStatus":
ALTER TABLE orders
    ADD CONSTRAINT CHK_OrderStatus CHECK(order_status IN
        ('CLOSED', 'PENDING_PAYMENT', 'COMPLETE', 'PROCESSING',
        'ON_HOLD', 'SUSPECTED_FRAUD', 'PENDING')
    );

-- ############# Find constraint name/info in information_schema ##############

-- Connect to `information_schema` database:
USE information_schema;
SELECT database();

-- TIP: We can use LIKE Operator with `SHOW TABLES`, `SHOW DATABASES` etc. commands:

SHOW TABLES LIKE '%constraints';
SHOW FULL TABLES LIKE '%constraints'; -- SHOW FULL TABLES; gives extra "table_type"
-- info (e.g. SYSTEM VIEW, BASE TABLE etc.) in addition to just Table Name.

-- OR: In order to get the same (& a bit more) info as with
-- SHOW TABLES LIKE '%constraints';
-- We can use the "information_schema.tables" like this:
DESCRIBE information_schema.tables;
SELECT table_name FROM information_schema.tables
	WHERE table_schema = 'information_schema'
    AND table_name LIKE '%constraints';

-- There are 3 tables in information_schema which store info about various
-- constraints defined in this MySQL instance's database tables:
-- 1. Table `information_schema.check_constraints`
-- 2. Table `information_schema.referential_constraints`
-- 3. Table `information_schema.table_constraints`
SELECT * FROM information_schema.check_constraints;
SELECT * FROM information_schema.referential_constraints;
SELECT * FROM information_schema.table_constraints;

-- ################ MORE EXAMPLES ####################

-- ======= CHECK: Age is Positive Integer =======
CREATE TABLE persons (
    person_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    
    -- Constraint specified as a Column-Level constraint:
    age INT CHECK (age > 0)
);

-- Test constraint with attempting to insert invalid record (age = -5):
INSERT INTO persons (person_id, first_name, last_name, age)
VALUES (1, 'Raj', 'Sharma', -5);
-- Error Code: 3819. Check constraint 'persons_chk_1' is violated.

-- ======= CHECK: Email pattern is rougly correct =======
CREATE TABLE customers (
    user_id INT,
    username VARCHAR(50),
    email VARCHAR(100),
    CHECK (email LIKE '%@%.%')
);
-- NOTE: How we used the LIKE Operator inside the CHECK Clause.

-- Test constraint with valid record:
INSERT INTO customers (user_id, username, email)
VALUES (1, 'sumitm', 'sumit@trendytech.in');
-- Works fine: Record inserted!

-- Test constraint with invalid record:
INSERT INTO customers (user_id, username, email)
VALUES (2, 'manishb', 'manish@california');
-- Error Code: 3819. Check constraint 'customers_chk_1' is violated.

-- ========== CHECK: Compare dates in CHECK Constraint =============
CREATE TABLE projects (
    project_id INT,
    project_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    CONSTRAINT projects_chk_enddate_startdate CHECK (end_date > start_date)
);
SHOW CREATE TABLE projects;

INSERT INTO projects (project_id, project_name, start_date, end_date)
VALUES (1, 'Project Alpha', '2023-01-01', '2023-12-31');

INSERT INTO projects (project_id, project_name, start_date, end_date)
VALUES (1, 'Project Beta', '2023-01-01', '2022-12-31');
-- Error Code: 3819. Check constraint 'projects_chk_enddate_startdate' is violated.
