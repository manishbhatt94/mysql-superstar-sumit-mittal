-- #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#
-- ##################### UNIQUE Constraint #########################
-- #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#

-- ~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~

-- Uses: SQL Standard syntax of 'UNIQUE' (instead of MySQL 'UNIQUE KEY')

DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers` (
    `customer_id` INT,
    `customer_fname` VARCHAR(50),
    `customer_lname` VARCHAR(50),
    `customer_email` VARCHAR(100) UNIQUE, -- Inline: SQL Standard's 'UNIQUE'.
    `customer_phone` VARCHAR(30) UNIQUE, -- Inline: SQL Standard's 'UNIQUE'.
    `customer_street` VARCHAR(255),
    `customer_city` VARCHAR(50),
    `customer_state` VARCHAR(50),
    `customer_zipcode` VARCHAR(10),
    PRIMARY KEY (`customer_id`)
);

SHOW INDEX FROM `customers`; -- Shows `key_name` (i.e. constraint names) as:
-- 'customer_email', 'customer_phone' (<-- Auto-generated constraint names).

SHOW CREATE TABLE `customers`;
/* Output:
CREATE TABLE `customers` (
  `customer_id` int NOT NULL,
  `customer_fname` varchar(50) DEFAULT NULL,
  `customer_lname` varchar(50) DEFAULT NULL,
  `customer_email` varchar(100) DEFAULT NULL,
  `customer_phone` varchar(30) DEFAULT NULL,
  `customer_street` varchar(255) DEFAULT NULL,
  `customer_city` varchar(50) DEFAULT NULL,
  `customer_state` varchar(50) DEFAULT NULL,
  `customer_zipcode` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `customer_email` (`customer_email`),
  UNIQUE KEY `customer_phone` (`customer_phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
*/

-- Dropping using auto-generated constraint name:

-- A) Using DROP INDEX:
DROP INDEX `customer_email` ON `customers`;
-- OR: B) Using ALTER TABLE...DROP INDEX:
ALTER TABLE `customers` DROP INDEX `customer_email`;
-- OR: C) Using ALTER TABLE...DROP CONSTRAINT:
ALTER TABLE `customers` DROP CONSTRAINT `customer_email`;

-- Adding UNIQUE Constraint again, using ALTER:

-- A) Custom Named Unique Constraint:
ALTER TABLE `customers` ADD CONSTRAINT `UC_customer_email` UNIQUE (`customer_email`);
ALTER TABLE `customers` DROP CONSTRAINT `UC_customer_email`;
-- B) Un-named (auto-named) Unique Constraint:
ALTER TABLE `customers` ADD UNIQUE (`customer_email`);
ALTER TABLE `customers` DROP CONSTRAINT `customer_email`;

-- ~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~

-- Uses: MySQL-specific syntax of 'UNIQUE KEY' (instead of just 'UNIQUE')

DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers` (
    `customer_id` INT,
    `customer_fname` VARCHAR(50),
    `customer_lname` VARCHAR(50),
    `customer_email` VARCHAR(100) UNIQUE KEY, -- Inline: MySQL's 'UNIQUE KEY'.
    `customer_phone` VARCHAR(30) UNIQUE KEY, -- Inline: MySQL's 'UNIQUE KEY'.
    `customer_street` VARCHAR(255),
    `customer_city` VARCHAR(50),
    `customer_state` VARCHAR(50),
    `customer_zipcode` VARCHAR(10),
    PRIMARY KEY (`customer_id`)
);
SHOW INDEX FROM `customers`;
SHOW CREATE TABLE `customers`;

DROP INDEX `customer_email` ON `customers`;
ALTER TABLE `customers` ADD UNIQUE KEY `UC_email` (`customer_email`);
SHOW INDEX FROM `customers`;

DROP INDEX `customer_phone` ON `customers`;
ALTER TABLE `customers` ADD UNIQUE KEY `UC_phone` (`customer_phone`);
SHOW INDEX FROM `customers`;

-- ~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~


DROP TABLE IF EXISTS `customers`;
/* NOTE:
	Thess inline syntax variants:
    CREATE TABLE table_name (
		col_name <Column-Data-Type> CONSTRAINT <Constrain-Name> UNIQUE,
        col_name <Column-Data-Type> CONSTRAINT <Constrain-Name> UNIQUE KEY,
    );
    These both above are errors and invalid syntax. Such syntax is not
    allowed for Unique Constraints.
    
    Workbench error tooltip:
    ```
    "UNIQUE" is not valid at this position, expecting CHECK
    ```
    
    Error on running:
    Error Code: 1064. You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'UNIQUE, -- Inline with constraint name.     `customer_phone` VARCHAR(30) CONSTRA' at line 5
*/
-- CREATE TABLE `customers` (
--     `customer_id` INT,
--     `customer_fname` VARCHAR(50),
--     `customer_lname` VARCHAR(50),
--     `customer_email` VARCHAR(100) CONSTRAINT UC_email UNIQUE, -- Inline with constraint name.
--     `customer_phone` VARCHAR(30) CONSTRAINT UC_phone UNIQUE, -- Inline with constraint name.
--     `customer_street` VARCHAR(255),
--     `customer_city` VARCHAR(50),
--     `customer_state` VARCHAR(50),
--     `customer_zipcode` VARCHAR(10),
--     PRIMARY KEY (`customer_id`)
-- );
SHOW INDEX FROM `customers`;
SHOW CREATE TABLE `customers`;

-- ~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~


DROP TABLE IF EXISTS `customers`;
/* NOTE:
	Thess inline syntax variants:
    CREATE TABLE table_name (
		col_name <Column-Data-Type> CONSTRAINT <Constrain-Name> UNIQUE,
        col_name <Column-Data-Type> CONSTRAINT <Constrain-Name> UNIQUE KEY,
    );
    These both above are errors and invalid syntax. Such syntax is not
    allowed for Unique Constraints.
    
    Workbench error tooltip:
    ```
    "UNIQUE" is not valid at this position, expecting CHECK
    ```
    
    Error on running:
    Error Code: 1064. You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'UNIQUE KEY, -- Inline with constraint name.     `customer_phone` VARCHAR(30) CON' at line 5

*/
-- CREATE TABLE `customers` (
--     `customer_id` INT,
--     `customer_fname` VARCHAR(50),
--     `customer_lname` VARCHAR(50),
--     `customer_email` VARCHAR(100) CONSTRAINT UC_email UNIQUE KEY, -- Inline with constraint name.
--     `customer_phone` VARCHAR(30) CONSTRAINT UC_phone UNIQUE KEY, -- Inline with constraint name.
--     `customer_street` VARCHAR(255),
--     `customer_city` VARCHAR(50),
--     `customer_state` VARCHAR(50),
--     `customer_zipcode` VARCHAR(10),
--     PRIMARY KEY (`customer_id`)
-- );
SHOW INDEX FROM `customers`;
SHOW CREATE TABLE `customers`;

-- ~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~


DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers` (
    `customer_id` INT,
    `customer_fname` VARCHAR(50),
    `customer_lname` VARCHAR(50),
    `customer_email` VARCHAR(100),
    `customer_phone` VARCHAR(30),
    `customer_street` VARCHAR(255),
    `customer_city` VARCHAR(50),
    `customer_state` VARCHAR(50),
    `customer_zipcode` VARCHAR(10),
    PRIMARY KEY (`customer_id`),
    UNIQUE (`customer_email`),
    UNIQUE (`customer_phone`)
);
SHOW INDEX FROM `customers`;
SHOW CREATE TABLE `customers`;

-- ~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~


DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers` (
    `customer_id` INT,
    `customer_fname` VARCHAR(50),
    `customer_lname` VARCHAR(50),
    `customer_email` VARCHAR(100),
    `customer_phone` VARCHAR(30),
    `customer_street` VARCHAR(255),
    `customer_city` VARCHAR(50),
    `customer_state` VARCHAR(50),
    `customer_zipcode` VARCHAR(10),
    PRIMARY KEY (`customer_id`),
    UNIQUE KEY (`customer_email`),
    UNIQUE KEY (`customer_phone`)
);
SHOW INDEX FROM `customers`;
SHOW CREATE TABLE `customers`;

-- ~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~


DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers` (
    `customer_id` INT,
    `customer_fname` VARCHAR(50),
    `customer_lname` VARCHAR(50),
    `customer_email` VARCHAR(100),
    `customer_phone` VARCHAR(30),
    `customer_street` VARCHAR(255),
    `customer_city` VARCHAR(50),
    `customer_state` VARCHAR(50),
    `customer_zipcode` VARCHAR(10),
    PRIMARY KEY (`customer_id`),
    CONSTRAINT `UC_email` UNIQUE (`customer_email`),
    CONSTRAINT `UC_phone` UNIQUE (`customer_phone`)
);

SHOW INDEX FROM `customers`; -- Shows `key_name` (i.e. constraint names) as:
-- 'UC_email', 'UC_phone' (<-- Custom constraint names).

