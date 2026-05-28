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
