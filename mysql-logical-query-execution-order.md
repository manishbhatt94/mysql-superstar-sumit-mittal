# MySQL Logical Query Execution Order — Study Notes

## 1. What is this concept called?

The order in which SQL clauses are **conceptually processed** by the database engine (regardless of how you *type* them) is called the:

> **Logical Query Processing Order** (also known as **Logical Query Execution Order**, or the **SQL Order of Operations**)

This is a **standard SQL concept** (not MySQL-specific), but it applies to MySQL just as it does to other RDBMS like SQL Server, PostgreSQL, Oracle, etc.

**Key idea:** The order you *write* a SQL query (syntax order) is NOT the order in which it's *logically executed* (execution order). Understanding this gap explains almost every "why doesn't this work?" SQL question.

---

## 2. Syntax Order (how you write it) vs Execution Order (how it's processed)

### Syntax (Written) Order
```sql
SELECT   [DISTINCT] column_list
FROM     table
JOIN     ... ON ...
WHERE    condition
GROUP BY column_list
HAVING   condition
ORDER BY column_list
LIMIT    n OFFSET m;
```

### Logical Execution Order
| Step | Clause              | Purpose                                                   |
|------|----------------------|-----------------------------------------------------------|
| 1    | `FROM`               | Identify source table(s)                                   |
| 2    | `JOIN` + `ON`         | Combine tables, apply join conditions                      |
| 3    | `WHERE`               | Filter individual rows (before grouping)                   |
| 4    | `GROUP BY`            | Group filtered rows into buckets                            |
| 5    | Aggregate functions   | Compute `SUM()`, `COUNT()`, `AVG()`, etc. per group         |
| 6    | `HAVING`              | Filter groups (after aggregation)                            |
| 7    | `SELECT`              | Choose/compute output columns, aliases created here          |
| 8    | `DISTINCT`            | Remove duplicate rows from the result set                    |
| 9    | `ORDER BY`            | Sort the final result set                                    |
| 10   | `LIMIT` / `OFFSET`    | Restrict number of rows returned                              |

**Memory trick:** `FROM → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT`

---

## 3. Why This Matters: Practical Implications

### 3.1 Aggregate functions: allowed in `HAVING`, NOT in `WHERE`

- `WHERE` (step 3) executes **before** grouping/aggregation (steps 4–5) even exist yet.
  So the engine has no aggregated values available to filter on.
- `HAVING` (step 6) executes **after** aggregation, so aggregate functions are valid there.

```sql
-- ❌ Invalid: aggregate function in WHERE
SELECT department, COUNT(*) 
FROM employees
WHERE COUNT(*) > 5      -- ERROR
GROUP BY department;

-- ✅ Valid: aggregate function in HAVING
SELECT department, COUNT(*) 
FROM employees
GROUP BY department
HAVING COUNT(*) > 5;
```

**Rule of thumb:**
- `WHERE` → filters **raw rows**, before grouping.
- `HAVING` → filters **grouped/aggregated results**, after grouping.

---

### 3.2 `SELECT` aliases usable in `ORDER BY`, but NOT in `WHERE`/`GROUP BY`/`HAVING` (standard SQL)

Since `SELECT` (step 7) runs **after** `WHERE`, `GROUP BY`, and `HAVING` (steps 3, 4, 6) — but **before** `ORDER BY` (step 9) — aliases defined in `SELECT` are:

- ❌ Not visible/usable inside `WHERE`, `GROUP BY`, `HAVING` (in strict standard SQL)
- ✅ Usable inside `ORDER BY`

```sql
SELECT salary * 12 AS annual_salary
FROM employees
ORDER BY annual_salary DESC;   -- ✅ Works — alias available (ORDER BY runs after SELECT)
```

```sql
SELECT salary * 12 AS annual_salary
FROM employees
WHERE annual_salary > 100000;  -- ❌ Invalid in strict standard SQL — WHERE runs before SELECT
```

> **MySQL-specific relaxation:** MySQL (as an extension beyond the SQL standard) *does* allow using `SELECT` aliases in `GROUP BY` and `HAVING` clauses (not in `WHERE`, since WHERE always executes before any alias could exist). This is a MySQL convenience feature — not guaranteed to be portable to other databases (e.g., strict PostgreSQL / SQL Server generally disallow alias use in `HAVING`).

