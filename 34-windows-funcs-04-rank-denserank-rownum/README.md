# MySQL - Window Functions (Part 4): RANK() vs DENSE_RANK() vs ROW_NUMBER()

Video Link:
https://www.youtube.com/watch?v=8LuNYJ0NRV0

<br>

---

## Resources

- [https://www.mysqltutorial.org/mysql-window-functions/mysql-row_number-function/](https://www.mysqltutorial.org/mysql-window-functions/mysql-row_number-function/)
- [https://www.mysqltutorial.org/mysql-window-functions/mysql-rank-function/](https://www.mysqltutorial.org/mysql-window-functions/mysql-rank-function/)
- [https://www.mysqltutorial.org/mysql-window-functions/mysql-dense_rank-function/](https://www.mysqltutorial.org/mysql-window-functions/mysql-dense_rank-function/)


---

## Differences


### ROW_NUMBER()

The `ROW_NUMBER()` is a window function that assigns a sequential number to
each row in the result set. The first number begins with one.


### RANK()

The `RANK()` function assigns a rank to each row within the partition of a
result set. The rank of a row is specified by one plus the number of ranks that
come before it.

Unlike the `ROW_NUMBER()` function, the `RANK()` function **does not always**
return consecutive integers.


### DENSE_RANK()

The `DENSE_RANK()` is a window function that assigns a rank to each row within a
partition or result set with no gaps in ranking values.

The rank of a row is increased by one from the number of distinct rank values
that come before the row.

If a partition has two or more rows with the same rank value, each of these rows will be assigned the same rank.

Unlike the RANK() function, the DENSE_RANK() function always returns consecutive rank values.