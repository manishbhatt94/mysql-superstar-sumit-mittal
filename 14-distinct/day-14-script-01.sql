USE retail_db;
SHOW TABLES;
SELECT * FROM customers;

-- ============= DDL / SEED DATA ===============

-- Create new table `employees_new`:
CREATE TABLE employees_new (
	emp_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_name VARCHAR(255) NOT NULL,
    emp_department VARCHAR(255) NOT NULL,
    emp_role VARCHAR(255) NOT NULL
);

INSERT INTO employees_new   -- Total 10 records inserted.
	(emp_name, emp_department, emp_role) VALUES
    ('John Doe', 'Sales', 'Manager'),
    ('Jane Smith', 'Sales', 'Representative'),
    ('Alice Johnson', 'Marketing', 'Manager'),
    ('Chris Lee', 'IT', 'Developer'), -- This record is duplicated by a later record.
    ('Jack White', 'Sales', 'Representative'),
    ('Eve Davis', 'IT', 'Support'),
    ('Frank Brown', 'Marketing', 'Representative'),
    ('Grace Wilson', 'HR', 'Manager'),
    ('Henry Taylor', 'HR', 'Recruiter'),
    ('Chris Lee', 'IT', 'Developer'); -- Duplicate record (ID will obviously be unique though).

SELECT * FROM employees_new;

DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS students;
CREATE TABLE students (
	student_id INT AUTO_INCREMENT,
    student_fname VARCHAR(30) NOT NULL,
    student_lname VARCHAR(30) NOT NULL,
    student_mname VARCHAR(30),
    student_email VARCHAR(160) NOT NULL,
    student_phone VARCHAR(20) NOT NULL,
    student_alternate_phone VARCHAR(20),
    years_of_exp INT NOT NULL,
    student_company VARCHAR(30),
    batch_date VARCHAR(30) NOT NULL,
    source_of_joining VARCHAR(30) NOT NULL,
    location VARCHAR(30) NOT NULL,
    PRIMARY KEY (student_id),
    UNIQUE KEY (student_email)
);

INSERT INTO students (student_fname, student_lname, student_email, student_phone, years_of_exp,
	student_company, batch_date, source_of_joining, location) VALUES
('Amit', 'Sharma', 'amit.sharma@gmail.com', '9191919191', 6, 'Walmart', '2021-02-05', 'LinkedIn', 'Bengaluru'),
('Priya', 'Rao', 'priya.rao@gmail.com', '9292929292', 3, 'Flipkart', '2021-02-05', 'LinkedIn', 'Hyderabad'),
('Rahul', 'Verma', 'rahul.verma@gmail.com', '9393939393', 12, 'Google', '2021-02-19', 'Twitter', 'Bengaluru'),
('Anjali', 'Singh', 'anjali.singh@gmail.com', '9494949494', 8, 'Walmart', '2021-02-19', 'Quora', 'Chennai'),
('Vikram', 'Patel', 'vikram.patel@gmail.com', '9595959595', 15, 'Microsoft', '2021-02-05', 'Friend', 'Pune'),
('Asha', 'Menon', 'asha.menon@gmail.com', '9696969696', 18, 'TCS', '2021-02-05', 'YouTube', 'Pune'),
('Kiran', 'Nair', 'kiran.nair@gmail.com', '9797979797', 20, 'Wipro', '2021-02-19', 'YouTube', 'Pune'),
('Ravi', 'Iyer', 'ravi.iyer@gmail.com', '9898989898', 14, 'Wipro', '2021-02-19', 'Quora', 'Chennai');

SELECT * FROM students;

-- #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#
-- #@#@##@#@##@#@##@#@#@##@#@#@#@ DISTINCT #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#
-- #@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@##@#@#

-- Select `customer_state` from `customers` table:
SELECT customer_state FROM customers;

-- ======== Single column with DISTINCT clause ===============

-- Show the unique `customer_state` values from `customers` table:
SELECT DISTINCT customer_state FROM customers;

-- Get count of the unique `customer_state` values from `customers` table:
SELECT COUNT(DISTINCT customer_state) FROM customers; -- Result: 44.

-- With alias:
SELECT COUNT(DISTINCT customer_state) AS states_count FROM customers;

