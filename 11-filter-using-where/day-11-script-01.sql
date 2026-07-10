USE retail_db;

-- Existing table (from Foreign Key lecture):
SHOW CREATE TABLE employees;
/*
CREATE TABLE `employees` (
  `employee_id` int NOT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `manager_id` int DEFAULT NULL,
  PRIMARY KEY (`employee_id`),
  KEY `employees_fk_manager_id` (`manager_id`),
  CONSTRAINT `employees_fk_manager_id` FOREIGN KEY (`manager_id`) REFERENCES `employees` (`employee_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
*/

-- =========== TABLE SETUP / SEED DATA =============

DROP TABLE IF EXISTS employees;
CREATE TABLE IF NOT EXISTS employees (
  employee_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  department_id INT,
  salary DECIMAL(10, 2),
  hire_date DATE,
  manager_id INT,
  email VARCHAR(100),
  phone_number VARCHAR(20),
  job_title VARCHAR(50)
);

INSERT INTO employees (first_name, last_name, department_id, salary, hire_date, manager_id, email, phone_number, job_title)
VALUES
('John', 'Doe', 1, 60000, '2018-01-15', NULL, 'john.doe@example.com', '555-1234', 'Manager'),
('Jane', 'Smith', 2, 50000, '2019-03-22', 1, 'jane.smith@example.com', '555-5678', 'Developer'),
('Michael', 'Johnson', 1, 45000, '2020-06-11', 1, 'michael.johnson@example.com', '555-8765', 'Analyst'),
('Emily', 'Davis', 3, 55000, '2017-09-30', NULL, 'emily.davis@example.com', '555-3456', 'Sales'),
('Daniel', 'Wilson', 3, 40000, '2018-11-10', 4, 'daniel.wilson@example.com', '555-6543', 'Sales Representative'),
('Sophia', 'Martinez', 2, 47000, '2021-01-25', 2, 'sophia.martinez@example.com', '555-7890', 'Developer'),
('James', 'Brown', 1, 38000, '2020-04-18', 1, 'james.brown@example.com', '555-1239', 'Support'),
('Olivia', 'Jones', 2, 62000, '2019-07-21', 1, 'olivia.jones@example.com', '555-4321', 'Lead Developer'),
('William', 'Garcia', 3, 52000, '2018-12-01', NULL, 'william.garcia@example.com', '555-5670', 'Sales Manager'),
('Isabella', 'Miller', 2, 48000, '2020-08-15', 2, 'isabella.miller@example.com', '555-6789', 'QA Engineer'),
('Alex', 'White', 1, 61000, '2020-11-23', 1, 'alex.white@example.com', '555-2345', 'HR Specialist'),
('Liam', 'Lee', 2, 55000, '2017-05-19', 8, 'liam.lee@example.com', '555-3457', 'Developer'),
('Emma', 'Clark', 3, 58000, '2021-03-14', 4, 'emma.clark@example.com', '555-4568', 'Sales Executive'),
('Noah', 'Lopez', 1, 43000, '2019-12-10', 1, 'noah.lopez@example.com', '555-5679', 'HR Assistant'),
('Ava', 'Gonzalez', 2, 49000, '2018-07-25', 2, 'ava.gonzalez@example.com', '555-6780', 'QA Analyst'),
('Mason', 'Harris', 3, 61000, '2016-08-29', 4, 'mason.harris@example.com', '555-7891', 'Senior Sales Manager'),
('Ethan', 'Walker', 1, 42000, '2021-02-10', 1, 'ethan.walker@example.com', '555-8901', 'HR Coordinator'),
('Mia', 'Young', 2, 57000, '2018-09-15', 8, 'mia.young@example.com', '555-9012', 'Developer'),
('Logan', 'Hall', 3, 45000, '2020-05-17', 4, 'logan.hall@example.com', '555-1230', 'Sales Associate'),
('Charlotte', 'Allen', 2, 53000, '2019-01-20', 8, 'charlotte.allen@example.com', '555-2341', 'UI/UX Designer'),
('Benjamin', 'King', 1, 47000, '2017-11-22', 1, 'benjamin.king@example.com', '555-3452', 'HR Manager'),
('Amelia', 'Wright', 2, 50000, '2020-06-13', 8, 'amelia.wright@example.com', '555-4563', 'Software Tester'),
('Lucas', 'Scott', 3, 49000, '2016-10-30', 4, 'lucas.scott@example.com', '555-5674', 'Sales Coordinator'),
('Ella', 'Green', 1, 53000, '2018-02-14', 1, 'ella.green@example.com', '555-6785', 'HR Specialist'),
('Aiden', 'Adams', 2, 51000, '2019-08-26', 8, 'aiden.adams@example.com', '555-7896', 'Backend Developer'),
('Grace', 'Baker', 3, 52000, '2021-04-21', 4, 'grace.baker@example.com', '555-8907', 'Sales Analyst'),
('Oliver', 'Nelson', 1, 45000, '2020-01-19', 1, 'oliver.nelson@example.com', '555-9018', 'HR Associate'),
('Avery', 'Carter', 2, 60000, '2017-12-11', 8, 'avery.carter@example.com', '555-1239', 'Front-End Developer'),
('Matthew', 'Mitchell', 3, 48000, '2018-06-07', 4, 'matthew.mitchell@example.com', '555-2340', 'Sales Representative'),
('Harper', 'Perez', 2, 56000, '2019-03-28', 8, 'harper.perez@example.com', '555-3451', 'Quality Assurance');