SHOW CREATE TABLE `customers`;
/* Output:
CREATE TABLE `customers` (
  `customer_id` int NOT NULL,
  `customer_fname` varchar(50) DEFAULT NULL,
  `customer_lname` varchar(50) DEFAULT NULL,
  `customer_email` varchar(100) DEFAULT NULL,
  `customer_phone` varchar(30) DEFAULT NULL,
  `customer_street` varchar(255) DEFAULT NULL,
  `customer_city` varchar(50) DEFAULT NULL,
  `customer_state` varchar(50) DEFAULT NULL,
  `customer_zipcode` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `UC_email` (`customer_email`),
  UNIQUE KEY `UC_phone` (`customer_phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
*/

-- ~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~


DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers` (
    `customer_id` INT,
    `customer_fname` VARCHAR(50),
    `customer_lname` VARCHAR(50),
    `customer_email` VARCHAR(100),
    `customer_phone` VARCHAR(30),
    `customer_street` VARCHAR(255),
    `customer_city` VARCHAR(50),
    `customer_state` VARCHAR(50),
    `customer_zipcode` VARCHAR(10),
    PRIMARY KEY (`customer_id`),
    CONSTRAINT `UC_email` UNIQUE KEY (`customer_email`),
    CONSTRAINT `UC_phone` UNIQUE KEY (`customer_phone`)
);

SHOW INDEX FROM `customers`; -- Shows `key_name` (i.e. constraint names) as:
-- 'UC_email', 'UC_phone' (<-- Custom constraint names).

SHOW CREATE TABLE `customers`;
/* Output:
CREATE TABLE `customers` (
  `customer_id` int NOT NULL,
  `customer_fname` varchar(50) DEFAULT NULL,
  `customer_lname` varchar(50) DEFAULT NULL,
  `customer_email` varchar(100) DEFAULT NULL,
  `customer_phone` varchar(30) DEFAULT NULL,
  `customer_street` varchar(255) DEFAULT NULL,
  `customer_city` varchar(50) DEFAULT NULL,
  `customer_state` varchar(50) DEFAULT NULL,
  `customer_zipcode` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `UC_email` (`customer_email`),
  UNIQUE KEY `UC_phone` (`customer_phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
*/

-- ~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~~-~-~-~-~-~-~-~

-- ########## VERIFY IF UNIQUENESS IS ENFORCED ##############

DESCRIBE `customers`;

INSERT INTO customers VALUES
    (1, 'Richard', 'Hernandez', 'richardhernandez@gmail.com', '9998887766',
        '6303 Heather Plaza', 'Brownsville', 'TX', '78521');
-- INSERT: Done!

SELECT * FROM customers;

INSERT INTO customers VALUES
    (2, 'Mary', 'Barrett', 'marybarrett@yahoo.com', '9998887766',
        '9526 New Commercial Avenue', 'Littleton', 'CO', '80126');
-- Has duplicate value '9998887766' for UNIQUE Constraint column `customer_phone`.
-- INSERT: Fails with error:
-- Error Code: 1062. Duplicate entry '9998887766' for key 'customers.UC_phone'


-- ############# DEMO THAT MULTIPLE NULLS ARE ALLOWED ################

INSERT INTO customers VALUES
    (2, 'Mary', 'Barrett', 'marybarrett@yahoo.com', '794-554-1917',
        '9526 New Commercial Avenue', 'Littleton', 'Colorado', '80126'),
	-- Three records below have `customer_phone` as NULL:
	(3, 'Jason', 'Statham', 'jason.s@reddif.com', NULL,
        '9790 Eliza Wells', 'South Ezekielchester', 'Maryland', '58436'),
	(4, 'Nina', 'Volkman', 'volkman23nina@hotmail.com', NULL,
        '7944 Keeling Coves', 'Wisokyfield', 'Kansas', '65888'),
	(5, 'Audrey', 'Hyatt', 'audry90hytt@msn.com', NULL,
        '121 Shad Point', 'Huntington Park', 'Nebraska', '62316'),
	-- Three records below have `customer_email` as NULL:
	(6, 'Frances', 'Leannon', NULL, '(807) 869-8032',
        '1076 Olson Roads', 'North Antwon', 'Minnesota', '90292'),
	(7, 'Raul', 'Williamson', NULL, '1-971-305-8770',
        '1069 Talia Ford', 'Kileyfurt', 'Delaware', '52621'),
	(8, 'Julie', 'King', NULL, '(334) 730-2595',
        '1750 Connelly Manor', 'Tonawanda', 'Nevada', '41883');
-- All records inserted!

SELECT * FROM customers;
