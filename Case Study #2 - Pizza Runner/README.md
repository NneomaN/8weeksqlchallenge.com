Made some edits to the original dataset code:
Added the schema to the table names as ms sql doesn't hae a search_path function
Changed the data type of pizza_runner.customer_orders.order_time from TIMESTAMP to DATETIME for MS SQL Server compatibility
Changed the data type of pizza_runner.runner_orders.pickup_time from VARCHAR (19) to DATETIME for compatibility with other datetime data. Also had to change 'null' entries to null