```sql
-- MySQL-specific: allowed as convenience
SELECT department, COUNT(*) AS emp_count
FROM employees
GROUP BY department
HAVING emp_count > 5;   -- Works in MySQL (non-standard extension)
```

---

### 3.3 `ORDER BY` and `DISTINCT` interaction

This is a subtle and important rule:

- **Without `DISTINCT`:** `ORDER BY` CAN reference columns that are **not** in the `SELECT` list (since the full underlying row is still logically available at sort time).

```sql
SELECT name FROM employees
ORDER BY hire_date;   -- ✅ Valid — hire_date not selected, but still allowed
```

- **With `DISTINCT`:** `ORDER BY` can ONLY use columns that **are** present in the `SELECT` list.
  Why? Because `DISTINCT` (step 8) collapses rows into a deduplicated result set **before** `ORDER BY` (step 9) runs. Once rows are deduplicated, the engine no longer has access to the original, non-selected column values — only what was projected in `SELECT`.

```sql
SELECT DISTINCT name FROM employees
ORDER BY hire_date;   -- ❌ Invalid (in strict standard behavior) 
                       -- hire_date isn't part of the deduplicated result set
```

```sql
SELECT DISTINCT name, hire_date FROM employees
ORDER BY hire_date;   -- ✅ Valid — hire_date is part of SELECT list
```

> **Note:** MySQL is sometimes lenient here in practice, but conceptually and per the SQL standard, this restriction exists because of the logical order (`DISTINCT` before `ORDER BY`). Relying on non-standard leniency is risky and non-portable — always include ORDER BY columns in the SELECT list when using DISTINCT.

---

### 3.4 `GROUP BY` restricts what can appear in `SELECT`

Once you `GROUP BY` a column, `SELECT` can only contain:
- Columns listed in `GROUP BY`, or
- Aggregate functions (`SUM`, `COUNT`, `AVG`, `MIN`, `MAX`, etc.)

```sql
SELECT department, AVG(salary) 
FROM employees
GROUP BY department;   -- ✅ Valid

SELECT department, employee_name, AVG(salary)
FROM employees
GROUP BY department;   -- ❌ Invalid in strict SQL mode 
                        -- (MySQL allows it under ONLY_FULL_GROUP_BY = OFF, 
                        --  but the returned employee_name is indeterminate)
```

> **MySQL note:** By default (since MySQL 5.7+), `ONLY_FULL_GROUP_BY` SQL mode is **enabled**, enforcing standard behavior. Disabling it allows non-grouped, non-aggregated columns in SELECT, but the value returned for such columns is **arbitrary/non-deterministic** per group.

---

### 3.5 `WHERE` cannot reference `SELECT`-only computed columns; `JOIN...ON` runs before `WHERE`

- Since `FROM`/`JOIN` (steps 1–2) execute before `WHERE` (step 3), join conditions in `ON` are applied first, and `WHERE` further filters the already-joined result.
- This matters especially for `LEFT JOIN`: putting a filter on the right-side table in `WHERE` (instead of `ON`) can turn your `LEFT JOIN` into an effective `INNER JOIN`, because `WHERE` runs after the join and eliminates the unmatched (NULL) rows.

```sql
-- Filter in ON: preserves LEFT JOIN behavior
SELECT * FROM a LEFT JOIN b ON a.id = b.a_id AND b.status = 'active';

-- Filter in WHERE: silently converts to INNER JOIN behavior
SELECT * FROM a LEFT JOIN b ON a.id = b.a_id WHERE b.status = 'active';
```

---

### 3.6 `LIMIT` / `OFFSET` always execute last

Since `LIMIT` (step 10) is the very last step, it operates on the **final, sorted, deduplicated** result set. This is why:
- `LIMIT` combined with `ORDER BY` gives predictable "top-N" results.
- `LIMIT` **without** `ORDER BY` gives no reliable/deterministic row order — the engine may return rows in any order (often physical/storage order, which can change).

---

## 4. Quick Reference Table — What Each Clause Can "See"

