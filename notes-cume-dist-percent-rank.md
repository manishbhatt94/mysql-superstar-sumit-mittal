# CUME_DIST() and PERCENT_RANK(): Beginner Notes

---

## 0. The one-minute version

- `ROW_NUMBER / RANK / DENSE_RANK` give a position: "I'm 3rd".
- `CUME_DIST / PERCENT_RANK` give the position as a **fraction from 0 to 1**: "I'm this far along the line".
- Why bother? "3rd" means nothing without the crowd size (3rd of 4 is bad, 3rd of 4,000 is great). A fraction means the same thing for 5 rows or 5 million rows.
- **The biggest idea:** these functions don't know what is "high" or "low", or "good" or "bad". They only know the **FRONT** and the **BACK** of a line. `ORDER BY ASC/DESC` decides which end is the front.

---

## 1. Step zero: what OVER (ORDER BY ...) actually does

It makes all rows stand in a line. That's all it does.

```
ORDER BY marks ASC          (smallest marks stand at the FRONT)

  FRONT                                         BACK
    |                                             |
    v                                             v
  [ 40 ] -> [ 60 ] -> [ 60 ] -> [ 80 ] -> [ 100 ]


ORDER BY marks DESC         (biggest marks stand at the FRONT)

  FRONT                                         BACK
    |                                             |
    v                                             v
  [ 100 ] -> [ 80 ] -> [ 60 ] -> [ 60 ] -> [ 40 ]
```

| Direction | Who stands at the front? |
|---|---|
| `ASC`  | numbers: smallest first. Dates: oldest first. Text: A to Z |
| `DESC` | numbers: largest first. Dates: newest first. Text: Z to A |

**"In front of me" means closer to the front of this line.** It does *not* mean "better" or "higher".

Side note: `OVER (ORDER BY ...)` only sets the line used for the calculation. It does **not** sort the final output of your query. Only the query's own last `ORDER BY` does that.

---

## 2. The two questions (the only two things to remember)

Both functions ask: "where am I standing in the line?" They count it differently.

| Function | The question it answers | Formula in words |
|---|---|---|
| `CUME_DIST` | "What fraction of **ALL** rows are at my spot **or in front of me**?" (me + my tie-mates + everyone ahead) | rows at-or-in-front ÷ N |
| `PERCENT_RANK` | "Of the **OTHER** rows, what fraction is **strictly in front** of me?" (tie-mates are NOT in front) | rows strictly in front ÷ (N - 1) |

N is the number of rows in the partition. If you use no `PARTITION BY`, that is the whole table.

Link to what you already know: **rows strictly in front of me = RANK - 1**. So `PERCENT_RANK = (RANK - 1) / (N - 1)`.

Memory hooks:

- **CUME_DIST = "Crowd up to me."** It counts me, so it is never 0, and the last row is always 1.0.
- **PERCENT_RANK = "People ahead of me."** It doesn't count me, so the first row is always 0.

---

## 3. Worked example: 5 students, marks 40, 60, 60, 80, 100 (N = 5)

### 3a. ORDER BY marks ASC (smallest at the front)

```
 FRONT                                         BACK
  [ 40 ] -> [ 60 ] -> [ 60 ] -> [ 80 ] -> [ 100 ]
```

| Marks | Rows strictly in front | Rows at-or-in-front (incl. me and ties) | CUME_DIST (÷ 5) | PERCENT_RANK (÷ 4) |
|---|---|---|---|---|
| 40  | 0 | 1 | **0.2** | **0**    |
| 60  | 1 | 3 | **0.6** | **0.25** |
| 60  | 1 | 3 | **0.6** | **0.25** |
| 80  | 3 | 4 | **0.8** | **0.75** |
| 100 | 4 | 5 | **1.0** | **1.0**  |

Reading it for exam marks, where high marks are good and ASC puts the weakest at the front:
- `CUME_DIST = 0.6` for a 60 means "60% of the class scored 60 or less". This is the textbook **percentile**.
- `PERCENT_RANK = 0.25` for a 60 means "25% of the *others* scored strictly less than me".

