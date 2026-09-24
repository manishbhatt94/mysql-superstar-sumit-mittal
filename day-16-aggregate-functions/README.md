# MySQL - Aggregate Functions - MIN, MAX, AVG, COUNT

Video Link:
https://www.youtube.com/watch?v=8i409XSdc4s

<br>

---

Aggregation is achieved by using GROUP BY.

Aggregate functions run on the grouping we define.

When we skip GROUP BY in our query, the entire data selected becomes the only
group - on which aggregate functions are computed.

According to the SQL Logical Query Execution Order, we saw that the order at
which **Aggregate Functions** are run, is after `GROUP BY` and before `HAVING`:

1. `FROM`
2. `JOIN` + `ON`
3. `WHERE`
4. `GROUP BY`
5. **Aggregate Functions**
6. `HAVING`
7. `SELECT`
8. `DISTINCT`
9. `ORDER BY`
10. `LIMIT` / `OFFSET`

In an aggregate query without `GROUP BY`, SQL treats the rows produced by
`FROM/JOIN` and filtered by `WHERE` as **one implicit group**.

When `GROUP BY` is omitted from an aggregate query, all rows produced after
`FROM/JOIN` and `WHERE` are treated as a single implicit group, and aggregate
functions are computed over that group.


---

## Schema Definition / Data Seeding

**Schema:**

```sql
USE retail_db;
SHOW TABLES;

DROP TABLE IF EXISTS `sales`;
CREATE TABLE IF NOT EXISTS `sales` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `product` VARCHAR(50),
  `category` VARCHAR(50),
  `amount` DECIMAL(10, 2),
  `sale_date` DATE,
  `quantity` INT,
  `customer_id` INT,
  `store_location` VARCHAR(50)
);
ALTER TABLE sales
ADD COLUMN unit_price DECIMAL(10,2) AFTER category;

SHOW TABLES;

```


**Data Seeding:**

```bash
mysql --local-infile=1 -u root -p -P 3306 retail_db
```

```sql
SET GLOBAL local_infile = ON;

SHOW GLOBAL VARIABLES LIKE 'localinfile'; -- Verify!

SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET AUTOCOMMIT = 0;

LOAD DATA LOCAL INFILE
'C:/Users/Manish/Dev/SQL/mysql-superstar/datasets/Extracted-01/sales.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'   -- Windows CRLF.
IGNORE 1 LINES   -- For CSV Header.
(id, product, category, unit_price, amount, sale_date, quantity, customer_id, store_location);

COMMIT;
SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;
SET AUTOCOMMIT = 1;


DESCRIBE sales;

SELECT COUNT(*) FROM sales;

SELECT * FROM sales LIMIT 15;
```
