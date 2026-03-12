# Day 04 - DCL + TCL - Grant/Revoke + Commit/Rollback

Some keyword acronyms of **Types of SQL Commands**:

1. **DDL (Data Definition Language)** - SQL commands that deal with the structure of the database tables, either create, modify, or update the structure of the tables. E.g. CREATE TABLE, DROP TABLE, ALTER TABLE, and similar.
2. **DML (Data Manipulation Language)** - SQL commands that are used to add, edit, delete the data or records within a table. E.g. INSERT, UPDATE, DELETE.
3. **DQL (Data Query Language)** - SQL commands that are used to query the existing data. E.g. SELECT.
4. **DCL (Data Control Language)** - SQL commands used for controlling access to database, like create DB users/roles, granting them permissions, revoking their permissions. E.g. CREATE USER, GRANT, REVOKE, and similar. These commands are normally used by DBAs only.
5. **TCL (Transaction Control Language)** - SQL commands used for manually handling transactions - when to commit, when to rollback. E.g. COMMIT, ROLLBACK.

## Giving granular table access to Analytics Firm “AnalyticX”

Let’s say we have below `customers` table:

```sql
CREATE TABLE customers (
    customer_id INT,
    customer_fname VARCHAR(45),
    customer_lname VARCHAR(45),
    customer_email VARCHAR(45),
    customer_phone VARCHAR(45),
    customer_street VARCHAR(255),
    customer_city VARCHAR(45),
    customer_state VARCHAR(45),
    customer_zipcode VARCHAR(45)
);
```

Now, we take services from a vendor firm AnalyticX - which provides business insights & analytics on our data.

But we want to provide the below limited access of the `customers` table to them:

1. People at AnalyticX should not have access to even see the `customer_email`, `customer_phone` and `customer_street` columns - for customer privacy protection reasons. They should only be able to see the other columns.
2. People at AnalyticX should only have read-only access to the table, i.e., they should not be allowed to delete or edit the data, or to alter or drop the table.

### Using a View for limited column visibility

Most RDBMS allow you to create a **VIEW**, which is essentially a stored `SELECT` definition over one or more tables. Whatever columns and rows the `SELECT` statement exposes are what users will see through the view.

In **MySQL**, a view is stored as metadata (the view definition). The view does not store its result set like a table.

Some RDBMS like Postgres have a Materialized View - which stores the VIEW’s data on disk - but when the original source changes, then we need to issue certain SQL commands to “REFRESH” the VIEW.

By creating a VIEW defined as the SELECT over the limited columns of `customers` table, we can satisfy our 1st access control requirement.

How to define this VIEW - Lets call it `customers_v` . Check the CREATE VIEW command below:

```sql
CREATE VIEW customers_v AS
    SELECT 
        customer_id, customer_fname, customer_lname,
        customer_city, customer_state, customer_zipcode
    FROM
        customers;
```

Now we can use SELECT on this VIEW, like a normal SELECT statement, as below. When this statement runs, MySQL expands the view definition and executes the underlying query (and may optimize it as part of the overall query plan).

```sql
SELECT * FROM customers_v LIMIT 5;
```

### Create a Database User

Syntax for creating a database user in MySQL, who can log in using a provided password, is given below, along with an example command. Note we also provide the **client host pattern** (for example, `localhost` for local connections, or a specific client IP like `203.0.113.10`) that determines **where this user is allowed to connect from**.

```sql
-- Syntax:
CREATE USER 'user_name'@'host_name' IDENTIFIED BY 'user_password';
-- Here <user_name>, <host_name> and <user_password> are all provided as string literals
-- i.e. surrounded with single quotes.

-- Example command:
CREATE USER 'analyticsx'@'localhost' IDENTIFIED BY 'mypasswd123';
```

#### What does `%` mean in the hostname?

In MySQL accounts, the identity is `'user'@'host'`.

- `%` in the host part is a **wildcard** that means **“any host”**.
- So, `'analyticsx'@'%'` means this user can attempt to connect **from anywhere** (subject to networking, firewalls, and server settings).
- `'analyticsx'@'localhost'` means this user can connect **only from the same machine** as the MySQL server.

Important: these are **different accounts**, and they can have different passwords and privileges:

- `'analyticsx'@'localhost'`
- `'analyticsx'@'%'`

---

## Putting it all together (end-to-end: least privilege + privacy)

