-- Actual Dataset that will be used through out the tutorial(https://www.youtube.com/watch?v=OT1RErkfLNQ&ab_channel=AlexTheAnalyst)

DROP DATABASE IF EXISTS `Parks_and_Recreation`;
CREATE DATABASE `Parks_and_Recreation`;
USE `Parks_and_Recreation`;



CREATE TABLE employee_demographics (
  employee_id INT NOT NULL,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  age INT,
  gender VARCHAR(10),
  birth_date DATE,
  PRIMARY KEY (employee_id)
);

CREATE TABLE employee_salary (
  employee_id INT NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  occupation VARCHAR(50),
  salary INT,
  dept_id INT
);


INSERT INTO employee_demographics (employee_id, first_name, last_name, age, gender, birth_date)
VALUES
(1,'Leslie', 'Knope', 44, 'Female','1979-09-25'),
(3,'Tom', 'Haverford', 36, 'Male', '1987-03-04'),
(4, 'April', 'Ludgate', 29, 'Female', '1994-03-27'),
(5, 'Jerry', 'Gergich', 61, 'Male', '1962-08-28'),
(6, 'Donna', 'Meagle', 46, 'Female', '1977-07-30'),
(7, 'Ann', 'Perkins', 35, 'Female', '1988-12-01'),
(8, 'Chris', 'Traeger', 43, 'Male', '1980-11-11'),
(9, 'Ben', 'Wyatt', 38, 'Male', '1985-07-26'),
(10, 'Andy', 'Dwyer', 34, 'Male', '1989-03-25'),
(11, 'Mark', 'Brendanawicz', 40, 'Male', '1983-06-14'),
(12, 'Craig', 'Middlebrooks', 37, 'Male', '1986-07-27');


INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES
(1, 'Leslie', 'Knope', 'Deputy Director of Parks and Recreation', 75000,1),
(2, 'Ron', 'Swanson', 'Director of Parks and Recreation', 70000,1),
(3, 'Tom', 'Haverford', 'Entrepreneur', 50000,1),
(4, 'April', 'Ludgate', 'Assistant to the Director of Parks and Recreation', 25000,1),
(5, 'Jerry', 'Gergich', 'Office Manager', 50000,1),
(6, 'Donna', 'Meagle', 'Office Manager', 60000,1),
(7, 'Ann', 'Perkins', 'Nurse', 55000,4),
(8, 'Chris', 'Traeger', 'City Manager', 90000,3),
(9, 'Ben', 'Wyatt', 'State Auditor', 70000,6),
(10, 'Andy', 'Dwyer', 'Shoe Shiner and Musician', 20000, NULL),
(11, 'Mark', 'Brendanawicz', 'City Planner', 57000, 3),
(12, 'Craig', 'Middlebrooks', 'Parks Director', 65000,1);



CREATE TABLE parks_departments (
  department_id INT NOT NULL AUTO_INCREMENT,
  department_name varchar(50) NOT NULL,
  PRIMARY KEY (department_id)
);

INSERT INTO parks_departments (department_name)
VALUES
('Parks and Recreation'),
('Animal Control'),
('Public Works'),
('Healthcare'),
('Library'),
('Finance');



#HAVING
select gender, avg(age)
from employee_demographics
group by gender
having avg(age) > 40;

select occupation, avg(salary) from employee_salary
where occupation like '%director%'
group by occupation
having avg(salary) between 20000 and 70000
;

#LIMIT & ALIAS
SELECT * FROM employee_demographics ORDER BY age DESC LIMIT 2, 3;

select gender, avg(age) as avg_age
from employee_demographics
group by gender 
having avg_age > 40;

#JOINS
select dem.employee_id, age, occupation from employee_demographics as dem
inner join employee_salary as sal
on dem.employee_id = sal.employee_id
;

select dem.employee_id, age, occupation from employee_demographics as dem
right join employee_salary as sal
on dem.employee_id = sal.employee_id
;

select emp1.employee_id as emp_santa, emp1.first_name as fname_santa,
emp2.employee_id as emp_name, emp2.first_name as fname_emp
from employee_salary as emp1
join employee_salary as emp2
on emp1.employee_id + 1 = emp2.employee_id;

select * from employee_demographics as dem
inner join employee_salary as sal
on dem.employee_id = sal.employee_id
inner join parks_departments as pd
on pd.department_id = sal.dept_id
order by dept_id
;

#UNION allows you to combine rows together.
#union allows you to combine the rows in data from separate tables or from the same tables 

select first_name, last_name, 'Old Man' as Label from employee_demographics 
where age > 40 and gender = 'Male'
union 
select first_name, last_name, 'Old Lady' as Label from employee_demographics
where age > 40 and gender = 'Female'
union
select first_name, last_name, 'Highly Paid Employee' AS label
from employee_salary
where salary > 70000
order by first_name
;

#String function
select first_name, right(first_name, 2) as trimmed_data, birth_date,
substring(birth_date, 6, 2) as birth_month
from employee_demographics;

select first_name, last_name, replace(first_name, 'r', 'R') as replaced_val,
locate('a', last_name) as located_val
from employee_demographics;

select first_name, last_name, concat(first_name, ' ', last_name) as full_name
from employee_demographics;

#CASE statement

select first_name, last_name, age,
case 
	when age <= 30 then 'Young'
    when age between 31 and 50 then 'old'
    else 'teen'
    end as age_identity
from employee_demographics;

-- Pay increase and bonus
-- <50000 = 5%
-- > 50000 = 7%
-- Finance = 10%

select first_name, last_name, salary,
case 
	when salary < 50000 then salary * 1.05
    when salary > 50000 then salary * 1.07 
    end as adjusted_salary,
case 
	when dept_id = 6 then salary * 1.10
    end as bonus_salary
from employee_salary;

select * from employee_demographics
where employee_id in (select employee_id from employee_salary as sal
join parks_departments as park
on sal.dept_id = park.department_id
where park.department_name = 'Parks and Recreation')
;

select *,(select avg(salary) as avg_salary from employee_salary) from employee_salary;

select avg(max_age) 
from(select gender, max(age) as max_age, min(age) as min_age, 
avg(age) as avg_age from employee_demographics group by gender) as aggr_table
;

#Window function

select sal.first_name, sal.last_name, dem.gender,
avg(salary) over(partition by gender) as avg_salary
from employee_salary as sal 
join employee_demographics as dem
	on sal.employee_id = dem.employee_id;
    
select sal.first_name, sal.last_name, sal.salary, dem.gender, dem.employee_id,
sum(salary) over(partition by gender order by employee_id) as cumulative_salary
from employee_salary as sal 
join employee_demographics as dem
	on sal.employee_id = dem.employee_id
;

select sal.first_name, sal.last_name, sal.salary, dem.gender,
row_number() over(partition by gender order by salary asc) as row_num,
rank() over (partition by gender order by salary asc) as rank_num,
dense_rank() over(partition by gender order by salary asc) as dense_num
from employee_salary as sal 
join employee_demographics as dem
	on sal.employee_id = dem.employee_id
;

#VIEW

create view limited_employee as 
select * from employee_salary
where salary > 50000;

select * from limited_employee;


#BASIC queries;

INSERT INTO employees (employee_id, name, department, salary)
VALUES
    (2, 'Bob', 'IT', 60000),
    (3, 'Charlie', 'Finance', 55000);


create database movies;

create table person(
	id int,
    lastname varchar(255),
    firstname varchar(255) not null,
    address varchar(255) not null,
    city varchar(255),
    primary key (id)
);

alter table person add chutia varchar(255), drop column city;
alter table person rename column chutia to customer_id;
alter table person modify column customer_id int not null unique;

drop table batman;

create table batman(
	movie_id int,
    budget int not null,
    customer_id int not null,
    franchise varchar(255),
    cast_names varchar(255) not null unique,
    premiere datetime default current_timestamp,
    primary key (movie_id),
    foreign key(customer_id) REFERENCES person(customer_id)
);

alter table batman modify column budget varchar(255);
alter table batman modify column budget varchar(255);
alter table batman rename column budget to overall_expenditure;
alter table batman add column gross_income varchar(255) not null;



create table product_data(
	product_id int auto_increment,
    product_name varchar(255),
    price decimal(5, 2),
    date_of_purchase datetime default current_timestamp,
    shop_address varchar(255),
	primary key(product_id)
);

insert into product_data(product_name, price, date_of_purchase, shop_address)
	values('shampoo', 800.50, '2023-12-20', 'farmgate, dhaka'),
          ('shampoo', 230.50, '2023-12-20', 'farmgate, dhaka'),
	      ('soap', 50.25, '2023-01-22', 'panthapath, dhaka'),
		  ('soap', 165.75, '2023-01-22', 'panthapath, dhaka'),
          ('biscuit', 500, '2023-02-15', 'gulshan, dhaka'),
          ('biscuit', 200.59, '2023-02-15', 'gulshan, dhaka')
;

select * from prod_modified;
create table prod_modified as
select product_name, avg(price) from product_data
group by product_name;



-- CTE(Common Table Expression)
-- It's kind of like a query within a query except we're going to name the subquery block and it will be a little bit more standardized
-- a little bit better formatted than actually using using a subquery. Kind of the purpose of these CTEs is to be able  to perform more advanced
--  calculations something that you can't easily do or can't do at all within just one query. When you build a CTE you can only use it
-- immediately after creating the CTE. You can't write it down below and reuse it because it's just like calling a query that you wrote before it.

WITH cte_example (Gender, AVG_sal, MAX_sal, MIN_sal, COUNT_sal) AS   -- This will overwrite the column names that you have in your actual CTE expression or the query that you have within your CTE
(
SELECT gender, AVG(salary) AS avg_salary, MAX(salary) as max_salary, MIN(salary) AS min_salary,
COUNT(salary) AS salaray_count FROM employee_demographics AS dem
JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
)
SELECT AVG(avg_salary) AS avg_of_salary FROM cte_example
;

-- You can crate multiple CTE within just one so if you wanted to do a more complex query or 
-- joining more complex queries together we can do that all within one CTE

 WITH cte_sample1 AS
 (
 SELECT employee_id, gender, birth_date 
 FROM employee_demographics
 WHERE birth_date > '1985-01-01'
 ),
 cte_sample2 AS
 (
 SELECT employee_id, salary
 FROM employee_salary
 WHERE salary > 50000
 )
 SELECT * FROM cte_sample1
 JOIN cte_sample2
	ON cte_sample1.employee_id = cte_sample2.employee_id
;


-- Temporary Table( These table's are only visible to the session that they're created
-- in. Mostly used in cases where we can store intermediate results for complex queries 
-- somewhat like a CTE but also for using it to manipulate data  before you can insert it 
-- into a more permanent table.


CREATE TEMPORARY TABLE temp_table 
(first_name varchar(100),
last_name varchar(50),
favourite_movie varchar(256)
);

-- It's basically like a real table except it just lives in memory and then go away
-- after a while but you can reuse this temp table over and over again

insert into temp_table
values('Alex', 'Freberg', 'LORD OF THE RINGS: THE TWO TOWERS');

SELECT * FROM temp_table;


-- example: 02 
create temporary table salary_lt_60k 
select * from employee_salary
where salary < 60000;

select * from salary_lt_60k;

-- Stored Procedure 
-- stored procedure are a way to save your SQL code that you can reuse over and over again.
-- When you save it, you can call that stored procedure and it's going to execute all the code 
-- that you wrote within your stored procedure. 

 use parks_and_recreation;         -- In case you want to save the procedure into a particular database;

select * from product_data;

 create procedure product_proc()
 select * from product_data
 where shop_address like 'gulshan,%';

call product_proc();               -- You can call the procedure in this way as well [call parks_and_recreation.product_proc();]


-- example 02:

use parks_and_recreation;
drop procedure if exists `product_data`;  -- Sometimes it is really beneficial to write somethinglike this before you create it in case you've already created a story procedure with that name that you're wanting to replace;

delimiter $$
create procedure product_price()
begin
	select * from product_data
	where product_name like 'shampoo%';
	select * from product_data
	where price > 150;
end $$
delimiter ;                   -- It is best practice at the end to change it back right;

call product_price();


-- example 03:

USE parks_and_recreation;
DROP PROCEDURE IF EXISTS `employee_data01`;
DELIMITER ??
CREATE PROCEDURE employee_data01(_param INT)
BEGIN
	SELECT * FROM employee_demographics
	WHERE employee_id = _param;
END ??
DELIMITER ;
CALL employee_data01(3);


-- Triggers and Event( A trigger is a block of code that executes automatically when an event takes place on a specific table)

DELIMITER $$
CREATE TRIGGER employee_insert
	AFTER INSERT ON  employee_salary
    FOR EACH ROW 
BEGIN
	INSERT INTO employee_demographics (employee_id, first_name, last_name)
    VALUES (NEW.employee_id, NEW.first_name, NEW.last_name);
END  $$
DELIMITER ;

INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES (13, 'jean-Ralphio', 'saperstein', 'Entertainment 720 ceO', 1000000, NULL);



-- EVENTS (A Trigger happens when an event takes place whereas an event takes place when it's scheduled)
-- So this is more of a SCHEDULED AUTOMATOR rather than a trigger that happens when an event takes place
-- This could be fantastic (when you're importing data you can pull data from a specific file path on a schedule, 
-- you can build reports that are exported to a file on a schedule)

DELIMITER $$
CREATE EVENT delete_retirees 
ON SCHEDULE EVERY 30 SECOND 
DO 
BEGIN
	DELETE FROM employee_demographics
    WHERE age > 60;
END $$
DELIMITER ;

select * from employee_demographics;
SHOW variables LIKE 'event%';    		-- Check if the value of the event is ON/OFF, in case the event did't happened as expected


--  DATA CLEANING PROJECT

-- 1.Remove duplicates
-- 2. Standardize the Data
-- 3. Null values or Blank values
-- 4. Remove any columns

SELECT * FROM layoffs LIMIT 10;

-- 1.Remove duplicates --
-- creating a staging database, we never work on the raw database that we're exporting
CREATE TABLE layoffs_staging LIKE layoffs;
SELECT * FROM layoffs_staging;
INSERT layoffs_staging SELECT * FROM layoffs;


with duplicate_cte as 
(select *,  row_number() over(partition by company, location, industry,
total_laid_off, percentage_laid_off, date, stage, country, 
funds_raised_millions) as row_num from layoffs_staging)
select * from duplicate_cte where row_num > 1;              


-- The main reason you can't DELETE rows directly from a CTE is that CTEs are just temporary result sets and do not physically store data.
with duplicate_cte as 
(select *,  row_number() over(partition by company, location, industry,
total_laid_off, percentage_laid_off, date, stage, country, 
funds_raised_millions) as row_num from layoffs_staging)
delete from duplicate_cte where row_num > 1;  

-- So the approach we're going to follow is to create a table 

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;
insert into layoffs_staging2 
select *, row_number() over(partition by company, location, industry,
total_laid_off, percentage_laid_off, date, stage, country, 
funds_raised_millions) as row_num from layoffs_staging;

delete from layoffs_staging2 where row_num > 1;

-- 2. Standardize Data [Finding issues in your data and fixing it] --

-- datacheck 
select distinct industry, company, `date`, country from layoffs_staging2 order by 1;
select * from layoffs_staging2 where industry like 'crypto%';
select * from layoffs_staging2;


update layoffs_staging2 set company = trim(company);
update layoffs_staging2 set industry = 'CryptoCurrency' where industry like 'Crypto%';
update layoffs_staging2 set country = trim(trailing '.' from country);
update layoffs_staging2 set `date` = str_to_date(`date`, '%m/%d/%Y');
alter table layoffs_staging2 modify column `date` date;

update layoffs_staging2 set industry = null where industry = '';
update layoffs_staging2 as tbl1
join layoffs_staging2 as tbl2
	on tbl1.company = tbl2.company
set tbl1.industry = tbl2.industry
where tbl1.industry is null and tbl2.industry is not null;

delete from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;
alter table layoffs_staging2 drop column row_num;
















