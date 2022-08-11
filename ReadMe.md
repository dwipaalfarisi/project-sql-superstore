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
<hr>

#### **Problem 1:**
Count the number of customer per city
<br>
```
SELECT  COUNT(DISTINCT(customer_id)) total_customer, 
        region 
FROM orders
GROUP BY 2;
```
**Result:**
| total_customer | region |
|:---:|:---:|
| 629 | Central |
| 674 | East |
| 512 | South |
| 686 | West |

<br>
<hr>

#### **Problem 2:**
Count the number of orders per region
<br>
```
SELECT  COUNT(DISTINCT(order_id)) total_order,
        region
FROM orders
GROUP BY 2;
```
**Result:**
| total_order | region |
|:---:|:---:|
| 1175 | Central |
| 1401 | East |
| 822 | South |
| 1611 | West |
<br>
<hr>

#### **Problem 3:**
Find the first order date of each customer
<br>
```
SELECT  DISTINCT(customer_id) customer_id, 
        MIN(order_date) first_order,
        ROW_NUMBER() OVER(ORDER BY customer_id) row_num
FROM orders
GROUP BY 1
ORDER BY 1;
```
**Result:**
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
<br>

> **Check** by counting the total of unique customer_id:

```
SELECT  COUNT(DISTINCT(customer_id)) cust_id
FROM orders
ORDER BY 1;
```

**Result:**

| cust_id |
|:---:|
| 793 |

<br>
<hr>

#### **Problem 4:**
1. Find the number of customer who made their first order in each region, each day.
```
SELECT  t1.first_buy, 
        t1.region, 
        COUNT(t1.customer_id) total_customer
FROM    (
        SELECT  customer_id, 
                MIN(order_date) first_buy, 
                region
        FROM orders
        GROUP BY 1, 3
        ORDER BY 2, 3
        ) t1
GROUP BY first_buy, region;
```
**Result:**
| first_buy | region | total_customer |
|:---:|:---:|:---:|
| 2017-01-02 | Central | 1 |
| 2017-01-03 | Central | 3 |
| 2017-01-03 | East | 1 |
| 2017-01-03 | West | 1 |
| 2017-01-04 | East | 1 |
| ... | ... | ... |
| 2020-12-23 | South | 1 |
| 2020-12-24 | East | 1 |
| 2020-12-28 | Central | 1 |
| 2020-12-28 | East | 1 |
| 2020-12-29 | East | 1 |

<br>

> **Check** by looking at each customer's first buy on `2017-01-03`:
```
SELECT  customer_id, 
        MIN(order_date) first_buy, 
        region
FROM orders
GROUP BY 1, 3
HAVING first_buy = '2017-01-03'
ORDER BY 3;
```
**Result**:
| customer_id | first_buy | region |
|:---:|:---:|:---:|
| VF-21715 | 2017-01-03 | Central |
| SC-20380 | 2017-01-03 | Central |
| GW-14605 | 2017-01-03 | Central |
| HR-14770 | 2017-01-03 | East |
| DB-13060 | 2017-01-03 | West |
<br>

2. Find the number of customer who made their first order in each city, each day, order by the most customer.
<br>

```
SELECT  t2.city, 
        t1.first_buy, 
        COUNT(t1.customer_id) total_customer
FROM    (  
        SELECT  customer_id, 
                MIN(order_date) first_buy 
        FROM orders 
        GROUP BY 1
        ) t1
JOIN customers t2 ON t1.customer_id = t2.customer_id
GROUP BY t2.city, t1.first_buy
ORDER BY 3 DESC;
```
**Result:**
| first_buy | region | total_customer |
|:---:|:---:|:---:|
| New York City | 2017-03-17 | 3 |
| Seattle | 2017-01-03 | 3 |
| San Francisco | 2017-12-07 | 2 |
| New York City | 2018-09-15 | 2 |
| Los Angeles | 2017-04-26 | 2 |
| ... | ... | ... |
| San Diego | 2017-01-20 | 1 |
| San Francisco | 2017-11-17 | 1 |
| Burlington | 2018-07-25 | 1 |
| Salem | 2017-10-13 | 1 |
| San Francisco | 2017-08-27 | 1 |
<br>

