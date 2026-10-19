# SQL Study Notes: `ON` vs `WHERE` in JOINs

## 1. The Core Idea

| Clause | Answers the question |
|--------|---------------------|
| `ON`   | **How are the two tables related?** (join condition / keys) |
| `WHERE`| **Which joined rows do I keep?** (filtering the result) |

Think of it as:
> `ON` = **how to match** rows  |  `WHERE` = **which matched rows to keep**


### Sample Scenario

Given below `employees` MySQL table:
```sql
DROP TABLE IF EXISTS employees;
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department_id INT,
    manager_id INT,
    salary DECIMAL(10, 2),
    designation VARCHAR(50)
); 
INSERT INTO employees (employee_id, employee_name, department_id, manager_id, salary, designation) VALUES
(1,    'Rajesh Kumar',     1,    NULL,   200000.00,    'CEO'                  ),    -- No manager.
(2,    'Sonal Gupta',      2,    1,      150000.00,    'VP IT'                ),    -- Reports to Rajesh Kumar.
(3,    'Anita Desai',      2,    2,      120000.00,    'Manager IT'           ),    -- Reports to Sonal Gupta.
(4,    'Vikram Singh',     3,    1,      110000.00,    'VP HR'                ),    -- Reports to Rajesh Kumar.
(5,    'Priya Nair',       2,    3,      130000.00,    'Developer IT'         ),    -- Reports to Anita Desai.
(6,    'Amit Sharma',      3,    4,      100000.00,    'HR Manager'           ),    -- Reports to Vikram Singh.
(7,    'Neha Patil',       4,    1,      140000.00,    'VP Finance'           ),    -- Reports to Rajesh Kumar.
(8,    'Rohit Verma',      4,    7,      90000.00,     'Finance Analyst'      ),    -- Reports to Neha Patil.
(9,    'Kavita Joshi',     2,    3,      125000.00,    'Developer IT'         ),    -- Reports to Anita Desai.
(10,   'Manish Kulkarni',  5,    1,      145000.00,    'VP Marketing'         ),    -- Reports to Rajesh Kumar.
(11,   'Nidhi Agarwal',    5,    10,     95000.00,     'Marketing Manager'    ),    -- Reports to Manish Kulkarni.
(12,   'Suresh Iyer',      4,    7,      85000.00,     'Accountant'           ),    -- Reports to Neha Patil.
(13,   'Ravi Menon',       6,    1,      135000.00,    'VP Operations'        ),    -- Reports to Rajesh Kumar.
(14,   'Anjali Sinha',     6,    13,     105000.00,    'Operations Manager'   ),    -- Reports to Ravi Menon.
(15,   'Tarun Mehta',      2,    2,      115000.00,    'IT Support'           ),    -- Reports to Sonal Gupta.
(16,   'Deepika Rao',      3,    4,      98000.00,     'HR Assistant'         ),    -- Reports to Vikram Singh.
(17,   'Karan Chawla',     5,    10,     92000.00,     'Marketing Analyst'    ),    -- Reports to Manish Kulkarni.
(18,   'Meena Kapoor',     4,    7,      102000.00,    'Finance Manager'      ),    -- Reports to Neha Patil.
(19,   'Sanjay Reddy',     6,    13,     108000.00,    'Logistics Coordinator'),    -- Reports to Ravi Menon.
(20,   'Shweta Tiwari',    2,    3,      127000.00,    'Developer IT'         );    -- Reports to Anita Desa.
```

> [!IMPORTANT]
> _**Scenario to discuss:**_
>
> **We need to find all employees who earn more than their department's average salary.**

---

## 2. INNER JOIN → `ON` vs `WHERE` = SAME RESULT

For **INNER JOIN**, these two are **logically identical** (same rows, same plan):

```sql
-- Style A: filter in WHERE
SELECT e.employee_id, e.salary, d.avg_salary
FROM employees e
INNER JOIN (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
) d ON e.department_id = d.department_id
WHERE e.salary > d.avg_salary;

-- Style B: filter in ON
SELECT e.employee_id, e.salary, d.avg_salary
FROM employees e
INNER JOIN (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
) d ON e.department_id = d.department_id
    AND e.salary > d.avg_salary;
```

Both return the **same 6 employees** (ids: 2, 4, 5, 7, 10, 13).

✅ **Why?** INNER JOIN keeps rows only when `ON` is `TRUE`. Adding extra conditions to `ON` just means "match only if also this" — same set as filtering afterwards.

**MySQL's optimizer usually produces the same execution plan either way.** Performance is not the deciding factor here — **readability is.**

---

## 3. Convention: Prefer `WHERE` for Filters

- **`ON`** → the *relationship*: `e.department_id = d.department_id`
- **`WHERE`** → the *filter*: `e.salary > d.avg_salary`

**Why?**
- Readers instantly see the join key vs. the filter.
- Cleaner when you add more conditions later.
- **Consistent behavior with OUTER JOINs** (see next section — this is the big one).

> 🎯 **Rule of thumb:** Join keys → `ON`. Row filters → `WHERE`.

---

## 4. ⚠️ OUTER JOIN → The Behavior DIFFERS!