### 3b. Same data, ORDER BY marks DESC (biggest at the front)

```
 FRONT                                         BACK
  [ 100 ] -> [ 80 ] -> [ 60 ] -> [ 60 ] -> [ 40 ]
```

| Marks | Rows strictly in front | Rows at-or-in-front (incl. me and ties) | CUME_DIST (÷ 5) | PERCENT_RANK (÷ 4) |
|---|---|---|---|---|
| 100 | 0 | 1 | **0.2** | **0**    |
| 80  | 1 | 2 | **0.4** | **0.25** |
| 60  | 2 | 4 | **0.8** | **0.5**  |
| 60  | 2 | 4 | **0.8** | **0.5**  |
| 40  | 4 | 5 | **1.0** | **1.0**  |

Now the front is the *best* student, so the meaning flips:
- `CUME_DIST = 0.2` for the 100 means "I'm in the **top 20%**". 20% of the class scored 100 or more.
- `CUME_DIST = 0.8` for a 60 means "80% of the class scored 60 or more".
- `PERCENT_RANK = 1.0` for the 40 means "**everyone else** is in front of me".

Same students, same marks, different numbers. Only the direction changed.

---

## 4. Ties: the END vs the START of a tie group

Tied rows stand side by side as a **tie group**.

```
ASC line:   [ 40 ]  [ 60  60 ]  [ 80 ]  [ 100 ]
                    \_______/
                    tie group
```

- `CUME_DIST` looks at the **END** of the tie group. It counts everyone in the group, so both 60s see 3 rows at-or-in-front, giving 3/5 = 0.6.
- `PERCENT_RANK` looks at the **START** of the tie group. It uses `RANK`, so both 60s have rank 2, giving (2-1)/4 = 0.25.

Short version: **CUME_DIST = END of the group, PERCENT_RANK = START of the group.**

---

## 5. Two pictures to hold in your head

### CUME_DIST is a cup filling up

Pour the rows into a cup in line order. Each row is 1/5 of the cup. A tie group is poured in all at once.

```
after 40         |##        |  0.2
after 60, 60     |######    |  0.6   <- both 60s are poured together
after 80         |########  |  0.8
after 100        |##########|  1.0   <- last row always fills the cup
```
`CUME_DIST` = "how full is the cup once I'm in?"

### PERCENT_RANK is a ruler

The first spot is 0, the last spot is 1, and the spots are evenly spaced.

```
 spot  :   0.00      0.25      0.50      0.75      1.00
           |---------|---------|---------|---------|
 row # :     1         2         3         4         5
 marks :  40        60        60        80       100
                      \         /
                       tied: both get 0.25 (the spot of the FIRST of them)
                       spot 0.50 stays empty, just like RANK skips 3
```
`PERCENT_RANK` = "where am I on the ruler?"

---

## 6. How the direction changes the meaning (the key section)

Take the same number, `CUME_DIST = 0.2`:

| Data | ORDER BY | Who is at the front? | `CUME_DIST = 0.2` means |
|---|---|---|---|
| Exam marks (high = good) | `marks ASC`  | lowest scorers  | 20% of the class scored **at or below** me, so I'm near the bottom |
| Exam marks (high = good) | `marks DESC` | highest scorers | 20% of the class scored **at or above** me, so I'm in the **top 20%** |
| Race time (low = good)   | `time ASC`   | fastest runners | 20% finished **at or before** me, so I'm in the **fastest 20%** |
| Race time (low = good)   | `time DESC`  | slowest runners | 20% finished in my time **or slower**, so I'm in the **slowest 20%** |

Look at rows 1 and 3: both use `ASC`, yet a small number is *bad* for marks and *good* for race times. SQL doesn't know which is good, so you must translate.

### The 3-step reading recipe (use it every time)

1. **Which end is the front?** ASC means smallest first. DESC means largest first.
2. **What does a small number mean?** "I'm near the front."
3. **Translate "front" into real words**: biggest spenders, fastest runners, newest orders, and so on.

