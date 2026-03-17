# Day 05 - Alter Table

ALTER command - Used to change the structure of an existing table.

<aside>
💡

**Can’t we just DROP & Re-CREATE the table with the structure changes?**

This is not the ideal way to update the structure of a table. Dropping a table, just for structure updates, can lead to data loss, if not done properly with backups. Besides, dropping the table, would affect the application program that is using this table.

So, it is better to use the ALTER TABLE command in MySQL.

</aside>

### Tracking orders data in a new `orders` table

We create this `orders` table using below CREATE TABLE statement:

```sql
-- Create `orders` table:
CREATE TABLE orders (
    order_id INT,
    order_item_id INT,
    order_date DATE,
    customer_id INT,
    product_id INT,
    quantity INT,
    product_price FLOAT,
    total_price FLOAT
);

-- Insert data for a couple orders:
INSERT INTO orders VALUES
(1, 1, '2013-07-25', 11599, 957, 1, 299.98, 299.98), -- Order #1
(2, 2, '2013-07-25', 256, 1073, 1, 199.99, 199.99),  -- Order #2
(2, 3, '2013-07-25', 256, 502, 5, 50.00, 250.00),    -- Order #2
(2, 4, '2013-07-25', 256, 403, 1, 129.99, 129.99);   -- Order #2
```

## Add new column for “Order Status”

ALTER TABLE command for adding a new column with name “order_status” to existing table “orders”:

```sql
ALTER TABLE orders ADD COLUMN order_status VARCHAR(20);
```

Two important observations to note after using ALTER TABLE … ADD COLUMN statement to add a new column:

1. **Value of the new column:** What is going to be the value of the records in this new column? (Since we, ourselves have not previously inserted data for it).
2. **Position of the new column:** Relative to the existing columns of the table, at what position is the new column created?

### Value at new column

The default value of the new column (which we provide in the column definition when using CREATE TABLE, or  ALTER TABLE … ADD COLUMN statement) is used to populate the new column for the existing records.

If we don’t mention any default value for the column, then the value NULL is used to populate such column.

### Position of the new column

A column added using `ALTER TABLE … ADD COLUMN` **is always appended at the end** of the table, after all existing columns.

There is no way to add a new column in the middle of the existing columns.

### Inserting record without column list

Earlier, our `orders` table had 8 columns, and we inserted the seed data using INSERT statement variant that omits specifying the column list, like this:

```sql
-- INSERT statement (without column-list) used initially - right after table creation:
INSERT INTO orders
VALUES (7, 14, '2013-07-25', 4530, 1073, 1, 199.99, 199.99);
-- Note: we provide 8 values for this record or data-tuple (Value Count = 8).
```

At that time (right after table creation):
The number of columns were 8, i.e. Column Count = 8.
And, the value count provided in the INSERT statement was also 8, i.e. Value Count for this INSERT statement = 8.

For INSERT statement without column-list, to work, the column count of the table must match the value count provided in the statement.

Now, executing the above INSERT statement gives below error:

> Error Code: 1136. Column count doesn't match value count at row 1
> 

### Best practice: Always provide column-names list in INSERT statements

To overcome the above error, and in general as well, it is a standard best practice to always provide the column-names list in all the INSERT statements.

This is also useful in cases, where we want to insert records, but populate only a few of the columns - like, we might not have values for the other columns at the time of initial insertion, or we might want to have those columns auto-filled with their respective column default values.

Sample INSERT statement using column-names list (in this case, omitting one column i.e. the `order_status` column):

```sql
INSERT INTO orders
(order_id, order_item_id, order_date, customer_id,
product_id, quantity, product_price, total_price)
VALUES
(7, 14, '2013-07-25', 4530, 1073, 1, 199.99, 199.99);
```

Here, above, since we omit the value for `order_status` when inserting this column, the inserted record will have NULL as the value of the `order_status` column.

We could have, equivalently, explicitly provided the NULL value for the `order_status` column for this record:

```sql
INSERT INTO orders
(order_id, order_item_id, order_date, customer_id, order_status,
product_id, quantity, product_price, total_price) VALUES
(7, 14, '2013-07-25', 4530, NULL, 1073, 1, 199.99, 199.99);
```

