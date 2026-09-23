# mysql-superstar-sumit-mittal

Course Playlist: https://www.youtube.com/playlist?list=PLtgiThe4j67ohOAzRW_mi-AsLFmj35gxH

Course Dashboard: https://courses.trendytech.in/v3/myaccount/course/188755/

---

## Notes Index

**Root directory notes:**

- [cli-fast-csv-import.md](./cli-fast-csv-import.md) \
  Fast CSV data import into MySQL table using MySQL CLI Client command `LOAD DATA LOCAL INFILE`.
- [mysql-logical-query-execution-order.md](./mysql-logical-query-execution-order.md) \
  *SQL Logical Query Execution Order* and correlation with SQL Syntax Order.
- [sql-joins-beginner-guide.md](./sql-joins-beginner-guide.md) \
  Beginner friendly simplified full guide to working with SQL Joins.

---

## Steps to import data into MySQL Table from CSV file:

1. Create the MySQL table using CREATE TABLE statement
   having roughly matching data types as in the CSV data.
2. In MySQL Workbench - Left Sidebar - Navigator - SCHEMAS view GUI tree,
   expand your database (`retail_db`) -> Tables, then right click & select
   the "Refresh All" option. Your newly created table should appear now.
3. Right click the "customers" table entry in the Navigator - SCHEMAS
   GUI tree, and select the "Table Data Import Wizard" context menu option.
4. Browse the path to the CSV file (customers.csv) containing the data.
5. Consult the notes at [cli-fast-csv-import.md](./cli-fast-csv-import.md) to
   check out a CLI based much faster approach to importing CSV data.
