# Day 08 - CONSTRAINTS -- Unique, Default, Auto Increment

# UNIQUE KEY Constraint

### Differences between PRIMARY KEY and UNIQUE KEYs

|      Feature     | PRIMARY KEY                                                                                 | UNIQUE KEY                                                                     |
|:----------------:|---------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------|
|   _Null Values_  | **Not Allowed**. Columns must have a value for every row.                                   | **Allowed**. By default, MySQL allows multiple NULL values in a unique column. |
|    _Quantity_    | **One per table**. You can only define a single primary key.                                | **Multiple**. A table can have many unique constraints on different columns.   |
|   _Index Type_   | Typically creates a **Clustered Index**, which dictates the physical storage order of data. | Typically creates a **Non-Clustered Index**.                                   |
|     _Purpose_    | Uniquely identifies each record/row in the table.                                           | Prevents duplicate entries in columns like email or phone number.              |
| _Auto Increment_ | Frequently used with `AUTO_INCREMENT` to generate IDs.                                      | Generally does not support auto-increment.                                     |

We can loosely say that, for the Primary Key of a MySQL table, the participant
columns, kind of implicitly get the uniqueness guarantee and also the NOT NULL
guarantee.

#### How can columns with UNIQUE Constraint hold Multiple NULL values?

One might think that a column with a UNIQUE Constraint, can hold only distinct
values. And so, how can NULL value be allowed to be present in multiple records
at such a column?

The reasoning behind this is that the SQL Standard states that the NULL value
isn't an actual value but it signifies the absence of a value. The standard also
mentions that "the NULL value is not considered equal to any other value,
including itself."

> (Copied from LLM - Google Gemini. May not be entirely accurate!)
>
> According to the ISO/ANSI SQL-92 standard, NULL represents an "unknown" or
> missing value rather than a zero or an empty string. Because NULL is not
> defined, it cannot be compared for equality with any other value—including
> another NULL.

> [!NOTE]
> Check below to see in action, how NULL doesn't compare equal to any value, not
> even itself. And we instead need to use the **IS operator** in ways like
> `IS NULL` and `IS NOT NULL` to check whether or not a value holds NULL.
> ```sql
> SELECT 19 = 19; -- Outputs: 1 (signifying boolean true value).
> SELECT 19 = 11; -- Outputs: 0 (signifying boolean false value).
> SELECT NULL = NULL; -- Outputs: NULL (signifying two empty values cannot be compared).
> SELECT NULL IS NULL; -- Outputs: 1 (signifying boolean true value).
> ```

So, for the purpose of enforcing uniqueness for a UNIQUE Constraint, MySQL can't
interpret two NULL values at the column in two records, as being the same value,
according to the SQL Standard.

Therefore, a UNIQUE Constraint bearing column ALLOWS multiple NULL values in
multiple records.

## MySQL's `UNIQUE KEY` and SQL Standard's `UNIQUE`

Note: (Copied from LLM - Duck AI. May not be entirely accurate!)

A UNIQUE constraint prevents duplicate non-NULL values for a column or column
set; in MySQL it is enforced by creating a unique index.

### Syntax variants (examples)
- Inline unnamed (simple, single column)
```sql
col VARCHAR(100) UNIQUE
```

- Table-level SQL-standard (named constraint)
```sql
CONSTRAINT unq_name UNIQUE (col)
```

- MySQL index-style (named index/key)
```sql
UNIQUE KEY unq_name (col)
-- or
UNIQUE INDEX unq_name (col)
```

- Composite unique (multi-column)
```sql
CONSTRAINT unq_combo UNIQUE (col1, col2)
-- or
UNIQUE KEY unq_combo (col1, col2)
```

- Add after create
```sql
ALTER TABLE t ADD CONSTRAINT unq_name UNIQUE (col);
-- or
ALTER TABLE t ADD UNIQUE KEY unq_name (col);
```

### What they do (behavior)
- Enforce uniqueness: prevent inserting duplicate values for the specified
  column(s).
- Implemented using a unique index internally (so they also speed lookups on
  those columns).
- MySQL allows multiple NULLs in a UNIQUE index (NULLs are not treated as
  equal).
- Duplicate insert attempts raise a duplicate-key error (ER_DUP_ENTRY).

