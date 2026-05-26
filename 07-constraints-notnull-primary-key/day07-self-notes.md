# Day 07 - CONSTRAINTS -- Not Null, and Primary Key

# NOT NULL Constraint

We have this `orders` table:

```sql
DROP TABLE IF EXISTS `orders`;

CREATE TABLE orders (
    order_id INT,
    order_item_id INT,
    order_date DATE,
    customer_id INT,
    order_status VARCHAR(30),
    product_id INT,
    quantity INT,
    product_price FLOAT,
    total_price FLOAT
);
```

## Add NOT NULL Constraint

<u>**Goal: Add NOT NULL Constraint to `order_status` column**</u>

Currently, as no columns have NOT NULL constraint, therefore below INSERT
statement works fine:

(This INSERT adds a new record to the table with NULL value in the
`order_status` column.)

```sql
INSERT INTO orders
    (order_id, order_item_id, order_date, customer_id, order_status,
    product_id, quantity, product_price, total_price)
    VALUES
    (1, 1, '2013-07-25', 11599, NULL, 957, 1, 299.98, 299.98);
```

<u>**Add NOT NULL Constraint in CREATE TABLE**</u>

To define a NOT NULL constraint when creating a table, add NOT NULL after the
data type of the column name.

Here, we have CREATE TABLE statement for "orders" table, where we specify the
"order_status" column to have the NOT NULL constraint:

```sql
CREATE TABLE orders (
    ...
    customer_id INT,
    order_status VARCHAR(30) NOT NULL, -- Note: the "NOT NULL" constraint!
    product_id INT,
    ...
);
```

<u>**Add NOT NULL Constraint to column in existing table using ALTER TABLE**</u>

We use the `ALTER TABLE ... MODIFY [COLUMN] <column_name> <constraint(s)>`
variant of ALTER TABLE statement.

Here, we ALTER the structure of existing "orders" table, and modify column
"order_status" to have the NOT NULL constraint:

```sql
ALTER TABLE orders MODIFY COLUMN order_status VARCHAR(30) NOT NULL;
```

In case, there are existing records in the table that have NULL values in this
column ("order_status"), then above ALTER statement for adding NOT NULL
constraint will fail with below error:

```txt
Error Code: 1138. Invalid use of NULL value
```

Then, we need to make sure there are no records that have NULL value for this
column, for example by setting a placeholder value:

```sql
UPDATE orders SET order_status = 'PENDING' WHERE order_status IS NULL;
```

After the above ALTER TABLE command executes successfully (i.e. after our
constraint has been added), we can verify if the constraint is working, by
trying to INSERT an invalid record (having NULL value in "order_status"
column):

```sql
INSERT INTO orders
    (order_id, order_item_id, order_date, customer_id, order_status,
    product_id, quantity, product_price, total_price)
    VALUES
    (1, 2, '2013-07-25', 11599, NULL, 814, 2, 50.00, 100.00);
```

And, we can see that the above command to try inserting an invalid record does
fail, and it gives this error:

```txt
Error Code: 1048. Column 'order_status' cannot be null
```

## Remove the NOT NULL Constraint from a column

We again use the same ALTER TABLE statement's variant as before (when adding
the constraint):

`ALTER TABLE ... MODIFY [COLUMN] <column_name> <constraint(s)>`

When removing the NOT NULL constraint present on a column, we just specify the
constraint as **NULL** in the above `ALTER TABLE` statement - which means that
NULL value(s) are allowed for this column.

Example: Here we remove the NOT NULL constraint from the "orders.order_status"
table column, which will allow the column to accept NULL values again:

```sql
ALTER TABLE orders MODIFY COLUMN order_status VARCHAR(30) NULL;
```

## Omitting column(s) in INSERT Column-List Syntax

Omitting column(s) in INSERT Column-List Syntax triggers the **default value**
of the omitted columns to be placed in the new record.

For any column where we haven't explicitly provided a **default value**, <u>the
value NULL is used by MySQL by default</u> as the **default value**.

So, assuming our "orders" table, currently to have NOT NULL constraint only on
the "order_status" column alone:

- We can execute an INSERT Column-List Syntax statement, and
- omit specifying the column name & value of any column that doesn't have the
  NOT NULL constraint, and
- we can see that, NULL is automatically populated as the value(s) in those
  column(s), in the newly inserted record.

### What if NOT-NULL Constraint column(s) is/are omitted in INSERT statement?

Let's add NOT NULL constraint on all columns of "orders" table, by re-creating
the table, using `DROP TABLE` and `CREATE TABLE` statements as follows:

(Note: We are not providing default values for any of the columns - which is
done when needed using *DEFAULT* clause.)

```sql
DROP TABLE IF EXISTS `orders`;

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_item_id INT NOT NULL,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    product_price FLOAT NOT NULL,
    total_price FLOAT NOT NULL
);
```

Now, let us use the INSERT Column-List syntax to insert a new record while
specifying only two columns in the INSERT statement, and see if the INSERT
statement is allowed or not, and what error is received:

```sql
INSERT INTO orders (order_id, order_item_id) VALUES (1, 1);
```

This above INSERT fails with error:

```txt
Error Code: 1364. Field 'order_date' doesn't have a default value
```

The reason might be:
- All omitted column names/values, trigger the placement of default value
  for those respective columns.
- Since none of these columns have an explicit **default value** specified
  using the *DEFAULT* clause,
- MySQL would, under normal circumstances of the column allowing NULL values,
  place the NULL value in the column.
- But, as these columns are having NOT NULL constraints, above is not an
  option for MySQL.
- So it fails the INSERT statement with an error telling that an explicit
  **default value** is absolutely required (but is missing) from this
  column, if you are not providing a value for the column in the INSERT
  statement.

---


# PRIMARY KEY Constraint