## Remove (DROP) a column

We have identified a redundant column “total_price” in the table. It is redundant to store values for this column, because the values for this column can be derived from the “quantity” and the “product_price” columns.

So, we need to remove the “total_price” column from the “orders” table.

We will use the ALTER TABLE … DROP COLUMN statement to do this, as follows:

```sql
ALTER TABLE orders DROP COLUMN total_price;
```

## Change data-type of (i.e. MODIFY) a column

Requirement: Change the data-type of `order_date` from `DATE` to `DATETIME` so we can store the order time in addition to the date.

```sql
ALTER TABLE orders MODIFY COLUMN order_date DATETIME;
-- Note: COLUMN keyword is optional in MySQL.
```

### What happens to existing data?

When converting `DATE` → `DATETIME`, MySQL keeps the date and sets the time to midnight.

Example: `2013-07-25` becomes `2013-07-25 00:00:00`.

### Column type compatibility considerations

- `DATE` → `DATETIME` is safe in terms of not losing information (time is simply added as `00:00:00`).
- `DATETIME` → `DATE` can lose information because the time portion will be truncated. Depending on MySQL `sql_mode` (for example, strict mode), you may get warnings or errors, so test the change on your data first.

### Quick checks after the change

```sql
DESC orders;
SELECT order_date FROM orders LIMIT 5;
```

### Note: DATETIME vs TIMESTAMP (MySQL)

- `DATETIME` stores the literal date/time value as entered.
- `TIMESTAMP` is stored in UTC and displayed in the session time zone.

Use `DATETIME` when you want to store the exact date and time value without timezone conversion.

## Rename a column

Use `ALTER TABLE ... RENAME COLUMN` to rename an existing column.

```sql
ALTER TABLE orders RENAME COLUMN order_date TO order_time;
```

### Notes

- In MySQL, `COLUMN` is **mandatory** for `RENAME COLUMN`.
- Renaming a column does not change the data, but it *can* break queries or application code that still uses the old column name.

### Quick checks

```sql
DESC orders;
SELECT order_time FROM orders LIMIT 5;
```

## Rename a table

Use `ALTER TABLE ... RENAME TO ...` to rename a table.

```sql
ALTER TABLE orders RENAME TO orders_with_status;
```

### Quick checks

```sql
SHOW TABLES;
DESC orders_with_status;
```

## MODIFY COLUMN: more data-type change scenarios (what works vs what fails)

You can often change a column’s data type, but the success depends on whether the existing values can be converted into the new type.

### Example: `FLOAT` → `INT`

```sql
ALTER TABLE orders MODIFY COLUMN product_price INT;
```

- This may **truncate** the decimal portion.

### Example: `INT` → `VARCHAR(n)` (safe if length is sufficient)

```sql
ALTER TABLE orders MODIFY COLUMN product_id VARCHAR(6);
```

- Pick `n` large enough to hold all existing values.

### Example that fails: `INT` → `VARCHAR(n)` with length too small

```sql
ALTER TABLE orders MODIFY COLUMN customer_id VARCHAR(3);
```

- This fails if any existing `customer_id` value needs more than 3 characters.

### Example that fails: `DATETIME` → `INT`

```sql
ALTER TABLE orders MODIFY COLUMN order_time INT;
```

- Date/time values generally cannot be meaningfully stored as an `INT` without an explicit transformation.

### Example: `DATETIME` → `VARCHAR` and back

```sql
ALTER TABLE orders MODIFY COLUMN order_time VARCHAR(50);
ALTER TABLE orders MODIFY COLUMN order_time DATETIME;
```

- `DATETIME` → `VARCHAR` is usually straightforward.
- `VARCHAR` → `DATETIME` only works if all existing strings are valid datetime values.

### Best practice for schema changes

Before running a type change on an important table:

- Check the current schema: `DESC orders;`
- Inspect representative data: `SELECT * FROM orders LIMIT 10;`
- Try the change in a non-production copy first (or take a backup).

[Day 05 - SQL Scripts](https://www.notion.so/Day-05-SQL-Scripts-32653dba8ae7807d97bafc0b7e40fe38?pvs=21)
