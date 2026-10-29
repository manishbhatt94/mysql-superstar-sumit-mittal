# MySQL - Compare SOURCE & TARGET Tables (Interview Questions)

Video Link:
https://www.youtube.com/watch?v=JWCHlb9aAHQ

<br>

---

## Q1: JOINS

Write an SQL query to generate the following output by comparing two tables,
SOURCE and TARGET, using joins and conditional logic. **(MEDIUM)** **(KOCH)**

1. Detect records that are in the SOURCE table but not in the TARGET table and
label them as "New in Source".
1. Detect records that are in the TARGET table but not in the SOURCE table and
label them as "New in Target".
1. Detect records that are in both tables but have different NAME values and
label them as "Mismatch".

The query should combine results from both tables, including appropriate
lables, and order the output by ID. The output should look like this. Write the
SQL query to achieve this output.

```txt
|   ID   |   Comment     |
|--------|---------------|
|    3   | New in Source |
|    4   | Mismatch      |
|    5   | New in Target |
```

Given the following data in SOURCE and TARGET tables:

**SOURCE Table:**

```txt
|   ID   |   NAME   |
|--------|----------|
|    1   |     A    |
|    2   |     B    |
|    3   |     C    |
|    4   |     D    |
```

**TARGET Table:**

```txt
|   ID   |   NAME   |
|--------|----------|
|    1   |     A    |
|    2   |     B    |
|    4   |     X    |
|    5   |     E    |
```

---


## Q2: Counting Bank Accounts by Salary Category | Conditional Aggregation (MEDIUM)

(Ref: [leetcode.com/problems/count-salary-categories/description/](https://leetcode.com/problems/count-salary-categories/description/))


Table: Accounts

