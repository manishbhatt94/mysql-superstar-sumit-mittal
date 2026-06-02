# Day 10 - UPDATE / ALTER / DELETE / TRUNCATE

## TRUNCATE vs DELETE

In MySQL, the <u>TRUNCATE statement is classified as a **DDL** (Data Definition
Language) command</u>. While it removes data like a DML command, <mark>it
operates by dropping and recreating the table structure or its underlying
tablespace</mark>, making it a structural operation that <u>performs an implicit
commit</u>.