> **Check** by looking at `row 1`'s **each customers' first buy**: `New York City` on `2017-03-17`
```
SELECT  DISTINCT(customer_id), 
        city, 
        MIN(order_date) first_buy
FROM    (
        SELECT  t2.city, 
                t1.order_date, 
                t1.customer_id 
        FROM orders t1
        JOIN customers t2 ON t1.customer_id = t2.customer_id
        WHERE t2.city = 'New York City'
        AND t1.order_date = '2017-03-17'
        ) t1
GROUP BY 1;
```
**Result:**
| first_buy | region | total_customer |
|:---:|:---:|:---:|
| AZ-10750 | New York City | 2017-03-17 |
| CP-12340 | New York City | 2017-03-17 |
| MH-17440 | New York City | 2017-03-17 |
<br>

> **Check** the city for each customer's first buy on `2017-01-03`
```
SELECY  customer_id,
        city 
FROM customers
WHERE customer_id IN ('AZ-10750', 'CP-12340', 'MH-17440'); 
```
**Result:**
| customer_id | city |
|:---:|:---:|
| AZ-10750 | New York City |
| CP-12340 | New York City |
| MH-17440 | New York City | 
<br>

#### **Problem 5:**
Find the first order GMV (sales) of each customer. If there is a tie, use order with the lower oder_id
<br>
```
SELECT  customer_id, 
        MIN(order_date) first_buy, 
        order_id, 
        sales
FROM    (
        SELECT  customer_id, 
                order_date, 
                sales
        FROM orders
        ORDER BY order_id
        ) t1
GROUP BY customer_id, order_id, sales
ORDER BY first_buy, order_id;
```

**Result:**
| customer_id | first_buy | order_id | sales |
|:---:|:---:|:---:|:---:|
| BD-11500 | 2017-01-02 | CA-2017-140795 | 468.9000 |
| DB-13060 | 2017-01-03 | CA-2017-104269 | 457.5680 |
| VF-21715 | 2017-01-03 | CA-2017-113880 | 17.4720 |
| VF-21715 | 2017-01-03 | CA-2017-113880 | 634.1160 |
| SC-20380 | 2017-01-03 | CA-2017-131009 | 129.5520 |
| ... | ... | ... | ... |
| CC-12430 | 2020-12-30 | CA-2020-126221 | 209.3000 |
| PO-18865 | 2020-12-30 | CA-2020-143259 | 323.1360 |
| PO-18865 | 2020-12-30 | CA-2020-143259 | 52.7760 |
| PO-18865 | 2020-12-30 | CA-2020-143259 | 90.9300 |
| JM-15580 | 2020-12-30 | CA-2020-156720 | 3.0240 |
<br>

> **Check** whether customer `SC-20380` have 4 (sales) for its first buy on `2017-01-03` 
```
SELECT order_date, order_id, sales
FROM orders
WHERE customer_id = 'SC-20380'
AND order_date = '2017-01-03'
ORDER BY 1, 2, 3
```

**Result:**
| order_date | order_id | sales | 
|:---:|:---:|:---:|
| 2017-01-03 | 2017-01-02 | CA-2017-140795 |
| 2017-01-03 | 2017-01-03 | CA-2017-104269 | 
| 2017-01-03 | 2017-01-03 | CA-2017-113880 | 
| 2017-01-03 | 2017-01-03 | CA-2017-113880 | 

<hr>

#### **Problem 6:**
Write a query that'll identify returning active users. A returning active user is a user that has made a second order within 7 days of any other of their orders. Output a list of customer_id(s) of these returning active users.
<br>
First, get the next order for each customer and find the difference (in day) between the order and the next order.
```
SELECT  customer_id, 
        order_date, 
        next_order, 
        DATEDIFF(next_order, order_date) difference
FROM    (
        SELECT  customer_id, 
                order_date,
                LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) next_order 
FROM orders
) t1
```
**Result:**

