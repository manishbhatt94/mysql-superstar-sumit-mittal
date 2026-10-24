# Recursive CTEs in MySQL: Beginner Study Notes

> **Goal:** Understand how a recursive CTE actually runs, step by step, so you can read and write one with confidence.
> **Assumes:** Basic SQL (SELECT, WHERE, JOIN) and basic Java.
> **Tested mentally against:** MySQL 8.0 (recursive CTEs need 8.0 or later).

---

## 1. The big idea in one paragraph

A recursive CTE is **not** recursion like a Java method calling itself. There is **no call stack**, nothing "returns", and nothing "unwinds". It is a **`while` loop that keeps collecting rows**. Each round takes **only the rows created in the previous round**, uses them to produce a new batch of rows, and adds that batch to the final result. The loop stops when a round produces **zero** new rows.

If you remember only one thing: **inside the recursive part, the CTE's name means "the previous round's rows", not "everything collected so far".**

---

## 2. Quick refresher: what is a (non-recursive) CTE?

A **CTE (Common Table Expression)** is a named temporary result you define at the top of a query with `WITH`, then use like a table.

```sql
WITH adults AS (
    SELECT * FROM people WHERE age >= 18
)
SELECT name FROM adults;
```

Think of it as a local variable holding a query result, valid only for this one statement.

A **recursive** CTE is a CTE that **refers to its own name inside its own definition**.

---

## 3. Anatomy of a recursive CTE

```sql
WITH RECURSIVE cte_name (col1, col2, ...) AS (

    -- PART 1: ANCHOR MEMBER (runs exactly once)
    SELECT ...

    UNION ALL      -- (or UNION / UNION DISTINCT)

    -- PART 2: RECURSIVE MEMBER (runs repeatedly)
    SELECT ...
    FROM cte_name          -- <- refers to ITSELF
    WHERE ...              -- <- usually contains the stop condition
)
-- PART 3: OUTER QUERY (runs exactly once, at the very end)
SELECT * FROM cte_name;
```

| Part | Runs how often | Job |
|---|---|---|
| **Anchor member** | Once | Produces the starting rows (like the Java "base case" / initial value) |
| **Recursive member** | Repeatedly, until it produces nothing | Builds new rows from the previous round's rows |
| **`UNION ALL`** | Glue | Appends each round's rows to the result |
| **Outer query** | Once, after the loop is finished | Reads the complete accumulated result |

**Two meanings of the CTE name (this is the key to everything):**

- Inside the recursive member, `cte_name` = **only the rows produced by the previous round**.
- In the outer query, `cte_name` = **the complete accumulated result of all rounds**.

---

## 4. The mental model: a `while` loop (Java version)

```java
// PART 1: anchor, runs once
List<Row> result    = runAnchorQuery();
List<Row> lastBatch = result;            // rows from the previous round

// PART 2: recursive member, runs in a loop
while (!lastBatch.isEmpty()) {
    // Inside the recursive SELECT, the CTE's name means "lastBatch"
    List<Row> newBatch = runRecursiveQuery(lastBatch);

    result.addAll(newBatch);             // UNION ALL: append to the result
    lastBatch = newBatch;                // REPLACE lastBatch, do not append to it
}

// PART 3: outer query, runs once on the finished result
return runOuterQuery(result);
```

### The two variables that matter

| Variable | What happens to it | Meaning |
|---|---|---|
| `result` | **Only grows** (append every round) | What the outer query will see at the end |
| `lastBatch` | **Replaced** every round | What the recursive member sees as the CTE's own name |

Mixing these two up is the **#1 beginner mistake**.

### Loop stops when

`newBatch` is empty (the recursive member returned **0 rows**). That is the equivalent of the recursion "base case".

---

## 5. How this differs from Java recursion