| Clause     | Can reference raw columns? | Can reference SELECT aliases? | Can use aggregate functions? |
|------------|:---------------------------:|:-------------------------------:|:-------------------------------:|
| `FROM`     | N/A (defines source)         | ❌                               | ❌                               |
| `WHERE`    | ✅                            | ❌ (standard) / ❌ in MySQL too   | ❌                               |
| `GROUP BY` | ✅                            | ✅ (MySQL extension)              | ❌                               |
| `HAVING`   | ✅                            | ✅ (MySQL extension)              | ✅                               |
| `SELECT`   | ✅                            | N/A (aliases defined here)       | ✅                               |
| `DISTINCT` | Operates on SELECT output    | ✅ (implicitly, via SELECT list) | N/A                              |
| `ORDER BY` | ✅ (only if no DISTINCT)      | ✅                               | ✅ (rarely needed)               |
| `LIMIT`    | N/A                          | N/A                              | N/A                              |

---

## 5. Summary — The Golden Rule

> **A clause can only "see" and use things that were computed by clauses executed BEFORE it in the logical order — regardless of where it's written in the query text.**

Everything above — alias visibility, aggregate function placement, DISTINCT + ORDER BY restrictions, GROUP BY constraints — falls directly out of this one rule combined with the fixed logical order:

```
FROM → JOIN/ON → WHERE → GROUP BY → aggregates → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT/OFFSET
```

Memorizing this pipeline resolves most "why is my SQL query throwing an error" confusion.

<br>

---

<br>

# Appendix

## Appendix 1. Why Filtering in `WHERE` Can Silently Turn a `LEFT JOIN` Into an `INNER JOIN`

This Appendix explains the idea discussed under **Section 3.5** with heading:
> 3.5 `WHERE` cannot reference `SELECT`-only computed columns; `JOIN...ON` runs before `WHERE`


This is one of the most common **silent bugs** in real-world SQL — your query
runs fine, returns no error, but quietly gives you the *wrong* rows. Let's
unpack it slowly, using our Students/Clubs story with one small addition.

### Extending Our Story Slightly

Let's say some clubs get **disbanded** over time (lack of funding, no teacher
supervisor, etc.), but old membership records stay in the database. We add one
new column to `clubs`:

| club_id | club_name        | is_active |
|---------|-------------------|-----------|
| 1       | Photography Club | TRUE      |
| 2       | Robotics Club    | **FALSE** (disbanded this year) |
| 3       | Drama Club       | TRUE      |
| 4       | Debate Club      | TRUE      |

Students, same as before:

| student_name | club_id |
|--------------|---------|
| Aarav        | 1 (Photography) |
| Priya        | 1 (Photography) |
| Kabir        | 2 (Robotics — disbanded) |
| Sneha        | NULL (no club)   |
| Vikram       | 3 (Drama) |

### The Task

