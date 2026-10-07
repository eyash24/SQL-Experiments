-- Functions Part 3
-- Null Functions
/*
Replace values
Null -> Value
	- ISNULL
	- COALESCE

Value -> Null
	- Nullif


Check for NULL
- IS NULL
- IS NOT NULL


-- ISNULL
-- ISNULL(value, replacement)
if value is null -> replacement 
else value

-- COALESCE
Returns the first non-null value from a list
-- COALESCE(value1, value2, ...)

ISNULL					|		COALESCE
limited to 2 value			Unlimited
Fast						Slow
present in					present in all database
SQL SERVER  -> ISNULL	
Oracle -> NVL				
MySQL -> IFNULL
*/

-- find avg scores of the customers
USE SalesDB;

SELECT * FROM Sales.Customers;

SELECT 
	CustomerID,
	Score,
	COALESCE(Score,0) Score2,
	AVG(Score) over () AvgScore, -- ignore the null row
	AVG(COALESCE(Score, 0)) OVER () AvgScore2 -- does not ignore the null row as replacing null with 0
FROM Sales.Customers;

-- display full name of customers in a single field by merging first and last name
-- add 10 bonus points to each customer's score
SELECT * FROM Sales.Customers;

SELECT 
	CustomerID,
	FirstName, 
	LastName,
	TRIM(
		COALESCE(FirstName, '') + ' ' + COALESCE(LastName, '')
	) AS Name,
	Score,
	COALESCE(Score, 0) + 10 AS New_score
FROM Sales.Customers;

/*
Handling Null in Joins
Joins does not work with null values 
	-> use isNULL or COALESCE in condition to replace null values with somethin and that is used for comparision
	-> The output still contain null value as null value replaced only during condiiton matching
*/

-- Handling NULLs before ORDER BY
-- sort the customers from lowest to highest score with null appearing last
SELECT * FROM Sales.Customers;

-- laxy method
SELECT 
	customerID,
	FirstName,
	Score,
	COALESCE(Score, 9999999)
FROM Sales.Customers
ORDER BY COALESCE(Score, 9999999) ASC;

-- Better method
SELECT 
	customerID,
	Score
	-- CASE WHEN Score IS NULL THEN 1 ELSE 0 END flag
FROM Sales.Customers
ORDER BY 
	CASE WHEN Score IS NULL THEN 1 ELSE 0 END,
	Score;


-- NULLIF 
-- compares two expression and returns:
	-- NULL if equal
	-- FIRST Value if not equal
-- NULLIF(value1, value2)

-- find the sales price for each order by dividing sales by qunatity
SELECT * FROM Sales.Orders;

SELECT 
	OrderID,
	Quantity,
	Sales,
	Sales / NULLIF(Quantity, 0) AS Sales_price
FROM Sales.Orders;


-- IS NULL and IS NOT NULL
-- Output: TRUE or FALSE

-- identify the customers who have no score
SELECT * FROM Sales.Customers;

SELECT 
*
FROM Sales.Customers
WHERE Score IS NULL;

-- show list of all customers who have score
SELECT 
*
FROM Sales.Customers
WHERE Score IS NOT NULL;

-- show all details for customers who have not placed any orders
SELECT * FROM Sales.Customers;
SELECT * FROM Sales.Orders;

SELECT 
c.*,
o.orderID
FROM Sales.Customers c
LEFT JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;


WITH Orders AS (
SELECT 1 ID, 'A' AS Category UNION
SELECT 2, NULL UNION
SELECT 3, '' UNION
SELECT 4, '	'
)

SELECT 
*,
DATALENGTH(Category) CategoryLen
FROM Orders;

/*
Handling NULL Values : Data Policies
- set of rules that defines how data should be handled
1. Use only NULL and Empty string, avoid using blank spaces
2. Only Use NULL, avoid using empty string and blank spaces
3. Use a default value in place of NULL, empty string, blank spaces
*/

WITH Orders AS (
SELECT 1 ID, 'A' AS Category UNION
SELECT 2, NULL UNION
SELECT 3, '' UNION
SELECT 4, ' '
)

SELECT 
*,
DATALENGTH(Category) AS CategoryLen,
DATALENGTH(TRIM(Category)) AS Policy1_ln,
NULLIF(TRIM(Category), '') AS Policy2,
COALESCE(
	NULLIF(TRIM(Category), ''), 'unknown'
) AS Policy3
FROM Orders;