| Java recursion | Recursive CTE |
|---|---|
| Method calls itself, stack grows deeper | A loop repeats, no stack |
| Base case returns a value | Anchor produces starting rows; stop happens when a round yields 0 rows |
| Values flow **back up** as calls return | Rows flow **forward**, each round feeds the next |
| Works on one value/node at a time | Works on a **whole batch (set) of rows** at once |
| Can return a value from each call | Nothing returns; rows are just collected |
| Depth limited by stack size (`StackOverflowError`) | Depth limited by `cte_max_recursion_depth` (error 3636) |

Closest Java analogy: **breadth-first traversal** with a queue, where each round processes one whole "level" (frontier) at a time.

---

## 6. Example 1: Counting from 1 to 3

### The query

```sql
WITH RECURSIVE cte_count (n) AS (
    SELECT 1                              -- anchor: start with n = 1
    UNION ALL
    SELECT n + 1                          -- recursive: add 1 to the previous n
    FROM cte_count
    WHERE n < 3                           -- stop condition
)
SELECT n FROM cte_count;
```

### Plain-English reading

1. Start with the single row `n = 1`.
2. Take the previous round's `n`; if it is less than 3, produce `n + 1`.
3. Repeat until nothing is produced.

### Step-by-step dry run

```
START (anchor runs once)
    anchor produces:   [1]
    result    = [1]
    lastBatch = [1]

ROUND 1
    cte_count (= lastBatch) is [1]
    row n=1: is 1 < 3 ?  YES  -> produce 1+1 = 2
    newBatch  = [2]
    result    = [1, 2]
    lastBatch = [2]                  <- replaced, no longer has the 1

ROUND 2
    cte_count (= lastBatch) is [2]
    row n=2: is 2 < 3 ?  YES  -> produce 2+1 = 3
    newBatch  = [3]
    result    = [1, 2, 3]
    lastBatch = [3]

ROUND 3
    cte_count (= lastBatch) is [3]
    row n=3: is 3 < 3 ?  NO   -> produce nothing
    newBatch  = []                   <- EMPTY, so the loop STOPS

END (outer query runs once)
    SELECT n FROM cte_count   ->   1, 2, 3
```

### Same thing as a table

| Round | What the recursive part sees (`lastBatch`) | What it produces (`newBatch`) | Accumulated `result` |
|---|---|---|---|
| anchor | n/a | `1` | `1` |
| 1 | `1` | `2` | `1, 2` |
| 2 | `2` | `3` | `1, 2, 3` |
| 3 | `3` | *(nothing, 3 < 3 is false)* **STOP** | `1, 2, 3` |

### Final output

```
+---+
| n |
+---+
| 1 |
| 2 |
| 3 |
+---+
```

### Takeaways

- Each round sees exactly **one** row (the one just created), never the older ones.
- The `WHERE n < 3` is what eventually makes the round empty. **Without it, the loop never ends** (until MySQL aborts it, see section 9).

---

## 7. Example 2: Employee hierarchy (org chart)

This is the classic real-world use: tree/hierarchy data stored in **one table** where each row points to its parent.

### Setup data

```sql
CREATE TABLE employees (
    employee_id   INT PRIMARY KEY,
    employee_name VARCHAR(50),
    manager_id    INT                -- points to another row's employee_id
);

INSERT INTO employees VALUES
    (1, 'John Doe',      NULL),      -- CEO, no manager
    (2, 'Jane Smith',    1),         -- reports to John
    (3, 'Bob Johnson',   2),         -- reports to Jane
    (4, 'Alice Brown',   2),         -- reports to Jane
    (5, 'Charlie Davis', 3);         -- reports to Bob
```

### The data as a table

```
employee_id | employee_name | manager_id
------------+---------------+-----------
     1      | John Doe      | NULL
     2      | Jane Smith    | 1
     3      | Bob Johnson   | 2
     4      | Alice Brown   | 2
     5      | Charlie Davis | 3
```

### The same data as a tree

```
John Doe (1)                       <- level 0
 └── Jane Smith (2)                <- level 1
      ├── Bob Johnson (3)          <- level 2
      │    └── Charlie Davis (5)   <- level 3
      └── Alice Brown (4)          <- level 2
```

