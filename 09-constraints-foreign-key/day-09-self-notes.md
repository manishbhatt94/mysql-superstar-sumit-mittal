# Day 09 - CONSTRAINTS -- FOREIGN KEY


Consult:

1. [https://www.mysqltutorial.org/mysql-basics/mysql-foreign-key/](https://www.mysqltutorial.org/mysql-basics/mysql-foreign-key/)
   - Archived page link: [https://web.archive.org Archive](https://web.archive.org/web/20260531093856/https://www.mysqltutorial.org/mysql-basics/mysql-foreign-key/)
1. [https://dev.mysql.com/doc/refman/8.4/en/create-table-foreign-keys.html](https://dev.mysql.com/doc/refman/8.4/en/create-table-foreign-keys.html)

---


MySQL supports *foreign keys*, which permit cross-referencing related data
across tables, and *foreign key constraints*, which help keep the related data
consistent.

 The essential syntax for a defining a foreign key constraint in a CREATE TABLE
 or ALTER TABLE statement includes the following:

```txt
[CONSTRAINT [symbol]] FOREIGN KEY
    [index_name] (col_name, ...)
    REFERENCES tbl_name (col_name,...)
    [ON DELETE reference_option]
    [ON UPDATE reference_option]

reference_option:
    RESTRICT | CASCADE | SET NULL | NO ACTION | SET DEFAULT
```

## Conditions & Restrictions

### Index on Foreign Keys and Referenced Keys

MySQL requires indexes on foreign keys and referenced keys so that foreign key
checks can be fast and not require a table scan.

In the referencing table, there must be an index where the foreign key columns
are listed as the first columns in the same order.

<mark>Such an index is created on the referencing table automatically if it does
not exist.</mark> This index might be silently dropped later if you create
another index that can be used to enforce the foreign key constraint. 

**Example:** This is a more complex example in which a `product_order` table has
foreign keys for two other tables. One foreign key references a two-column index
in the `product` table. The other references a single-column index in the
`customer` table:

```sql
CREATE TABLE product (
   category INT NOT NULL,
   id INT NOT NULL,
   price DECIMAL,
   PRIMARY KEY(category, id)
) ENGINE=INNODB;

CREATE TABLE customer (
   id INT NOT NULL,
   PRIMARY KEY (id)
) ENGINE=INNODB;

CREATE TABLE product_order (
   `no` INT NOT NULL AUTO_INCREMENT,
   product_category INT NOT NULL,
   product_id INT NOT NULL,
   customer_id INT NOT NULL,

   PRIMARY KEY(no),
   INDEX (product_category, product_id),
   INDEX (customer_id),

   FOREIGN KEY (product_category, product_id)
      REFERENCES product(category, id)
      ON UPDATE CASCADE ON DELETE RESTRICT,

   FOREIGN KEY (customer_id)
      REFERENCES customer(id)
) ENGINE=INNODB;
```

## Referential Actions

When an `UPDATE` or `DELETE` operation affects a key value in the *parent table*
that has matching rows in the *child table*, the result depends on the
**referential action** specified by `ON UPDATE` and `ON DELETE` subclauses of
the FOREIGN KEY clause. Referential actions include:

1. **`CASCADE`**: Delete or update the row from the parent table and
   automatically delete or update the matching rows in the child table. Both
   `ON DELETE CASCADE` and `ON UPDATE CASCADE` are supported.

   **Note:** Cascaded foreign key actions do not activate triggers.
1. **`SET NULL`**: Delete or update the row from the parent table and set the
   foreign key column or columns in the child table to NULL. Both the
   `ON DELETE SET NULL` and `ON UPDATE SET NULL` clauses are supported.

   If you specify a SET NULL action, make sure that you have not declared the
   columns in the child table as having the NOT NULL constraint.
1. **`RESTRICT`**: Rejects the delete or update operation for the parent table.
   Specifying `RESTRICT` (or `NO ACTION`) is the same as omitting the `ON DELETE`
   or `ON UPDATE` clause.
1. **`NO ACTION`**: A keyword from standard SQL. For *InnoDB Storage Engine*,
   this is equivalent to `RESTRICT`; the delete or update operation for the
   parent table is immediately rejected if there is a related foreign key value
   in the referenced table. For *NDB Storage Engine*, the behaviour is different.
1. **`SET DEFAULT`**: This action is recognized by the MySQL parser, but both
   *InnoDB* and *NDB* reject table definitions containing `ON DELETE SET DEFAULT`
   or `ON UPDATE SET DEFAULT` clauses.


MySQL rejects any `INSERT` or `UPDATE` operation that attempts to create a
foreign key value in a child table if there is no matching candidate key value
in the parent table.

For an `ON DELETE` or `ON UPDATE` that is not specified, the default action is
always `NO ACTION`.

## Self-referencing Foreign Key

> Content taken from: [https://www.mysqltutorial.org](https://www.mysqltutorial.org/mysql-basics/mysql-foreign-key/)


Sometimes, the child and parent tables may refer to the same table. In this case, the foreign key references back to the primary key within the same table.

See the following employees table:

![Table `employees` has the self-referencing Foreign Key `reportsTo`](assets/images/fig-01-self-ref-foreign-key-employees.png "Figure: Table `employees` has the self-referencing Foreign Key `reportsTo`")

*Figure: Table `employees` has the self-referencing Foreign Key `reportsTo`*
