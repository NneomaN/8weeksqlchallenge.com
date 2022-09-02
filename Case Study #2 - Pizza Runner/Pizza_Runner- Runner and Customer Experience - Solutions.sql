---- Q1 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

-- First we need to define the week range starting from whatever day Jan 1st falls on

-- create variable to hold first day of week value
declare @dw_no int
set @dw_no = datepart(dw, '2021-01-01');

-- set first day of week to 
set datefirst @dw_no;

-- find runners who registered in each 7 day period
select
    concat(
	    'Week ',
		datepart(wk, registration_date)
		) as week_no
	, count(runner_id) runners
from pizza_runner.runners
group by datepart(wk, registration_date)

-- return first day of week to default
set datefirst 1;


---- Q2 What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
with pickup_mins as
(
select 
    distinct ro.order_id
	, ro.runner_id 
	, datediff(minute, co.order_time, ro.pickup_time) as minutes_to_pickup
from
    pizza_runner.customer_orders_clean as co
	right join
	pizza_runner.runner_orders as ro on co.order_id = ro.order_id
where ro.pickup_time is not null
)

select
    runner_id
	, avg(minutes_to_pickup) average_pickup_minutes
from pickup_mins
group by runner_id;

-- Q3 Is there any relationship between the number of pizzas and how long the order takes to prepare?
with pickup_mins as
(
select 
    ro.order_id
	, ro.runner_id 
	, datediff(minute, co.order_time, ro.pickup_time) as minutes_to_pickup
from
    pizza_runner.customer_orders_clean as co
	right join
	pizza_runner.runner_orders as ro on co.order_id = ro.order_id
where ro.pickup_time is not null
)

select
    pm.order_id
	, count(pm.order_id) pizzas
	, avg(pm.minutes_to_pickup) avg_pickup_mins
from pickup_mins as pm
group by pm.order_id;

--- Q4 What was the average distance travelled for each customer?
select 
    co.customer_id
	, round(avg(ro.distance_km), 2) as avg_distance_travelled
from
    pizza_runner.customer_orders_clean as co
	right join
	pizza_runner.runner_orders_clean as ro on co.order_id = ro.order_id
where ro.cancellation is NULL
group by co.customer_id;

-- Q5 What was the difference between the longest and shortest delivery times for all orders?
select max(duration_mins)-min(duration_mins) as duration_range
from pizza_runner.runner_orders_clean;

-- Q6 What was the average speed for each runner for each delivery and do you notice any trend for these values?
select
    runner_id
	, order_id
	, avg(duration_mins) avg_duration
from pizza_runner.runner_orders_clean
where cancellation is null
group by runner_id, order_id
order by runner_id, order_id;

-- riders appear to be getting faster

---- Q7 What is the successful delivery percentage for each runner?
with all_orders as
(
select
    runner_id
	, count(distinct order_id) as all_orders
from pizza_runner.runner_orders_clean
group by runner_id
),
successful_orders as
(
select
    runner_id
	, count(distinct order_id) as successful_orders
from pizza_runner.runner_orders_clean
where cancellation is null
group by runner_id
)
 
select
    ao.runner_id
	, concat((successful_orders*100)/all_orders, '%') as perc_successful_orders
from 
    all_orders as ao
	join
	successful_orders as so on ao.runner_id = so.runner_id
