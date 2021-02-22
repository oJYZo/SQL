-- Analyzing Big Data I
-- Final Project
-- Grace Nolitse
-- Yuxiao Yang
-- Jianying Zhu

use db_analysis_using_sql;

--    Q-1. Write A SQL Query to Fetch “firstname” From customers Table Using The Alias Name As <CUSTOMER _NAME>.'
select * from customers;
select firstname as 'CUSTOMER_NAME' from customers;

--    Q-2. Write An SQL Query To Fetch “firstname” From Customer Table Using The Alias Name As <CUSTOMER_NAME> but 
-- make it appear in NON-CAPITAL LETTERS'
select lower(firstname) as 'CUSTOMER_NAME' from customers;

--    Q-3. Write a query to recover the number of customers that we have for each name and order them name alphabetically.
select * from customers;
select firstname as 'Customer_name', sum(1) as 'Number_of_customers' from customers group by firstname order by firstname;

--    Q-4. Write a SQL Query To Print The First Three Characters from each customer name. Use the table customers
select * from customers;
select substring(firstname,1,3) as 'First_three_characters' from customers;
-- select firstname as 'Customer_name', substring(firstname,1,3) as 'First_three_characters' from customers;

--    Q-5.a Write a SQL Query to Find the Position of the Alphabet (‘A’) In The Column ‘firstname’ using the customer table.
select * from customers;
select firstname as 'Customer_name', locate('a', firstname) as 'Position_of_A' from customers;
-- select firstname as 'Customer_name', position('a' in firstname) as 'Position_of_A' from customers;
-- select firstname as 'Customer_name', instr(firstname, 'a') as 'Position_of_A' from customers;

-- Q-5.b Write a SQL query to learn from the data how much money does my firm collect from cities that have the letter A in 3rd position.
select city, round(sum(totalprice)) as Total_Revenue from orders where locate('a', city, 3) = 3 group by city;
select round(sum(totalprice)) as Total_Revenue from 
	(select city, totalprice, locate('a', city, 3) from orders where locate('a', city, 3) = 3) aa; -- -- The total revenue is 880,061
-- The total revenue collected from cities that have the letter A in 3rd position is 880,061

--    Q-6. Write a SQL Query That Fetches the Unique Values from the customers Table And Prints Its Length.
select distinct firstname as 'Customer_name' from customers;
select distinct firstname as 'Customer_name', char_length(firstname) as 'Name_length' from customers;

--   Q-7. Write a SQL Query to Print the first name from the customer Table After Replacing ‘Z’ With ‘z’. Hint (google command replace)
select firstname as 'Customer_name', replace(firstname, 'Z', 'z') as 'Modified_name_z' from customers;
select firstname as 'Customer_name', replace(firstname, 'Z', 'z') as 'Modified_name_z' from customers where firstname regexp 'z';

--    Q-8. Write a SQL Query To Print All customers Details From The customers Table, and  Order them By firstname in Ascending order. 
-- IMPORTANT: DROP ALL THE MISSING VALUES (of firstname)
select * from customers;
select * from customers where firstname is not null order by firstname asc;

--  Q-9. Write a SQL Query to recover all the names after dropping duplicities and ordering them in ASCending order.
select distinct firstname as 'Customer_name' from customers order by firstname asc;

--  Q-10. Write a SQL Query to find out how many customers are named Taylor or Jordan.
select * from customers;
select firstname as 'Customer_name', sum(1) as 'Number_of_customers' from customers where 
	firstname in('taylor', 'jordan') group by firstname;

--  Q-11. Write a SQL Query to find out which is the most unisex name across our customer database, for example 
-- 100% of our customers that are named john are men but that it is not the same for names such as jordan.
select * from (
SELECT firstname, (SUM(CASE WHEN gender='M' THEN 1 ELSE 0 END)/COUNT(*)) as 'male_percent', 
(SUM(CASE WHEN gender='F' THEN 1 ELSE 0 END)/COUNT(*)) as 'female_percent'
FROM customers 
GROUP BY firstname) aa where male_percent between 0.4 and 0.6 and female_percent between 0.4 and 0.6;
-- The most unisex names are JUDAH, SANDEEP, ROBERTSON, WM, EKREM, HAMID

-- Using a percentage difference approach, we can also see that those names are the ones with the smallest percentage difference
-- between male and female (0.0000)
select firstname, male_percent, female_percent, abs(male_percent - female_percent) as Difference_percent from (
SELECT firstname, gender, (SUM(CASE WHEN gender='M' THEN 1 ELSE 0 END)/COUNT(*)) as 'male_percent', 
(SUM(CASE WHEN gender='F' THEN 1 ELSE 0 END)/COUNT(*)) as 'female_percent'
FROM customers where gender is not null GROUP BY firstname)aa order by difference_percent;

-- Create a table that displays 3 columns name %_male and %_female.

--    Q-12. Write A SQL Query to Show The Current Date. Curdate()
select curdate() as 'Current_date';

