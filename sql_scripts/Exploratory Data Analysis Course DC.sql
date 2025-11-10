-- Summarizing and Aggregating Numeric Data




-- Truncate
-- Use trunc() to examine the distributions of attributes of the Fortune 500 companies.
-- Remember that trunc() truncates numbers by replacing lower place value digits with zeros:
-- trunc(value_to_truncate, places_to_truncate)
-- Negative values for places_to_truncate indicate digits to the left of the decimal to replace, while positive values indicate 
-- digits to the right of the decimal to keep.-- 

-- Instructions 1/2
-- Use trunc() to truncate employees to the 100,000s (5 zeros).
-- Count the number of observations with each truncated value.

-- Truncate employees
SELECT trunc(employees, -5) AS employee_bin,
    -- Count number of companies with each truncated value
    count(*)
FROM fortune500 -- Use alias to group
GROUP BY employee_bin -- Use alias to order
ORDER BY employee_bin;

-- Instructions 2/2
-- Repeat step 1 for companies with < 100,000 employees (most common).
-- This time, truncate employees to the 10,000s place.

-- Truncate employees
SELECT trunc(employees, -4) AS employee_bin,
    -- Count number of companies with each truncated value
    count(*)
FROM fortune500 -- Limit to which companies?
WHERE employees < 100000 -- Use alias to group
GROUP BY employee_bin -- Use alias to order
ORDER BY employee_bin;


-- Generate series Summarize the distribution of the number of questions with the tag "dropbox" on Stack Overflow per day by binning the data.
-- Recall: generate_series(from, to, step) You can reference the slides using the PDF icon in the upper right corner of the screen.

-- Instructions 1 / 3 
-- Start by selecting the minimum
-- and maximum of the question_count column for the tag 'dropbox' so you know the range of
-- values to cover with the bins.

-- Select the min and max of question_count
SELECT min(question_count), 
       max(question_count)
  -- From what table?
  FROM stackoverflow
 -- For tag dropbox
 where tag = 'dropbox';
 
 
--  Instructions 2/3
-- Next, use generate_series() to create bins of size 50 from 2200 to 3100.
-- To do this, you need an upper and lower bound to define a bin.
-- This will require you to modify the stopping value of the lower bound and the starting value of the upper bound by the bin width.

-- Create lower and upper bounds of bins
SELECT generate_series(2200, 3050, 50) AS lower,
       generate_series(2250, 3100, 50) AS upper;
       
       
-- Instructions 3/3
-- Select lower and upper from bins, along with the count of values within each bin bounds.
-- To do this, you'll need to join 'dropbox', which contains the question_count for tag "dropbox", to the bins created by generate_series().
-- The join should occur where the count is greater than or equal to the lower bound, and strictly less than the upper bound.

-- Bins created in Step 2
WITH bins AS (
      SELECT generate_series(2200, 3050, 50) AS lower,
             generate_series(2250, 3100, 50) AS upper),
     -- Subset stackoverflow to just tag dropbox (Step 1)
     dropbox AS (
      SELECT question_count 
        FROM stackoverflow
       WHERE tag='dropbox') 
-- Select columns for result
-- What column are you counting to summarize?
SELECT lower, upper, count(question_count) 
  FROM bins  -- Created above
       -- Join to dropbox (created above), keeping all rows from the bins table in the join
       LEFT JOIN dropbox
       -- Compare question_count to lower and upper
         ON question_count >= lower 
        AND question_count < upper
 -- Group by lower and upper to count values in each bin
 GROUP BY lower, upper
 -- Order by lower to put bins in order
 ORDER BY lower;
 
 

-- Correlation
-- What's the relationship between a company's revenue and its other financial attributes? Compute the correlation between revenues 
-- and other financial variables with the corr() function.

-- Instructions
-- Compute the correlation between revenues and profits.
-- Compute the correlation between revenues and assets.
-- Compute the correlation between revenues and equity.
 
 -- Correlation between revenues and profit
SELECT corr(revenues, profits) AS rev_profits,
	   -- Correlation between revenues and assets
       corr(revenues, assets) AS rev_assets,
       -- Correlation between revenues and equity
       corr(revenues, equity) AS rev_equity 
  FROM fortune500;
  
  
-- Mean and Median
-- Compute the mean (avg()) and median assets of Fortune 500 companies by sector.
-- Use the percentile_disc() function to compute the median:
-- percentile_disc(0.5) WITHIN GROUP (ORDER BY column_name)