Quick reference for `CUME_DIST` and `PERCENT_RANK`: a **small** value means near the front, and a **large** value means near the back.

---

## 7. Real-life scenarios

### A. Result card percentile (marks, higher is better)
```sql
CUME_DIST() OVER (ORDER BY marks ASC)
```
A result of 0.9 means 90% of students scored the same as you or less. This is the "90th percentile" you see on entrance exam result cards.

### B. Fastest 10% of runners (time, lower is better)
```sql
CUME_DIST() OVER (ORDER BY race_time ASC) <= 0.10
```
ASC puts the fastest at the front, so the front 10% are the fastest 10%.

### C. Slowest 5% of deliveries (to investigate delays)
```sql
CUME_DIST() OVER (ORDER BY delivery_hours DESC) <= 0.05
```
DESC puts the slowest at the front, so the front 5% are the worst 5%.

### D. Salary standing inside each department (PARTITION BY)
```sql
CUME_DIST() OVER (PARTITION BY dept ORDER BY salary DESC)
```
Each department gets its own line and its own N:

```
   Sales dept (N = 3)                  HR dept (N = 2)
   FRONT ----------> BACK              FRONT -------> BACK
   [70k] -> [50k] -> [30k]             [60k] -> [40k]
    0.33     0.67     1.00              0.50     1.00
```
The 70k Sales employee is in the top 33% of Sales, and the 60k HR employee is in the top 50% of HR. Different group sizes, but the same comparable scale.

### E. Top 20% of orders by Sales (like your Orders table)
```sql
SELECT * FROM (
    SELECT OrderID, Sales,
           CUME_DIST() OVER (ORDER BY Sales DESC) AS DistRank
    FROM Orders
) t
WHERE DistRank <= 0.2;
```
DESC puts the biggest sales at the front, so `<= 0.2` is the top 20% of orders.

### F. Dates also work
`CUME_DIST() OVER (ORDER BY OrderDate ASC)` = "what share of all orders were placed on or before this date?" It is useful for growth tracking.

---

## 8. Which ORDER BY do I need?

| I want... | ORDER BY | Filter / read |
|---|---|---|
| **Top** 20% biggest values  | `col DESC` | `CUME_DIST <= 0.2` |
| **Bottom** 20% smallest values | `col ASC` | `CUME_DIST <= 0.2` |
| Textbook percentile ("X% are at or below me") | `col ASC` | read `CUME_DIST` as is |
| "I'm in the top X%" label | `col DESC` | read `CUME_DIST` as is |
| Fastest 10% (small is good) | `time ASC` | `CUME_DIST <= 0.1` |
| Slowest 10% | `time DESC` | `CUME_DIST <= 0.1` |

The pattern is always the same: **put the group you care about at the front, then take the first X% with `<= X`.**

---

## 9. Common mistakes

1. **Wrong direction.** `ORDER BY Sales ASC` with `<= 0.2` gives the *bottom* 20%, not the top.
2. **Reading the number without checking ORDER BY.** The same 0.2 can mean "top 20%" or "bottom 20%".
3. **Share of rows is not share of money.** `CUME_DIST = 0.8` means 80% of the *orders*, not 80% of the *revenue*.
4. **Expecting PERCENT_RANK to always reach 1.0.** If the last rows tie, it doesn't. For marks 50, 90, 90 the ranks are 1, 2, 2, so `PERCENT_RANK` = 0, 0.5, 0.5. `CUME_DIST`'s last value is always 1.0.
5. **Thinking OVER (ORDER BY) sorts the output.** It doesn't. Add a normal `ORDER BY` at the end if you want sorted output.
6. **`<= 0.2` never returns more than 20% of rows**, but it can return fewer. A tie group that straddles the cutoff gets excluded as a whole, because all its members share the same `CUME_DIST`.

---

## 10. Words decoded

| Word | Plain meaning |
|---|---|
| Distribution | How the values are spread out across the rows |
| Cumulative | Counting up as you go, like a running total |
| Cumulative distribution | How much of the data has been "used up" by this point in the line |
| Percentile | The same fraction times 100 (0.8 = 80th percentile). Textbooks assume ASC order |

