-- Filters

-- Comparison Operator
-- retrieve all customers who are from Germany
SELECT *
FROM customers
WHERE 
	country = 'Germany';

-- retreive all customers who are not from Germany
SELECT * 
FROM customers
WHERE 
	country != 'Germany';

SELECT * 
FROM customers
WHERE 
	country <> 'Germany';

-- retreive all customers score greater than 500
SELECT *
FROM customers
WHERE
	score > 500;

-- retreive all customers score greater than equal to 500
SELECT *
FROM customers
WHERE
	score >= 500;


-- retreive all customers score less than 500
SELECT *
FROM customers
WHERE
	score < 500;

-- retreive all customers score less than equal to 500
SELECT *
FROM customers
WHERE
	score <= 500;

-- Logical Operator
-- retrieve all customers who are from USA and score > 500
SELECT * 
FROM customers
WHERE 
	country = 'USA'
	AND score > 500;

-- retrieve all customers who are either from USA or score > 500
SELECT *
FROM customers
WHERE
	country = 'USA'
	OR score > 500;

-- retreive all score not less than 500
SELECT *
FROM customers
WHERE 
	NOT score < 500;


-- Range Operator 
-- retrieve all customers whose score is between 100 and 500
SELECT *
FROM customers
WHERE 
	score BETWEEN 100 AND 500;

-- In 'between' both the boundaries are inclusive

SELECT *
FROM customers
WHERE score >= 100 and score <= 500;

-- Membership operator
-- retrieve all customers from either Germany or USA
SELECT *
FROM customers
WHERE country IN ('Germany', 'USA');

SELECT *
FROM customers
WHERE country = 'Germany' or country = 'USA';

-- LIKE Operator
/*
% -> 0, 1, many
_ -> 1
*/

-- find all customers whoes first name starts with 'M'
SELECT *
FROM customers
where first_name LIKE 'M%';

-- find all customers whoes first name ends with 'n'
SELECT *
FROM customers
where first_name LIKE '%n';

-- find all customers whose first_name contains a 'r'
SELECT *
FROM customers
WHERE first_name LIKE '%r%';

-- find all customers whose first_name contains a 'r' in the third position
SELECT *
FROM customers
WHERE first_name LIKE '__r%';






