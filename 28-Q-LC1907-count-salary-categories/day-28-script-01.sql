USE trendytech_interview_problems;

-- LC Question Link:
-- https://leetcode.com/problems/count-salary-categories/description/

-- LC Question Title:
-- 1907. Count Salary Categories


-- ==== Schema setup ======
CREATE TABLE IF NOT EXISTS Accounts (account_id INT, income INT);
TRUNCATE TABLE Accounts;
INSERT INTO Accounts (account_id, income) VALUES ('3', '108939');
INSERT INTO Accounts (account_id, income) VALUES ('2', '12747');
INSERT INTO Accounts (account_id, income) VALUES ('8', '87709');
INSERT INTO Accounts (account_id, income) VALUES ('6', '91796');


-- ####### First Approach ########

SELECT 'Low Salary' AS category,
	SUM(CASE WHEN income < 20000 THEN 1 ELSE 0 END) AS accounts_count
FROM Accounts
UNION ALL
SELECT 'Average Salary',
	SUM(CASE WHEN income BETWEEN 20000 AND 50000 THEN 1 ELSE 0 END)
FROM Accounts
UNION ALL
SELECT 'High Salary',
	SUM(CASE WHEN income > 50000 THEN 1 ELSE 0 END)
FROM Accounts;

-- In MySQL, boolean expressions evaluate to 1 or 0, so we could have
-- skipped the CASE WHEN above, and just put the boolean expression
-- within the SUM function:
SELECT 'Low Salary' AS category,
	SUM(income < 20000) AS accounts_count
FROM Accounts
UNION ALL
SELECT 'Average Salary',
	SUM(income BETWEEN 20000 AND 50000)
FROM Accounts
UNION ALL
SELECT 'High Salary',
	SUM(income > 50000)
FROM Accounts;


-- Using MySQL's IF() function along with COUNT:
-- https://www.mysqltutorial.org/mysql-control-flow-functions/mysql-if-function/
-- IF() function syntax:
-- IF(expr,if_true_expr,if_false_expr)

SELECT 'Low Salary' AS category,
	COUNT(IF(income < 20000, 1, NULL)) AS accounts_count
FROM Accounts
UNION ALL
SELECT 'Average Salary',
	COUNT(IF(income BETWEEN 20000 AND 50000, 1, NULL))
FROM Accounts
UNION ALL
SELECT 'High Salary',
	COUNT(IF(income > 50000, 1, NULL))
FROM Accounts;


-- ==== Second Approach ======

-- This query doesn't work, in cases when some categories don't exist
-- where it should have printed those categories as well with zero count:
SELECT t.category, COUNT(*) AS accounts_count
FROM (
	SELECT account_id, income,
		CASE
		WHEN income < 20000 THEN 'Low Salary'
		WHEN income BETWEEN 20000 AND 50000 THEN 'Average Salary'
		ELSE 'High Salary'
		END AS category
	FROM Accounts
) t
GROUP BY t.category;
-- Result: Leaves out the category 'Average Salary' from the result.
-- Should have printed it along with zero.
-- Therefore, this solution is not acceptable.


-- To make this work, we'll have a result-set containing just all the category
-- names, and then LEFT JOIN that with the above results, to make sure all
-- categories are available in the final result:
WITH salary_cats AS (
	SELECT 'Low Salary' AS category
	UNION ALL
	SELECT 'Average Salary'
	UNION ALL
	SELECT 'High Salary'
), cat_counts AS (
	SELECT t.category, COUNT(*) AS accounts_count
	FROM (
		SELECT account_id, income,
			CASE
			WHEN income < 20000 THEN 'Low Salary'
			WHEN income BETWEEN 20000 AND 50000 THEN 'Average Salary'
			ELSE 'High Salary'
			END AS category
		FROM Accounts
	) t
	GROUP BY t.category
)
SELECT
	sc.category,
	COALESCE(cc.accounts_count, 0) AS accounts_count
FROM salary_cats sc LEFT OUTER JOIN cat_counts cc
ON sc.category = cc.category;
