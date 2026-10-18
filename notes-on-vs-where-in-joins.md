# SQL Study Notes: `ON` vs `WHERE` in JOINs

## 1. The Core Idea

| Clause | Answers the question |
|--------|---------------------|
| `ON`   | **How are the two tables related?** (join condition / keys) |
| `WHERE`| **Which joined rows do I keep?** (filtering the result) |

Think of it as:
> `ON` = **how to match** rows  |  `WHERE` = **which matched rows to keep**

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

