USE trendytech_joins_practice;
SHOW TABLES;
SELECT * FROM categories;
SELECT * FROM customers;
SELECT * FROM departments;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM products;

DROP TABLE IF EXISTS employees;
CREATE TABLE IF NOT EXISTS employees (
	employee_id INT PRIMARY KEY,
	employee_name VARCHAR(100),
	department_id INT,
	manager_id INT,
	salary DECIMAL(10, 2),
	designation VARCHAR(50)
); 

INSERT INTO employees (employee_id, employee_name, department_id, manager_id, salary, designation) VALUES
(1,    'Rajesh Kumar',     1,    NULL,   200000.00,    'CEO'                  ),    -- No manager.
(2,    'Sonal Gupta',      2,    1,      150000.00,    'VP IT'                ),    -- Reports to Rajesh Kumar.
(3,    'Anita Desai',      2,    2,      120000.00,    'Manager IT'           ),    -- Reports to Sonal Gupta.
(4,    'Vikram Singh',     3,    1,      110000.00,    'VP HR'                ),    -- Reports to Rajesh Kumar.
(5,    'Priya Nair',       2,    3,      130000.00,    'Developer IT'         ),    -- Reports to Anita Desai.
(6,    'Amit Sharma',      3,    4,      100000.00,    'HR Manager'           ),    -- Reports to Vikram Singh.
(7,    'Neha Patil',       4,    1,      140000.00,    'VP Finance'           ),    -- Reports to Rajesh Kumar.
(8,    'Rohit Verma',      4,    7,      90000.00,     'Finance Analyst'      ),    -- Reports to Neha Patil.
(9,    'Kavita Joshi',     2,    3,      125000.00,    'Developer IT'         ),    -- Reports to Anita Desai.
(10,   'Manish Kulkarni',  5,    1,      145000.00,    'VP Marketing'         ),    -- Reports to Rajesh Kumar.
(11,   'Nidhi Agarwal',    5,    10,     95000.00,     'Marketing Manager'    ),    -- Reports to Manish Kulkarni.
(12,   'Suresh Iyer',      4,    7,      85000.00,     'Accountant'           ),    -- Reports to Neha Patil.
(13,   'Ravi Menon',       6,    1,      135000.00,    'VP Operations'        ),    -- Reports to Rajesh Kumar.
(14,   'Anjali Sinha',     6,    13,     105000.00,    'Operations Manager'   ),    -- Reports to Ravi Menon.
(15,   'Tarun Mehta',      2,    2,      115000.00,    'IT Support'           ),    -- Reports to Sonal Gupta.
(16,   'Deepika Rao',      3,    4,      98000.00,     'HR Assistant'         ),    -- Reports to Vikram Singh.
(17,   'Karan Chawla',     5,    10,     92000.00,     'Marketing Analyst'    ),    -- Reports to Manish Kulkarni.
(18,   'Meena Kapoor',     4,    7,      102000.00,    'Finance Manager'      ),    -- Reports to Neha Patil.
(19,   'Sanjay Reddy',     6,    13,     108000.00,    'Logistics Coordinator'),    -- Reports to Ravi Menon.
(20,   'Shweta Tiwari',    2,    3,      127000.00,    'Developer IT'         );    -- Reports to Anita Desa.


DROP TABLE IF EXISTS courses;
CREATE TABLE IF NOT EXISTS courses (
	course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    prerequisite_id INT,
    duration_weeks INT
);

INSERT INTO courses (course_id, course_name, prerequisite_id, duration_weeks) VALUES
( 1,   'Intro to Programming',  NULL,   10 ),        -- Prerequisite course is NULL.
( 2,   'Data Structures',       1,      8  ),        -- Prerequisite course is 'Intro to Programming'.
( 3,   'Algorithms',            2,      10 ),        -- Prerequisite course is 'Data Structures'.
( 4,   'Operating Systems',     2,      12 ),        -- Prerequisite course is 'Data Structures'.
( 5,   'Databases',             1,      8  );        -- Prerequisite course is 'Intro to Programming'.

-- #%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%


-- ############################# SELF JOIN #############################

SELECT * FROM employees;
SELECT * FROM employees;