### Practical differences & notes
- Semantic intent:
  - CONSTRAINT ... UNIQUE = declarative, SQL-standard constraint.
  - UNIQUE KEY / UNIQUE INDEX = index-focused, MySQL-style.
- Naming:
  - CONSTRAINT names a constraint; UNIQUE KEY names the index. In MySQL these
    occupy the same namespace for keys/indexes.
- Parser/grammar:
  - Inline unnamed `col ... UNIQUE` is allowed.
  - Inline named `CONSTRAINT name UNIQUE` after a column is not allowed by MySQL
    grammar — name it at table level or use UNIQUE KEY.
- Portability:
  - CONSTRAINT ... UNIQUE is more portable across RDBMS.
  - UNIQUE KEY/UNIQUE INDEX is MySQL-specific syntax (but many DBs support
    UNIQUE INDEX too).
- SHOW CREATE TABLE will usually display unique declarations in MySQL form
  (UNIQUE KEY).
- Performance: no difference in enforcement; both create a unique index, so
  performance characteristics are the same.

### When to use which (quick guidance)
- Use CONSTRAINT ... UNIQUE for clarity and portability (when you want to
  express a data rule).
- Use UNIQUE KEY/UNIQUE INDEX when you are primarily thinking about indexing or
  following MySQL conventions.
- Use inline unnamed UNIQUE for short single-column declarations when you don’t
  need a name.

### Common operations (cheat-sheet)
- Create table with named unique:
```sql
CREATE TABLE t (
  id INT PRIMARY KEY,
  email VARCHAR(100),
  CONSTRAINT unq_email UNIQUE (email)
);
```
- Create table with UNIQUE KEY:
```sql
CREATE TABLE t (
  id INT PRIMARY KEY,
  email VARCHAR(100),
  UNIQUE KEY unq_email (email)
);
```
- Add unique constraint/index:
```sql
ALTER TABLE t ADD CONSTRAINT unq_email UNIQUE (email);
-- or
ALTER TABLE t ADD UNIQUE KEY unq_email (email);
```
- Drop by name:
```sql
ALTER TABLE t DROP INDEX unq_email;
-- (same for constraint name since index is underlying object)
```
- Check definition:
```sql
SHOW CREATE TABLE t;
SHOW INDEX FROM t;
```

### Quick memory aids
- UNIQUE constraint = uniqueness rule + unique index.
- CONSTRAINT = rule (standard); UNIQUE KEY = index (MySQL).
- If you want to name it inline after a column and MySQL errors — move the name
  to a table-level CONSTRAINT or use UNIQUE KEY.

## NOT NULL Constraint along with UNIQUE Constraint

We can also provide NOT NULL constraint together with UNIQUE constraint, on a
<u>particular column</u> (Since NOT NULL is specifically only a per-single-column
constraint).

