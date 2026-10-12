# MySQL - INNER JOIN

Video Link:
https://www.youtube.com/watch?v=5BVZj4QWPQM

<br>

---

## Setup Data

Refer [joins-practice-database-setup.md](./joins-practice-database-setup.md).

Here we create a new database called `trendytech_joins_practice`, and create the
below six (6) tables within it:

1. categories
2. customers
3. departments
4. order_items
5. orders
6. products


### Seeding Data

Login to MySQL using your user account (don't use `mysqlsh`, just the classic
old `mysql` CLI client):

```bash
mysql --local-infile=1 -u root -p -P 3306 trendytech_joins_practice
```

At the MySQL client shell, follow these steps:

```sql
SET GLOBAL local_infile = ON;

SHOW GLOBAL VARIABLES LIKE 'localinfile'; -- Verify!
-- Must output: variable_name "local_infile" ---> value as "ON"

SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET AUTOCOMMIT = 0;



-- (1) Load `categories` table with seed data:

LOAD DATA LOCAL INFILE
'C:/Users/Manish/Dev/SQL/mysql-superstar/datasets/Extracted-01/categories.csv'
INTO TABLE categories
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'   -- Mac (*nix) CRLF.
IGNORE 1 LINES   -- For CSV Header.
(category_id, category_department_id, category_name);
/* Must output similar to below:
Query OK, 58 rows affected (0.03 sec)
Records: 58  Deleted: 0  Skipped: 0  Warnings: 0
*/

COMMIT;

DESCRIBE categories;
SELECT COUNT(*) FROM categories; -- Returns count : 58 records.
SELECT * FROM categories LIMIT 15;



-- (2) Load `customers` table with seed data:

LOAD DATA LOCAL INFILE
'C:/Users/Manish/Dev/SQL/mysql-superstar/datasets/Extracted-01/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'   -- Mac (*nix) CRLF.
IGNORE 1 LINES   -- For CSV Header.
(customer_id, customer_fname, customer_lname, customer_email, customer_phone, customer_street, customer_city, customer_state, customer_zipcode);
/* Must output similar to below:
Query OK, 12435 rows affected (0.23 sec)
Records: 12435  Deleted: 0  Skipped: 0  Warnings: 0
*/

COMMIT;

DESCRIBE customers;
SELECT COUNT(*) FROM customers; -- Returns count : 12,435 records.
SELECT * FROM customers LIMIT 15;



-- (3) Load `departments` table with seed data:

LOAD DATA LOCAL INFILE
'C:/Users/Manish/Dev/SQL/mysql-superstar/datasets/Extracted-01/departments.csv'
INTO TABLE departments
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'   -- Mac (*nix) CRLF.
IGNORE 1 LINES   -- For CSV Header.
(department_id, department_name);
/* Must output similar to below:
Query OK, 6 rows affected (0.00 sec)
Records: 6  Deleted: 0  Skipped: 0  Warnings: 0
*/

COMMIT;

DESCRIBE departments;
SELECT COUNT(*) FROM departments; -- Returns count : 6 records.
SELECT * FROM departments LIMIT 15;



-- (4) Load `order_items` table with seed data:

LOAD DATA LOCAL INFILE
'C:/Users/Manish/Dev/SQL/mysql-superstar/datasets/Extracted-01/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'   -- Mac (*nix) CRLF.
IGNORE 1 LINES   -- For CSV Header.
(order_item_id, order_item_order_id, product_id, quantity, total_amount, price);
/* Must output similar to below:
Query OK, 172198 rows affected (2.83 sec)
Records: 172198  Deleted: 0  Skipped: 0  Warnings: 0
*/

COMMIT;

DESCRIBE order_items;
SELECT COUNT(*) FROM order_items; -- Returns count : 1,72,198 records.
SELECT * FROM order_items LIMIT 15;



-- (5) Load `orders` table with seed data:

LOAD DATA LOCAL INFILE
'C:/Users/Manish/Dev/SQL/mysql-superstar/datasets/Extracted-01/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'   -- Mac (*nix) CRLF.
IGNORE 1 LINES   -- For CSV Header.
(order_id, order_date, customer_id, order_status);
/* Must output similar to below:
Query OK, 68883 rows affected (1.07 sec)
Records: 68883  Deleted: 0  Skipped: 0  Warnings: 0
*/

COMMIT;

DESCRIBE orders;
SELECT COUNT(*) FROM orders; -- Returns count : 68,883 records.
SELECT * FROM orders LIMIT 15;



-- (6) Load `products` table with seed data:

LOAD DATA LOCAL INFILE
'C:/Users/Manish/Dev/SQL/mysql-superstar/datasets/Extracted-01/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'   -- Mac (*nix) CRLF.
IGNORE 1 LINES   -- For CSV Header.
(product_id, product_category_id, product_name, product_description, product_price, product_image);
/* Must output similar to below:
Query OK, 1345 rows affected (0.04 sec)
Records: 1345  Deleted: 0  Skipped: 0  Warnings: 0
*/

COMMIT;

DESCRIBE products;
SELECT COUNT(*) FROM products; -- Returns count : 1,345 records.
SELECT * FROM products LIMIT 15;



SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;
SET AUTOCOMMIT = 1;

```

