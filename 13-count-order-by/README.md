# COUNT Function. ORDER BY.

Video Link:
https://www.youtube.com/watch?v=3wLsP6zDsfA

<br>

---

## COUNT(...) Aggregate Function

Reference: [www.mysqltutorial.org/mysql-aggregate-functions/mysql-count/](https://www.mysqltutorial.org/mysql-aggregate-functions/mysql-count/)

The `COUNT()` function is an aggregate function that returns the number of rows in a table. The
`COUNT()` function allows you to count all rows or only rows that match a specified condition.

The return type of the `COUNT()` function is **`BIGINT`**. The `COUNT()` function returns **0** if
there is no matching row found.

The `COUNT()` function has **three** forms:

1. `COUNT(*)`
1. `COUNT(expression)`
1. `COUNT(DISTINCT expression)`


### COUNT(\*) function

The `COUNT(*)` function returns the number of rows in a result set returned by a `SELECT` statement.
The `COUNT(*)` returns the number of rows **including** duplicate, non-NULL and NULL rows.


### COUNT(expression)

The `COUNT(expression)` returns the number of rows that **do not contain** `NULL` values as the
result of the `expression`.


### COUNT(DISTINCT expression)

The `COUNT(DISTINCT expression)` returns the number of **distinct** rows that do not contain `NULL`
values as the result of the `expression`.


### COUNT(\*) function with a GROUP BY example

The `COUNT(*)` function is often used with a `GROUP BY` clause to return the
*number of elements in each group*.

For example, this statement uses the `COUNT()` function with the `GROUP BY` clause to return the
number of products in each product line:

```sql
SELECT 
    productLine, 
    COUNT(*)
FROM
    products
GROUP BY productLine;
```


### COUNT(\*) with a HAVING clause example

For example, to find vendors who supply at least 9 products, you use the `COUNT(*)` function in the
`HAVING` clause as shown in the following query:

```sql
SELECT 
    productVendor, 
    COUNT(*)
FROM
    products
GROUP BY productVendor
HAVING COUNT(*) >= 9
ORDER BY COUNT(*) DESC;
```


### COUNT IF example

You can use a control flow expression and functions e.g., `IF`, `IFNULL`, and `CASE` in the
`COUNT()` function to count rows whose values match a condition.

Example, consider below `orders` table with columns:
```sql
CREATE TABLE orders (
    orderNumber INT AUTO_INCREMENT PRIMARY KEY,
    orderDate DATE,
    requiredDate DATE,
    shippedDate DATE,
    status VARCHAR(30),
    comments TEXT,
    customerNumber INT
);
```

The following query use `COUNT()` with `IF` function to find the number of cancelled, on hold, and
disputed orders from the orders table:

```sql
SELECT 
    COUNT(IF(status = 'Cancelled', 1, NULL)) 'Cancelled',
    COUNT(IF(status = 'On Hold', 1, NULL)) 'On Hold',
    COUNT(IF(status = 'Disputed', 1, NULL)) 'Disputed'
FROM
    orders;
```

<br>

---


## ORDER BY


### ORDER BY clause to sort data using a custom list

Reference: [https://www.mysqltutorial.org/mysql-basics/mysql-order-by/#using-mysql-order-by-clause-to-sort-data-using-a-custom-list](https://www.mysqltutorial.org/mysql-basics/mysql-order-by/#using-mysql-order-by-clause-to-sort-data-using-a-custom-list)


> <u>**MySQL** `FIELD()` function:</u>
> MySQL `FIELD()` function  returns the index (1-based position) of a value within a list of values.
> Syntax:
> ```sql
> FIELD(value, value1, value2, ...)
> ```
>
> In this syntax:
> - `value`: The value for which you want to find the position.
> - `value1, value2, ...`: A list of values against which you want to compare the specified value.
>
> The `FIELD()` function returns the position of the `value` in the list of values
> (`value1, value2, ...` and so on).
>
> If the value is not found in the list, the `FIELD()` function returns **0**.
>
> Example:
> ```sql
> SELECT FIELD(degree_result, 'Honours', 'Distinction', 'First Division', 'Second Division', 'Passed');
> -- Here if `degree_result` has a value in this above list (i.e. 'Honours', 'Distinction',
> -- 'First Division', 'Second Division', 'Passed'), then we get the position number as return, else
> -- we get zero.
> ```
