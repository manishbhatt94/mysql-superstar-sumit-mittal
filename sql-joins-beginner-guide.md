# SQL Joins — A Beginner's Intuitive Guide

> No prior DBMS theory needed. Everything here is taught through **one single
> story**: a school with **Students** and **Clubs**. Keep this story in your head
> for the entire guide — it never changes.

---

## 0. The Story We'll Use Everywhere

Imagine a school with two lists:

**A `clubs` list** (the clubs that exist in school):

| club_id | club_name         |
|---------|-------------------|
| 1       | Photography Club  |
| 2       | Robotics Club     |
| 3       | Drama Club        |
| 4       | Debate Club       |

**A `students` list** (the students, and which club — if any — they've joined):

| student_id | student_name | club_id | mentor_id |
|------------|--------------|---------|-----------|
| 201        | Aarav        | 1       | NULL      |
| 202        | Priya        | 1       | 201       |
| 203        | Kabir        | 2       | NULL      |
| 204        | Sneha        | NULL    | NULL      |
| 205        | Vikram       | 3       | 203       |

Notice two deliberately "messy" real-life details — keep these in mind, they matter later:
- **Sneha (204)** hasn't joined any club yet → her `club_id` is empty/`NULL`.
- **Debate Club (4)** has zero members → no student in the `students` table has `club_id = 4`.

Every join type below answers a different version of the same question:
**"How do I combine the Students list with the Clubs list?"** — the difference is
just *what happens to Sneha and Debate Club* in each case.

```sql
CREATE TABLE clubs (
    club_id   INT PRIMARY KEY,
    club_name VARCHAR(50)
);

CREATE TABLE students (
    student_id   INT PRIMARY KEY,
    student_name VARCHAR(50),
    club_id      INT NULL,
    mentor_id    INT NULL
);

INSERT INTO clubs VALUES
  (1, 'Photography Club'),
  (2, 'Robotics Club'),
  (3, 'Drama Club'),
  (4, 'Debate Club');

INSERT INTO students VALUES
  (201, 'Aarav',  1,    NULL),
  (202, 'Priya',  1,    201),
  (203, 'Kabir',  2,    NULL),
  (204, 'Sneha',  NULL, NULL),
  (205, 'Vikram', 3,    203);
```

---

## 1. What Is a "Join," Intuitively?

Forget SQL for a moment. You already do "joins" in real life:

> You have your **class attendance sheet** (names) and a **library card list**
> (who has a library card). If you want one combined sheet showing *"each
> student, and their library card number if they have one,"* you're mentally
> **joining** the two lists using the student's name as the matching link.

That's all a SQL join is: **line up two tables using a shared value** (here,
`club_id` appears in both `students` and `clubs`), and produce one combined
result. The different join *types* simply differ in **what to do about the
names that don't have a match on the other side.**

---

## 2. Decoding the Confusing Words: "Inner," "Outer," "Full," "Left," "Right"

This is the part that trips up almost everyone, so let's slow way down.

### Picture two overlapping circles

Imagine drawing a circle around your **Students** list and another circle around
your **Clubs** list, and pushing them together so they overlap in the middle —
like a Venn diagram:

```
   STUDENTS circle                              CLUBS circle
 ┌─────────────────────┐                  ┌─────────────────────┐
 │                     │                  │                     │
 │   Sneha             │                  │                     │
 │  (no club yet)      │                  │                     │
 │            ┌────────┼──────────────────┼──────────┐          │
 │            │       Aarav, Priya,       Debate     │          │
 │            │       Kabir, Vikram       Club       │          │
 │            │      (matched with a     (no member) │          │
 │            │       real club)                     │          │
 │            └────────┼──────────────────┼──────────┘          │
 │                     │                  │                     │
 └─────────────────────┘                  └─────────────────────┘
   "OUTER" zone            "INNER" zone         "OUTER" zone
   (only in Students)    (in BOTH — matched)   (only in Clubs)
```

Now the vocabulary basically names **which zone(s) of this picture you want to keep**:

