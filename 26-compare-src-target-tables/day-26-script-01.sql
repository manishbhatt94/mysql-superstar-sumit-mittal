CREATE DATABASE trendytech_interview_problems;

USE trendytech_interview_problems;


-- ####### Q1. #########

DROP TABLE IF EXISTS source_t;
CREATE TABLE IF NOT EXISTS source_t (
	ID INT PRIMARY KEY,
	NAME VARCHAR(10)
);
INSERT INTO source_t (ID, NAME) VALUES
(1, 'A'), (2, 'B'), (3, 'C'), (4, 'D');

DROP TABLE IF EXISTS target_t;
CREATE TABLE IF NOT EXISTS target_t (
	ID INT PRIMARY KEY,
	NAME VARCHAR(10)
);
INSERT INTO target_t (ID, NAME) VALUES
(1, 'A'), (2, 'B'), (4, 'X'), (5, 'E');

-- ==== Using EXCEPTs, with INNER JOIN ======

SELECT `ID`, 'New in Source' AS `COMMENT` FROM source_t
EXCEPT SELECT `ID`, 'New in Source' FROM target_t
UNION ALL
SELECT `ID`, 'New in Target' AS `COMMENT` FROM target_t
EXCEPT SELECT `ID`, 'New in Target' FROM source_t
UNION ALL
SELECT s.ID, 'Mismatch' AS `COMMENT`
FROM source_t s INNER JOIN target_t t
ON s.ID = t.ID AND s.NAME != t.NAME
ORDER BY ID;

-- === OR: Using only JOINs (without EXCEPT): =====
SELECT s.ID, 'New in Source' AS `COMMENT`
FROM source_t s LEFT JOIN target_t t ON s.ID = t.ID
WHERE t.ID IS NULL
UNION ALL
SELECT t.ID, 'New in Target' AS `COMMENT`
FROM source_t s RIGHT JOIN target_t t ON s.ID = t.ID
WHERE s.ID IS NULL
UNION ALL
SELECT s.ID, 'Mismatch' AS `COMMENT`
FROM source_t s INNER JOIN target_t t
ON s.ID = t.ID AND s.NAME != t.NAME
ORDER BY ID;

-- ==== Or: we can skip the INNER JOIN (for the 'Mismatch' case),
-- and instead have those results from either one of the LEFT JOIN
-- or the RIGHT JOIN query: =====

-- Records that are: 'New in Source', or 'Mismatch'
SELECT
	s.ID,
	CASE
    WHEN t.ID IS NULL THEN 'New in Source'
    WHEN s.NAME != t.NAME THEN 'Mismatch'
    END AS `COMMENT`    
FROM source_t s LEFT JOIN target_t t ON s.ID = t.ID
WHERE t.ID IS NULL OR s.NAME != t.NAME
-- Union all
UNION ALL
-- Records that are 'New in Target':
SELECT t.ID, 'New in Target' AS `COMMENT`
FROM source_t s RIGHT JOIN target_t t ON s.ID = t.ID
WHERE s.ID IS NULL
-- Ordering the "union all" results
ORDER BY ID;