```sql
DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers` (
    `customer_id` INT,
    `customer_fname` VARCHAR(50),
    `customer_lname` VARCHAR(50),
    `customer_email` VARCHAR(100) NOT NULL UNIQUE,
    `customer_phone` VARCHAR(30),
    `customer_street` VARCHAR(255),
    `customer_city` VARCHAR(50),
    `customer_state` VARCHAR(50),
    `customer_zipcode` VARCHAR(10),
    PRIMARY KEY (`customer_id`)
);
```

> **Note:** A column having a NOT NULL constraint, in addition to a UNIQUE
> Constraint is useful in cases where the value of the column must be unique
> across all records, and the column MUST have a value (i.e. it can't be empty or
> NULL) for any record.
>
> For example, `customer_email` might be falling under this criteria. It need not
> be selected as Primary Key, since for that we have `customer_id`; but we want
> it to be the email present for all records (i.e. Not Null), and to be unique.

<br>

---

<br>

# DEFAULT Constraint

**Note:** Some text & examples are taken from [W3Schools - MySQL DEFAULT Constraint](https://www.w3schools.com/mysql/mysql_default.asp)
page.

The `DEFAULT` constraint is used to automatically insert a default value for a
column, if no value is specified.

The default value will be added to all new records (if no other value is
specified).

### SQL Standard History

* **Standard:** Part of the official core **SQL-92** standard.
* **Purpose:** Allowed developers to explicitly assign a column's default value
  during data modification, instead of just omitting the column name.

### DEFAULT Constraint on CREATE TABLE

The following SQL sets a `DEFAULT` value for the "City" column upon creation of
the "Persons" table:

```sql
CREATE TABLE Persons (
    ID int PRIMARY KEY,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Age int,
    City varchar(255) DEFAULT 'Bengaluru'
);
```

The `DEFAULT` constraint can also be used to insert system values, by using
functions like `CURRENT_DATE()` to insert the current date:

```sql
CREATE TABLE Orders (
    ID int PRIMARY KEY,
    OrderNumber int NOT NULL,
    OrderDate date DEFAULT (CURRENT_DATE())
    -- ⬆️ Noticed the extra surrounding parenthesis around CURRENT_DATE?
    -- This will be covered under using "expressions" as default value.
);
```

### Default Value - Literals & Expressions

> The default value specified in a DEFAULT clause can be **a literal constant**
> *or* **an expression**.
>
> With one exception, **enclose expression default values within parentheses** to
> distinguish them from literal constant default values.
>
> —— <cite>[MySQL 8.4 Reference Manual - Data Type Defaults](https://dev.mysql.com/doc/refman/8.4/en/data-type-defaults.html#data-type-defaults-explicit)</cite>

Examples [^14]:

```sql
CREATE TABLE t1 (
    -- literal defaults:
    i INT         DEFAULT 0,
    c VARCHAR(10) DEFAULT '',
    -- expression defaults:
    f FLOAT       DEFAULT (RAND() * RAND()),
    b BINARY(16)  DEFAULT (UUID_TO_BIN(UUID())),
    d DATE        DEFAULT (CURRENT_DATE + INTERVAL 1 YEAR),
    p POINT       DEFAULT (Point(0,0)),
    j JSON        DEFAULT (JSON_ARRAY())
);
```

The exception is that, for `TIMESTAMP` and `DATETIME` columns, you can specify
the `CURRENT_TIMESTAMP` function as the default, without enclosing parentheses.
This allows for below column defintitions in the CREATE TABLE statements to be
valid:

```sql
-- This is valid, the default value provided is an Expression,
-- but for CURRENT_TIMESTAMP function, there is an exception
-- to not require surrounding it with parentheses.
CREATE TABLE t1 (
  ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  dt DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Below is also valid. This contains syntax for defining the
-- column with "an auto-update value" using `ON UPDATE` clause:
CREATE TABLE t1 (
  ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  dt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**Expressions provided as default value in DEFAULT Clause, must be enclosed within parentheses:**

As stated earlier, aside from the exception case of `CURRENT_TIMESTAMP`
function, other valid expressions supplied to DEFAULT Clause, must be enclosed
within parentheses.

This includes, for instance, the `CURDATE` / `CURRENT_DATE` / `CURDATE()` /
`CURRENT_DATE()` function.

Example of receiving error on not enclosing this within parentheses:

```sql
DROP TABLE IF EXISTS `orders`;

-- Incorrect way below (not enclosing expression within parentheses):
CREATE TABLE `orders` (
  `order_id` INT PRIMARY KEY,
  `customer_id` INT,
  `product_id` INT,
  `quantity` INT,
  `order_date` DATE DEFAULT CURRENT_DATE -- This line gives error!

  -- OR (Equivalent to above - all give same error):
  -- `order_date` DATE DEFAULT CURRENT_DATE()
  -- `order_date` DATE DEFAULT CURDATE
  -- `order_date` DATE DEFAULT CURDATE()
);
-- Error Received:
/*
Error Code: 1064. You have an error in your SQL syntax; check the manual that
  corresponds to your MySQL server version for the right syntax to use near
  'CURRENT_DATE )' at line 6
*/

-- Correct way (enclosed within parentheses):
CREATE TABLE `orders` (
  `order_id` INT PRIMARY KEY,
  `customer_id` INT,
  `product_id` INT,
  `quantity` INT,
  `order_date` DATE DEFAULT (CURRENT_DATE)
);
```

### DEFAULT Constraint on ALTER TABLE

To define a `DEFAULT` constraint on the "City" column when the table is already
created, use the following SQL:

```sql
ALTER TABLE Persons
ALTER City SET DEFAULT 'Bengaluru';
```

### DROP a DEFAULT Constraint

To drop a `DEFAULT` constraint, use the following SQL:

```sql
ALTER TABLE Persons
ALTER City DROP DEFAULT;
```

## Statements (other than CREATE TABLE) where DEFAULT is supported

### A. INSERT Statements (Explicit Value)

You can use `DEFAULT` as a placeholder value inside the `VALUES` clause.

```sql
INSERT INTO users (id, name, status) VALUES (1, 'Alice', DEFAULT);
```

* **PostgreSQL:** Fully supported.
* **MySQL:** Fully supported.

### B. INSERT Statements (Entire Row)

Inserting a row consisting *entirely* of default values has syntax differences:

* **PostgreSQL:** Uses the standard `DEFAULT VALUES` clause.
  ```sql
  INSERT INTO users DEFAULT VALUES;
  ```
* **MySQL:** Does **not** support the standard clause. You must pass an empty
  values list instead.
  ```sql
  INSERT INTO users () VALUES ();
  ```

### C. UPDATE Statements

You can reset an existing column back to its predefined default value.

```sql
UPDATE users SET status = DEFAULT WHERE id = 1;
```

* **PostgreSQL:** Fully supported.
* **MySQL:** Fully supported.

### Summary Cheat Sheet

| Feature | PostgreSQL | MySQL |
| :--- | :---: | :---: |
| `VALUES (..., DEFAULT)` | ✅ Yes | ✅ Yes |
| `SET col = DEFAULT` | ✅ Yes | ✅ Yes |
| `DEFAULT VALUES` clause | ✅ Yes | ❌ No (Use `() VALUES ()`) |

<br>

## ALTER TABLE Variants: ALTER COLUMN vs. MODIFY COLUMN vs. RENAME COLUMN vs. CHANGE COLUMN

> **Note:** This section is LLM generated (Gemini). Beware of hallucinations.

Here is your quick-review study sheet to clearly distinguish between these
commands.

To answer your direct question immediately:

**No, `ALTER TABLE ... ALTER COLUMN` cannot change nullability (NULL/NOT NULL),
data types, or sizes**.

According to the [Official MySQL Documentation](https://dev.mysql.com/doc/refman/9.0/en/alter-table.html),
it is highly specialized and can only be used for two specific property types: [^1] [^2]

  1. **Setting / dropping a column's default value** (`SET DEFAULT` /
     `DROP DEFAULT`).
  2. **Changing column visibility** (`SET VISIBLE` / `SET INVISIBLE`)
     available in MySQL 8.0+. [^1] [^2] [^3] [^4]

### 📝 MySQL Revision Notes: Modifying Columns [^5]

Think of your table column as an object with three attributes: a **Name**, a
**Data Type/Size**, and **Properties** (Default values, Visibility). Choose
your command based on exactly what you want to touch. [^6] [^7]

```txt
       CHANGE COLUMN  ======> Modifies EVERYTHING (Name + Type + Defaults)
      /      ||      \
     /       ||       \
    V        ||        V
[ Name ]  [ Type ]  [ Default / Visibility ]
    ^        ||        ^

    |        ||        |
RENAME    MODIFY     ALTER
COLUMN    COLUMN     COLUMN
```

### 1. ALTER COLUMN (The Surgical Tweaker)

* **Intuition:** It surgically changes only the default value or the structural
  visibility of a column. It leaves the name, data type, and constraints (
  `NOT NULL`, `UNSIGNED`, etc.) completely untouched.
* **Performance:** Extremely fast. It only alters table metadata without rebuilding
  the entire table dataset.
* **Examples:**
  [^3] [^8]
  ```sql
  -- Set a default value:
  ALTER TABLE users ALTER COLUMN status SET DEFAULT 'active';

  -- Remove a default value:
  ALTER TABLE users ALTER COLUMN status DROP DEFAULT;

  -- Hide a column from "SELECT *" (MySQL 8.0+):
  ALTER TABLE users ALTER COLUMN social_security_num SET INVISIBLE;
  ```

### 2. MODIFY COLUMN (The Structural Transformer) [^7]

* **Intuition:** Used when you want to **change the definition** of the column
  (data type, size, or nullability constraints) but want to
  **keep the same name**.
* **Catch:** You must write out the *entire* new definition. If you omit an
  existing property (like `NOT NULL`), MySQL might drop it.
* **Examples:**
  [^2] [^4] [^9]
  ```sql
  -- Expand a column size and make it mandatory:
  ALTER TABLE users MODIFY COLUMN username VARCHAR(100) NOT NULL;

  -- Change data type entirely:
  ALTER TABLE users MODIFY COLUMN age TINYINT UNSIGNED;
  ```

### 3. CHANGE COLUMN (The All-In-One Heavyweight)

* **Intuition:** The legacy powerhouse that can **rename and structurally change**
  a column at the same time.
* **Syntax Quirk:** You must provide **both** the `old_column_name` *and* the
  `new_column_name`, followed by the complete definition — even if you are
  only trying to rename it.
* **Examples:**
  [^2] [^3] [^4] [^6] [^10]
  ```sql
  -- Rename AND change data type at the same time:
  ALTER TABLE users CHANGE COLUMN user_pass password VARCHAR(255) NOT NULL;

  -- Rename ONLY (Requires restating the unchanged data type):
  ALTER TABLE users CHANGE COLUMN phone mobile_number VARCHAR(15);
  ```

### 4. RENAME COLUMN (The Pure Labeler)

* **Intuition:** Added in MySQL 8.0 to fix the annoyance of `CHANGE COLUMN`. It
  **only changes the name** of the column.
* **Benefit:** You do not have to restate the data type, size, or properties.
  They are preserved perfectly automatically.
* **Examples:**
  [^4] [^11] [^12]
  ```sql
  -- Clean and simple renaming:
  ALTER TABLE users RENAME COLUMN fname TO first_name;
  ```

### ⏱️ Quick Memory Matrix

| Command [^2] [^4] [^9] [^13] | Can Rename? | Can Change Type/Size? | Can Change NOT NULL? | Can Change Default? |
|:---|:---:|:---:|:---:|:---:|
| ALTER COLUMN | ❌ | ❌ | ❌ | ✔️ (Plus Visibility) |
| MODIFY COLUMN | ❌ | ✔️ | ✔️ | ✔️ |
| CHANGE COLUMN | ✔️ | ✔️ | ✔️ | ✔️ |
| RENAME COLUMN | ✔️ | ❌ | ❌ | ❌ |

### References

[^1]: [https://dev.mysql.com](https://dev.mysql.com/doc/refman/9.0/en/alter-table.html)
[^2]: [https://dev.mysql.com](https://dev.mysql.com/doc/refman/8.0/en/alter-table-examples.html)
[^3]: [https://hoelz.ro](https://hoelz.ro/ref/mysql-alter-table-alter-change-modify-column)
[^4]: [https://stackoverflow.com](https://stackoverflow.com/questions/14767174/modify-column-vs-change-column)
[^5]: [https://www.youtube.com](https://www.youtube.com/watch?v=xEtUCsqgw8E)
[^6]: [https://stackoverflow.com](https://stackoverflow.com/questions/1356866/how-do-i-change-the-data-type-for-a-column-in-mysql)
[^7]: [https://www.geeksforgeeks.org](https://www.geeksforgeeks.org/mysql/mysql-alter-table-statement/)
[^8]: [https://dev.mysql.com](https://dev.mysql.com/blog-archive/mysql-8-0-innodb-now-supports-instant-add-column/)
[^9]: [https://www.w3schools.com](http://www.w3schools.com/mySQL/mysql_alter.asp)
[^10]: [https://www.techonthenet.com](https://www.techonthenet.com/mysql/tables/alter_table.php)
[^11]: [https://dev.mysql.com](https://dev.mysql.com/doc/refman/9.0/en/alter-table.html)
[^12]: [https://www.w3schools.com](https://www.w3schools.com/sql/sql_alter.asp)
[^13]: [https://www.w3schools.com](http://www.w3schools.com/mySQL/mysql_alter.asp)
[^14]: [https://dev.mysql.com](https://dev.mysql.com/doc/refman/8.4/en/data-type-defaults.html#data-type-defaults-explicit)