-- For simplicity & ease of understanding, we will treat the:
-- a) Left side `employees` table  - to be representing Employees, and the..
-- a) Right side `employees` table - to be representing Managers.


-- ====== Display details of employees, along with their manager's name & salary,
-- for each employee ========
SELECT e.*, m.employee_name AS manager_name, m.salary AS manager_salary
FROM employees e LEFT OUTER JOIN employees m ON e.manager_id = m.employee_id;


-- ====== Find all employees who have no manager ========

-- Approach 1: With LEFT JOIN plus IS NULL on right table:
SELECT e.*, m.employee_name AS manager_name, m.salary AS manager_salary
FROM employees e LEFT OUTER JOIN employees m ON e.manager_id = m.employee_id
WHERE m.employee_id IS NULL;

-- Approach 2: Simpler - just use `employees` table & check if `manager_id` is NULL:
SELECT * FROM employees WHERE manager_id IS NULL;


-- ====== Find all employees who DO NOT manage anyone (i.e. who don't
-- have any reportees) ========

-- Following same convention of left & right tables being like:
-- left side employees table representing "records of employees", and
-- right side employees table representing "records of managers";
-- If we take a RIGHT (OUTER) JOIN, and then filter (using WHERE)
-- only rows where left side columns are NULL, i.e. for a record
-- from the "managers" side, no corresponding record from the "employees"
-- side was found - hence no reportees.

SELECT
	m.employee_id, m.employee_name, m.designation, m.salary, m.department_id
FROM employees e RIGHT JOIN employees m ON e.manager_id = m.employee_id
WHERE e.manager_id IS NULL;
-- Result: 13 records returned.
-- So, 13 (out of total 20) employees do not manage anyone.
-- These include employee_id's:
-- 5, 6, 8, 9, 11, 12, 14, 15, 16, 17, 18, 19, 20.
-- These above are employee_id's of employees who have no reportees.

-- Verify by cross-checking whether any of these employee_id's is
-- present as the manager_id of any employee
SELECT * FROM employees WHERE manager_id IN
	(5, 6, 8, 9, 11, 12, 14, 15, 16, 17, 18, 19, 20);
-- Result: No records. Hence verified.


-- ===== List the employees who are earning more than their managers =========

SELECT e.*, m.employee_name AS manager_name, m.salary AS manager_salary
FROM employees e INNER JOIN employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;


-- ===== Find employees who are earning more than the avg. salary of their department =========

-- *** Approach 1: Using sub-query. No joins used. ***

-- First, let's find the avg. salary for all departments:
SELECT e2.department_id, AVG(e2.salary) FROM employees e2 GROUP BY e2.department_id;
-- dept_id=1 --> avg_salary=200000.00
-- dept_id=2 --> avg_salary=127833.33
-- dept_id=3 --> avg_salary=102666.67
-- dept_id=4 --> avg_salary=104250.00
-- dept_id=5 --> avg_salary=110666.67
-- dept_id=6 --> avg_salary=116000.00

-- Then, let us find avg. salary for a particular dept_id=6
SELECT AVG(e2.salary) FROM employees e2
WHERE e2.department_id = 6
GROUP BY e2.department_id;
-- Got the expected result, i.e. avg_salary=116000.00

SELECT e2.department_id, AVG(e2.salary) FROM employees e2 GROUP BY e2.department_id;

SELECT * FROM
employees AS e1
WHERE e1.salary > (
	SELECT AVG(e2.salary) FROM employees e2
	WHERE e2.department_id = e1.department_id
	GROUP BY e2.department_id
);
-- Result: 6 employee records (who earn more than their dept. avg. salary)
-- These 6 employee's employee_id's are (2, 4, 5, 7, 10, 13).

-- *** Approach 2: (Novel approach) Using JOIN ***
-- Here we treat the result set of "avg dept salary for all depts" as one
-- of the JOIN tables - which we will join with the `employees` table
-- so that after joining, each record has an employee along with that
-- employee's dept. avg. salary:

SELECT
	e.employee_id, e.employee_name, e.department_id, e.designation, e.salary,
    depts_avg.avg_salary AS dept_avg_salary
