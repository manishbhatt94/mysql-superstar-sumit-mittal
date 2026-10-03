# MySQL - Built-In Functions - Date Functions + Numeric Functions

Video Link:
https://www.youtube.com/watch?v=yUtWwA82ny4

<br>

---

## DATE / TIME Functions

### Current Date / Time

- Current Date (Only Date)
  - Function: `CURDATE()`
  - Synonyms: `CURRENT_DATE()` & `CURRENT_DATE`.
  - Result Format (in string context): `'YYYY-MM-DD'` string.
  - Result Format (in numeric context): `YYYYMMDD` integer.
  - Cannot be used as the DEFAULT value of a table's column.

- Current Time (Only Time)
  - Function: `CURTIME()`
  - Synonyms: `CURRENT_TIME()` & `CURRENT_TIME`.
  - Result Format (in string context): `'hh:mm:ss'` string.
  - Result Format (in numeric context): `hhmmss` integer.
  - Cannot be used as the DEFAULT value of a table's column.

- Current Timestamp (Both Date & Time)
  - Function: `NOW()`
  - Synonyms: `CURRENT_TIMESTAMP()`, `CURRENT_TIMESTAMP`, `LOCALTIME()`, `LOCALTIMESTAMP()`.
  - Result Format (in string context): `'YYYY-MM-DD HH:MM:DD'` string.
  - **CAN** be used as the DEFAULT value of a table's column.


#### Using the NOW() function as the default value for a column

```sql
CREATE TABLE contacts(
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at DATETIME NOT NULL DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);
```

### Other Date / Time Functions Covered


- Extracting parts from a Date / Time value
  - Using functions like `DATE()`, `TIME()`, `YEAR()`, `MONTH()`, `DAY()` etc.
  - Getting "Name of month" using `MONTHNAME()` and "Name of day of week" using `DAYNAME()`.
  - Using SQL Standard function `EXTRACT(unit FROM datetime)` to extract various parts.
- MySQL date/time **intervals** with `INTERVAL` operator.
- Date addition & subtraction with `DATE_ADD()` / `DATE_SUB()` (or `ADDDATE()` / `SUBDATE()`).
- Find number of days b/w two date values with `DATEDIFF()`.
- Formatting datetime values with `DATE_FORMAT()` - which handles both date & time formatting. (For only formatting a TIME type value, we can use `TIME_FORMAT()` function.)
- Getting Unix timestamp of a datetime (or of current timestamp), and getting the datetime value from a Unix timestamp. Using `UNIX_TIMESTAMP()` & `FROM_UNIXTIME` functions.
