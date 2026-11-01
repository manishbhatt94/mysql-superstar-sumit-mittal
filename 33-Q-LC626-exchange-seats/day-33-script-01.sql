USE trendytech_interview_problems;

-- LC Question Link:
-- https://leetcode.com/problems/exchange-seats/description/

-- LC Question Title:
-- LC 626. Exchange Seats


-- ==== Schema setup ======
CREATE TABLE IF NOT EXISTS Seat (
	id INT,
	student VARCHAR(255)
);
TRUNCATE TABLE Seat;
INSERT INTO Seat (id, student) VALUES ('1', 'Abbot');
INSERT INTO Seat (id, student) VALUES ('2', 'Doris');
INSERT INTO Seat (id, student) VALUES ('3', 'Emerson');
INSERT INTO Seat (id, student) VALUES ('4', 'Green');
INSERT INTO Seat (id, student) VALUES ('5', 'Jeames');

SELECT * FROM Seat;


-- ####### First Approach ########

WITH tbl_agg AS (
    SELECT COUNT(*) AS total FROM Seat
)
SELECT
    CASE
        WHEN id % 2 = 0 THEN (id - 1)  -- When Even
        WHEN id = (SELECT total FROM tbl_agg) THEN id  -- When Odd But Last
        ELSE (id + 1)  -- When Odd But Not Last
    END AS id, student
FROM Seat ORDER BY id;