FROM
employees e INNER JOIN (
	-- Treating below result set, as the right side table of
    -- the INNER JOIN:
	SELECT department_id, AVG(salary) AS avg_salary
    FROM employees GROUP BY department_id
) depts_avg
ON e.department_id = depts_avg.department_id
WHERE e.salary > depts_avg.avg_salary;
-- Result: The same: 6 employee records (who earn more than their dept. avg. salary).
-- These 6 employee's employee_id's are (2, 4, 5, 7, 10, 13). Same as with previous approach.

-- Important Note: Here, for the case of INNER JOINs as in above query, we could
-- have placed the filtering condition in either of the WHERE clause (as we did)
-- or within the ON clause (together with the key matching condition using AND)
-- and both ways would yield the exact same results.
-- However, when using an OUTER JOIN to preserve one side records, whether or not
-- any matches found, then filtering inside WHERE will essentially filter out the
-- non-matching records from the OUTER side which defeats the purpose of using
-- an OUTER JOIN (and basically converts the OUTER JOIN to an INNER JOIN). So in
-- such cases, we keep the additional filter condition within the ON clause.
-- More details in notes markdown files: [notes-on-vs-where-in-joins.md] and
-- [sql-joins-beginner-guide.md]


-- ====== Find `courses` that take longer to complete than their prerequisite course =======
-- (Also include courses that don't have any prerequisite course)

SELECT * FROM courses;

-- Treating left side `courses` table as representing list of courses,
-- and right side `courses` table as representing list of prerequisite courses.

-- First, let's see the list of all courses, along with their prerequisite course
-- and the duration of the prerequisite course:
SELECT cr.*,
	pc.course_name AS prereq_course_name,
    pc.duration_weeks AS prereq_course_duration
FROM courses cr LEFT OUTER JOIN courses pc  -- `cr` (course); `pc` (prerequisite course).
	ON cr.prerequisite_id = pc.course_id;
-- Note that, we used LEFT JOIN as we're instructed to keep courses that
-- don't have a prerequisite course (no JOIN match)

-- Now, let's print all courses with their prerequisite course name & duration,
-- all courses must be printed, and if the duration of a course is more than
-- the duration of it's prerequisite course, then we show the prerequisite course's
-- name/duration, else we show it as NULL. This is the perfect situation for
-- using a LEFT (OUTER) JOIN and also keeping the filter condition within the ON
-- clause only (not inside WHERE as it would filter out some courses but we need
-- to show all courses).
SELECT cr.*,
	pc.course_name AS prereq_course_name,
    pc.duration_weeks AS prereq_course_duration
FROM courses cr LEFT OUTER JOIN courses pc
	ON cr.prerequisite_id = pc.course_id AND cr.duration_weeks > pc.duration_weeks;

-- Now, finally, we want to show only those courses whose duration is more
-- than their prerequisite course's duration:

-- (1) Let's do it using LEFT JOIN & filter condition inside WHERE (LEFT JOIN
-- essentially becomes INNER JOIN):
SELECT cr.*,
	pc.course_name AS prereq_course_name,
    pc.duration_weeks AS prereq_course_duration
FROM courses cr LEFT OUTER JOIN courses pc
	ON cr.prerequisite_id = pc.course_id
WHERE cr.duration_weeks > pc.duration_weeks;

-- (2) Let's do it using INNER JOIN & filter condition inside WHERE (in case
-- of INNER JOIN this filter condition can equivalently be also put within ON):
SELECT cr.*,
	pc.course_name AS prereq_course_name,
    pc.duration_weeks AS prereq_course_duration
FROM courses cr INNER JOIN courses pc
	ON cr.prerequisite_id = pc.course_id
WHERE cr.duration_weeks > pc.duration_weeks;

-- (3) To also include the courses which do not have any prerequisite course
-- we can just add an OR filter in the WHERE above, like this:
SELECT cr.*,
	pc.course_name AS prereq_course_name,
    pc.duration_weeks AS prereq_course_duration
FROM courses cr LEFT OUTER JOIN courses pc
	ON cr.prerequisite_id = pc.course_id
WHERE cr.duration_weeks > pc.duration_weeks OR cr.prerequisite_id IS NULL;
-- What changed?: Just used LEFT JOIN and added "OR cr.prerequisite_id IS NULL"
-- to WHERE condition.

