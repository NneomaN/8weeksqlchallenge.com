# Case Study 1 - Danny's Diner

<img src="https://user-images.githubusercontent.com/77930192/185515689-0f3802f9-c91a-478e-ade6-961d4f1d59e6.png" alt="Danny's Diner Image" width="500px" height="500px"/>

*My attempt at solving the Danny's Diner case study of the 8 weeks SQL challenge using T-SQL to query data hosted on an MS SQL Server*.

## Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, 
especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. 
Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program.  
Additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

## Available Data
![Danny's Diner](https://user-images.githubusercontent.com/77930192/185516328-5aa04194-e92b-497a-84aa-63882a653c92.png)  
Here's a view of the schema of the sample data provided.  
More details on the case study can be found [here](https://8weeksqlchallenge.com/case-study-1/).

## Case Study Solutions

**1. What is the total amount each customer spent at the restaurant?**  
```SQL
select 
    s.customer_id
    , sum(m.price) as amount_spent
from dannys_diner.sales as s 
    full outer join  
    dannys_diner.menu as m on s.product_id = m.product_id
group by s.customer_id;
```

The sales and menu tables were joined to be able to acces the price information of the products bought by customers. This was then sumed up per customer to determine how much was spent by each. 

customer_id | amount_spent
----------- | ------------
A           | 76
B           | 74
C           | 36

The sample data provided shows that customer A has spent the most closely followed by customer B. 


**2. How many days has each customer visited the restaurant?**  
```SQL
select
    s.customer_id
    , count(distinct s.order_date) as number_of_days
from dannys_diner.sales as s
group by s.customer_id;
```

It is important to include the *distinct* funtion when counting the days as customers can visit the stoe tice in one day or purchase more than one item during their visit, and each purchse is recorded on a separate row.

customer_id | number_of_days
----------- | --------------
A           | 4
B           | 6
C           | 2


**3. What was the first item from the menu purchased by each customer?**  
```SQL
with
    product_rankings as (
        select
	    customer_id
	    , product_id
	    , order_date
	    ,rank() over(partition by customer_id order by order_date asc) product_rank
	from dannys_diner.sales
    )

select distinct
	pr.customer_id
	, m.product_name
from product_rankings as pr 
    inner join 
    dannys_diner.menu as m on pr.product_id = m.product_id
where pr.product_rank = 1;
```

First we need to rank the products bought by each customer according to the order_date. we do this using the *rank() over(partition by )* functions. The result is instantiated in a common table expression called 'product rankings'. The final result is a query from this table joined to the menu table, to get the product name information, filtered to where the product rank is *1*, returning the first item purchased by each customer.

customer_id | product_name
----------- | ------------
A           | curry
A           | sushi
B           | curry
C           | ramen


**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**  
```SQL
select top 1
    m.product_name
    , count(s.product_id) as number_of_purchases
from dannys_diner.sales as s
    inner join 
    dannys_diner.menu as m on s.product_id = m.product_id
group by m.product_name
order by count(s.product_id) desc;
```

Each occurrence of the product ids in the sales table is counted, and the results are ordered by the highest product count. The top result is filtered as the most purchased product.

product_name | number_of_purchases
------------ | -------------------
ramen        | 8


**5. Which item was the most popular for each customer?**  
```SQL
with 
    product_freq as (
        select 
	    customer_id
	    , product_id
	    , count(product_id) count_of_ids
	    , RANK() over(partition by customer_id order by count(product_id) desc) as number_of_purchases
	from dannys_diner.sales
	group by customer_id, product_id
    )

select 
    pf.customer_id
    , m.product_name most_popular_product
from product_freq as pf
    inner join 
    dannys_diner.menu as m on pf.product_id = m.product_id
where pf.number_of_purchases = 1;
```
First we need to rank the products bought by each customer according to the number of each product purchased. As with the 3rd question, we use the *rank() over(partition by )* functions. The result is instantiated in a common table expression called 'product_freq'. The final result is a query from this table joined to the menu table, to get the product name information, filtered to where the product rank is *1*, returning the most purchased product by each customer.

customer_id | most_popular_product
----------- | --------------------
A           | ramen
B           | sushi
B           | curry
B           | ramen
C           | ramen


**6. Which item was purchased first by the customer after they became a member?**  
```SQL
with
    member_purchases as (
	select
	    s.customer_id
	    , s.product_id
	    ,rank() over(partition by s.customer_id order by s.order_date) as order_rank
	    ,order_date
	    ,join_date
	from dannys_diner.sales as s
	    inner join
	    dannys_diner.members as c on s.customer_id = c.customer_id
	where s.order_date >=  c.join_date
    )

select
    mp.customer_id
    , m.product_name
from member_purchases as mp
    inner join 
    dannys_diner.menu as m on mp.product_id = m.product_id
where mp.order_rank = 1;
```

Again we employ the use of a CTE to create a subset of data for purchases where customers have signed up to be members. This is determined by selecting records where the orders are made on or after the date a customer became a member. 


customer_id | product_name
----------- | ------------
A           | curry
B           | sushi


**7. Which item was purchased just before the customer became a member?**  
```SQL
with
    premember_purchases as (
        select
	    s.customer_id
	    , s.product_id
	    ,rank() over(partition by s.customer_id order by s.order_date desc) as order_rank
	    ,order_date
	    ,join_date
	from dannys_diner.sales as s
	    inner join
	    dannys_diner.members as c on s.customer_id = c.customer_id
	where s.order_date < c.join_date
    )

select
    pmp.customer_id
    , m.product_name
from premember_purchases as pmp
    inner join
    dannys_diner.menu as m on pmp.product_id = m.product_id
where pmp.order_rank = 1;
```

Here we create a subset of data for purchases before customers have signed up to be members. This is determined by selecting records where the orders are before the date a customer became a member. 


customer_id | product_name
----------- | ------------
A           | sushi
A           | curry
B           | sushi


**8. What is the total items and amount spent for each member before they became a member?**  
```SQL
select 
    s.customer_id
    , count(s.product_id) as total_items
    , sum(m.price) as amount_spent
from dannys_diner.sales as s
    inner join
    dannys_diner.members as c on s.customer_id = c.customer_id
    inner join
    dannys_diner.menu as m on s.product_id = m.product_id
where s.order_date < c.join_date
group by s.customer_id;
```
customer_id | total_items | amount_spent
----------- | ----------- | ------------
A           | 2           | 25
B           | 3           | 40


**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**  
```SQL
with
    product_points as (
        select
	    m.product_id
	    , case
	        when product_id = 1
	        then m.price*20
		else m.price*10
	      end as points_earned
	from dannys_diner.menu as m
    )

select
    s.customer_id
    , sum(pp.points_earned) as total_points
from dannys_diner.sales as s
    inner join
    product_points as pp on s.product_id = pp.product_id
group by s.customer_id;
```

A CTE is created to denote points for products purchased using the 'Case' clause. This is then joined to the sales table to generate the final result set grouping sales by customer_id and summing the product points.

customer_id | total_points
----------- | ------------
A           | 860
B           | 940
C           | 360

**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**  
```SQL
with
    purchase_points as (
        select
	    s.customer_id
	    , s.product_id
	    , s.order_date
	    , c.join_date
	    , case
	        when s.order_date between c.join_date and dateadd(d, 6, c.join_date)
		    or s.product_id = 1
		then m.price*20
		else m.price *10
	      end as product_points
	from dannys_diner.sales as s
	    inner join
	    dannys_diner.menu as m on s.product_id = m.product_id
	    inner join
	    dannys_diner.members as c on s.customer_id = c.customer_id
	where s.order_date <= '2021-01-31'
    )
    
select
    customer_id
    , sum(product_points) as total_points
from purchase_points as pp
group by customer_id;
```

A similar CTE is created as in the previous question using the 'Case' clause, which is adjusted to accommodate records where the order date is within a week of the join date, using the dateadd function. We only add 6 days as the join date is accounted for in the first week. The result set is filtered for orders on or before the last day of January. The final result set is then queried from this table.


customer_id | total_points
----------- | ------------
A           | 1370
B           | 820