### The query

```sql
WITH RECURSIVE EmployeeHierarchy AS (
    -- ANCHOR: start from the top (the person with no manager)
    SELECT
        employee_id,
        employee_name,
        manager_id,
        0 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- RECURSIVE: find the direct reports of whoever was found in the previous round
    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        eh.level + 1
    FROM employees e
    INNER JOIN EmployeeHierarchy eh
        ON e.manager_id = eh.employee_id
)
SELECT employee_id, employee_name, manager_id, level
FROM EmployeeHierarchy
ORDER BY level, employee_id;
```

### Understanding the recursive part (the tricky bit)

Two things are joined:

- `employees e`: the **full, normal table** (always all 5 rows, never changes).
- `EmployeeHierarchy eh`: **only the previous round's rows** (changes every round).

The join condition `e.manager_id = eh.employee_id` reads as:

> "Find every employee `e` whose **manager** is one of the people found in the previous round."

In other words: **"give me the direct reports of the people I found last round."** And `eh.level + 1` means "one level deeper than their boss".

### Step-by-step dry run

```
START (anchor runs once)
    anchor: employees with manager_id IS NULL -> John Doe (level 0)
    result    = [John]
    lastBatch = [John]

ROUND 1
    eh (= lastBatch) = [John (id 1)]
    Who has manager_id = 1 ?  -> Jane
    newBatch  = [Jane (level 1)]
    result    = [John, Jane]
    lastBatch = [Jane]

ROUND 2
    eh (= lastBatch) = [Jane (id 2)]
    Who has manager_id = 2 ?  -> Bob, Alice
    newBatch  = [Bob (level 2), Alice (level 2)]
    result    = [John, Jane, Bob, Alice]
    lastBatch = [Bob, Alice]

ROUND 3
    eh (= lastBatch) = [Bob (id 3), Alice (id 4)]
    Who has manager_id = 3 or 4 ?  -> Charlie (manager_id = 3)
    newBatch  = [Charlie (level 3)]
    result    = [John, Jane, Bob, Alice, Charlie]
    lastBatch = [Charlie]

ROUND 4
    eh (= lastBatch) = [Charlie (id 5)]
    Who has manager_id = 5 ?  -> NOBODY
    newBatch  = []                    <- EMPTY, so the loop STOPS

END (outer query runs once)
    SELECT ... ORDER BY level, employee_id  on all 5 rows
```

### Same thing as a table

| Round | `lastBatch` (what `eh` is) | Query: "who reports to them?" | `newBatch` | Accumulated `result` |
|---|---|---|---|---|
| anchor | n/a | `manager_id IS NULL` | John (L0) | John |
| 1 | John | `manager_id = 1` | Jane (L1) | John, Jane |
| 2 | Jane | `manager_id = 2` | Bob (L2), Alice (L2) | John, Jane, Bob, Alice |
| 3 | Bob, Alice | `manager_id IN (3, 4)` | Charlie (L3) | all 5 |
| 4 | Charlie | `manager_id = 5` | *(nobody)* **STOP** | all 5 |

### Final output

```
+-------------+---------------+------------+-------+
| employee_id | employee_name | manager_id | level |
+-------------+---------------+------------+-------+
|           1 | John Doe      |       NULL |     0 |
|           2 | Jane Smith    |          1 |     1 |
|           3 | Bob Johnson   |          2 |     2 |
|           4 | Alice Brown   |          2 |     2 |
|           5 | Charlie Davis |          3 |     3 |
+-------------+---------------+------------+-------+
```

### Why `level` works

`level` is **not** stored in the table. The anchor creates it as `0`, and every round computes `previous level + 1`. Since each round is exactly one level deeper in the tree, the number of the round equals the level.

### Takeaways

- Each round = **one level of the tree** (BFS style).
- The loop ends naturally when the tree runs out of children. No explicit `WHERE` stop condition was needed here, because the data itself ends (the join finds nobody).
- `ORDER BY` goes in the **outer** query, which runs once at the end, not inside each round.

