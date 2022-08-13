USE superstore;

-- @BLOCK
-- create table customers1
create table customers1 (
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

SET GLOBAL local_infile=1;

-- @block
-- load data into customers1
LOAD DATA LOCAL INFILE 'D:/PRO/sql-superstore/fix/customers1.csv' INTO TABLE customers1 
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;

-- @BLOCK
-- check customers1 table
DESC customers1;
SELECT * FROM customers1 LIMIT 10;


-- @BLOCK
-- create orders table
CREATE TABLE orders1 (
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
    FOREIGN KEY (customer_id) REFERENCES customers1(customer_id)
);

-- @block
-- load data into orders1 table
LOAD DATA LOCAL INFILE 'D:/PRO/sql-superstore/fix/orders1.csv' INTO TABLE orders1
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;

-- @BLOCK
-- check customers1 table
DESC orders1;
SELECT * FROM orders1 LIMIT 10;

-- @BLOCK
drop table orders1;

-- @block 
drop table customers1;
