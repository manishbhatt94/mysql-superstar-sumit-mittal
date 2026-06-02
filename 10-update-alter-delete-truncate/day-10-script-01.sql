DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_id INT,
    customer_fname VARCHAR(45),
    customer_lname VARCHAR(45),
    customer_email VARCHAR(45),
    customer_phone VARCHAR(45),
    customer_street VARCHAR(255),
    customer_city VARCHAR(45),
    customer_state VARCHAR(45),
    customer_zipcode VARCHAR(45)
);