SELECT * FROM employees;

-- Count of records:
SELECT COUNT(*) FROM employees; -- 30

-- Get all employee records where "first_name" is 'John':
SELECT * FROM employees WHERE first_name = 'John';

-- Get all employee records where "salary" is greater than 60000:
SELECT * FROM employees WHERE salary > 60000;
-- And, count of all such records:
SELECT COUNT(*) FROM employees WHERE salary > 60000;

-- Get all employee records whose "first_name" appears after 'John'
-- in alphabetical order:
SELECT * FROM employees WHERE first_name > 'John';

-- Get all employee records where "department_id" is 3:
SELECT * FROM employees WHERE department_id = 3;

-- Get all employees who have been hired after the year 2019:
-- (i.e. hired in the year 2020 or later)
SELECT * FROM employees WHERE hire_date >= '2019-12-31';

-- Get all employees whose "department_id" = 1 and salary > 50000:
SELECT * FROM employees WHERE department_id = 1 AND salary > 50000;

SELECT DISTINCT department_id FROM employees;

-- Get all employees who are either working in department with 
-- "department_id" = 1 or "department_id" = 2:
SELECT * FROM employees WHERE department_id = 1 OR department_id = 2;
-- OR, using the IN operator:
SELECT * FROM employees WHERE department_id IN (1, 2);

-- Get all managers (job_title) from department_id 1 or 2:
SELECT * FROM employees WHERE
(department_id = 1 OR department_id = 2) AND job_title = 'Manager';

-- ===== "BETWEEN" Operator: =======

-- Get all employees whoes salary lies in range 30000 to 45000:
SELECT * FROM employees WHERE salary BETWEEN 30000 AND 45000;
-- Note: Both ends are inclusive when using BETWEEN!

-- Get all employees who were hired in the year 2019:
SELECT * FROM employees WHERE hire_date BETWEEN '2019-01-01' AND '2019-12-31';

-- Get all employees who don't work in departments 1 or 2:
SELECT * FROM employees WHERE department_id NOT IN (1, 2);

SELECT DISTINCT job_title FROM employees;
-- Get all employees whose "job_title" is not 'Manager' nor
-- 'Sales Manager':
SELECT * FROM employees WHERE job_title NOT IN ('Manager', 'Sales Manager');

SELECT job_title, COUNT(*) FROM employees
GROUP BY job_title ORDER BY job_title ASC;

-- Get all employees who do not have a manager:
SELECT * FROM employees WHERE manager_id IS NULL;