| Word      | What it literally means                                                                    |
|-----------|--------------------------------------------------------------------------------------------|
| **INNER** | Keep only the **middle** overlapping zone — rows that exist on **both** sides. Nothing from the outside crescents.   |
| **OUTER** | Keep the overlapping middle **PLUS** at least one of the outside crescents (the unmatched leftovers). |
| **LEFT**  | When doing an outer join, keep the outside crescent from the table written **first** (the "left" table in your SQL). |
| **RIGHT** | Keep the outside crescent from the table written **second** (the "right" table in your SQL). |
| **FULL**  | Keep **both** outside crescents — nothing from either table is left out. The "full" picture. |

### Why these specific English words?

- **"Inner"** — because the matched rows sit visually in the **inner**, overlapping
  part of the two circles. It's the "inside" bit, shared by both.
- **"Outer"** — because the unmatched rows live in the **outer** part of each
  circle — the part sticking outside the overlap, away from the center.
- **"Left" / "Right"** — purely about **which table you typed first vs. second**
  in your `FROM ... JOIN ...` line. Whichever table name appears on the *left*
  side of the `JOIN` keyword is the "left" table; the one after `JOIN` is the
  "right" table. It's just positional, like reading left-to-right.
- **"Full"** — plain English "full" = complete, nothing missing. A "full" join
  gives you the **complete picture**: every row from both tables, matched where
  possible.

### So why is there no "FULL INNER JOIN" or "LEFT INNER JOIN"?

Because it would be a contradiction:
- **INNER already means "throw away all unmatched rows, no exceptions."**
- **LEFT / RIGHT / FULL all exist specifically to say "keep some unmatched rows."**

Saying "full inner join" is like saying "a completely partial list" — the two
words fight each other. So SQL simply doesn't allow combining `INNER` with
`LEFT`/`RIGHT`/`FULL`. `INNER JOIN` always stands alone.

### One more shortcut that confuses people: the word "OUTER" is optional!

