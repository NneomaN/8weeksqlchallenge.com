
-- Q1 How many pizzas were ordered?
select count(co.order_id) as pizzas_ordered
from pizza_runner.customer_orders co;

-- Q2 How many unique customer orders were made?
select count(distinct co.order_id) as orders_made
from pizza_runner.customer_orders co;

-- Q3 How many successful orders were delivered by each runner?
/* 
-- Need to udate empty values to enssure accurate results everytime
UPDATE pizza_runner.runner_orders
SET cancellation = NULL
WHERE cancellation = '' or cancellation = 'null' 
*/

select count(runner_id) successful_orders
from pizza_runner.runner_orders
where cancellation is null;

-- Q4 How many of each type of pizza was delivered?

/*
-- had to change column type to enabble grouping as text type cannot be sorted
alter table pizza_runner.pizza_names
alter column pizza_name varchar(25);
*/

select
    pn.pizza_name,
	count(co.order_id) orders_made
from pizza_runner.customer_orders as co
     inner join
	 pizza_runner.pizza_names pn on co.pizza_id = pn.pizza_id
group by pn.pizza_name;

-- Q5 How many Vegetarian and Meatlovers were ordered by each customer?
select
    co.customer_id,
	pn.pizza_name,
	count(pn.pizza_id) oders_made
from
    pizza_runner.customer_orders as co
	left join
	pizza_runner.pizza_names as pn on co.pizza_id = pn.pizza_id
group by co.customer_id, pn.pizza_name
order by co.customer_id;

-- Q6 What was the maximum number of pizzas delivered in a single order?
with pizzas_by_order 
as
    (
	select
	    co.order_id
		, count(co.pizza_id) pizzas_ordered
	from pizza_runner.customer_orders as co
	group by co.order_id
	)

select max(pizzas_ordered) as max_pizzas_in_order
from pizzas_by_order;

-- Q7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
/* 
-- Need to udate empty values to enssure accurate results everytime
UPDATE pizza_runner.customer_orders
SET exclusions = NULL
WHERE exclusions = '' or exclusions = 'null'

UPDATE pizza_runner.customer_orders
SET extras = NULL
WHERE extras = '' or extras = 'null'
*/

/* WIP
with customer_changes 
as
    (
	select
	    co.customer_id
		, count(co.pizza_id) pizzas_ordered
		, count(co.extras) as extras
		, count(co.exclusions) as exclusions
	from pizza_runner.customer_orders as co
	group by co.customer_id
	)

select
    customer_id
	, change
	, no_changes
from customer_changes as cc
unpivot
    (no_changes for change in
	   (extras, exclusions)
	   ) as unpvt;
*/

-- Q8 How many pizzas were delivered that had both exclusions and extras?
--WIP

-- Q9 What was the total volume of pizzas ordered for each hour of the day?
select
    datename(hh, order_time) as hour_of_day
	, count(order_id) pizzas_ordered
from pizza_runner.customer_orders
group by datename(hh, order_time);

-- Q10 What was the volume of orders for each day of the week?

select
    datepart(dw, order_time) as day_no
    , datename(dw, order_time) as day_of_week
	, count(order_id) pizzas_ordered
from pizza_runner.customer_orders
group by 
    datepart(dw, order_time)
	, datename(dw, order_time)
order by day_no;