--   Q-13. Write a query that returns the number of days between any order and today
select Orderdate, curdate() as 'Current_date', datediff(curdate(), orderdate) as 'Number_Days_difference' from orders;
select Orderdate, curdate() as 'Current_date', datediff(curdate(), orderdate) as 'Number_Days_difference' from orders
	order by orderdate;

-- Q-14. Write A SQL Query To recover the orders that are from new mexico and occurred between February 2009 and October 2009.
select * from orders;
-- Details of orders from New Mexico between time period:
select * from (select * from orders where state = 'NM')aa where 
	Orderdate between cast('2009-02-01' as date) and cast('2009-10-31' as date); 
-- Total revenue collected from New Mexico NM between between February 2009 and October 2009:
select round(sum(totalprice)) as Total_Revenue from (select totalprice, Orderdate from orders where state = 'NM')aa where 
	Orderdate between cast('2009-02-01' as date) and cast('2009-10-31' as date);

 -- Q-15. Write An SQL Query To Print recover the orders that are from new mexico and take values between february 2009 and 
 -- October 2009  aggregate them by day of the week
 select dayofweek(orderdate) as 'Day_of_week', round(sum(totalprice)) as Total_Revenue from 
	(select totalprice, Orderdate from orders where state = 'NM') aa where Orderdate between 
	cast('2009-02-01' as date) and cast('2009-10-31' as date) group by dayofweek(orderdate);
-- With day names:
select dayname(orderdate) as 'Day_of_week', round(sum(totalprice)) as Total_Revenue from 
	(select totalprice, Orderdate from orders where state = 'NM') aa where Orderdate between 
	cast('2009-02-01' as date) and cast('2009-10-31' as date) group by dayname(orderdate);

-- Q-16. What is the average total price paid in a given order by month in the states that have coast in the Pacific, Atlantic
-- and without land locked?
-- We assume the average total price paid to be the average total money collected (sum of totalprice)
select * from orders;
-- Pacific: AK, CA, HI, OR, WA
select state, month(orderdate) as `Month`, round(sum(totalprice)) as Total_paid from orders
	where state in ('AK', 'CA', 'HI', 'OR', 'WA') group by state, `Month` order by `Month` asc;
select `Month`, round(avg(Total_paid)) as Avg_total_paid from
	(select state, month(orderdate) as `Month`, round(sum(totalprice)) as Total_paid from orders 
    where state in ('AK', 'CA', 'HI', 'OR', 'WA')group by state, `Month` order by `Month` asc) aa group by `Month`;

-- Atlantic: ME, NH, MA, RI, CO, NY, NJ, DE, MD, VA, NC, SC, GA, and FL
select `Month`, round(avg(Total_paid)) as Avg_total_paid from
	(select state, month(orderdate) as `Month`, round(sum(totalprice)) as Total_paid from 
    orders where state in ('ME', 'NH', 'MA', 'RI', 'CO', 'NY', 'NJ', 'DE', 'MD', 'VA', 'NC', 'SC', 'GA', 'FL')group by state, 
    `Month` order by `Month` asc) aa group by `Month`;

-- Without landlocked: TX, LA, MS, AL, MI, WI, MN, IL, PA, OH
select `Month`, round(avg(Total_paid)) as Avg_total_paid from
	(select state, month(orderdate) as `Month`, round(sum(totalprice)) as Total_paid from orders 
    where state in ('TX', 'LA', 'MS', 'PA', 'OH', 'AL', 'MI', 'WI', 'MN', 'IL') group by state, 
    `Month` order by `Month` asc) aa group by `Month`;

-- Q-17. Create a query that returns the population of the 5 most populated zipcodes in every state
select stab as State, zcta5 as Zipcode, TotPopsf1 as Population, row_number() over (partition by stab order by 
	TotPopsf1 desc) as Zipcode_ranking from zipcensus;
select * from (select stab as State, zcta5 as Zipcode, TotPopsf1 as Population, row_number() over (partition by stab order by 
	TotPopsf1 desc) as zipcode_ranking from zipcensus) aa where zipcode_ranking <= 5;

-- Q-18. Compare the average population of the zipcodes located in states with less 200 zipcodes with those located in states
-- with more than 200 zipcodes.
select stab, count(zcta5) as n_zips, avg(Totpopsf1) as avg_pop from zipcensus group by stab having n_zips < 200;
select round(avg(avg_pop)) as Avg_population from (
	select stab, count(zcta5) as n_zips, avg(Totpopsf1) as avg_pop from zipcensus group by stab having n_zips < 200) aa;
-- The average population of the zipcodes in states with less than 200 zipcodes is 11917.

select round(avg(avg_pop)) as Avg_population from (
	select stab, count(zcta5) as n_zips, avg(Totpopsf1) as avg_pop from zipcensus group by stab having n_zips > 200) aa;
-- The average population of the zipcodes in states with more than 200 zipcodes is 8320.
-- So the average population of zipcodes in states with less than 200 zipcodes is bigger.

-- Q.19 Write A SQL Query To Fetch The First 10% Records From the table orders.
select count(*) from orders; -- 192983 total rows (records)
select round(count(*)/10) as 'n_10%_rows' from orders; -- first 10% rows 
select * from orders order by orderdate limit 19298; -- first 10% records