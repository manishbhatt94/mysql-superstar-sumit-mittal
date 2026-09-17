USE retail_db;
SHOW TABLES;

SELECT * FROM employees;

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
('Harper', 'Perez', 2, 56000, '2019-03-28', 8, 'harper.perez@example.com', '555-3451', 'Quality Assurance'),
('Alice', 'Wonder', 2, 45000, '2022-07-13', 2, 'alice.wonderexample.com', '666-3213', 'Office Manager'),
('Bob', 'Builder', 3, 48000, '2021-11-10', 3, 'bob%builder@example.com', '666-4837', 'Android Developer');

-- =================================================================

SELECT * FROM employees;

-- ############### LIKE Operator (Wildcards: '_' and '%') ####################

-- LIKE Operator Wildcards (% and _):
/*
% (Percent sign):
Matches zero or more character(s).

_ (Underscore sign):
Matches exactly one character.

*/

-- Get all employees whose `first_name` starts with the letter 'J'
SELECT * FROM employees WHERE first_name LIKE 'J%';

-- Get all employees whose `first_name` ends with the letter 'n'
SELECT * FROM employees WHERE first_name LIKE '%n';

-- Get all employees whose `first_name` starts with 'Ja',
-- and ends with the letter 'e'
SELECT * FROM employees WHERE first_name LIKE 'Ja%e';

-- Get all employees whose `first_name` is exactly 4 characters long:
SELECT * FROM employees WHERE first_name LIKE '____'; -- 4 underscores used!

-- Or, just a basic query using LENGTH() string function (and no pattern matching):
SELECT * FROM employees WHERE LENGTH(first_name) = 4;

-- Get all employees whose `first_name` is at-least 4 characters long:
SELECT * FROM employees WHERE first_name LIKE '____%';
-- (4 Underscore signs and a Percent sign used!)

-- Or, just a basic query using LENGTH() string function (and no pattern matching):
SELECT * FROM employees WHERE LENGTH(first_name) >= 4;

-- Get all employees whose `job_title` contains the string 'developer':
SELECT * FROM employees WHERE job_title LIKE '%developer%';


-- Simple/Dumb email pattern match (with % and _):
/*
Rules:
-----@---.--

1. Atleast one character before '@' symbol.
2. Atleast one character after '@' symbol (domain name).
3. One Dot (.) character.
4. Atleast two characters after the dot (TLD - Top Level Domain name).

Pattern:
'_%@_%.__%'
*/

-- Get all records where email is INVALID according to the above rules:
SELECT * FROM employees WHERE email NOT LIKE '_%@_%.__%'; -- Notice use of NOT LIKE.

-- Get all records where email is VALID according to the above rules:
SELECT * FROM employees WHERE email LIKE '_%@_%.__%';

-- Escaping the LIKE WILDCARD special characters (Percent / Underscore sign)

-- Get all records where `email` has a literal '%' percent symbol character:
-- '\' (Back-slash) is the default escape character.
SELECT * FROM employees WHERE email LIKE '%\%%';

-- Or, if we need to, we can specify a custom escape character other than Backslash
-- (like we specified the '&' here as the escape character for this query), using
-- "MySQL LIKE operator with the ESCAPE clause"
-- https://www.mysqltutorial.org/mysql-basics/mysql-like/#mysql-like-operator-with-the-escape-clause
SELECT * FROM employees WHERE email LIKE '%&%%' ESCAPE '&';

-- Syntax of LIKE Operator:
-- expression LIKE pattern ESCAPE escape_character

SELECT 'manish_sql' LIKE '%\_%'; -- Matches (Result is 1, not 0)


-- ############### REGULAR EXPRESSIONS ####################

-- Get all employees whose `first_name` starts with either of these
-- letters 'A' or 'B' or 'C' or 'D':

-- Without REGEX (only using LIKE):
SELECT * FROM employees WHERE
	first_name LIKE 'A%' OR
    first_name LIKE 'B%' OR
    first_name LIKE 'C%' OR
    first_name LIKE 'D%';

