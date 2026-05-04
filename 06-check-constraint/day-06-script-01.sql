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

-- Valid values of `order_status`:
-- CLOSED, PENDING_PAYMENT, COMPLETE, PROCESSING, ON_HOLD, SUSPECTED_FRAUD, PENDING

-- Insert record with 'CLOSE' as order_status (which is NOT a valid status
-- according to our business):
INSERT INTO orders VALUES
(1, 1, '2013-07-25', 11599, 'CLOSE', 957, 1, 299.98, 299.98);
-- Above INSERT statement works, because we haven't yet added any constraint
-- that validates the value of order_status.

SELECT * FROM orders;

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

-- NOW Test if constraint is working (i.e. validating data)

-- Check if the new constraint works & validates data, by inserting
-- an invalid record:
INSERT INTO orders VALUES
(1, 1, '2013-07-25', 11599, 'CLOSE', 957, 1, 299.98, 299.98);
-- As expected above INSERT fails due to *CHECK constraint violation*
-- and gives below error:
-- Error Code: 3819. Check constraint 'orders_chk_1' is violated.

-- Try to insert a valid record:


SHOW CREATE TABLE orders;
