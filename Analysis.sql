/* ========== ANALYSIS =========*/

select * from sales;
select * from product;

select * from goldusers_signup;
select * from users;

/* what is the total amount each customer spent on zomato? */

select userid
		,SUM(price) as Spent
from sales as s
	left join product as p
		on s.product_id = p.product_id
GROUP BY userid

/* How many days has each customer visited zomato apart from the sign up date? */


select userid
		,COUNT(distinct created_date) as days
from sales 
group by userid

/* What is the first product purchased by each customer? */

SELECT userid
		,product_name
FROM (
SELECT a.userid	
		,product_id
FROM (
SELECT userid
		,min(created_date) as MinDate
from sales as s 
	left join product as p
		on s.product_id = p.product_id
group by userid) as a
inner join sales as s
	on a.MinDate = s.created_date
	and a.userid = s.userid ) as b
	inner join product as p
		on b.product_id = p.product_id

/* another way */
SELECT userid
		,product_name
FROM (
SELECT *, 
		rank() over(partition by userid order by created_date) rnk
from sales) as b
	inner join product as p
		on b.product_id = p.product_id
WHERE rnk = 1

/* What is the most purchased item on the menu and how many times was it purchased by each customers? */

SELECT userid
		,COUNT(product_id) as TimesPurchased
FROM sales
where product_id =
(SELECT top 1 product_id
FROM sales
group by product_id
ORDER BY COUNT(product_id) desc)
GROUP BY userid
ORDER BY TimesPurchased desc

/* Which item was the most popular for each customer? */

SELECT userid
		,product_id
FROM (
SELECT *
		,ROW_NUMBER() OVER (PARTITION BY userid ORDER BY TimesPurchased desc) row
FROM (
SELECT userid
		,product_id
		,COUNT(product_id) as TimesPurchased
FROM sales
GROUP BY userid
		,product_id) as a) as b
WHERE row = 1