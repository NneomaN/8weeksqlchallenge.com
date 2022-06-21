-- Q1 What is the total amount each customer spent at the restaurant?
select 
    s.customer_id
	, sum(m.price) as amount_spent
from dannys_diner.sales as s 
	full outer join 
	dannys_diner.menu as m on s.product_id = m.product_id
group by s.customer_id;

-- Q2 How many days has each customer visited the restaurant?
select
    s.customer_id
	, count(distinct s.order_date) as number_of_days
from dannys_diner.sales as s
group by s.customer_id;

-- Q3 What was the first item from the menu purchased by each customer?
with product_rankings
as
    (
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

--Q4 What is the most purchased item on the menu and how many times was it purchased by all customers?
select top 1
	m.product_name
	, count(s.product_id) as number_of_purchases
from dannys_diner.sales as s
	inner join 
	dannys_diner.menu as m on s.product_id = m.product_id
group by m.product_name
order by count(s.product_id) desc;

--Q5 Which item was the most popular for each customer?
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
inner join dannys_diner.menu as m on pf.product_id = m.product_id
where pf.number_of_purchases = 1;

--Q6 Which item was purchased first by the customer after they became a member?
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
		where s.order_date >=  c.customer_id
	)

	select top 1 
		mp.customer_id
		, m.product_name
	from member_purchases as mp
		inner join 
		dannys_diner.menu as m on mp.product_id = m.product_id
	where mp.order_rank = 1;

--Q7 Which item was purchased just before the customer became a member?


--Q8 What is the total items and amount spent for each member before they became a member?


--Q9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


--Q10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
