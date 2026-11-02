USE trendytech_interview_problems;

-- Using the same "employees" table created in "day-29-script-01.sql" file:
-- employees(employee_id, employee_name, department, city, salary, hire_date):
SELECT * FROM employees;

SELECT COUNT(*) FROM employees;  -- 16 records.

SELECT COUNT(DISTINCT salary) FROM employees;
-- 13 records (i.e. Out of total 16 records, 3 have duplicate `salary` values).

SELECT COUNT(DISTINCT hire_date) FROM employees;
-- 16 records (i.e. all hire_date's are distinct).

SELECT *,
	ROW_NUMBER() OVER(ORDER BY hire_date) row_num_val,
	RANK() OVER(ORDER BY hire_date) rank_val,
	DENSE_RANK() OVER(ORDER BY hire_date) dense_rank_val
FROM employees;
-- In this case, because the `hire_date` column's values are all distinct,
-- and since ORDER BY within OVER() is applied on such a column, then
-- we'll see that all three (row_num_val, rank_val, & dense_rank_val)
-- give unique sequential numbers from 1 to the partition size (here no
-- partition specified, so the entire table comes under one big partition).

/* The results produced by ROW_NUMBER, RANK & DENSE_RANK are the same
when there are no duplicates in the OVER's ORDER clause.
*/

/*
- When there are no ties / duplicates, then all of these (ROW_NUMBER, RANK & DENSE_RANK)
  will give the same results.
- The difference comes when there are ties.
- Two (or more) records having tie in the value of their OVER(ORDER BY ..) column,
  will have the same value of RANK & DENSE_RANK.
- In case of RANK, the first value after duplicate(s) WILL SKIP the next ranks.
- In case of DENSE_RANK, the first value after duplicate(s) WILL NOT SKIP the next ranks.
*/

SELECT *,
	ROW_NUMBER() OVER(ORDER BY salary DESC) row_num_val,
	RANK() OVER(ORDER BY salary DESC) rank_val,
	DENSE_RANK() OVER(ORDER BY salary DESC) dense_rank_val
FROM employees;
