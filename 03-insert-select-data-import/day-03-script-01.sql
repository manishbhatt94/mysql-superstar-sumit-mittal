CREATE TABLE order_items (
    order_item_id INT,
    order_item_order_id INT,
    order_item_product_id INT,
    order_item_quantity INT,
    order_item_subtotal FLOAT,
    order_item_product_price FLOAT
);

INSERT INTO order_items VALUES (1, 1, 957, 1, 299.98, 299.98);
INSERT INTO order_items VALUES (2, 1, 958, 1, 113.3, 113.3);
-- Rounding and precision errors with FLOAT type, especially with monetary values
INSERT INTO order_items VALUES (3, 1, 959, 1, 339.9878, 339.9856);

-- Use DECIMAL data type: DECIMAL(P, D), where P = Total no. of digits, and
-- D = No. of digits after the decimal point.
-- DECIMAL is a fixed-precision data type that stores exact values, making it
-- ideal for financial data where precision is crucial

-- Modify the column definition (data-type & constraints) of column(s):
ALTER TABLE order_items
    MODIFY COLUMN order_item_subtotal DECIMAL(20, 4),
    MODIFY COLUMN order_item_product_price DECIMAL(20, 4);

SELECT * FROM order_items;

-- Create `customers` table:
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
-- ALTER TABLE customers RENAME COLUMN customer_password TO customer_phone;

-- Inserting record with all columns (with All Column Insert syntax)
INSERT INTO customers VALUES
(1, 'Richard', 'Hernandez', 'richardhernandez@gmail.com', '9191919191', '6303 Heather Plaza', 'Brownsville', 'TX', '78521');

-- Inserting record with NOT all columns (with All Column Insert syntax)
-- Error Code: 1136. Column count doesn't match value count at row 1
-- INSERT INTO customers VALUES
-- (2,'Mary','Barrett','marybarrett@yahoo.com','8181818181','Littleton','CO','80126');

-- Inserting record with Selective Column Insert syntax:
INSERT INTO customers
(customer_id, customer_fname, customer_lname, customer_email, customer_phone, customer_city, customer_state, customer_zipcode)
VALUES
(2,'Mary','Barrett','marybarrett@yahoo.com','8181818181','Littleton','CO','80126');

-- Inserting record with reordered column values with Selective Column Insert syntax:
INSERT INTO customers
(customer_fname, customer_id, customer_lname, customer_email, customer_phone, customer_city, customer_state, customer_zipcode)
VALUES
('John',3,'Cena','johncena9@aol.net','9876543210','Phoenix','AZ','70524');

SELECT * FROM customers;

-- Selecting a few columns / Renaming columns
SELECT customer_fname AS firstname, customer_id, customer_city, customer_state FROM customers;

-- Truncate (delete all records from) `customers` table
-- to import data from CSV file:
-- TRUNCATE TABLE customers;

-- Get count of rows:
SELECT COUNT(*) FROM customers;

-- Limit the number of records returned:
SELECT * FROM customers LIMIT 5;

-- Ordering by a column in ASC (default sort direction, i.e. can omit ASC) order
SELECT * FROM customers ORDER BY customer_fname ASC LIMIT 10;
SELECT * FROM customers ORDER BY customer_fname LIMIT 10;

-- Ordering by a column in DESC (descending) order
SELECT * FROM customers ORDER BY customer_fname DESC LIMIT 10;

-- Create `employees` table:
CREATE TABLE employees (
    employee_id INT,
    employee_name VARCHAR(100),
    employee_email VARCHAR(100),
    employee_phone VARCHAR(15),
    city VARCHAR(50),
    salary DECIMAL(10, 2)
);

SELECT * FROM employees;

