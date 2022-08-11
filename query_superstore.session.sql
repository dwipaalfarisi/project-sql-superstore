use wanda;

-- task 1
-- count the number of customer per region

SELECT  COUNT(DISTINCT(customer_id)) 
        total_customer, 
        region 
FROM orders
GROUP BY 2;

-- @BLOCK
-- show all column names
SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_SCHEMA = Database()
AND TABLE_NAME = 'orders' ;

-- @BLOCK
-- task 2
-- count the number of orders per region
select count(distinct(order_id)) total_order, region
from orders
group by 2;

-- @block
-- task 3
-- find the first order date of each customer
select distinct(customer_id), min(order_date)
from orders
group by 1
order by 1
;

-- @block
-- task 4
-- find the number of customer who made their first order, in each region, for each day

-- this will result with unique customer first buy and shows it's region
-- some date may have several users' first buy for that region
SELECT  customer_id, 
        MIN(order_date) first_buy, 
        region
FROM orders
GROUP BY 1, 3 
ORDER BY 2, 3;

-- use count to get the total of users' first buy for each region on each day
SELECT  t1.first_buy, 
        t1.region, 
        count(t1.customer_id) total_customer
from    (
        SELECT  customer_id, 
                MIN(order_date) first_buy, 
                region
        FROM orders
        GROUP BY 1, 3
        ORDER BY 2, 3
        ) t1
group by first_buy, region;

-- whether using distinct or not, the result would stay the same
SELECT t1.first_buy, t1.region, COUNT(DISTINCT(t1.customer_id))
FROM (
        SELECT  customer_id, 
                MIN(order_date) first_buy, 
                region
        FROM orders
        GROUP BY 1, 3
        ORDER BY 2, 1
) t1
GROUP BY t1.first_buy, t1.region;

-- check
select customer_id, min(order_date) first_buy, region
from orders
group by 1, 3
having first_buy = '2017-01-03'
order by 3;

select customer_id, (order_date), region from orders
where customer_id = 'SC-20380'
order by 2;
-- DB-13060 true 
-- GW-14605 true
-- HR-14770 true
-- SC-20380 


-- @block

select t2.city, t1.first_buy, count(t1.customer_id) total_customer
from (select     customer_id, 
            min(order_date) first_buy 
    from orders 
group by 1) t1
join customers t2 on t1.customer_id=t2.customer_id
group by t2.city, t1.first_buy
order by 3 DESC;

-- check the customers' first buy whether there's indeed total of 3 in New York on 2017-03-17
select t1.customer_id, min(order_date) first_buy, t2.city from orders t1, customers t2
where t2.customer_id = t1.customer_id
group by 1, 3
having t2.city = 'New York City'
AND first_buy = '2017-03-17';
-- AZ-10750 true
-- CP-12340 true
-- MH-17440 true

-- check the city
select city, customer_id from customers
where customer_id in ('AZ-10750', 'CP-12340', 'MH-17440'); 

-- check another date and city
select t1.customer_id, min(order_date) first_buy, t2.city from orders t1, customers t2
where t2.customer_id = t1.customer_id
group by 1, 3
having t2.city = 'Seattle'
AND first_buy = '2017-01-03';

-- DB-13060 true
-- GW-14605 true
-- SC-20380 true

-- check another date and city
select t1.customer_id, min(order_date) first_buy, t2.city from orders t1, customers t2
where t2.customer_id = t1.customer_id
group by 1, 3
having t2.city = 'Los Angeles'
AND first_buy = '2017-08-04';

-- PC-19000 true
-- RA-19885 true



-- @block
-- task 5
-- find the first order GMV (sales) of each customer. If there is a tie, use the order with lower order_id

SELECT customer_id, min(order_date) first_buy, order_id, sales
FROM (
        SELECT customer_id, order_date, order_id, sales
        FROM orders
        ORDER BY order_id) t1
GROUP BY customer_id, order_id, sales
ORDER BY first_buy, order_id;

-- check 
-- SC-20380 is 4
-- CA-2017-131009 
-- sales :129, 18, 362, 63

SELECT order_date, order_id, sales
FROM orders
WHERE customer_id = 'SC-20380'
AND order_date = '2017-01-03'
ORDER BY 1, 2, 3

--look on stackoverflow on how to get sales



-- @block
-- task 6
-- question inspired: https://platform.stratascratch.com/coding/10322-finding-user-purchases?code_type=3

-- Write a query that'll identify returning active users. A returning active user is a user that has made a second purchase within 7 days of any other of their purchases. Output a list of user_ids of these returning active users.


-- customer_id, customer_name, segment, city, state

/*  
flow:
- get id, purchase date, next_order if any
- purchase within 7 days

*/

-- temporary table
with returning_user as(
select distinct(customer_id)
from(

select  customer_id, 
        order_date, 
        next_order, 
        datediff(next_order, order_date) difference
from(
select  customer_id, 
        order_date,
        lead(order_date, 1) over (partition by customer_id order by order_date)next_order 
from orders
) t1
) t2
where difference <= 7
) 

select * from returning_user ru

-- check starts here
right join (select distinct(customer_id) from orders) od
on ru.customer_id = od.customer_id
where ru.customer_id is null;

/* 
list of customer_id here is the result
of the check above
where it returns all customer_id that
is not showing from the query above.

The goal is to prove that every element of the list of customer_id
are not returning customers
 */
select  customer_id,
        order_date,
        next_order,
        datediff(next_order, order_date) difference
from    (

        select  customer_id, 
                order_date,
                lead(order_date, 1) over (partition by customer_id order by order_date)next_order 
        from orders
        where customer_id in    (
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
where datediff(next_order, order_date) <= 7;
-- query returns 0 which prove the query above

