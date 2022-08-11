# SQL Project: Problem 1 to 6
## Description

This project mainly based on performing queries on a MySQL database. The goal is to get used to data analysis workflow using MySQL.<br>
<br>
The workflow:
1. Acquire the dataset
1. Clean the dataset 
1. Import into MySQL
1. Solve some questions:
    1. Problem 1
    1. Problem 2
    1. Problem 3
    1. Problem 4
    1. Probelm 5
    1. Problem 6

## 1. Acquire The Dataset
Dataset is provided by Wanda Kinasih (from her YT channel): [here](https://drive.google.com/drive/folders/1Dm-zQB9uIiNe6-c7y7X5q8uxY6GWTf0g)<br>
Download the dataset from both sheets as `csv`. Actually, you can use any format but I prefer csv for this project.

## 2. Clean The Dataset
There are some problems with this dataset that I think would affect when querying, such as:<br>
*(for orders table)*
- column names have spaces;
- inconsistent date format;
- the last column does not have a name

*(for customers table)*
- column names

#### Action 1: Delete the last column in the Orders table

#### Action 2: Change the column names:
Orders table:

| row_id | order_id | order_date | ship_date | ship_mode | customer_id | country | post_code | region | product_id | category | sub_category | product_name | sales | quantity | discount | profit | 
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|

Customers table:

| customer_id | customer_name | segment | city | state |
|---|---|---|---|---|

#### Action 3: Clean the data
If you notice, date format in `order_date` and `ship_date` in the Orders table are inconsistent.
There are two types: `DD/MM/YYYY`and `MM/D/YYYY`. <br>
I use Excel to match SQL default date format (`YYYY-MM-DD`).<br>

1. Select the `order_date` column rows and perform `Sort A to Z` -> `Continue with current selection`
2. You will find the date data are split into two categories: fixed to the left and fixed to the right. Select all data fixed to the left since this is not a date format.
3. Go to menu `Data` --> `Text to Columns` --> choose `Delimeted`, then `Next` --> untick all Delimiters, then `Next` --> choose `Date` and `MDY`--> `Finish`
4. Do the same thing for  `ship_date`
5. Select both columns' rows (values) --> `format cells` --> `custom` --> for the Type: use `YYYY-MM-DD` --> `Ok`
6. You will see the two columns' values are now set to `YYYY-MM-DD` format.

## 3. Import into MySQL
#### Action 1: Create a database and connection for the project
1. Login to  MySQL and create a database:
```
mysql> CREATE DATABASE superstore;
```
2. Create connection session to MySQL. Here, I use **SQLTools** *extension* in **VS Code** for the connection—Navigate to `.vscode/setting.json` for the connection settings. Saving the file will create `superstore_project.session.sql` file.
4. I will use `superstore_project.session.sql` to create table, insert data, query, etc.
5. Use *superstore* database:
```
USE superstore;
```
6. Create `customers` table:
```
CREATE TABLE customers (
    customer_id VARCHAR(8) NOT NULL,
    customer_name TEXT,
    segment TEXT,
    city TEXT,
    state TEXT,
    PRIMARY KEY (customer_id)
);
```
6. Show the upload folder:
```
SHOW VARIABLES LIKE "secure_file_priv";
```
Copy the values. In my case, it's:<br>
`C:/ProgramData/MySQL/MySQL Server 8.0/Uploads`
<br>
<br>
Copy `Orders.csv` and `Customers.csv` datasets into the above directory.

> **Note**: You can import the dataset using the workbench and skip this step. If using terminal or `session.sql` file from `SQLTools`, follow this step.

7. Load the data into `customers` table:
```
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Customer.csv' INTO TABLE customers 
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;
```
>**Note**: Try checking the table by using ```DESC customers;``` OR
```SELECT * FROM customers LIMIT 10;```

8. Create  `orders` table:
```
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
```

9. Load data into `orders` table:
```
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Orders.csv' INTO TABLE orders 
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES;
```
>**Note**: Try checking the table by using ```DESC orders;``` OR
```SELECT * FROM orders LIMIT 10;```

## 4. Solve some questions
To perform query, I'll use a new connection called `query_superstore.session.sql`. I'll execute and save all my queries inside this connection file.<br>
>To see the my queries, navigate to `query_superstore.session.sql`

<br>_Feel free to use any method to query from the database._
<br>
<br>
#### Problem 1:
Count the number of customer per city
<br>
```
SELECT  COUNT(DISTINCT(customer_id)) total_customer, 
        region 
FROM orders
GROUP BY 2;
```
Result:
| total_customer | region |
|:---:|:---:|
| 629 | Central |
| 674 | East |
| 512 | South |
| 686 | West |

#### Problem 2:
Count the number of orders per region
<br>
```
SELECT  COUNT(DISTINCT(order_id)) total_order,
        region
FROM orders
GROUP BY 2;
```
Result:
| total_order | region |
|:---:|:---:|
| 1175 | Central |
| 1401 | East |
| 822 | South |
| 1611 | West |

#### Problem 3:
Find the first order date of each customer
<br>
```
SELECT  DISTINCT(customer_id) customer_id, 
        MIN(order_date) first_order,
        ROW_NUMBER() OVER(ORDER BY customer_id) row_num
FROM orders
GROUP BY 1
ORDER BY 1;
-- 1-50 of 793

Result
| customer_id | first_order | row_num |
|:---:|:---:|:---:|
| AA-10315 | 2017-03-31 | 1 |
| AA-10375 | 2017-04-21 | 2 |
| AA-10480 | 2017-04-05 | 3 |
| AA-10645 | 2017-01-12 | 4 |
| ... | ... | ... |
| YS-21880 | 2018-07-25 | 791 |
| ZC-21910 | 2017-10-13 | 792 |
| ZD-21925 | 2017-08-27 | 793 |

```
Check by counting the total of unique customer_id:
```
SELECT  COUNT(DISTINCT(customer_id)) cust_id
FROM orders
ORDER BY 1;
```

Result
| cust_id |
|:---:|
| 793 |

#### Problem 4:
1. Find the number of customer who made their first order in each region, each day.
2. Find the number of customer who made their first order in each city, each day.
<br>
#### Problem 5:
Find the first order GMV (sales) of each customer. If there is a tie, use order with the lower oder_id
<br>
#### Problem 6:
Write a query that'll identify returning active users. A returning active user is a user that has made a second order within 7 days of any other of their orders. Output a list of customer_id(s) of these returning active users.
<br>

