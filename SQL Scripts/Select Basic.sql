USE MyDatabase;
-- comment
/*
multi-line comments
*/

-- Retreive all Customer Data
-- SELECT * FROM dbo.customers;

-- Retrieve each customers name, country and score
SELECT 
	first_name, 
	country, 
	score 
from customers;

-- retreive customers with score not equal to 0
SELECT
	*
FROM customers
WHERE
	score != 0;

-- Retrieve customers from germany
SELECT *
FROM customers
WHERE country = 'Germany';

-- retrieve all customers and sort the score in descending order
SELECT *
FROM customers
ORDER BY score DESC


-- retrieve all customers and sort results by the lowest score first
SELECT *
FROM customers
ORDER BY score ASC

-- retrieve all customers, sort result by country and by the highest score
SELECT *
FROM customers
ORDER BY -- sorting is sequential
	country ASC, 
	score DESC;

-- find total score for each country
SELECT 
	country, 
	sum(score) AS total_score
FROM customers
GROUP BY country;

/*
Group by Rule:
All columns in the Select must be either aggregated or included in the Group by

Result of group by determined by unique value of the grouped columns
*/

SELECT 
	country, 
	first_name,
	sum(score) AS total_score
FROM customers
GROUP BY 
	country,
	first_name;

-- find the total score and total number of customers of each country
SELECT 
	country,
	SUM(score) AS Total_score,
	COUNT(id) AS Total_customers
FROM customers
GROUP BY
	country;

/*
Having:
filter data after aggregation,
can be only used with Group by clause


Difference btw where and having
Where: filter data before aggregation
Having: filter data after aggregation
*/

-- retreive avg score of each country 
-- considering only customers whoes score not equal to 0 
-- and country whose avg score is greated than 430
SELECT 
	country,
	avg(score) A AVG_SCORE,
FROM 
	customers
WHERE 
	score != 0
GROUP BY
	country
HAVING
	






