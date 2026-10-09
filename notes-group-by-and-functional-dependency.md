# GROUP BY and Functional Dependency Notes

## What is a Functional Dependency?

A **functional dependency** describes a relationship between columns (or sets of columns) in a table.

We write it as:

```text
A → B
```

This means:

> If you know the value of A, you can uniquely determine the value of B.

In other words, for any given value of A, there is only **one possible value** of B.

### Simple Example

In an `employees` table:

```text
employeeNumber → firstName
employeeNumber → lastName
```

Because each employee number belongs to exactly one person, knowing the `employeeNumber` tells you exactly what the `firstName` and `lastName` must be.

Functional dependency is the key idea that lets MySQL (and other databases that follow the SQL standard) allow certain non-grouped, non-aggregated columns in the `SELECT` list.

---

## Beginner Rule

When using `GROUP BY`, every column in the `SELECT` list must be either:

- Included in the `GROUP BY` clause, **or**
- Used inside an aggregate function such as:
  - `COUNT()`
  - `SUM()`
  - `AVG()`
  - `MIN()`
  - `MAX()`
  - `GROUP_CONCAT()`

Example:

```sql
SELECT department_id, COUNT(*)
FROM employees
GROUP BY department_id;
```

---

## Advanced Rule (SQL Standard)

A non-aggregated column may also appear in the `SELECT` list if it is **functionally dependent** on the grouped columns.

---

## Single-Table Example

Table:

```text
employees
------------------------------------------------
employeeNumber (PK) | firstName | lastName
------------------------------------------------
1002                | Diane     | Murphy
1056                | Mary      | Patterson
```

Functional dependencies:

```text
employeeNumber → firstName
employeeNumber → lastName
```

Query:

```sql
SELECT
    employeeNumber,
    firstName,
    lastName
FROM employees
GROUP BY employeeNumber;
```

Why is this valid?

Because each `employeeNumber` identifies exactly one employee, so `firstName` and `lastName` are already uniquely determined.

---

## Primary Key Rule

If you group by a Primary Key, then every column of that table is functionally dependent on the grouped column.

Example:

```text
employeeNumber
  → firstName
  → lastName
  → email
  → officeCode
  → jobTitle
```

Therefore this is valid:

```sql
SELECT
    employeeNumber,
    firstName,
    lastName,
    email,
    officeCode,
    jobTitle
FROM employees
GROUP BY employeeNumber;
```

---

## UNIQUE NOT NULL Rule

A `UNIQUE NOT NULL` column generally behaves like a Primary Key for functional dependency purposes.

Example:

```text
username → firstName
username → lastName
```

Therefore grouping by `username` may allow selecting `firstName` and `lastName`.

---

## Two-Table INNER JOIN Example

Table: `employees`

```text
employeeNumber (PK) | firstName
--------------------|----------
1002                | Diane
1056                | Mary
```

Table: `customers`

```text
customerName          | salesRepEmployeeNumber
----------------------|-----------------------
Signal Gift Stores    | 1002
Mini Wheels Co.       | 1002
Australian Gifts      | 1056
```

Query:

```sql
SELECT
    employeeNumber,
    firstName,
    GROUP_CONCAT(DISTINCT customerName ORDER BY customerName)
FROM employees
INNER JOIN customers
    ON customers.salesRepEmployeeNumber = employeeNumber
GROUP BY employeeNumber;
```

Result:

```text
employeeNumber | firstName | GROUP_CONCAT(customerName)
---------------|-----------|---------------------------------
1002           | Diane     | Mini Wheels Co.,Signal Gift Stores
1056           | Mary      | Australian Gifts
```

Why is `firstName` allowed?

Because:

```text
employeeNumber → firstName
```

and `employeeNumber` is the grouped column.

This is the same idea used in the MySQL `GROUP_CONCAT()` tutorial example.

---

## Example of an Invalid Query

Table:

```text
department_id | employee_name
--------------|--------------
10            | John
10            | Mary
10            | Steve
```

Query:

```sql
SELECT
    department_id,
    employee_name,
    COUNT(*)
FROM employees
GROUP BY department_id;
```

Problem:

```text
department_id = 10

Which employee_name should be returned?

John?
Mary?
Steve?
```

There is no single correct value, so the query is invalid.

---

## SQL Standard vs Database Support

**SQL Standard**
- Allows functionally dependent columns in grouped queries.

**MySQL**
- Supports functional dependency detection (since 5.7.5).
- Common case: grouping by a Primary Key or `UNIQUE NOT NULL` column.
- Controlled by `ONLY_FULL_GROUP_BY` SQL mode (enabled by default).

**PostgreSQL**
- Also supports functional dependency detection.
- Most commonly recognized when grouping by a table's Primary Key.

---

## Mental Model

**Beginner rule:**

```text
SELECT columns
⊆ GROUP BY columns
  + aggregate expressions
```

**Advanced rule:**

```text
SELECT columns
⊆ GROUP BY columns
  + aggregate expressions
  + functionally dependent columns
```

**Key takeaway:**

```text
Primary Key
  ⇒ determines the entire row

UNIQUE NOT NULL
  ⇒ usually determines the entire row

Therefore:

GROUP BY a key
  ⇒ may allow selecting other columns
    without listing them in GROUP BY
```