To satisfy both requirements (hide sensitive columns + read-only access), the standard pattern is:

### 1) Create the view (column filtering)

```sql
CREATE VIEW customers_v AS
    SELECT 
        customer_id, customer_fname, customer_lname,
        customer_city, customer_state, customer_zipcode
    FROM
        customers;
```

### 2) Create a dedicated user

```sql
CREATE USER 'analyticsx'@'localhost' IDENTIFIED BY 'mypasswd123';
```

### 3) Grant **only** SELECT on the view (not on the base table)

```sql
GRANT SELECT ON retail_db.customers_v TO 'analyticsx'@'localhost';
```

### 4) Optional: revoke later (remove access)

```sql
REVOKE SELECT ON retail_db.customers_v FROM 'analyticsx'@'localhost';
```

### 5) Optional cleanup: drop user

```sql
DROP USER 'analyticsx'@'localhost';
```

#### Recommended verification checks (after login as the user)

- This should work:

```sql
SELECT * FROM retail_db.customers_v LIMIT 5;
```

- These should fail if you did not grant them:
    - Selecting from the base table:
    
    ```sql
    SELECT * FROM retail_db.customers;
    ```
    
    - DML attempts (should be blocked by privileges):
    
    ```sql
    DELETE FROM retail_db.customers_v WHERE customer_id = 1;
    ```
    

## Login as the MySQL user (quick reference)

```bash
mysql -u analyticsx -h localhost -p -D retail_db
```

Or using MySQL Shell in SQL mode:

```bash
mysqlsh analyticsx@localhost:3306/retail_db --sql
```

---

## TCL (Transaction Control Language): transactions, COMMIT, ROLLBACK

TCL commands let you control *when* changes made by DML statements (like `INSERT`, `UPDATE`, `DELETE`) are permanently saved.

### Autocommit ON vs OFF

- When `autocommit = ON` (common default), each DML statement is committed automatically.
- When `autocommit = OFF`, DML changes stay **pending** until you explicitly `COMMIT` or `ROLLBACK`.

### Example: rollback an accidental delete

```sql
USE retail_db;
SET autocommit = OFF;

DELETE FROM employees WHERE employee_id = 1;
ROLLBACK; -- undo the delete
```

### Example: commit changes (cannot be rolled back after commit)

```sql
DELETE FROM employees WHERE employee_id > 95;
COMMIT; -- make the delete permanent

ROLLBACK; -- no effect now (changes already committed)
```

### Important MySQL behavior: DDL causes an implicit commit

DDL statements (like `CREATE TABLE`, `DROP TABLE`, `ALTER TABLE`) are **implicitly committed** in MySQL.

- This means you cannot roll back a DDL change like `DROP TABLE employees;`.
- Also, if you do DML and then run a DDL statement, the DDL can **force a commit** of your pending DML changes.

Example pattern:

```sql
SET autocommit = OFF;

-- DML (pending)
INSERT INTO employees VALUES (701, 'Goku', 'goku.dbz@gmail.com', '921-192-912', 'Tokyo', 50000.00);

-- DDL (forces an implicit commit)
CREATE TABLE anime ( show_name VARCHAR(100), pilot_date date );

-- Trying to rollback now does nothing (the insert was already committed)
ROLLBACK;
```

### Switch back to autocommit

```sql
SET autocommit = ON;
```

---

## Notes: `information_schema` (MySQL system catalog)

In MySQL, `information_schema` is a built-in database that stores metadata about:

- databases (schemas)
- tables and views
- columns
- privileges, constraints, and more

This is useful when you want to *inspect* the structure of your database using SQL queries (instead of only using commands like `SHOW TABLES`).

### How to tell whether an object is a table or a view

You can check `information_schema.tables` and look at the `table_type` column.

- `BASE TABLE` means it is a real table.
- `VIEW` means it is a view.

Example:

```sql
USE information_schema;
SELECT *
FROM information_schema.tables
WHERE table_schema = 'retail_db';
```

### How to list column metadata for a database

Column details for all tables/views are available in `information_schema.columns`.

Example:

```sql
SELECT *
FROM information_schema.columns
WHERE table_schema = 'retail_db';
```

[Day 04 - SQL Script](https://www.notion.so/Day-04-SQL-Script-32153dba8ae78008816ddb43225aabb1?pvs=21)
