USE superstore;

-- @BLOCK
-- create table customers
create table customers (
    customer_id varchar(8) not null,
    customer_name text,
    segment text,
    city text,
    state text,
    primary key (customer_id)
);

-- @BLOCK
-- show the MySQL upload folder
SHOW VARIABLES LIKE "secure_file_priv";

-- @block
-- load data into customers
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Customer.csv' INTO TABLE customers 
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;

-- @BLOCK
-- check customers table
DESC customers;
SELECT * FROM customers LIMIT 10;


-- @BLOCK
-- create orders table
CREATE TABLE orders (
    row_id INT NOT NULL AUTO_INCREMENT,
    order_id  VARCHAR(14) NOT NULL,
    order_date  VARCHAR(14) NOT NULL,
    ship_date DATE NOT NULL,
    ship_mode VARCHAR(14) ,
    customer_id VARCHAR(10) NOT NULL,
    country TEXT,
    post_code VARCHAR(5),
    region TEXT,
    product_id VARCHAR(20) NOT NULL,
    category TEXT,
    sub_category TEXT,
    product_name TEXT,
    sales DECIMAL(10, 4) NOT NULL,
    quantity INT NOT NULL,
    discount DECIMAL(10, 4),
    profit DECIMAL(10, 4),
    PRIMARY KEY (row_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- @block
-- load data into orders table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Orders.csv' INTO TABLE orders 
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;

-- @BLOCK
-- check customers table
DESC orders;
SELECT * FROM orders LIMIT 10;