-- Instructions
-- Select the mean and median of assets.
-- Group by sector.
-- Order the results by the mean.

-- What groups are you computing statistics by?
SELECT sector,
       -- Select the mean of assets with the avg function
       avg(assets) AS mean,
       -- Select the median
       percentile_disc(0.5) within group (order by assets) AS median
  FROM fortune500
 -- Computing statistics for each what?
 GROUP BY sector
 -- Order results by a value of interest
 ORDER BY mean;
 
 
--  Create a temp table
-- Find the Fortune 500 companies that have profits in the top 20% for their sector (compared to other Fortune 500 companies).
-- To do this, first, find the 80th percentile of profit for each sector with
-- percentile_disc(fraction) 
-- WITHIN GROUP (ORDER BY sort_expression)
-- and save the results in a temporary table.
-- Then join fortune500 to the temporary table to select companies with profits greater than the 80th percentile cut-off.

-- Instructions 1/2
-- Create a temporary table called profit80 containing the sector and 80th percentile of profits for each sector.
-- Alias the percentile column as pct80.

-- To clear table if it already exists; fill in name of temp table
DROP TABLE IF EXISTS ___;

-- Create the temporary table
create temp table profit80 AS 
  -- Select the two columns you need; alias as needed
  SELECT sector, 
         percentile_disc(0.8) within group (order by profits) AS pct80
    -- What table are you getting the data from?
    from fortune500
   -- What do you need to group by?
   group by sector;
   
-- See what you created: select all columns and rows from the table you created
SELECT * 
  FROM profit80;
  
  
-- Instructions 2/2
-- Using the profit80 table you created in step 1, select companies that have profits greater than pct80.
-- Select the title, sector, profits from fortune500, as well as the ratio of the company's profits to the 80th percentile profit.
 
 -- Code from previous step
DROP TABLE IF EXISTS profit80;

CREATE TEMP TABLE profit80 AS
  SELECT sector, 
         percentile_disc(0.8) WITHIN GROUP (ORDER BY profits) AS pct80
    FROM fortune500 
   GROUP BY sector;

-- Select columns, aliasing as needed
SELECT title, fortune500.sector, 
       profits, profits/pct80 AS ratio
-- What tables do you need to join?  
  FROM fortune500 
       LEFT JOIN profit80
-- How are the tables joined?
       ON profit80.sector=fortune500.sector
-- What rows do you want to select?
 WHERE profits > pct80;
 
 
-- Create a temp table to simplify a query
-- The Stack Overflow data contains daily question counts through 2018-09-25 for all tags, but each tag has a different starting date in the data.
-- Find out how many questions had each tag on the first date for which data for the tag is available, as well as how many questions had 
-- the tag on the last day. Also, compute the difference between these two values.
-- To do this, first compute the minimum date for each tag.
-- Then use the minimum dates to select the question_count on both the first and last day. To do this, join the temp table startdates 
-- to two different copies of the stackoverflow table: one for each column - first day and last day - aliased with different names.

-- Instructions 1/2
-- First, create a temporary table called startdates with each tag and the min() date for the tag in stackoverflow.
 
 -- To clear table if it already exists
DROP TABLE IF EXISTS startdates;

-- Create temp table syntax
CREATE temp table startdates AS
-- Compute the minimum date for each what?
SELECT tag,
       min(date) AS mindate
  FROM stackoverflow
 -- What do you need to compute the min date for each tag?
 group by tag;
 
 -- Look at the table you created
 SELECT * 
   FROM startdates;
   
   
-- Instructions 2/2
-- Join startdates to stackoverflow twice using different table aliases.
-- For each tag, select mindate, question_count on the mindate, and question_count on 2018-09-25 (the max date).
-- Compute the change in question_count over time.
 
 -- To clear table if it already exists
DROP TABLE IF EXISTS startdates;

CREATE TEMP TABLE startdates AS
SELECT tag, min(date) AS mindate
  FROM stackoverflow
 GROUP BY tag;
 
