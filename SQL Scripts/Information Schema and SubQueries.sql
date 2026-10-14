-- Advance SQL Part 1
-- Information Schema and SubQueries

/*
Information Schema 
- system defined schema with built-in views that provide info about database
*/
-- Use Database
USE SalesDB;

SELECT 
* 
FROM INFORMATION_SCHEMA.TABLES;

SELECT 
* 
FROM INFORMATION_SCHEMA.COLUMNS;

-- Sub Queries
-- also called inner query 
-- main query <-> outer query
/*
Types based on Dependency
1. Correlated subquery: subquery related to main query
2. Non-correlated subquery : subquery independent from main query

Types based on Result Types
1. Scalar subquery: Returns a scalar value
2. Row subquery: Returns multiple rows
3. Table subquery: Returns multiple rows and columns

Types based on Location / Clauses
1. Select clause
2. From clause
3. Join clause
4. Where clause
	4.1 Comparision operators : <,>,=,!=, >=, <=
	4.2 Logical operators : IN, ANY, ALL, EXIST 
*/

-- Use Database
USE SalesDB;

-- SubQuery: Result Types 
-- 1. Scalar query
SELECT
AVG(Sales)
FROM Sales.Orders;

-- 2. Row query
SELECT
OrderID
FROM Sales.Orders;

-- Table Query
SELECT 
* 
FROM Sales.Orders;


-- SubQuery: Location / Clause Type
-- 1. From Clause
-- used to create temporary table for the main query

-- find the products that have a proce higher than the average price of all products
SELECT 
productID
FROM (
	SELECT
	productID,
	price,
	AVG(Price) OVER() as AVGPrice
	FROM Sales.Products
) t
WHERE price > AVGPrice;

-- rank customers based on their total amt of sales
SELECT 
*,
RANK() OVER(ORDER BY totalSales DESC) as SalesRank
FROM (
	SELECT 
		customerID,
		SUM(Sales) AS totalSales
	FROM Sales.Orders
	GROUP BY CustomerID
) t

-- 2. Select Clause
-- only scalar subqueries are allowed to be used in select clause

-- show productID, name, price, total number of orders
SELECT * FROM Sales.Products;
SELECT * FROM Sales.Orders;

SELECT
	productID,
	product,
	price,
	(SELECT COUNT(OrderID) FROM Sales.Orders) as TotalOrders
FROM Sales.Products;

-- 3. Join Clause
-- show all customer details and find total orders for each customers
SELECT c.*, t.CustomerOrders FROM Sales.Customers   c
LEFT JOIN (
	SELECT 
		CustomerID,
		COUNT(OrderID) as CustomerOrders
	FROM Sales.Orders
	GROUP BY CustomerID 
) t
ON c.CustomerID = t.CustomerID;

-- 4. Where Clause
-- 4.1 Comparison operators
-- only scalar subqueries allowed 

-- find the products that have a price higher then the avg price of all products
SELECT
ProductID,
price
FROM Sales.Products
WHERE price > (Select AVG(price) FROM Sales.Products);

-- 4.2 Logical Operators
-- 4.2.1 IN operator

-- show the details of orders made by customers in Germany
SELECT * FROM Sales.Customers;
SELECT * FROM Sales.Orders;

SELECT 
*
FROM Sales.Orders
WHERE CustomerID IN (SELECT CustomerID FROM Sales.Customers WHERE Country = 'Germany');


-- show the details of orders not made by customers in Germany
SELECT 
*
FROM Sales.Orders
WHERE CustomerID NOT IN (SELECT CustomerID FROM Sales.Customers WHERE Country = 'Germany');

SELECT 
*
FROM Sales.Orders
WHERE CustomerID IN (SELECT CustomerID FROM Sales.Customers WHERE Country != 'Germany');

-- 4.2.2 ANY operators
-- checks if value matches any value from the list
-- check if value true for at least one value in a list

-- find female employees whose salary are greater than the salaries of any male employees
SELECT * FROM Sales.Employees;

SELECT 
* 
FROM Sales.Employees
WHERE Gender = 'F' AND Salary > ANY(
	SELECT Salary FROM Sales.Employees WHERE Gender='M'
);

-- 4.2.3 ALL operator
-- check if value matches ALL values within a list

-- find female employees whose salary are greater than the salaries of all male employees

SELECT 
* 
FROM Sales.Employees
WHERE Gender = 'F' AND Salary > ALL(
	SELECT Salary FROM Sales.Employees WHERE Gender='M'
);

-- 4.2.4 EXISTS operator
-- checks whether the sub query returns any row

-- show the details of orders made by customers in germany
SELECT 
* 
FROM Sales.Orders o
WHERE EXISTS (
	SELECT 1
	FROM Sales.Customers c
	WHERE Country = 'Germany'
	AND o.customerID = c.CustomerID
);

-- show the details of orders made by customers not in germany
SELECT 
* 
FROM Sales.Orders o
WHERE NOT EXISTS (
	SELECT 1
	FROM Sales.Customers c
	WHERE Country = 'Germany'
	AND o.customerID = c.CustomerID
);


/* SubQuery: Dependency Type
1. correlated sub query
- subquery depends on main query
- subquery executed for each row
- cannot be executed on its own
- bad performance
- coomplex to read
- dynamic filtering 

2. Non correlated subquery
- sub query independent of main query
- sub query executed only once 
- can be executed on it own
- better performance
- easier to read
- used for static comparisons, static filtering
*/


-- show all customer details and find the total order of each customers
SELECT * FROM Sales.Customers;
SELECT * FROM Sales.Orders;

SELECT 
*,
(SELECT COUNT(*) FROM Sales.Orders o WHERE o.CustomerID = c.CustomerID) as totalOrders
FROM Sales.Customers c;

 