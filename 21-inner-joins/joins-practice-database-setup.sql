CREATE DATABASE trendytech_joins_practice;
USE trendytech_joins_practice;
SHOW TABLES;

/* Tables:

1. categories
2. customers
3. departments
4. order_items
5. orders
6. products

*/

DROP TABLE IF EXISTS `categories`;
CREATE TABLE IF NOT EXISTS `categories` (
	`category_id` INT,
	`category_department_id` INT,
	`category_name` VARCHAR(45)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `customers`;
CREATE TABLE IF NOT EXISTS `customers` (
	`customer_id` INT NOT NULL,
	`customer_fname` VARCHAR(45) DEFAULT NULL,
	`customer_lname` VARCHAR(45) DEFAULT NULL,
	`customer_email` VARCHAR(45) DEFAULT NULL,
	`customer_phone` VARCHAR(45) DEFAULT NULL,
	`customer_street` VARCHAR(255) DEFAULT NULL,
	`customer_city` VARCHAR(45) DEFAULT NULL,
	`customer_state` VARCHAR(45) DEFAULT NULL,
	`customer_zipcode` VARCHAR(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `departments`;
CREATE TABLE IF NOT EXISTS `departments` (
	`department_id` INT,
	`department_name` VARCHAR(45)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `order_items`;
CREATE TABLE IF NOT EXISTS `order_items` (
	-- order_item_id,order_item_order_id,product_id,quantity,total_amount,price
	`order_item_id` INT,
	`order_item_order_id` INT,
	`product_id` INT,
	`quantity` INT,
	`total_amount` DECIMAL(10, 2),
	`price` DECIMAL(10, 2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*
CREATE TABLE `orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `order_date` date NOT NULL,
  `customer_id` int DEFAULT NULL,
  `order_status` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  KEY `fk_customer_id_idx` (`customer_id`),
  CONSTRAINT `fk_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=68884 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
*/
DROP TABLE IF EXISTS `orders`;
CREATE TABLE IF NOT EXISTS `orders` (
	-- order_id,order_date,customer_id,order_status
	`order_id` INT,
	`order_date` DATE DEFAULT NULL,
	`customer_id` INT DEFAULT NULL,
	`order_status` VARCHAR(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS `products`;
CREATE TABLE IF NOT EXISTS `products` (
	-- Product_id,Product_category_id,Product_name,product_description,product_price,product_image
	`product_id` INT,
	`product_category_id` INT,
	`product_name` VARCHAR(80),
	`product_description` VARCHAR(120),
	`product_price` DECIMAL(10, 2),
	`product_image` VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



TABLE categories;
TABLE customers;
TABLE departments;
TABLE order_items;
TABLE orders;
TABLE products;



-- #############################################################################
-- ######################    Add Constraints    ################################
-- #############################################################################

-- AFTER data import is done.

ALTER TABLE categories
  MODIFY category_id INT NOT NULL AUTO_INCREMENT,
  ADD PRIMARY KEY (category_id);
/* Output:
Query OK, 58 rows affected (0.07 sec)
Records: 58  Duplicates: 0  Warnings: 0
*/

ALTER TABLE customers
  MODIFY customer_id INT NOT NULL AUTO_INCREMENT,
  ADD PRIMARY KEY (customer_id);
/* Output:
Query OK, 12435 rows affected (0.38 sec)
Records: 12435  Duplicates: 0  Warnings: 0
*/

ALTER TABLE departments
  MODIFY department_id INT NOT NULL AUTO_INCREMENT,
  ADD PRIMARY KEY (department_id);
/* Output:
Query OK, 6 rows affected (0.06 sec)
Records: 6  Duplicates: 0  Warnings: 0
*/

ALTER TABLE order_items
  MODIFY order_item_id INT NOT NULL AUTO_INCREMENT,
  ADD PRIMARY KEY (order_item_id);
/* Output:
Query OK, 172198 rows affected (1.68 sec)
Records: 172198  Duplicates: 0  Warnings: 0
*/

ALTER TABLE orders
  MODIFY order_id INT NOT NULL AUTO_INCREMENT,
  ADD PRIMARY KEY (order_id);
/* Output:
Query OK, 68883 rows affected (0.60 sec)
Records: 68883  Duplicates: 0  Warnings: 0
*/

ALTER TABLE products
  MODIFY product_id INT NOT NULL AUTO_INCREMENT,
  ADD PRIMARY KEY (product_id);
/* Output:
Query OK, 1345 rows affected (0.09 sec)
Records: 1345  Duplicates: 0  Warnings: 0
*/


-- #############################################################################
-- ######################    Add Foreign Key Constraints    ####################
-- #############################################################################

-- 1. categories.category_department_id  →  departments.department_id
ALTER TABLE categories
  ADD CONSTRAINT fk_categories_department
    FOREIGN KEY (category_department_id)
    REFERENCES departments (department_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- 2. products.product_category_id  →  categories.category_id
ALTER TABLE products
  ADD CONSTRAINT fk_products_category
    FOREIGN KEY (product_category_id)
    REFERENCES categories (category_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- 3. orders.customer_id  →  customers.customer_id
ALTER TABLE orders
  ADD CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id)
    REFERENCES customers (customer_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- 4. order_items.order_item_order_id  →  orders.order_id
ALTER TABLE order_items
  ADD CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_item_order_id)
    REFERENCES orders (order_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- 5. order_items.product_id  →  products.product_id
ALTER TABLE order_items
  ADD CONSTRAINT fk_order_items_product
    FOREIGN KEY (product_id)
    REFERENCES products (product_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;



-- See all foreign keys that now exist
SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'trendytech_joins_practice'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;