---

## 8. Common mistakes and misconceptions

1. **"The recursive part sees all rows collected so far."**
   Wrong. It sees **only the previous round's rows**. Older rows are already saved in the result and are never processed again.

2. **"Each round's output includes the old rows too."**
   Wrong. Each round outputs **only brand-new rows**. Old rows are never re-output.
   - Counting: round outputs are `[2]`, then `[3]`, never `[2,3]`.
   - Employees: `[Jane]`, then `[Bob, Alice]`, then `[Charlie]`.

3. **Forgetting the final empty round.**
   The loop only ends because a round produced **0 rows**. When tracing by hand, always draw that last empty step.

4. **Thinking of a call stack / return values.**
   There is no stack and no "coming back up". It is a forward-only loop; the answer is simply the accumulation of all rounds.

5. **Treating `eh` / `cte_count` as a fixed table.**
   Inside the recursive member it points to a *different* set of rows each round.

6. **Putting `ORDER BY` / final logic inside the recursive part.**
   Final sorting, filtering and aggregation belong in the outer query.

7. **Forgetting a stop condition on data that can loop forever** (see next section).

---

## 9. Safety, termination and `UNION` vs `UNION ALL`

### Infinite loops

If every round always produces at least one row, the loop never stops. Example (no stop condition):

```sql
WITH RECURSIVE forever (n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM forever      -- no WHERE, never ends
)
SELECT * FROM forever;
```

MySQL protects you with a **recursion depth limit**:

```sql
SHOW VARIABLES LIKE 'cte_max_recursion_depth';   -- default 1000
SET SESSION cte_max_recursion_depth = 5000;      -- change it if you truly need more
```

When the limit is exceeded you get an error (3636) saying the recursion depth was exceeded. A limit exists for runaway queries; do not just raise it to "fix" a missing stop condition.

### Cycles in data

If your data contains a cycle (for example, A's manager is B and B's manager is A), the loop would bounce around forever.

- `UNION ALL` keeps every row, so a cycle goes on forever (until the depth limit).
- `UNION` (= `UNION DISTINCT`) **discards rows already present** in the result, which can break simple cycles.

### `UNION ALL` vs `UNION`

| | `UNION ALL` | `UNION` (DISTINCT) |
|---|---|---|
| Duplicates | Kept | Removed |
| Speed | Faster | Slower (needs duplicate checks) |
| Cycle protection | None | Partial |
| Typical use | Trees (no cycles) | Graphs (possible cycles) |

---

## 10. Rules and restrictions (MySQL 8.0)

- The **anchor** member must **not** reference the CTE itself. It comes first.
- The **recursive** member must reference the CTE **exactly once**, and only in its `FROM` clause (not inside a subquery).
- Column **names** come from the CTE column list (if given), otherwise from the anchor's `SELECT`.
- Column **data types** are decided by the **anchor** member only. If the anchor produces something too narrow (for example a short string) and later rounds produce longer values, they can get truncated or cause an error. Use `CAST(... AS ...)` in the anchor to give the column enough room.
- The recursive member must not use: aggregate functions (`SUM`, `COUNT`, ...), window functions, `GROUP BY`, `ORDER BY`, or `DISTINCT`.
- If the CTE is joined with `LEFT JOIN`, it must not be on the right-hand side of that join.
- Column count and order must match between the anchor and recursive members.

---

## 11. Template to write your own

```sql
WITH RECURSIVE my_cte AS (
    -- 1) Starting rows (once)
    SELECT <columns>, <starting counter or level>
    FROM <table>
    WHERE <what are my starting rows?>

    UNION ALL

    -- 2) Next rows, built from the PREVIOUS round's rows
    SELECT <columns>, <counter or level + 1>
    FROM <table> t
    JOIN my_cte c ON <how does a new row connect to a previous-round row?>
    -- WHERE <optional stop condition>
)
SELECT * FROM my_cte;
```