-- Do the same for `customer_city`:
SELECT COUNT(DISTINCT customer_city) AS cities_count FROM customers; -- Result: 562.


-- ======== Multiple columns with DISTINCT clause ===============

-- Find distinct combinations of "Department & Role" in the `employees_new` table:
SELECT DISTINCT emp_department, emp_role FROM employees_new;

-- Get count of above distinct combinations:
SELECT COUNT(DISTINCT emp_department, emp_role) FROM employees_new; -- Result: 8.

-- Find distinct rows (i.e. unique values combination of all columns, except the ID column)
-- in `employees_new` table:
SELECT DISTINCT emp_name, emp_department, emp_role FROM employees_new; -- 9 rows.
-- Note that our data of total 10 rows, contained a record whose non-ID column
-- values were duplicated once. That is, below are the two records, from which
-- SELECT DISTINCT returns only one:
-- (4, 'Chris Lee', 'IT', 'Developer') and
-- (10, 'Chris Lee', 'IT', 'Developer').

-- If a table doesn't have a unique constrained column (like a Primary Key or any Unique column),
-- then we can use: [SELECT DISTINCT *] to return only unique rows (checking uniqueness by
-- comparing all column values):
SELECT DISTINCT * FROM employees_new; -- 10 rows. (Returns all ten rows).
-- This returns all ten rows (no duplicates) since `emp_id` is a (unique) Primary Key column,
-- which won't have duplicate values, even if all other columns have duplicate values for some rows.


-- ======= LIMIT Related: ==========
SELECT * FROM students ORDER BY years_of_exp DESC;

-- Find the top 3 students with highest `years_of_exp`:
SELECT * FROM students ORDER BY years_of_exp DESC LIMIT 3; -- Kiran, Asha, Vikram.
-- Or, using the `LIMIT offset, rows` syntax:
SELECT * FROM students ORDER BY years_of_exp DESC LIMIT 0, 3;
--  Same: Kiran, Asha, Vikram.

-- Find the students with 3rd, 4th and 5th highest experience:
SELECT * FROM students ORDER BY years_of_exp DESC LIMIT 2, 3;
-- Vikram, Ravi, Rahul.

-- Find the students with the 2nd, 3rd and 4th lowest experience:
SELECT * FROM students ORDER BY years_of_exp ASC LIMIT 1, 3;
-- Amit, Anjali, Rahul.


-- ========= DISTINCT on columns having NULLs =============

-- Update `students` table and set Middle Names in 2 records (rest all are NULL):

UPDATE students SET student_mname = 'Subramanyam' WHERE student_id = 8;
-- 'Ravi Iyer' becomes 'Ravi Subramanyam Iyer'!

UPDATE students SET student_mname = 'Prasanna' WHERE student_id = 2;
-- 'Priya Rao' becomes 'Priya Prasanna Rao'!

-- Now, we get all DISTINCT Middle Names (column `student_mname`):
-- (DISTINCT clause will keep just one NULL in the result-set)
SELECT DISTINCT student_mname FROM students;
-- Result: NULL, Prasanna, Subramanyam.

/*
When you specify a column that has NULL values in the DISTINCT clause,
the DISTINCT clause will keep only one NULL value because it considers
all NULL values are the same.
*/


-- ######### DISTINCT and ORDER BY gotcha ##############

-- Get `source_of_joining` of the 5 most experienced students:
SELECT source_of_joining FROM students
	ORDER BY years_of_exp DESC LIMIT 5;
-- Result: YouTube, YouTube, Friend, Quora, Twitter.

-- But this contains duplicate values. Let's attempt to use DISTINCT:
SELECT DISTINCT source_of_joining FROM students
	ORDER BY years_of_exp DESC LIMIT 5; -- Gives error:
-- Error below:
/* Error Code: 3065. Expression #1 of ORDER BY clause is not in SELECT list,
   references column 'retail_db.students.years_of_exp' which is not in SELECT list;
   this is incompatible with DISTINCT.
*/

-- This error can be explained by knowing the SQL Logical Query Execution Order.
-- Read notes file "mysql-logical-query-execution-order.md" for the same.