-- Select tag (Remember the table name!) and mindate
SELECT startdates.tag, 
       mindate, 
       -- Select question count on the min and max days
	   so_min.question_count AS min_date_question_count,
       so_max.question_count AS max_date_question_count,
       -- Compute the change in question_count (max- min)
       so_max.question_count - so_min.question_count AS change
  FROM startdates
       -- Join startdates to stackoverflow with alias so_min
       INNER JOIN stackoverflow AS so_min
          -- What needs to match between tables?
          ON startdates.tag = so_min.tag
         AND startdates.mindate = so_min.date
       -- Join to stackoverflow again with alias so_max
       INNER JOIN stackoverflow AS so_max
       	  -- Again, what needs to match between tables?
          ON startdates.tag = so_max.tag
         AND so_max.date = '2018-09-25';
 
 
-- Insert into a temp table
-- While you can join the results of multiple similar queries together with UNION, sometimes it's easier to break a query down into steps. 
-- You can do this by creating a temporary table and inserting rows into it.
-- Compute the correlations between each pair of profits, profits_change, and revenues_change from the Fortune 500 data.
-- The resulting temporary table should have the following structure:

-- measure	profits	profits_change	revenues_change
-- profits	1.00	#	#
-- profits_change	#	1.00	#
-- revenues_change	#	#	1.00

-- Recall the round() function to make the results more readable:
-- round(column_name::numeric, decimal_places)
-- Note that Steps 1 and 2 do not produce output. It is normal for the query result pane to say "Your query did not generate any results."

-- Instructions 1/3
-- Create a temp table correlations.
-- Compute the correlation between profits and each of the three variables (i.e. correlate profits with profits, profits with profits_change, etc).
-- Alias columns by the name of the variable for which the correlation with profits is being computed.
 
 DROP TABLE IF EXISTS correlations;

-- Create temp table 
create temp table correlations AS
-- Select each correlation
SELECT 'profits'::varchar AS measure,
       -- Compute correlations
       corr(profits, profits) AS profits,
       corr(profits, profits_change) AS profits_change,
       corr(profits, revenues_change) AS revenues_change
  FROM fortune500;

  select * from correlations;
  
  
-- Instructions 2/3
-- Insert rows into the correlations table for profits_change and revenues_change.
 
 DROP TABLE IF EXISTS correlations;

CREATE TEMP TABLE correlations AS
SELECT 'profits'::varchar AS measure,
       corr(profits, profits) AS profits,
       corr(profits, profits_change) AS profits_change,
       corr(profits, revenues_change) AS revenues_change
  FROM fortune500;

-- Add a row for profits_change
-- Insert into what table?
INSERT INTO correlations
-- Follow the pattern of the select statement above using profits_change instead of profits
SELECT 'profits_change'::varchar AS measure,
       corr(profits_change, profits) AS profits,
       corr(profits_change, profits_change) AS profits_change,
       corr(profits_change, revenues_change) AS revenues_change
  FROM fortune500;

-- Repeat the above, but for revenues_change
INSERT INTO correlations
SELECT 'revenues_change'::varchar AS measure,
       corr(revenues_change, profits) AS profits,
       corr(revenues_change, profits_change) AS profits_change,
       corr(revenues_change, revenues_change) AS revenues_change
  FROM fortune500;
  
  
-- Instructions 3/3
-- Select all rows and columns from the correlations table to view the correlation matrix.
-- First, you will need to round each correlation to 2 decimal places.
-- The output of corr() is of type double precision, so you will need to also cast columns to numeric.
 
 
 DROP TABLE IF EXISTS correlations;

CREATE TEMP TABLE correlations AS
SELECT 'profits'::varchar AS measure,
       corr(profits, profits) AS profits,
       corr(profits, profits_change) AS profits_change,
       corr(profits, revenues_change) AS revenues_change
  FROM fortune500;

INSERT INTO correlations
SELECT 'profits_change'::varchar AS measure,
       corr(profits_change, profits) AS profits,
       corr(profits_change, profits_change) AS profits_change,
       corr(profits_change, revenues_change) AS revenues_change
  FROM fortune500;

INSERT INTO correlations
SELECT 'revenues_change'::varchar AS measure,
       corr(revenues_change, profits) AS profits,
       corr(revenues_change, profits_change) AS profits_change,
       corr(revenues_change, revenues_change) AS revenues_change
  FROM fortune500;

-- Select each column, rounding the correlations
SELECT measure, 
       round(profits::numeric, 2) AS profits,
       round(profits_change::numeric, 2) AS profits_change,
       round(revenues_change::numeric, 2) AS revenues_change
  FROM correlations;
 
 
 
 