| customer_id | order_date | next_order | difference |
|:---:|:---:|:---:|:---:|
| AA-10315 | 2017-03-31 | 2017-03-31 | 0 |
| AA-10315 | 2017-03-31 | 2017-09-15 | 168 |
| AA-10315 | 2017-09-15 | 2017-09-15 | 0 |
| AA-10315 | 2017-09-15 | 2018-04-10 | 207 |
| AA-10315 | 2018-04-10 | 2019-03-03 | 327 |
| AA-10315 | 2019-03-03 | 2019-03-03 | 0 |
| AA-10315 | 2019-03-03 | 2019-03-03 | 0 |
| AA-10315 | 2019-03-03 | 2019-03-03 | 0 |
| AA-10315 | 2019-03-03 | 2020-06-29 | 484 |
| AA-10315 | 2020-06-29 | 2020-06-29 | 0 |
| AA-10315 | 2020-06-29 | NULL | NULL |
| AA-10375 | 2017-04-21 | 2017-10-24 | 184 |
| ... | ... | ... | ... |
<br>

Now, get id, only when the difference is <= 7 days. Use CTE.

```
WITH returning_user AS  (
SELECT DISTINCT(customer_id)
FROM    (
        SELECT  customer_id, 
                order_date, 
                next_order, 
                DATEDIFF(next_order, order_date) difference
        FROM    (
                select  customer_id, 
                        order_date,
                        LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) next_order 
                FROM orders
                ) t1
        ) t2
WHERE difference <= 7
        ) 

SELECT * FROM returning_user ru
```

**Result:**
| customer_id |
|:---:|
| AA-10315 |
| AA-10375 |
| AA-10480 |
| AA-10645 |
| AB-10015 |
| AB-10060 |
| AB-10105 |
| AB-10150 |
| AB-10165 |
| AB-10255 |
| AB-10600 |
| AC-10420 |
| ... |
<br>

> **Check** customers which don't appear from the previous query

```
WITH returning_user AS  (
SELECT DISTINCT(customer_id)
FROM    (
        SELECT  customer_id, 
                order_date, 
                next_order, 
                DATEDIFF(next_order, order_date) difference
        FROM    (
                select  customer_id, 
                        order_date,
                        LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) next_order 
                FROM orders
                ) t1
        ) t2
WHERE difference <= 7
        ) 

SELECT * FROM returning_user ru

-- check starts here
RIGHT JOIN (SELECT DISTINCT(customer_id) FROM orders) od
ON ru.customer_id = od.customer_id
WHERE ru.customer_id IS NULL;
```

**Result:**
| ru.customer_id | od.customer_id |
|---|---|
| NULL | JR-15700 |
| NULL | LB-16735 |
| NULL | LD-16855 |
| NULL | LH-16750 |
| NULL | LT-16765 |
| NULL | NB-18580 |
| NULL | NF-18475 |
| NULL | PB-19210 |
| NULL | RD-19660 |
| NULL | RE-19405 |
| NULL | SH-20635 |
| NULL | TB-21190 |
| NULL | TS-21085 |
| NULL | TT-21265 |
<br>

> Now, let's **check** the list of the id's from above's table. Check whether they meet the condition as `returning order`

```
SELECT customer_id,
        order_date,
        next_order,
        DATEDIFF(next_order, order_date) difference
FROM    (

        SELECT  customer_id, 
                order_date,
                LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) next_order 
        FROM orders
        WHERE customer_id IN    (
                                'AO-10810',
                                'BE-11410',
                                'BO-11425',
                                'BW-11065',
                                'CJ-11875',
                                'EK-13795',
                                'EL-13735',
                                'FW-14395',
                                'JC-15340',
                                'JR-15700',
                                'LB-16735',
                                'LD-16855',
                                'LH-16750',
                                'LT-16765',
                                'NB-18580',
                                'NF-18475',
                                'PB-19210',
                                'RD-19660',
                                'RE-19405',
                                'SH-20635',
                                'TB-21190',
                                'TS-21085',
                                'TT-21265'
                                )
        ) t1
WHERE DATEDIFF(next_order, order_date) <= 7;
```

**Result:**<br>
`Query returned 0 rows`
<br>
<br>
**This returns 0 rows, means that none of the customers from that particular list are returning customers. Meaning we have the correct answer for the problem.**
<br>
<hr>

# END