The school wants to print **this year's full student roster** — every single
student must appear, no exceptions — but the club name should only show up if
that club is **still running this year**. If a student's club got disbanded
(like Kabir's), or they never had a club (like Sneha), just leave the club
name blank. Nobody should vanish from the roster.

This screams `LEFT JOIN` — "keep every student, no matter what." The only
question is: **where do we put the `is_active = TRUE` condition?**


### Option A: Filter Inside `ON` (Correct)

```sql
SELECT s.student_name, c.club_name
FROM students s
LEFT JOIN clubs c ON s.club_id = c.club_id AND c.is_active = TRUE;
```

**Think of `ON` as the "matching rulebook" — it decides what counts as a real
match, *before* the LEFT JOIN's safety net kicks in.** Here, the rulebook says:
*"Only count it as a real match if the club_id lines up **AND** the club is
active."* Kabir's Robotics Club fails that second part, so — as far as this
join is concerned — Kabir simply **has no matching club**. But that's totally
fine, because `LEFT JOIN`'s whole job is to keep the student anyway, just with
blank club info.

**Result — all 5 students present, exactly as intended:**

| student_name | club_name         |
|--------------|--------------------|
| Aarav        | Photography Club  |
| Priya        | Photography Club  |
| Kabir        | NULL (blank)       |
| Sneha        | NULL (blank)       |
| Vikram       | Drama Club        |



### Option B: Filter Inside `WHERE` (The Silent Bug)

```sql
SELECT s.student_name, c.club_name
FROM students s
LEFT JOIN clubs c ON s.club_id = c.club_id
WHERE c.is_active = TRUE;
```

Looks almost identical, right? But this small change breaks everything.
Here's why — remember, **`WHERE` always runs *after* the join is already
finished** (this is the Logical Execution Order from earlier in your notes:
`FROM`/`JOIN` happens in step 1–2, `WHERE` is step 3).

So let's walk through it in two separate phases, exactly as the database does:

**Phase 1 — The `LEFT JOIN` runs first, with no filtering yet:**

| student_name | club_name (matched) | is_active |
|--------------|----------------------|-----------|
| Aarav        | Photography Club    | TRUE      |
| Priya        | Photography Club    | TRUE      |
| Kabir        | Robotics Club       | **FALSE**    |
| Sneha        | NULL (no match found) | **NULL**  |
| Vikram       | Drama Club          | TRUE      |

Notice: at this point, the `LEFT JOIN` **did its job correctly** — all 5
students are still here. Kabir got matched to Robotics Club (a real match —
the `ON` here only checks `club_id`, nothing else). Sneha got `NULL`s because
she genuinely has no club.

**Phase 2 — `WHERE c.is_active = TRUE` now filters this table, row by row,
with zero awareness that this data came from a LEFT JOIN:**

- Aarav → `is_active = TRUE` → ✅ keep
- Priya → `is_active = TRUE` → ✅ keep
- Kabir → `is_active = FALSE` → ❌ **removed** (fails the condition)
- Sneha → `is_active = NULL` → ❌ **removed** (comparing anything to `NULL`
  is never `TRUE` — it's treated as "unknown," which `WHERE` throws away)
- Vikram → `is_active = TRUE` → ✅ keep

**Final result — only 3 students left:**

| student_name | club_name         |
|--------------|--------------------|
| Aarav        | Photography Club  |
| Priya        | Photography Club  |
| Vikram       | Drama Club        |

**Kabir and Sneha are both gone** — silently. No error, no warning. The query
*looks* like a `LEFT JOIN` in your code, but it *behaves* exactly like an
`INNER JOIN` — because `WHERE` ended up demanding that every surviving row
have a real, matching, active club. That's the exact same requirement an
`INNER JOIN` enforces.


### The One-Sentence Takeaway

> **`ON` filters *while deciding what counts as a match* (so `LEFT JOIN` can
> still protect unmatched rows with `NULL`s). `WHERE` filters *after* the match
> is already decided (so it has no idea those `NULL`s were an intentional
> safety net — it just sees a failed condition and throws the row away).**

**Simple rule of thumb going forward:** if you're using `LEFT JOIN` specifically
*because* you want to keep unmatched left-side rows (like Sneha, or students in
disbanded clubs), then **any condition about the right-hand table (`clubs`)
must go inside `ON`, never inside `WHERE`.** The moment a right-table condition
lands in `WHERE`, you've accidentally rebuilt an `INNER JOIN`.

---

## Appendix 2. How Can `ORDER BY` Use a Column Not in `SELECT`? (Resolving the Apparent Contradiction)

This is a genuinely sharp question — and the confusion comes from a slightly
too-literal reading of "logical order of execution." Let's fix that mental
model.

### The Wrong Mental Model (understandably, what you assumed)

> "SELECT happens before ORDER BY → SELECT must physically shrink each row
> down to only the selected columns → ORDER BY then only receives that
> shrunk-down data → so how can it sort by a column that got thrown away?"

This is logical, but it's based on a mental picture that's slightly off: that
`SELECT` **deletes** the non-selected columns from each row before passing
data downstream. It doesn't. Let's replace that picture with a more accurate one.

### The Correct Mental Model: A Conveyor Belt Carrying Full Boxes

Picture your query as a **conveyor belt** in a factory. Each "box" moving
along the belt is one row, and — this is the key part — **the box still
contains every single column from the original table(s)**, all the way from
`FROM` through `WHERE`, even after it passes the `SELECT` station.

```
FROM/JOIN → WHERE → GROUP BY/HAVING → SELECT → ORDER BY → LIMIT → (final output)
   📦          📦          📦          📦       📦       📦        🧾
 full box   full box    full box    full box,     sorts     trims    print receipt
                                    PLUS a        using     to the   - returns only
                                    "receipt"     any       final    selected columns
                                    🧾 label     column,   rows
                                    is prepared   selected
                                                  or not
```


Here's what actually happens at each station:

- **`FROM`/`JOIN`/`WHERE`/`GROUP BY`:** the full box (every column) moves
  through, getting filtered/grouped along the way.
- **`SELECT`:** this station doesn't strip the box down. It just **prepares
  the final printed receipt** — deciding which columns (and computed
  expressions/aliases) will actually be shown to the customer at the very end.
  The box itself, with all its original columns, keeps moving down the belt.
- **`ORDER BY`:** this station comes right after `SELECT`, and it can still
  reach into the **full box** — not just the receipt — to sort by *any*
  column that survived `WHERE`/`GROUP BY`, whether or not it made it onto the
  receipt.
- **Only at the very end**, after sorting and `LIMIT` are done, does the
  system actually **print the receipt** (i.e., return only the `SELECT`ed
  columns to you) and throw the rest of the box away.

So `SELECT`'s real logical role isn't "shrink the row" — it's **"decide what
gets displayed in the final output,"** which is a separate concern from "what
data is still available for later clauses like `ORDER BY` to use."

### Walking Through An Example

```sql
SELECT first_name
FROM employees
WHERE job_title != 'Manager'
ORDER BY salary DESC
LIMIT 5;
```

1. `FROM employees` → full rows, every column (`first_name`, `salary`,
   `job_title`, `employee_id`, everything).
2. `WHERE job_title != 'Manager'` → filters down to fewer full rows — still
   every column intact, just fewer boxes on the belt.
3. `SELECT first_name` → prepares the "receipt template": *"only print
   `first_name` at the end."* But the full rows (including `salary`) keep
   moving down the belt.
4. `ORDER BY salary DESC` → reaches into the still-full rows and sorts them
   by `salary`, even though `salary` isn't on the receipt.
5. `LIMIT 5` → keeps only the top 5 sorted boxes.
6. **Only now** does the system actually print the receipt — outputting just
   `first_name` for those 5 rows, discarding `salary` from the visible result.

**Real-life analogy to make this stick:** Imagine asking an assistant,
*"Give me the names of the 5 highest-paid non-manager employees."* Your
assistant obviously has to **look at salary** to figure out who the top 5 even
are — they just don't write the salary number down on the final list they
hand you. Looking at data to determine order, and choosing what to print, are
two different jobs. `ORDER BY` needs to *look*; `SELECT` decides what to
*print*. Nothing stops the "looking" step from using a column the "printing"
step leaves out.

### So Why DOES `DISTINCT` Break This, Then?

This is the one exception you already learned, and now you can understand
*why* it's an exception, using the conveyor belt picture.

`DISTINCT` doesn't just prepare a receipt template — it actually **merges
multiple boxes into one**, based only on the receipt columns. Say two
different employees, "Aarav" and "Aarav" (same first name, different
salaries), both end up on the receipt as just `"Aarav"`. `DISTINCT` looks at
the receipt-only view, sees two identical `"Aarav"` entries, and **collapses
them into a single box** — but now, whose salary does that merged box even
belong to? Aarav-1's, or Aarav-2's? There's no correct answer — **the original
full-box identity is gone.**

That's precisely why, once `DISTINCT` is involved, `ORDER BY` **loses access**
to any column not on the receipt — the full boxes genuinely no longer exist
as distinct, individual things by the time `ORDER BY` runs. Without
`DISTINCT`, every box stays fully intact and individually identifiable all the
way through to `ORDER BY`, which is why non-selected columns remain usable.

### The One-Sentence Takeaway

> **The "logical order of execution" governs what each clause is allowed to
> *reference by name* (like a `SELECT` alias), not whether the underlying row
> data still physically exists. Full row data survives all the way to
> `ORDER BY` — the only thing that actually erases it early is `DISTINCT`,
> because merging duplicate rows destroys their individual identity.**

