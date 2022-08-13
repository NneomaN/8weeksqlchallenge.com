
-- Q1 How many pizzas were ordered?
select count(order_id) as pizzas_ordered
from pizza_runner.customer_orders_clean;

-- Q2 How many unique customer orders were made?
select count(distinct order_id) as orders_made
from pizza_runner.customer_orders_clean;

-- Q3 How many successful orders were delivered by each runner?
select
    runner_id
	, count(runner_id) successful_orders
from pizza_runner.runner_orders_clean
where cancellation is null
group by runner_id;

-- Q4 How many of each type of pizza was delivered?
select
    pn.pizza_name,
	count(co.order_id) orders_made
from pizza_runner.customer_orders_clean as co
     inner join
	 pizza_runner.pizza_names pn on co.pizza_id = pn.pizza_id
	 inner join
	 pizza_runner.runner_orders_clean ro on co.order_id = ro.order_id
where ro.cancellation is null
group by pn.pizza_name;

-- Q5 How many Vegetarian and Meatlovers were ordered by each customer?
with orders as
(
select
    order_id
	, customer_id
	, co.pizza_id
	, pizza_name
from
    pizza_runner.customer_orders_clean as co
	join
	pizza_runner.pizza_names as pn on co.pizza_id = pn.pizza_id
)
select
    customer_id
	, sum(Meatlovers) as Meatlovers
	, sum(Vegetarian) as Vegetarian
from orders
pivot
    (
	count(order_id)
	for pizza_name in (Meatlovers, Vegetarian)
	) 
	as pvt_pizza_names
group by customer_id;

-- Q6 What was the maximum number of pizzas delivered in a single order?
with pizzas_by_order 
as
(
select
    co.order_id
	, count(co.pizza_id) pizzas_delivered
from
    pizza_runner.customer_orders_clean as co
	inner join
	pizza_runner.runner_orders_clean ro on co.order_id = ro.order_id
where ro.cancellation is null
group by co.order_id
)

select max(pizzas_delivered) as max_pizzas_delivered
from pizzas_by_order;

-- Q7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

with delivered_pizzas 
as
    (
	select co.order_id,
	customer_id,
	case when exclusions is null and extras is null then 'pizzas_without_changes'
			else 'pizzas_with_changes'
	end as [change]
	from
	    pizza_runner.customer_orders_clean as co
		join
		pizza_runner.runner_orders_clean as ro on co.order_id = ro.order_id
	where cancellation is null
	)

SELECT customer_id, pizzas_with_changes, pizzas_without_changes
FROM delivered_pizzas 
PIVOT 
( 
count(order_id) FOR [change] IN (pizzas_with_changes, pizzas_without_changes) 
) AS PivotTable;

-- Q8 How many pizzas were delivered that had both exclusions and extras?
select count(pizza_id) pizzas_with_exc_and_ext
from
    pizza_runner.customer_orders_clean as co
	join
	pizza_runner.runner_orders_clean as ro on co.order_id = ro.order_id
where cancellation is null and (exclusions is not null and extras is not null)


-- Q9 What was the total volume of pizzas ordered for each hour of the day?
select
    concat(
	    'Hour ',
		datename(hh, order_time)
		) as hour_of_day
	, count(order_id) pizzas_ordered
from pizza_runner.customer_orders_clean
group by datename(hh, order_time);

-- Q10 What was the volume of orders for each day of the week?

select
    datepart(dw, order_time) as day_no
    , datename(dw, order_time) as day_of_week
	, count(order_id) pizzas_ordered
from pizza_runner.customer_orders_clean
group by 
    datepart(dw, order_time)
	, datename(dw, order_time)
order by day_no;