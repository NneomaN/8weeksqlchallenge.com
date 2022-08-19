
# Case Study 2 - Pizza Runner

 <img src="https://user-images.githubusercontent.com/77930192/185507440-8ea5519c-343c-48aa-8816-bce7fab3a70e.png" alt="8weeksqlchallenge_Pizza_Runner_Banner" width="500" height="500"/>

My attempt at solving the Pizza Runner case study of the 8 weeks SQL challenge using T-SQL to query data hosted on an MS SQL Server.

## Problem Statement

Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”  
Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea  
to combine with it - he was going to Uberize it - and so Pizza Runner was launched!  
Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house)  
and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

## Available Data

![ERD of available Pizza Runner data](https://user-images.githubusercontent.com/77930192/185513103-b38189aa-69d0-446b-90b6-a2ffa00380db.png)  
Here's a view of the schema of data provided.
I made some edits to the original dataset code to enforce compatibility with my MS SQL Server:
- I added the schema 'pizza_runner' to the table names as MS SQL Server doesn't support the 'search_path' function
- Changed the data type of customer_orders.order_time from TIMESTAMP to DATETIME as MS SQL Server doesn't support inserting into a timestamp column
After successfully importing the sample data provided, some data cleaning was necessary to handle null values and setting the appropriate data type

More details on the case study can be found [here](https://8weeksqlchallenge.com/case-study-2/)