**This is the scenario to remember for interviews.**

Using `LEFT JOIN` (keep all employees, annotate with dept average):

### Filter in `WHERE` → kills the LEFT JOIN

```sql
SELECT e.employee_id, e.salary, d.avg_salary
FROM employees e
LEFT JOIN (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees GROUP BY department_id
) d ON e.department_id = d.department_id
WHERE e.salary > d.avg_salary;   -- ← filter here
```

**Result: only 6 rows.** All non-matching employees are removed.
→ The `LEFT JOIN` silently becomes an **INNER JOIN** for this predicate.
*(Why? Rows where `d.avg_salary` is `NULL` fail `>` → `UNKNOWN` → excluded by `WHERE`.)*

### Filter in `ON` → preserves the LEFT JOIN

```sql
SELECT e.employee_id, e.salary, d.avg_salary
FROM employees e
LEFT JOIN (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees GROUP BY department_id
) d ON e.department_id = d.department_id
    AND e.salary > d.avg_salary;   -- ← filter here
```

**Result: all 20 employees.** The 6 above-average get the avg populated; the other 14 get `avg_salary = NULL`.

### 🚨 Golden Rule

> A predicate on the **nullable (outer) side** placed in **`WHERE`** → **turns the OUTER JOIN into an INNER JOIN**.

- Want to **restrict** results → `WHERE`
- Want to **preserve** outer rows with NULLs → `ON`

---

## 5. When Should an Inequality Live in `ON`?

**Non-equi joins** — where the inequality **is** the match condition:

```sql
-- Attach salary band to each employee
SELECT e.employee_name, e.salary, sb.band_name
FROM employees e
JOIN salary_bands sb
  ON e.salary BETWEEN sb.low AND sb.high;   -- inequality IS the join
```

Here `BETWEEN` is *how you match* rows → belongs in `ON`.

Your `e.salary > d.avg_salary` is different: the match is on `department_id`, so the salary comparison is a **post-join filter** → `WHERE`.

---

## 6. Quick Decision Table

| Situation | Put in… |
|-----------|---------|
| Equi-join keys (`a.id = b.a_id`) | `ON` |
| Non-equi join (range, `BETWEEN`, `<`, `>` to **match** rows) | `ON` |
| Filter on joined result (`salary > dept_avg`) | `WHERE` |
| OUTER JOIN — restrict result | `WHERE` (becomes inner) |
| OUTER JOIN — keep unmatched rows (NULLs) | `ON` |

---

## 7. Two Ways to Solve "Above Dept Average"

| Approach | How it works | Notes |
|----------|--------------|-------|
| **Correlated subquery** (in `WHERE`) | Recomputes dept average per employee row | Simple, reads naturally |
| **JOIN with derived table** | Computes avg once per dept, then joins | Usually **more efficient** on large tables; good habit |

Both return the same 6 rows. ✅

---

## 8. Interview Soundbites (memorize)

- *"For INNER JOIN, `ON` and `WHERE` filters are equivalent in result; MySQL's optimizer usually treats them the same."*
- *"`ON` defines the relationship; `WHERE` filters the result — I follow that convention for readability."*
- *"For OUTER JOINs, placing a predicate on the outer side in `WHERE` silently converts it to an INNER JOIN."*
- *"Inequalities belong in `ON` only when they **are** the join condition (non-equi joins)."*
- *"Derived-table JOIN usually beats a correlated subquery for computing aggregates per group."*

---

## 9. Anti-Join Pitfall: `LEFT JOIN ... ON ... IS NULL` (Real Bug Case Study)

**Goal:** Find customers who have **never** placed an order.

### ❌ Broken Query — Returns ALL 12,435 Customers

```sql
SELECT c.*, o.order_id, o.order_date, o.order_status
FROM customers c
LEFT JOIN orders o
       ON c.customer_id = o.customer_id
      AND o.order_id IS NULL;   -- ← WRONG place
```

**Result:** All 12,435 customers, all order columns `NULL`. Not what we wanted.

### Why It Fails — Pipeline Trace

`ON` is evaluated **during** the join to decide *who matches whom*.

| Customer type | `c.customer_id = o.customer_id` | `o.order_id IS NULL` | Combined (`AND`) | Outcome |
|---|---|---|---|---|
| **Has orders** | ✅ TRUE | ❌ FALSE (real order_ids) | ❌ FALSE | No match → NULL-extended row |
| **No orders** | (no rows to test) | — | — | No match → NULL-extended row |

→ **Every** customer hits the NULL-extended fallback → 12,435 rows, order columns all NULL.

**Key insight:** `ON ... AND right_col IS NULL` means *"match only against NULL-valued right rows"* (i.e. never, for a PK-like column). It does **not** mean "keep only unmatched rows."

### The Mental Model

```
LEFT JOIN pipeline:
  1. For each left row, scan right table
  2. Keep pairs where ON is TRUE
  3. If a left row got 0 matches → still emit it with NULLs on the right side
  4. THEN apply WHERE to filter the output
```

- **`ON` = "who gets paired with whom"** (during join)
- **`WHERE` = "which of those pairings do I keep"** (after join)
- "Unmatched" status only exists in the **output** → filter it in `WHERE`.

