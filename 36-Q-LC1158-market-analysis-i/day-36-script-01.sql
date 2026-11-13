USE trendytech_interview_problems;

-- LC Question Link:
-- https://leetcode.com/problems/market-analysis-i/description/

-- LC Question Title:
-- LC 1158. Market Analysis I


-- ==== Schema setup ======
DROP TABLE IF EXISTS Users;
CREATE TABLE IF NOT EXISTS Users (
    user_id INT PRIMARY KEY,
    join_date DATE,
    favorite_brand VARCHAR(10)
);
DROP TABLE IF EXISTS Orders;
CREATE TABLE IF NOT EXISTS Orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    item_id INT,
    buyer_id INT,
    seller_id INT
);
DROP TABLE IF EXISTS Items;
CREATE TABLE IF NOT EXISTS Items (
    item_id INT PRIMARY KEY,
    item_brand VARCHAR(10)
);
TRUNCATE TABLE Users;
INSERT INTO Users (user_id, join_date, favorite_brand) VALUES ('1', '2018-01-01', 'Lenovo');
INSERT INTO Users (user_id, join_date, favorite_brand) VALUES ('2', '2018-02-09', 'Samsung');
INSERT INTO Users (user_id, join_date, favorite_brand) VALUES ('3', '2018-01-19', 'LG');
INSERT INTO Users (user_id, join_date, favorite_brand) VALUES ('4', '2018-05-21', 'HP');
TRUNCATE TABLE Orders;
INSERT INTO Orders (order_id, order_date, item_id, buyer_id, seller_id) VALUES ('1', '2019-08-01', '4', '1', '2');
INSERT INTO Orders (order_id, order_date, item_id, buyer_id, seller_id) VALUES ('2', '2018-08-02', '2', '1', '3');
INSERT INTO Orders (order_id, order_date, item_id, buyer_id, seller_id) VALUES ('3', '2019-08-03', '3', '2', '3');
INSERT INTO Orders (order_id, order_date, item_id, buyer_id, seller_id) VALUES ('4', '2018-08-04', '1', '4', '2');
INSERT INTO Orders (order_id, order_date, item_id, buyer_id, seller_id) VALUES ('5', '2018-08-04', '1', '3', '4');
INSERT INTO Orders (order_id, order_date, item_id, buyer_id, seller_id) VALUES ('6', '2019-08-05', '2', '2', '4');
TRUNCATE TABLE Items;
INSERT INTO Items (item_id, item_brand) VALUES ('1', 'Samsung');
INSERT INTO Items (item_id, item_brand) VALUES ('2', 'Lenovo');
INSERT INTO Items (item_id, item_brand) VALUES ('3', 'LG');
INSERT INTO Items (item_id, item_brand) VALUES ('4', 'HP');



-- ####### First Approach ########

SELECT u.user_id AS buyer_id,
    u.join_date,
    COUNT(o.order_id) AS orders_in_2019
FROM users u LEFT JOIN orders o
ON u.user_id = o.buyer_id AND o.order_date BETWEEN '2019-01-01' AND '2019-12-31'
GROUP BY u.user_id;


-- Note: Here specifying the order_date criteria (orders of year 2019 only) in a
-- WHERE clause, will actually yield missing records for the user_id's who don't
-- have any buy orders in 2019; since even though the LEFT JOIN will keep all
-- users, but the later WHERE will remove those users, which is not what we want
-- as we need the count of zero (0) to be displayed against such users.