Since `LEFT`, `RIGHT`, and `FULL` are **only ever used for outer joins anyway**
(there's no other kind of left/right/full join), SQL lets you drop the word
`OUTER` entirely:

- `LEFT JOIN` = `LEFT OUTER JOIN` (identical, same result)
- `RIGHT JOIN` = `RIGHT OUTER JOIN` (identical, same result)
- `FULL JOIN` = `FULL OUTER JOIN` (identical, same result)

Most people just write `LEFT JOIN` / `RIGHT JOIN` and skip the word `OUTER`
altogether — that's why you'll see both forms in real code.

**Quick recap table:**

| SQL keyword                     | Keeps middle (matched)? | Keeps Students-only leftovers? | Keeps Clubs-only leftovers? |
|---------------------------------|:----:|:---:|:---:|
| `INNER JOIN`                    | ✅  | ❌  | ❌  |
| `LEFT JOIN` (= LEFT OUTER)      | ✅  | ✅  | ❌  |
| `RIGHT JOIN` (= RIGHT OUTER)    | ✅  | ❌  | ✅  |
| `FULL JOIN` (= FULL OUTER)      | ✅  | ✅  | ✅  |

Keep this table in your head — everything below is just this table, demonstrated with real rows.

---

## 3. `INNER JOIN` — "Only Show Me Real Matches"

**Plain-English meaning:** "Give me students **and** their club name, but only
for students who actually **have** a club. Skip anyone/anything without a match
on both sides."

**What survives from our story:** Aarav, Priya, Kabir, Vikram (all have a real
club) ✅. **Sneha is dropped** (no club) ❌. **Debate Club is dropped** (no
student) ❌.

| student_name | club_name          |
|--------------|--------------------|
| Aarav        | Photography Club   |
| Priya        | Photography Club   |
| Kabir        | Robotics Club      |
| Vikram       | Drama Club         |

**Real-life moment you'd use this:** You're printing **club membership badges**.
You only want students who are actually in a club — no point printing a badge
for Sneha (no club) or handing out a badge for an empty Debate Club.

```sql
-- Identical in MySQL and PostgreSQL
SELECT s.student_name, c.club_name
FROM students s
INNER JOIN clubs c ON s.club_id = c.club_id;
```

---

## 4. `LEFT JOIN` — "Show Me Everyone on the Left List, No Matter What"

**Plain-English meaning:** "Give me **every single student**, and their club
name if they have one — but don't drop a student just because they don't have a
club yet. If there's no match, just leave the club name blank."

**What survives:** All 5 students, including Sneha (with a blank/`NULL` club
name). Debate Club is still dropped — it's not in the *Students* list, and this
join only "protects" the left table (`students`).

| student_name | club_name          |
|--------------|--------------------|
| Aarav        | Photography Club   |
| Priya        | Photography Club   |
| Kabir        | Robotics Club      |
| Sneha        | NULL               |
| Vikram       | Drama Club         |

**Real-life moment:** The class teacher wants a **full class roster** to hand
out at parent-teacher meetings — showing club involvement where it exists, but
still listing every student, including ones like Sneha who haven't joined a
club (so the teacher can encourage her to join one).

```sql
-- Identical in MySQL and PostgreSQL
SELECT s.student_name, c.club_name
FROM students s
LEFT JOIN clubs c ON s.club_id = c.club_id;
```

> **Memory trick:** "LEFT" = the table you wrote on the **left of the word
> `JOIN`** is the one that's fully protected. Every row from it survives, no
> matter what.

---

## 5. `RIGHT JOIN` — "Show Me Everyone on the Right List, No Matter What"

**Plain-English meaning:** Exact mirror image of `LEFT JOIN`. "Give me **every
club**, and its members if it has any — but don't drop a club just because
nobody's joined it yet."

**What survives:** All 4 clubs, including Debate Club (with a blank/`NULL`
student name). Sneha is dropped this time — she's not tied to any club, and
this join only protects the *Clubs* list.

| student_name | club_name          |
|--------------|--------------------|
| Aarav        | Photography Club   |
| Priya        | Photography Club   |
| Kabir        | Robotics Club      |
| Vikram       | Drama Club         |
| NULL         | Debate Club        |

**Real-life moment:** The school admin is preparing next year's **club funding
report** and needs to see **every club that exists**, including brand-new ones
with zero members yet (like Debate Club), to decide if it needs a promotional
push.

```sql
-- Identical in MySQL and PostgreSQL
SELECT s.student_name, c.club_name
FROM students s
RIGHT JOIN clubs c ON s.club_id = c.club_id;
```

> **Practical tip:** Most people rarely write `RIGHT JOIN` in real code — they
> just swap the table order and use `LEFT JOIN` instead, since it's easier to
> read left-to-right:
> ```sql
> SELECT s.student_name, c.club_name
> FROM clubs c
> LEFT JOIN students s ON s.club_id = c.club_id;   -- same result as the RIGHT JOIN above
> ```

---

## 6. `FULL JOIN` — "Show Me Absolutely Everything From Both Lists"

**Plain-English meaning:** "Give me every student AND every club. Match them up
where possible. Don't drop **anything** from either side, ever."

**What survives:** Everyone and everything — Sneha (no club) AND Debate Club (no
student) both appear.

| student_name | club_name          |
|--------------|--------------------|
| Aarav        | Photography Club   |
| Priya        | Photography Club   |
| Kabir        | Robotics Club      |
| Sneha        | NULL               |
| Vikram       | Drama Club         |
| NULL         | Debate Club        |

**Real-life moment:** End-of-year **school activity audit** — you need one
report showing *both* "students not yet involved in any club" *and* "clubs that
never got any members," so the school can decide where to intervene next year.

```sql
-- ✅ PostgreSQL: works directly
SELECT s.student_name, c.club_name
FROM students s
FULL JOIN clubs c ON s.club_id = c.club_id;
```

```sql
-- ❌ MySQL has no FULL JOIN keyword at all — you build it by
-- combining a LEFT JOIN and a RIGHT JOIN with UNION
SELECT s.student_name, c.club_name
FROM students s
LEFT JOIN clubs c ON s.club_id = c.club_id

UNION

SELECT s.student_name, c.club_name
FROM students s
RIGHT JOIN clubs c ON s.club_id = c.club_id;
```

> **Why `UNION` and not `UNION ALL` here?** `UNION` automatically removes exact
> duplicate rows. The matched rows (Aarav, Priya, Kabir, Vikram) would otherwise
> appear **twice** — once from the `LEFT JOIN` half and once from the `RIGHT
> JOIN` half. Plain `UNION` quietly merges those duplicates into one copy.

---

## 7. `CROSS JOIN` — "Pair Absolutely Everyone With Absolutely Everything"

**Plain-English meaning:** No matching condition at all. "Take every student and
pair them with every single club — even ones they're not in." If there are 5
students and 4 clubs, you get 5 × 4 = **20 rows**.

**Real-life moment:** It's the start of the school year, and you're building a
**"club interest survey"** — a form where every student needs to rate their
interest (1–5) in *every* club, regardless of what they're already in. You need
one row per student-club combination to build that blank form.

```sql
-- Identical in MySQL and PostgreSQL
SELECT s.student_name, c.club_name
FROM students s
CROSS JOIN clubs c;
```

*(Sample of the 20 rows: Aarav–Photography, Aarav–Robotics, Aarav–Drama,
Aarav–Debate, Priya–Photography, Priya–Robotics... and so on for every student
against every club.)*

---

## 8. `SELF JOIN` — "Match a Table Against Itself"

**Plain-English meaning:** Not a new keyword — just a regular join where **both
sides happen to be the same table**, wearing two different "hats" (aliases).

**The story detail we set up for this:** the `students` table has a
`mentor_id` column — some students mentor other, newer students. Aarav mentors
Priya. Kabir mentors Vikram.

**Real-life moment:** The school wants a printed sheet showing **"which senior
student is mentoring which junior student"** — both mentor and student live in
the exact same `students` table, so you join the table to a second "copy" of
itself.

```sql
-- Identical in MySQL and PostgreSQL
SELECT junior.student_name AS student, senior.student_name AS mentor
FROM students junior
LEFT JOIN students senior ON junior.mentor_id = senior.student_id;
```

| student | mentor |
|---------|--------|
| Aarav   | NULL   |
| Priya   | Aarav  |
| Kabir   | NULL   |
| Sneha   | NULL   |
| Vikram  | Kabir  |

> We used `LEFT JOIN` (not `INNER JOIN`) here on purpose — so students **without**
> a mentor (like Aarav, Kabir, Sneha) still show up in the list, just with a
> blank mentor.

---

## 9. Cheat Sheet — "Which Join Do I Reach For?"

| I want to...                                                              | Use this join        |
|---------------------------------------------------------------------------|----------------------|
| Only see clean, fully-matched pairs (both sides confirmed)                | `INNER JOIN`         |
| See **every row from my main/left table**, matched info if it exists      | `LEFT JOIN`          |
| See **every row from the other/right table**, matched info if it exists   | `RIGHT JOIN`         |
| See **absolutely everything from both tables**, matched or not            | `FULL JOIN`          |
| Generate **every possible combination** of two lists                      | `CROSS JOIN`         |
| Compare rows **within the same table** to each other                      | `SELF JOIN`          |

---


## 10. `NATURAL JOIN` — "Auto-Match on Whatever Column Name Matches"

**Plain-English meaning:** "Don't make me write `ON s.club_id = c.club_id` — just
look at both tables, find the column(s) with the **same name** in both, and
match on that automatically."

In our story, `students` and `clubs` both have a column called `club_id` — so
`NATURAL JOIN` quietly does exactly what `INNER JOIN ... ON s.club_id =
c.club_id` does, just with less typing.

**What survives:** Identical result to `INNER JOIN` from Section 3 — Aarav,
Priya, Kabir, Vikram. Sneha and Debate Club are still dropped (natural join is
just an inner join under the hood, by default).

| student_name | club_name          |
|--------------|--------------------|
| Aarav        | Photography Club   |
| Priya        | Photography Club   |
| Kabir        | Robotics Club      |
| Vikram       | Drama Club         |

**Real-life moment:** You're quickly poking around the database in a SQL
console, just exploring — you already know `club_id` is the obvious shared
column, and you don't want to type out the full `ON` condition for a
throwaway query.

```sql
-- Identical in MySQL and PostgreSQL
SELECT student_name, club_name
FROM students
NATURAL JOIN clubs;
```

> **Why this is risky in real, long-lived code:** Imagine someone later adds a
> `notes` column to **both** `students` and `clubs` (for unrelated reasons —
> maybe teacher remarks on one, club description on the other). Your
> `NATURAL JOIN` would **silently** start also trying to match rows where
> `notes` is equal too — even though you never asked for that, and the column
> name overlap was a total coincidence. Your query's behavior changes without
> you touching a single line of your SQL. That's why most real-world codebases
> avoid `NATURAL JOIN` and prefer being explicit with `ON` (or `USING`, next
> section) — explicit is safer than automatic here.

---

## 11. `JOIN ... USING (column)` — "Auto-Match, But I'll Tell You Which Column"

**Plain-English meaning:** A middle ground between `INNER JOIN ... ON` (fully
explicit) and `NATURAL JOIN` (fully automatic). "Match these two tables on
`club_id` specifically — I'm naming it myself, so there's no guessing."

**What survives:** Same result as `INNER JOIN` again — Aarav, Priya, Kabir,
Vikram.

```sql
-- Identical in MySQL and PostgreSQL
SELECT student_name, club_name
FROM students
JOIN clubs USING (club_id);
```

**Real-life moment:** Same badge-printing scenario as `INNER JOIN` (Section 3),
but you'd reach for `USING` instead of `ON` when the column name genuinely is
identical in both tables (`club_id` in both) and you want shorter, cleaner code
— without the unpredictability risk of `NATURAL JOIN`.

**One small but real difference from `ON`:** with `ON`, you get **two separate
columns** in a sense — `s.club_id` and `c.club_id` — and you'd normally pick
one to display. With `USING`, SQL automatically **merges them into a single
output column** called `club_id`, since you told it they represent the same
thing:

```sql
-- With ON: club_id exists twice conceptually (you pick which one to show)
SELECT s.club_id, s.student_name, c.club_name
FROM students s
JOIN clubs c ON s.club_id = c.club_id;

-- With USING: club_id is automatically a single, merged column
SELECT club_id, student_name, club_name
FROM students
JOIN clubs USING (club_id);
```

> **Rule of thumb:** Use `ON` by default (most explicit, most common in real
> code). Reach for `USING` only as a shorthand when the matching column names
> are identical and you like the merged-column behavior. Avoid `NATURAL JOIN`
> in code that will live for a long time.

---

## 12. Semi-Joins and Anti-Joins — "Just Checking If a Match Exists, Not Fetching It"

These aren't a `JOIN` keyword at all — they're written using `WHERE EXISTS` /
`WHERE NOT EXISTS`. But conceptually, they answer join-shaped questions, so
they belong right alongside everything else you've learned.

### The problem they solve

Imagine Photography Club has **two** members (Aarav and Priya). Now ask
yourself: *"Which clubs have at least one member?"* If you tried to answer this
with a plain `INNER JOIN`...

```sql
SELECT DISTINCT c.club_name
FROM clubs c
INNER JOIN students s ON s.club_id = c.club_id;
```

...you'd have to remember to add `DISTINCT`, because Photography Club would
otherwise show up **twice** (once per matching student) — even though you only
asked for club names, not student details. That duplication is a side-effect
of `JOIN` fetching actual matched row-pairs.

**Semi-join fixes this at the root:** instead of "fetch the matching rows,
then clean up duplicates," it just asks **"does at least one match exist? Yes
or no"** — and only ever returns **one copy** of each row from the table you
started with, no `DISTINCT` needed.

### Semi-Join (`EXISTS`) — "Only Clubs That Have Someone"

**Plain-English meaning:** "For each club, check: does at least one student
belong to it? If yes, keep the club (once). If no, drop it. Don't actually
fetch the student's details — I don't need them."

**What survives:** Photography Club, Robotics Club, Drama Club — each listed
**exactly once**, even though Photography Club has 2 members. Debate Club is
dropped (zero members).

| club_name         |
|--------------------|
| Photography Club  |
| Robotics Club     |
| Drama Club        |

**Real-life moment:** The school wants a simple list of **"active clubs"** (any
club with at least one member) to publish on the noticeboard — just club
names, no student data needed, and definitely no duplicate club names.

```sql
-- Identical in MySQL and PostgreSQL
SELECT c.club_name
FROM clubs c
WHERE EXISTS (
    SELECT 1 FROM students s WHERE s.club_id = c.club_id
);
```

### Anti-Join (`NOT EXISTS`) — "Only Clubs That Have Nobody"

**Plain-English meaning:** The exact opposite check — "For each club, does
**zero** students belong to it? If so, keep it."

**What survives:** Only Debate Club (zero members).

| club_name     |
|---------------|
| Debate Club   |

**Real-life moment:** The school admin's **"clubs needing a promotional push"**
report from Section 6 — but this time you only care about the empty-club list
itself, not a combined student+club table with a bunch of `NULL`s in it.

```sql
-- Identical in MySQL and PostgreSQL
SELECT c.club_name
FROM clubs c
WHERE NOT EXISTS (
    SELECT 1 FROM students s WHERE s.club_id = c.club_id
);
```

> You can flip this around too — *"which students have NOT joined any club
> yet?"* (just Sneha) — using the exact same anti-join pattern, starting from
> `students` instead:
> ```sql
> SELECT s.student_name
> FROM students s
> WHERE NOT EXISTS (
>     SELECT 1 FROM clubs c WHERE c.club_id = s.club_id
> );
> ```

**Semi-join vs. anti-join, in one line:** `EXISTS` = "keep me if a match is
found." `NOT EXISTS` = "keep me if a match is NOT found." Same shape,
opposite question.

---

## 13. Updated Cheat Sheet — Including These New Patterns

| I want to...                                                                  | Use this                 |
|-------------------------------------------------------------------------------|--------------------------|
| Only see clean, fully-matched pairs (both sides confirmed)                    | `INNER JOIN`             |
| See **every row from my main/left table**, matched info if it exists          | `LEFT JOIN`              |
| See **every row from the other/right table**, matched info if it exists       | `RIGHT JOIN`             |
| See **absolutely everything from both tables**, matched or not                | `FULL JOIN`              |
| Generate **every possible combination** of two lists                          | `CROSS JOIN`             |
| Compare rows **within the same table** to each other                          | `SELF JOIN`              |
| Quick, throwaway match on same-named columns (exploring, not production code) | `NATURAL JOIN`           |
| Explicit match on a shared column name, shorter than `ON`                     | `JOIN ... USING (col)`   |
| Check "does a match exist?" without duplicating rows or fetching other-side data | `WHERE EXISTS (...)`  |
| Check "does NO match exist?" (find the unmatched/orphaned rows only)          | `WHERE NOT EXISTS (...)` |

---

## 14. Subtle but Important: Bare `JOIN` Always Means `INNER JOIN`

Easy to miss as a beginner, so it deserves its own callout: whenever you see
just the word `JOIN` on its own — with **no** `INNER`, `LEFT`, `RIGHT`, or
`FULL` before it — it always means `INNER JOIN`. Nothing else. No exceptions.

This is true in **standard SQL, MySQL, and PostgreSQL alike** — not a
vendor-specific quirk.

```sql
-- These two queries are 100% identical — same result, same behavior
SELECT s.student_name, c.club_name
FROM students s
JOIN clubs c ON s.club_id = c.club_id;

SELECT s.student_name, c.club_name
FROM students s
INNER JOIN clubs c ON s.club_id = c.club_id;
```

**Why this works:** `INNER` is treated as the "default flavor" of `JOIN` — so
SQL lets you drop the word entirely, purely as a shorthand. It's not a fourth,
separate join type; it's just `INNER JOIN` with less typing.

### The Full "Optional Keyword" Pattern

You already learned that the word `OUTER` is optional after `LEFT`/`RIGHT`/`FULL`
(Section 2). Now that you know bare `JOIN` = `INNER JOIN`, here's the complete,
exhaustive picture of every shorthand SQL allows:

| What you can type       | What it actually means      |
|-------------------------|-----------------------------|
| `JOIN`                  | `INNER JOIN`                |
| `INNER JOIN`            | `INNER JOIN` (no shorthand available — nothing to drop) |
| `LEFT JOIN`             | `LEFT OUTER JOIN`           |
| `RIGHT JOIN`            | `RIGHT OUTER JOIN`          |
| `FULL JOIN`             | `FULL OUTER JOIN`           |

**The key pattern to remember:**
- **`INNER` is the only word that can be dropped completely** — because it's
  the "nothing special happening" default. Say nothing, get `INNER`.
- **`LEFT` / `RIGHT` / `FULL` can never be dropped** — there'd be no way for
  SQL to guess which one you meant.
- **The trailing `OUTER` after `LEFT`/`RIGHT`/`FULL` can always be dropped** —
  because those three words only ever mean an outer join anyway, so spelling
  out `OUTER` is just extra clarity, not extra meaning.

> **Style tip for your own code:** Many teams deliberately always write
> `INNER JOIN` in full (never bare `JOIN`), purely so anyone skimming the query
> can instantly see the join type without needing to remember "bare JOIN means
> inner" as a rule. Both forms are 100% correct SQL — it's just a readability
> preference, not a functional difference.