---

## 11. Cheat sheet

```
CUME_DIST    = (rows at-or-in-front of me, incl. ties) / N
               never 0 | last row = 1.0 | looks at END of tie group
               "crowd up to me" | cup filling up

PERCENT_RANK = (RANK - 1) / (N - 1)
               first row = 0 | looks at START of tie group
               "people ahead of me" | ruler from 0 to 1

FRONT of line = whatever ORDER BY puts first
    ASC  -> smallest first      DESC -> largest first
SMALL value  = near the front   LARGE value = near the back
```

---

## 12. Practice SQL

Run this and compare the four columns against sections 3a and 3b:

```sql
SELECT marks,
       CUME_DIST()    OVER (ORDER BY marks ASC)  AS cd_asc,
       PERCENT_RANK() OVER (ORDER BY marks ASC)  AS pr_asc,
       CUME_DIST()    OVER (ORDER BY marks DESC) AS cd_desc,
       PERCENT_RANK() OVER (ORDER BY marks DESC) AS pr_desc
FROM (SELECT 40 AS marks UNION ALL SELECT 60 UNION ALL SELECT 60
      UNION ALL SELECT 80 UNION ALL SELECT 100) t
ORDER BY marks;
```

Expected output:

| marks | cd_asc | pr_asc | cd_desc | pr_desc |
|---|---|---|---|---|
| 40  | 0.2 | 0    | 1.0 | 1.0  |
| 60  | 0.6 | 0.25 | 0.8 | 0.5  |
| 60  | 0.6 | 0.25 | 0.8 | 0.5  |
| 80  | 0.8 | 0.75 | 0.4 | 0.25 |
| 100 | 1.0 | 1.0  | 0.2 | 0    |

Then fill in the empty `CUME_DIST` section of your file:

```sql
/* TASK 9:
   Find the Orders that fall within the Highest 40% of Sales
*/
SELECT OrderID, Sales, ROUND(DistRank, 2) AS DistRank FROM (
    SELECT OrderID, Sales,
           CUME_DIST() OVER (ORDER BY Sales DESC) AS DistRank
    FROM Orders
) t
WHERE DistRank <= 0.4;
```
Try changing `DESC` to `ASC` and see what you get.

---

## 13. Quiz

Salaries are **20k, 30k, 30k, 50k**, with `ORDER BY salary DESC`.

1. Write the line from FRONT to BACK.
2. What is `CUME_DIST` for 50k, 30k and 20k?
3. What is `PERCENT_RANK` for 50k, 30k and 20k?
4. In plain words, what does `CUME_DIST = 0.75` mean for the 30k employees?
5. To get the **bottom** 25% of earners with `CUME_DIST <= 0.25`, which direction do you need?

**Answers**

1. 50k -> 30k -> 30k -> 20k.
2. 50k: 1/4 = **0.25**. 30k: 3/4 = **0.75** (both 30ks, plus the 50k). 20k: 4/4 = **1.0**.
3. Ranks are 1, 2, 2, 4, so the formula is (rank-1)/3. 50k: **0**. 30k: 1/3 = **0.33**. 20k: 3/3 = **1.0**.
4. "75% of employees earn 30k or more." The front is the highest earners, so "at-or-in-front" means "same or higher".
5. **ASC**. The line becomes 20k, 30k, 30k, 50k with `CUME_DIST` 0.25, 0.75, 0.75, 1.0, so `<= 0.25` returns just the 20k.

---

## 14. Self-check: you're ready when you can say these without peeking

- [ ] "ORDER BY builds a line, and the functions measure my place in that line."
- [ ] "ASC puts smallest at the front, DESC puts largest at the front."
- [ ] "CUME_DIST counts me and my ties, PERCENT_RANK counts only people strictly ahead."
- [ ] "A small value means near the front. I translate 'front' into real words."
- [ ] "For top X%, I use DESC and `CUME_DIST <= X`."