Three questions to ask yourself when writing one:

1. **Where do I start?** (anchor)
2. **Given a row from the previous round, how do I get the next row(s)?** (recursive member)
3. **When does it stop?** (stop condition in `WHERE`, or data that runs out)

---

## 12. Self-check questions

Try answering before reading the answers.

1. In the recursive part, what does the CTE's own name refer to?
2. After round 2 in the counting example, what are `result` and `lastBatch`?
3. Why is there a "round 3" in the counting example even though it produces nothing?
4. Which variable in the Java loop is *replaced* each round, and which only *grows*?
5. In the employee query, how many times does the outer `ORDER BY level, employee_id` run?
6. What happens if you remove `WHERE n < 3` from the counting example?

<details>
<summary>Answers</summary>

1. Only the rows produced by the **previous round**.
2. `result = [1, 2, 3]`, `lastBatch = [3]`.
3. Because the loop only discovers there is nothing left by *running* the recursive part once more on `[3]`; it returns 0 rows and that is what stops the loop.
4. `lastBatch` is replaced; `result` only grows.
5. **Once**, after all rounds are done.
6. It never stops, until MySQL aborts with a recursion depth exceeded error (default limit 1000).

</details>

---

## 13. Practice exercises

**A. Powers of 2.** Produce `n` from 0 to 5 and `val = 2^n` (1, 2, 4, 8, 16, 32).

<details>
<summary>Solution</summary>

```sql
WITH RECURSIVE powers (n, val) AS (
    SELECT 0, 1
    UNION ALL
    SELECT n + 1, val * 2 FROM powers WHERE n < 5
)
SELECT * FROM powers;
```

Trace: `[ (0,1) ]` -> `[ (1,2) ]` -> `[ (2,4) ]` -> `[ (3,8) ]` -> `[ (4,16) ]` -> `[ (5,32) ]` -> round on `(5,32)` is empty, so stop.

</details>

**B. Everyone under Jane Smith** (all direct and indirect reports, including Jane herself at level 0), using the employees table above.

<details>
<summary>Solution</summary>

```sql
WITH RECURSIVE team AS (
    SELECT employee_id, employee_name, manager_id, 0 AS level
    FROM employees
    WHERE employee_id = 2                        -- start at Jane instead of the CEO

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.manager_id, t.level + 1
    FROM employees e
    JOIN team t ON e.manager_id = t.employee_id
)
SELECT * FROM team ORDER BY level, employee_id;
```

Trace: anchor `[Jane]` -> round 1 `[Bob, Alice]` -> round 2 `[Charlie]` -> round 3 `[]` stop. Result: Jane, Bob, Alice, Charlie.

</details>

**C. (Challenge)** Show each employee together with their full chain of command as text, such as `John Doe > Jane Smith > Bob Johnson`.
Hint: add a `path` column built with `CONCAT(path, ' > ', e.employee_name)`, and use `CAST(employee_name AS CHAR(200)) AS path` in the anchor so the column is wide enough (see the data type rule in section 10).

---

## 14. One-minute summary (cheat sheet)

```
1. Anchor runs ONCE            -> starting rows
2. Recursive part runs in a LOOP, seeing ONLY the previous round's rows
3. Each round's NEW rows are APPENDED to the result (UNION ALL)
4. Each round's NEW rows also REPLACE the "previous round" for the next loop
5. Loop STOPS when a round produces 0 rows
6. Outer query runs ONCE on the full accumulated result
```

Java form:

```java
result = anchor();
lastBatch = result;
while (!lastBatch.isEmpty()) {
    newBatch = recursivePart(lastBatch);
    result.addAll(newBatch);
    lastBatch = newBatch;
}
return outerQuery(result);
```

---

## 15. Further reading

- MySQL Tutorial: https://www.mysqltutorial.org/mysql-basics/mysql-recursive-cte/
- MySQL 8.0 Reference Manual, "WITH (Common Table Expressions)": https://dev.mysql.com/doc/refman/8.0/en/with.html