### ✅ Fix 1 — `LEFT JOIN ... WHERE ... IS NULL` (classic anti-join)

```sql
SELECT c.*
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

| Customer type | `o.order_id` after join | Kept by `WHERE`? |
|---|---|---|
| Has orders | populated (NOT NULL) | ❌ removed |
| No orders | NULL | ✅ kept |

### ✅ Fix 2 — `NOT EXISTS` (clearest intent, NULL-safe)

```sql
SELECT c.*
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
);
```

### ⚠️ Fix 3 — `NOT IN` (careful with NULLs)

```sql
SELECT c.*
FROM customers c
WHERE c.customer_id NOT IN (
    SELECT customer_id FROM orders WHERE customer_id IS NOT NULL  -- guard!
);
```

**Why the guard?** `x NOT IN (1, 2, NULL)` → `UNKNOWN` (never `TRUE`) → returns **zero rows** if any NULL appears in the subquery. In your `orders` schema, `customer_id` is nullable, so this is a real risk.

### Side-by-Side: What the Two ON/WHERE Queries Ask

| Query | Plain-English meaning |
|---|---|
| `ON ... AND o.order_id IS NULL` | "Match customer with an order **whose `order_id` is NULL** (a fake row). Never matches → emit everyone with NULLs." |
| `WHERE o.order_id IS NULL` | "Do the normal join, then keep only rows where **no order was matched**." |

Same words, opposite semantics.

### Anti-Join Styles — Cheat Sheet

| Style | Portable? | NULL-safe? | When to use |
|---|---|---|---|
| `LEFT JOIN ... WHERE right.pk IS NULL` | ✅ | ✅ | Classic, works everywhere |
| `NOT EXISTS (...)` | ✅ | ✅ | **Default choice** — clearest intent |
| `NOT IN (...)` | ✅ | ❌ | Only when subquery column is `NOT NULL` or guarded |

### 🏎️ Performance: Which Does More Work?

**Think in server steps, not Big-O.** All three answer the same question; what differs is **how well MySQL can optimize them**.

| Approach | How MySQL Runs It (Conceptually) | Complexity | Key Caveat |
|---|---|---|---|
| `LEFT JOIN ... IS NULL` | Scan `customers`; for each, look up matching orders; emit NULL-extended row when none found. | **O(C × log O)** with index on `orders.customer_id`. Predictable. | Sometimes the `IS NULL` check blocks certain optimizations — but generally fine for anti-joins. |
| `NOT EXISTS` | Same idea: per customer, check if any order exists; can short-circuit at first match. | **O(C × log O)** with index. MySQL 8.0.17+ often **rewrites it into the exact same anti-join** as `LEFT JOIN`. | Older MySQL (pre-8) had quirks making it marginally slower — largely irrelevant now. |
| `NOT IN` | Build list of `customer_id`s having orders, then scan `customers` and check absence. | **O(C + O)** ideal, but can degrade badly. | **NULL trap**: even one NULL in the subquery → returns empty set. Optimizer often **cannot** use the fast anti-join → falls back to **materializing** the subquery (extra memory/disk I/O). |

**Why `NOT IN` can be the "heaviest":**
1. **Materialize subquery** → build a temporary table of `orders.customer_id`.
2. **Scan the temp table** → extra memory/disk I/O and indexing time.
3. Because of SQL three-valued logic with `NULL`, MySQL **cannot safely** fold it into an efficient anti-join when the column is nullable.

That extra machinery is the "more work" → less predictable, often slower.

### 🎯 Practical Hierarchy (for revision)

1. **`NOT EXISTS`** — **Safest default.** Null-safe, clearest intent, optimized perfectly in modern MySQL.
2. **`LEFT JOIN ... IS NULL`** — **Classic & portable.** Equally fast in MySQL for this pattern.
3. **`NOT IN`** — **Use with caution.** Only when subquery column is `NOT NULL` (or explicitly guarded). Otherwise: performance + correctness trap.

### Interview Soundbite

> "All three methods solve the anti-join problem. In modern MySQL, `NOT EXISTS` and `LEFT JOIN ... IS NULL` are usually rewritten into the same efficient anti-join plan. `NOT IN` can be semantically dangerous with NULLs and often forces the optimizer to materialize the subquery — making it less predictable and potentially slower."

### Rules to Remember

1. **`ON` = matching logic. `WHERE` = output filter.** Predicates on the outer side of a `LEFT JOIN` go in **`WHERE`**.
2. **`WHERE right_col IS NULL` after `LEFT JOIN` = anti-join** ("find rows with no match").
3. **`ON ... AND right_col IS NULL` almost never means what you think** — it means "match against NULL-valued right rows" (usually: never matches).
4. **A `LEFT JOIN` cannot be filtered to "unmatched only" via `ON`.** The unmatched status only exists post-join → must be filtered in `WHERE`.
5. **Prefer `NOT EXISTS`** when writing anti-joins fresh — safest with NULLs and reads like English.
6. **Avoid `NOT IN` on nullable columns** — silent empty results + likely optimizer materialization cost.