-- ========= Using MySQL REGEXP operator =============
-- Syntax: expression REGEXP pattern

-- Get all employees whose `first_name` starts with either of these
-- letters 'A' or 'B' or 'C' or 'D':
SELECT * FROM employees WHERE
	first_name REGEXP '^[ABCD]';
-- (In regex, '^' matches start of string, and '$' matches end of string)

SELECT 'Derek' REGEXP '^[ABCD]';
SELECT 'Derek' REGEXP '^[ABCD].+';
SELECT 'D' REGEXP '^[ABCD].+';
SELECT 'Dr' REGEXP '^[ABCD].?$';
SELECT 'D' REGEXP '^[ABCD].?$';
SELECT 'Dre' REGEXP '^[ABCD].?$';

-- Get all employees whose `first_name` starts with either of these
-- letters 'r' or 'y' or 'm':
SELECT * FROM employees WHERE first_name REGEXP '[rym]$';

-- Get all employees whose `first_name` has a vowel (a/e/i/o/u)
-- at the 2nd (second) character:
SELECT * FROM employees WHERE first_name REGEXP '^.[aeiou]';

-- Get all employees whose `first_name` DOES NOT has a vowel (a/e/i/o/u)
-- at the 2nd (second) character:
SELECT * FROM employees WHERE first_name NOT REGEXP '^.[aeiou]';


-- Simple Email pattern matching using simple REGEXP
-- Rules:
-- username@domain.tld
-- username:
--    Allowed Characters: a-z 0-9 . _
--    Starts With: An alphabet (a-z)
--    Length: 1 or more characters
-- domain:
--    Allowed Characters: a-z 0-9
--    Starts With: An alphabet (a-z)
--    Length: 1 or more characters
-- tld:
--    Allowed Characters: a-z
--    Length: 2 or more characters

-- Below pattern doesn't validate for starting character must be
-- an alphabet letter:
SELECT '^[a-z0-9._]+@[a-z0-9]+\\.[a-z]{2,}';
SELECT '7zip@sad.why' REGEXP '^[a-z0-9._]+@[a-z0-9]+\\.[a-z]{2,}'; -- True

-- Below pattern also checks for above "Starts With" condition:
SELECT '^[a-z][a-z0-9._]*@[a-z][a-z0-9]*\\.[a-z]{2,}';
SELECT '7zip@sad.why' REGEXP '^[a-z][a-z0-9._]*@[a-z][a-z0-9]*\\.[a-z]{2,}'; -- False
SELECT 'yo.7_zip@sad.why' REGEXP '^[a-z][a-z0-9._]*@[a-z][a-z0-9]*\\.[a-z]{2,}'; -- True

SELECT 'hello.world' REGEXP '^[a-z]+\\.[a-z]+$'; -- True
SELECT 'hello?world' REGEXP '^[a-z]+\\.[a-z]+$'; -- False

-- Get all employees whose `first_name` is exactly 3 characters long:
SELECT * FROM employees WHERE first_name REGEXP '^...$';
-- (Above: Used three dot characters in regex along with string begin & end anchors ^ and $)

-- Get all employees whose `first_name` is at-least 7 characters long:
SELECT * FROM employees WHERE last_name REGEXP '.......';
-- (Above: Used seven dot characters in regex)

-- Negated Character Set (Place ^ right after opening square bracket):
SELECT '3w' REGEXP '^[^0-9][a-z0-9]+$'; -- False
SELECT '3weed' REGEXP '^[^0-9][a-z0-9]+$'; -- False
SELECT 'w33d' REGEXP '^[^0-9][a-z0-9]+$'; -- True

-- Escaping hyphen in Character Set []:
-- (Below: Only match either 'a', 'z' or '-')
-- (Note: we needed double back-slash in character set [] since
-- single would match the back-slash literally)
SELECT 'bull' REGEXP '[a\\-z]+'; -- False (Hyphen is escaped and matched literally).
SELECT 'azzzaaa--aazz-zazz---aa--' REGEXP '[a\\-z]+'; -- True
