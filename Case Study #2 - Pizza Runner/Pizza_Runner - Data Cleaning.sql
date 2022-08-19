---- Clean Customer Orders Table

select top 10 *
from pizza_runner.customer_orders
/* 
We need to udate the empty values to ensure accurate results everytime, as empty rows could affect some aggregations
Rather than update the empty strings or the rows with null manually entered as string, in the exclusions and extras columns,
we will create a new table with the cleaned values inserted into it. 
This is in order to preserve the raw data and prevent data loss due to human errors
*/

select
    order_id
	, customer_id
	, pizza_id
	, case 
	    when exclusions = 'null'
		    or exclusions = ''
		then NULL 
		else exclusions end
		as exclusions
	, case 
	    when extras = 'null'
		    or extras = ''
		then NULL 
		else extras end
		as extras
	, order_time
into pizza_runner.customer_orders_clean
from pizza_runner.customer_orders



---- Clean Runner Orders Table
select top 10 * from pizza_runner.runner_orders

/* 
We need to udate the empty values to ensure accurate results everytime, as empty rows could affect some aggregations
Rather than update the rows, we will create a new table with the cleaned values inserted into it.
This is in order to preserve the raw data and prevent data loss due to human errors


*/


select
    order_id
	, runner_id
	, cast(pickup_time as datetime) pickup_time  -- change the pickup_time to  a datetime data type
	, case
	    when distance in('null','')
		    then NULL
		when distance like '%km'
		    then cast(trim(left(distance, patindex('%km', distance)-1)) as float)
		else cast(distance as float)
	  end as distance_km    --extract the numerical characters in the distance column in order to aggregate the distance
	, case
	    when duration in ('null','')
		    then NULL
		when duration like '%min%'
		    then cast(trim(left(duration, patindex('%min%', duration)-1)) as int)
		else cast(duration as int)
	  end as duration_mins   -- extract the numerical characters in the duration column in order to aggregate duration
	, case
	    when cancellation in ('null','')
		    then NULL
		else cancellation
	  end as cancellation -- replace empty and 'null' rows with NULL to avoid errors in aggregation
into pizza_runner.runner_orders_clean 
from pizza_runner.runner_orders


-- we now have to change column type to enabble grouping as text type cannot be sorted


alter table pizza_runner.pizza_names
alter column pizza_name varchar(30)

---- Clean Pizza Recipes Table
alter table pizza_runner.pizza_recipes
alter column toppings varchar(30)

---- Clean Pizza Toppings Table
alter table pizza_runner.pizza_toppings
alter column topping_name varchar(30)