-- Bulk insert 100 records into `employees` table:
INSERT INTO employees
(employee_id, employee_name, employee_email, employee_phone, city, salary) VALUES
(1, 'John Smith', 'john.smith1@gmail.com', '123-555-0001', 'New York', 50000.00),
(2, 'Jane Doe', 'jane.doe2@gmail.com', '123-555-0002', 'Los Angeles', 51000.00),
(3, 'Alice Johnson', 'alice.johnson3@gmail.com', '123-555-0003', 'Chicago', 52000.00),
(4, 'Bob Brown', 'bob.brown4@gmail.com', '123-555-0004', 'Houston', 53000.00),
(5, 'Carol White', 'carol.white5@gmail.com', '123-555-0005', 'Phoenix', 54000.00),
(6, 'Dave Black', 'dave.black6@gmail.com', '123-555-0006', 'Philadelphia', 55000.00),
(7, 'Eva Green', 'eva.green7@gmail.com', '123-555-0007', 'San Antonio', 56000.00),
(8, 'Frank Blue', 'frank.blue8@gmail.com', '123-555-0008', 'San Diego', 57000.00),
(9, 'Grace Yellow', 'grace.yellow9@gmail.com', '123-555-0009', 'Dallas', 58000.00),
(10, 'Hank Pink', 'hank.pink10@gmail.com', '123-555-0010', 'San Jose', 59000.00),
(11, 'Ivy Purple', 'ivy.purple11@gmail.com', '123-555-0011', 'Austin', 60000.00),
(12, 'Jack Orange', 'jack.orange12@gmail.com', '123-555-0012', 'Jacksonville', 61000.00),
(13, 'Kara Red', 'kara.red13@gmail.com', '123-555-0013', 'Fort Worth', 62000.00),
(14, 'Leo Gold', 'leo.gold14@gmail.com', '123-555-0014', 'Columbus', 63000.00),
(15, 'Mia Silver', 'mia.silver15@gmail.com', '123-555-0015', 'Charlotte', 64000.00),
(16, 'Nina Bronze', 'nina.bronze16@gmail.com', '123-555-0016', 'San Francisco', 65000.00),
(17, 'Owen Copper', 'owen.copper17@gmail.com', '123-555-0017', 'Indianapolis', 66000.00),
(18, 'Pia Violet', 'pia.violet18@gmail.com', '123-555-0018', 'Seattle', 67000.00),
(19, 'Quinn Amber', 'quinn.amber19@gmail.com', '123-555-0019', 'Denver', 68000.00),
(20, 'Ray Lime', 'ray.lime20@gmail.com', '123-555-0020', 'Washington', 69000.00),
(21, 'Sue Teal', 'sue.teal21@gmail.com', '123-555-0021', 'Boston', 70000.00),
(22, 'Tom Olive', 'tom.olive22@gmail.com', '123-555-0022', 'El Paso', 71000.00),
(23, 'Uma Cyan', 'uma.cyan23@gmail.com', '123-555-0023', 'Detroit', 72000.00),
(24, 'Vic Magenta', 'vic.magenta24@gmail.com', '123-555-0024', 'Nashville', 73000.00),
(25, 'Wes Chartreuse', 'wes.chartreuse25@gmail.com', '123-555-0025', 'Portland', 74000.00),
(26, 'Xena Maroon', 'xena.maroon26@gmail.com', '123-555-0026', 'Memphis', 75000.00),
(27, 'Yale Indigo', 'yale.indigo27@gmail.com', '123-555-0027', 'Oklahoma City', 76000.00),
(28, 'Zara Turquoise', 'zara.turquoise28@gmail.com', '123-555-0028', 'Las Vegas', 77000.00),
(29, 'Aaron Silver', 'aaron.silver29@gmail.com', '123-555-0029', 'Louisville', 78000.00),
(30, 'Bella Gold', 'bella.gold30@gmail.com', '123-555-0030', 'Baltimore', 79000.00),
(31, 'Cameron Copper', 'cameron.copper31@gmail.com', '123-555-0031', 'Milwaukee', 80000.00),
(32, 'Dana Bronze', 'dana.bronze32@gmail.com', '123-555-0032', 'Albuquerque', 81000.00),
(33, 'Eli Violet', 'eli.violet33@gmail.com', '123-555-0033', 'Tucson', 82000.00),
(34, 'Faith Amber', 'faith.amber34@gmail.com', '123-555-0034', 'Fresno', 83000.00),
(35, 'George Lime', 'george.lime35@gmail.com', '123-555-0035', 'Sacramento', 84000.00),
(36, 'Hannah Teal', 'hannah.teal36@gmail.com', '123-555-0036', 'Kansas City', 85000.00),
(37, 'Ian Olive', 'ian.olive37@gmail.com', '123-555-0037', 'Long Beach', 86000.00),
(38, 'Julia Cyan', 'julia.cyan38@gmail.com', '123-555-0038', 'Mesa', 87000.00),
(39, 'Kyle Magenta', 'kyle.magenta39@gmail.com', '123-555-0039', 'Atlanta', 88000.00),
(40, 'Lily Chartreuse', 'lily.chartreuse40@gmail.com', '123-555-0040', 'Colorado Springs', 89000.00),
(41, 'Max Maroon', 'max.maroon41@gmail.com', '123-555-0041', 'Virginia Beach', 90000.00),
(42, 'Nina Indigo', 'nina.indigo42@gmail.com', '123-555-0042', 'Raleigh', 91000.00),
(43, 'Oscar Turquoise', 'oscar.turquoise43@gmail.com', '123-555-0043', 'Omaha', 92000.00),
(44, 'Paula Silver', 'paula.silver44@gmail.com', '123-555-0044', 'Miami', 93000.00),
(45, 'Quinn Gold', 'quinn.gold45@gmail.com', '123-555-0045', 'Oakland', 94000.00),
(46, 'Rose Copper', 'rose.copper46@gmail.com', '123-555-0046', 'Minneapolis', 95000.00),
(47, 'Sam Bronze', 'sam.bronze47@gmail.com', '123-555-0047', 'Tulsa', 96000.00),
(48, 'Tina Violet', 'tina.violet48@gmail.com', '123-555-0048', 'Arlington', 97000.00),
(49, 'Uma Amber', 'uma.amber49@gmail.com', '123-555-0049', 'New Orleans', 98000.00),
(50, 'Victor Lime', 'victor.lime50@gmail.com', '123-555-0050', 'Wichita', 99000.00),
(51, 'Wendy Teal', 'wendy.teal51@gmail.com', '123-555-0051', 'Cleveland', 50000.00),
(52, 'Xander Olive', 'xander.olive52@gmail.com', '123-555-0052', 'Tampa', 51000.00),
(53, 'Yasmin Cyan', 'yasmin.cyan53@gmail.com', '123-555-0053', 'Bakersfield', 52000.00),
(54, 'Zach Magenta', 'zach.magenta54@gmail.com', '123-555-0054', 'Aurora', 53000.00),
(55, 'Ava Chartreuse', 'ava.chartreuse55@gmail.com', '123-555-0055', 'Anaheim', 54000.00),
(56, 'Blake Maroon', 'blake.maroon56@gmail.com', '123-555-0056', 'Santa Ana', 55000.00),
(57, 'Cora Indigo', 'cora.indigo57@gmail.com', '123-555-0057', 'Corpus Christi', 56000.00),
(58, 'Dylan Turquoise', 'dylan.turquoise58@gmail.com', '123-555-0058', 'Riverside', 57000.00),
(59, 'Ella Silver', 'ella.silver59@gmail.com', '123-555-0059', 'Lexington', 58000.00),
(60, 'Finn Gold', 'finn.gold60@gmail.com', '123-555-0060', 'St. Louis', 59000.00),
(61, 'Grace Copper', 'grace.copper61@gmail.com', '123-555-0061', 'Stockton', 60000.00),
(62, 'Harry Bronze', 'harry.bronze62@gmail.com', '123-555-0062', 'Cincinnati', 61000.00),
(63, 'Ivy Violet', 'ivy.violet63@gmail.com', '123-555-0063', 'Pittsburgh', 62000.00),
(64, 'Jake Amber', 'jake.amber64@gmail.com', '123-555-0064', 'Anchorage', 63000.00),
(65, 'Kay Lime', 'kay.lime65@gmail.com', '123-555-0065', 'Henderson', 64000.00),
(66, 'Leo Teal', 'leo.teal66@gmail.com', '123-555-0066', 'Greensboro', 65000.00),
(67, 'Mila Olive', 'mila.olive67@gmail.com', '123-555-0067', 'Plano', 66000.00),
(68, 'Nate Cyan', 'nate.cyan68@gmail.com', '123-555-0068', 'Newark', 67000.00),
(69, 'Olivia Magenta', 'olivia.magenta69@gmail.com', '123-555-0069', 'Lincoln', 68000.00),
(70, 'Paul Chartreuse', 'paul.chartreuse70@gmail.com', '123-555-0070', 'Orlando', 69000.00),
(71, 'Quincy Maroon', 'quincy.maroon71@gmail.com', '123-555-0071', 'Irvine', 70000.00),
(72, 'Rita Indigo', 'rita.indigo72@gmail.com', '123-555-0072', 'Toledo', 71000.00),
(73, 'Sam Turquoise', 'sam.turquoise73@gmail.com', '123-555-0073', 'Durham', 72000.00),
(74, 'Tara Silver', 'tara.silver74@gmail.com', '123-555-0074', 'Chula Vista', 73000.00),
(75, 'Umar Gold', 'umar.gold75@gmail.com', '123-555-0075', 'Fort Wayne', 74000.00),
(76, 'Vera Copper', 'vera.copper76@gmail.com', '123-555-0076', 'Jersey City', 75000.00),
(77, 'Will Bronze', 'will.bronze77@gmail.com', '123-555-0077', 'St. Petersburg', 76000.00),
(78, 'Xena Violet', 'xena.violet78@gmail.com', '123-555-0078', 'Laredo', 77000.00),
(79, 'Yosef Amber', 'yosef.amber79@gmail.com', '123-555-0079', 'Madison', 78000.00),
(80, 'Zara Lime', 'zara.lime80@gmail.com', '123-555-0080', 'Chandler', 79000.00),
(81, 'Adam Teal', 'adam.teal81@gmail.com', '123-555-0081', 'Buffalo', 80000.00),
(82, 'Bella Olive', 'bella.olive82@gmail.com', '123-555-0082', 'Lubbock', 81000.00),
(83, 'Charlie Cyan', 'charlie.cyan83@gmail.com', '123-555-0083', 'Scottsdale', 82000.00),
(84, 'Dina Magenta', 'dina.magenta84@gmail.com', '123-555-0084', 'Reno', 83000.00),
(85, 'Eli Chartreuse', 'eli.chartreuse85@gmail.com', '123-555-0085', 'Glendale', 84000.00),
(86, 'Fay Maroon', 'fay.maroon86@gmail.com', '123-555-0086', 'Norfolk', 85000.00),
(87, 'Gina Indigo', 'gina.indigo87@gmail.com', '123-555-0087', 'Winston-Salem', 86000.00),
(88, 'Hank Turquoise', 'hank.turquoise88@gmail.com', '123-555-0088', 'North Las Vegas', 87000.00),
(89, 'Ivy Silver', 'ivy.silver89@gmail.com', '123-555-0089', 'Irving', 88000.00),
(90, 'Jack Gold', 'jack.gold90@gmail.com', '123-555-0090', 'Chesapeake', 89000.00),
(91, 'Kate Copper', 'kate.copper91@gmail.com', '123-555-0091', 'Gilbert', 90000.00),
(92, 'Leo Bronze', 'leo.bronze92@gmail.com', '123-555-0092', 'Hialeah', 91000.00),
(93, 'Mia Violet', 'mia.violet93@gmail.com', '123-555-0093', 'Garland', 92000.00),
(94, 'Nina Amber', 'nina.amber94@gmail.com', '123-555-0094', 'Frisco', 93000.00),
(95, 'Owen Lime', 'owen.lime95@gmail.com', '123-555-0095', 'Baton Rouge', 94000.00),
(96, 'Paul Teal', 'paul.teal96@gmail.com', '123-555-0096', 'Fremont', 95000.00),
(97, 'Quinn Olive', 'quinn.olive97@gmail.com', '123-555-0097', 'Richmond', 96000.00),
(98, 'Rose Cyan', 'rose.cyan98@gmail.com', '123-555-0098', 'Boise', 97000.00),
(99, 'Sam Magenta', 'sam.magenta99@gmail.com', '123-555-0099', 'San Bernardino', 98000.00),
(100, 'Tina Chartreuse', 'tina.chartreuse100@gmail.com', '123-555-0100', 'Spokane', 99000.00);
