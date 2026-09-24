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

-- INSERT INTO employees (first_name, last_name, department_id, salary, hire_date, manager_id, email, phone_number, job_title)
-- VALUES
