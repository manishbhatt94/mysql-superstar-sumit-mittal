USE trendytech_interview_problems;

-- LC Question Link:
-- https://leetcode.com/problems/create-a-session-bar-chart/description/

-- LC Question Title:
-- LC 1435. Create a Session Bar Chart


-- ==== Schema setup ======
CREATE TABLE IF NOT EXISTS Sessions (
	session_id INT PRIMARY KEY,
	duration INT NOT NULL
);
TRUNCATE TABLE Sessions;
INSERT INTO Sessions (session_id, duration) VALUES
(1, 30),
(2, 199),
(3, 299),
(4, 580),
(5, 1000);

SELECT * FROM Sessions;


-- ####### First Approach ########

-- All bins may not be present, depending on the data:
SELECT session_id, duration,
	CASE
	WHEN                         duration < 5  * 60  THEN 0  -- '[0-5>'
	WHEN duration >= 5 * 60  AND duration < 10 * 60  THEN 1  -- '[5-10>'
	WHEN duration >= 10 * 60 AND duration < 15 * 60  THEN 2  -- '[10-15>'
	ELSE 3  -- '15 or more'
	END AS duration_bucket
FROM Sessions;

-- Still, let's group by them, and find counts:
SELECT s.duration_bucket, COUNT(*) AS total
FROM (
	SELECT session_id, duration,
		CASE
		WHEN                         duration < 5  * 60  THEN 0  -- '[0-5>'
		WHEN duration >= 5 * 60  AND duration < 10 * 60  THEN 1  -- '[5-10>'
		WHEN duration >= 10 * 60 AND duration < 15 * 60  THEN 2  -- '[10-15>'
		ELSE 3  -- '15 or more'
		END AS duration_bucket
	FROM Sessions
) s GROUP BY s.duration_bucket;

-- Now, we need a temporary result-set having all Bucket / Bin details
-- and LEFT JOIN it will the above results, to ensure all buckets
-- appear in the final result:
WITH bin_details AS (
	SELECT 0 AS duration_bucket, '[0-5>' AS bin
    UNION ALL
    SELECT 1, '[5-10>'
    UNION ALL
    SELECT 2, '[10-15>'
    UNION ALL
    SELECT 3, '15 or more'
), grouped_sessions AS (
	SELECT s.duration_bucket, COUNT(*) AS total
	FROM (
		SELECT session_id, duration,
			CASE
			WHEN                         duration < 5  * 60  THEN 0  -- '[0-5>'
			WHEN duration >= 5 * 60  AND duration < 10 * 60  THEN 1  -- '[5-10>'
			WHEN duration >= 10 * 60 AND duration < 15 * 60  THEN 2  -- '[10-15>'
			ELSE 3  -- '15 or more'
			END AS duration_bucket
		FROM Sessions
	) s GROUP BY s.duration_bucket
)
SELECT bd.bin, COALESCE(gs.total, 0) AS total
FROM bin_details bd LEFT OUTER JOIN grouped_sessions gs
	ON bd.duration_bucket = gs.duration_bucket;


-- ####### Second Approach ########

SELECT '[0-5>'      AS bin, COUNT(*) AS total FROM Sessions
	WHERE duration < 5 * 60
UNION ALL
SELECT '[5-10>'     AS bin, COUNT(*) AS total FROM Sessions
	WHERE duration >= 5 * 60  AND duration < 10 * 60
UNION ALL
SELECT '[10-15>'    AS bin, COUNT(*) AS total FROM Sessions
	WHERE duration >= 10 * 60 AND duration < 15 * 60
UNION ALL
SELECT '15 or more' AS bin, COUNT(*) AS total FROM Sessions
	WHERE duration >= 15 * 60;


-- ####### Third Approach ########

-- Instead of using COUNT, we can use SUM(boolean_expression) and provide the respective
-- boolean expression inside as argument to SUM(..), and we know that MySQL will implicitly
-- cast boolean values to either 1 or 0, where an integer is expected (like the argument of SUM)

SELECT '[0-5>' AS bin, SUM(duration < 5 * 60) AS total FROM Sessions
UNION ALL
SELECT '[5-10>', SUM(duration >= 5 * 60  AND duration < 10 * 60) FROM Sessions
UNION ALL
SELECT '[10-15>', SUM(duration >= 10 * 60 AND duration < 15 * 60) FROM Sessions
UNION ALL
SELECT '15 or more', SUM(duration >= 15 * 60) FROM Sessions;
