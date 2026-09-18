# MySQL Notes – Orders Table & Bulk CSV Import

## 0. Create "orders" table from Workbench GUI

Generated SQL:

```sql
CREATE TABLE `retail_db`.`orders` (
  `order_id` INT NOT NULL AUTO_INCREMENT,
  `order_date` DATE NOT NULL,
  `customer_id` INT NULL,
  `order_status` VARCHAR(40) NULL,
  PRIMARY KEY (`order_id`),
  INDEX `fk_customer_id_idx` (`customer_id` ASC) VISIBLE,
  CONSTRAINT `fk_customer_id`
    FOREIGN KEY (`customer_id`)
    REFERENCES `retail_db`.`customers` (`customer_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
```

---

## 1. Foreign Key Requirement
When creating a foreign key, the **referenced column** in the parent table **must be indexed**.

- Best practice → make it a **PRIMARY KEY**.
- Error I hit:  
  `ERROR 1822: Failed to add the foreign key constraint. Missing index for constraint ... in the referenced table`

**Fix for customers table:**
```sql
ALTER TABLE customers
  MODIFY customer_id INT NOT NULL,
  ADD PRIMARY KEY (customer_id);
```

Workbench automatically adds an index on the child side (`orders.customer_id`) – that is normal and
useful.

---

## 2. Why Workbench Import Wizard is Extremely Slow

The Table Data Import Wizard inserts row-by-row.

For 70k rows it can take forever.

Removing indexes/FK helps only a little.

**Never use the wizard for large CSVs.**

---

## 3. Fast Way – LOAD DATA LOCAL INFILE

### Drop PK / Index / FK from "orders" table for little import speed

```sql
-- Drop FK
ALTER TABLE orders DROP FOREIGN KEY `fk_customer_id`;

-- Drop Index
ALTER TABLE orders DROP INDEX `fk_customer_id_idx`;

-- Drop PK
ALTER TABLE orders DROP PRIMARY KEY;

-- Remove AUTO_INCREMENT
ALTER TABLE orders MODIFY COLUMN order_id INT NOT NULL;
```


### Enable local_infile (both sides)


**Client Side: (MySQL Client - mysql CLI)**

```bash
mysql --local-infile=1 -u root -p retail_db
```

(MySQL Shell 8.0, i.e. `mysqlsh` CLI, did not accept `--local-infile` option on my machine.)


**Server Side: (MySQL Server)**

```sql
SET GLOBAL local_infile = ON;

-- Confirm with:
SHOW GLOBAL VARIABLES LIKE 'local_infile';
```


### Useful settings before loading

```sql
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET AUTOCOMMIT = 0;
```


### Actual load command that worked

```sql
LOAD DATA LOCAL INFILE 'C:/Users/Manish/Dev/SQL/mysql-superstar/datasets/Extracted-01/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'          -- important!
IGNORE 1 LINES
(order_id, order_date, customer_id, order_status);
```

**Key lesson:** Line endings matter a lot.

- Windows-style  → `\r\n`
- Unix/Mac-style → `\n`    ← this was my case
- Sometimes just   `\r`

If you get `Records: 0` with no warnings → almost always wrong line terminator.


Successful `LOAD DATA LOCAL INFILE` command output looks like:

```txt
Query OK, 68883 rows affected (0.58 sec)
Records: 68883  Deleted: 0  Skipped: 0  Warnings: 0
```


**After load:**

```sql
COMMIT;
SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;
SET AUTOCOMMIT = 1;
```

<u>Result:</u> **68,883 rows in 0.58 seconds 🚀**

---

## 4. Handling AUTO_INCREMENT after bulk load

I dropped the PK + AUTO_INCREMENT before loading for speed:
```sql
ALTER TABLE orders
  MODIFY order_id INT NOT NULL,
  DROP PRIMARY KEY;
```


After successful load I put them back:
```sql
ALTER TABLE orders
  MODIFY order_id INT NOT NULL AUTO_INCREMENT,
  ADD PRIMARY KEY (order_id);
```

And, MySQL automatically set `Auto_increment = 68884` (max + 1).

To force it manually:
```sql
ALTER TABLE orders AUTO_INCREMENT = 68884;
```

---

## 5. Handy MySQL CLI trick: \\G

Instead of `;` at end of an SQL statement that shows result set, we can use **`\G`** to get
**vertical output** (one field per line).


Very useful for:

```sql
SHOW TABLE STATUS LIKE 'orders'\G

SHOW CREATE TABLE orders\G

SELECT * FROM orders WHERE order_id = 1\G

DESCRIBE orders\G
```

It’s purely a client-side display trick — it does not change the SQL itself.


---

## Quick Checklist for next large CSV import

1. Use classic MySQL CLI `mysql --local-infile=1` (instead of the newer `mysqlsh` MySQL Shell)
1. When logged in as root, run `SET GLOBAL local_infile = ON;`
1. Disable FK/unique checks + autocommit
1. Match the correct `LINES TERMINATED BY` (Line Endings present in the CSV file)
1. Explicitly list columns
1. Re-add indexes/FK/AUTO_INCREMENT after load
1. Verify with `SELECT COUNT(*)` and `SHOW TABLE STATUS ... \G`
