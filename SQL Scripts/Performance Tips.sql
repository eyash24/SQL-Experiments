/*
Performance tips
golden rule: 
- alway check the execution plan to confirm performance improvements when optimising query
- if no improvement, then focus on readability 
*/

-- use database
USE SalesDB;

-- Tip 1: Select only what is required 
SELECT * FROM Sales.Customers; -- bad practice

SELECT CustomerID, Country, Score FROM Sales.Customers;

-- Tip 2: Avoid unnecessary distinct and order by clause
SELECT DISTINCT FirstName
FROM Sales.Customers
ORDER BY FirstName;

SELECT FirstName
FROM Sales.Customers;

-- Tip 3: For exploration purpose, Limit Rows 
SELECT 
	OrderId,
	Sales
FROM Sales.Orders;

SELECT TOP 5
	OrderId,
	Sales
FROM Sales.Orders;

-- Tip 4: Create Nonclustered Index on frequently used columns in where clause
SELECT 
*
FROM Sales.Orders
WHERE OrderStatus = 'Delivered';

CREATE NONCLUSTERED INDEX idx_Orders_OrderStatus 
ON Sales.Orders (OrderStatus);

-- Tip 5: Avoid applying functions to columns in WHERE clauses 
-- functions on columns can block index usage

-- bad
SELECT *
FROM Sales.Orders
WHERE LOWER(OrderStatus) = 'delivered';

-- good
SELECT 
*
FROM Sales.Orders
WHERE OrderStatus = 'Delivered'; -- uses index

-- bad
SELECT *
FROM Sales.Customers
WHERE SUBSTRING(FirstName, 1,1) = 'A';

-- good
SELECT *
FROM Sales.Customers
WHERE FirstName LIKE 'A%';

-- bad
SELECT *
FROM Sales.Orders
WHERE YEAR(orderDate) = 2025;

-- good
SELECT *
FROM Sales.Orders
WHERE OrderDate BETWEEN '2025-01-01' AND '2025-12-31';

-- Tip 6: Avoid using leading wildcards as they prevent index usage 
-- bad
SELECT * 
FROM Sales.Customers
WHERE LastName LIKE '%Gold%';

-- good
SELECT * 
FROM Sales.Customers
WHERE LastName LIKE 'Gold%';

-- Tip 7: Use IN instead of multiple OR
-- bad
SELECT *
FROM Sales.Orders
WHERE CustomerID = 1 or CustomerId = 2 OR CustomerID = 3;

-- good
SELECT *
FROM Sales.Orders
WHERE CustomerID IN (1,2,3);

-- Joining Data
-- Tip 8: Understand the speed of Joins and use INNER JOIN when possible 
-- best performance 
SELECT c.firstname, o.orderId from Sales.Customers c INNER JOIN Sales.Orders o ON c.CustomerID = o.CustomerID;

-- slightly slow performance
SELECT c.firstname, o.orderId from Sales.Customers c LEFT JOIN Sales.Orders o ON c.CustomerID = o.CustomerID;
SELECT c.firstname, o.orderId from Sales.Customers c RIGHT JOIN Sales.Orders o ON c.CustomerID = o.CustomerID;

-- worst performance
-- SELECT c.firstname, o.orderId from Sales.Customers c OUTER JOIN Sales.Orders o ON c.CustomerID = o.CustomerID; -- full anti join 

-- Tip 9: Use Explicit Join (ANSI JOIN) Instead of Implicit Join (non-ANSI Join)
-- bad
SELECT o.orderid, c.firstname
FROM sales.Orders o, Sales.Customers c
WHERE c.CustomerID = o.CustomerID;

-- good
SELECT o.orderid, c.firstname
FROM sales.Orders o
INNER JOIN Sales.Customers c
ON c.CustomerID = o.CustomerID;

-- Tip 10: Make sure to index the columns used in the ON clause
SELECT o.orderid, c.firstname
FROM sales.Orders o
INNER JOIN Sales.Customers c
ON c.CustomerID = o.CustomerID;

CREATE NONCLUSTERED INDEX idx_Orders_CustomerID ON Sales.Orders (CustomerID);

-- Tip 11: Filter Before Joining (Big tables)
-- filter after the join (WHERE) -> for small and medium size tables
SELECT o.orderid, c.firstname
FROM sales.Orders o
INNER JOIN Sales.Customers c
ON c.CustomerID = o.CustomerID
WHERE o.OrderStatus = 'Delivered';

-- filter during join (ON)
SELECT o.orderid, c.firstname
FROM sales.Orders o
INNER JOIN Sales.Customers c
ON c.CustomerID = o.CustomerID
AND o.OrderStatus = 'Delivered';

-- filter before join (Subquery) -> for large tables
SELECT o.orderid, c.firstname
FROM (SELECT orderID, customerID FROM Sales.Orders WHERE OrderStatus = 'Delivered') o
INNER JOIN Sales.Customers c
ON c.CustomerID = o.CustomerID;

-- Tip 12: Aggregate Data before joining big tables
-- grouping and joining -> Small and Medium sized tables
SELECT c.CustomerID, c.firstname, COUNT(o.OrderID) as OrderCount
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName;

-- pre-aggregated subquery -> best for big tables 
SELECT c.customerID, c.firstname, o.orderCount
FROM Sales.Customers c
INNER JOIN (
	SELECT CustomerID, COUNT(orderID) AS OrderCount
	FROM Sales.Orders
	GROUP BY CustomerID
) o
ON c.CustomerID = o.CustomerID;

-- correlated subquery
SELECT 
	c.customerID,
	c.firstname,
	(
		SELECT Count(o.orderID)
		FROM Sales.Orders o
		WHERE o.CustomerID = c.customerID
	) as OrderCount
FROM Sales.Customers c;
-- worst performance as SQL executes aggregation for every row

-- Tip 13: Use Union instead of OR in Joins
-- bad
SELECT o.orderID, c.firstname
FROM Sales.Orders o
INNER JOIN sales.Customers c
ON c.CustomerID = o.CustomerID
OR c.CustomerID = o.SalesPersonID;

-- good 
SELECT o.orderID, c.firstname
FROM Sales.Orders o
INNER JOIN sales.Customers c 
ON c.customerID = o.CustomerID
UNION
SELECT o.orderID, c.firstname
FROM Sales.Orders o
INNER JOIN sales.Customers c 
ON c.customerID = o.SalesPersonID;

-- Tip 14: Check for Nested Loops and Use SQL Hints
SELECT o.orderID, c.firstname
FROM Sales.Customers c
INNER JOIN Sales.Orders o 
ON c.CustomerID = o.CustomerID;

-- for big tables use HASH JOIN 
SELECT o.orderID, c.firstname
FROM Sales.Customers c
INNER JOIN Sales.Orders o 
ON c.CustomerID = o.CustomerID
OPTION (HASH JOIN);
 
-- Tip 15: Use UNION ALL instead of UNION if duplicates are accpetable 
-- bad
SELECT CustomerID FROM Sales.Orders
UNION
SELECT CustomerID FROM Sales.OrdersArchive;

-- good
SELECT CustomerID FROM Sales.Orders
UNION ALL
SELECT CustomerID FROM Sales.OrdersArchive;

-- Tip 16: Use UNION ALL + Distinct instead of using UNION | duplicates are not acceptable
-- bad 
SELECT CustomerID FROM Sales.Orders
UNION
SELECT CustomerID FROM Sales.OrdersArchive;

-- good 
SELECT DISTINCT CustomerID 
FROM (
	SELECT CustomerID FROM Sales.Orders
	UNION ALL
	SELECT CustomerID FROM Sales.OrdersArchive
) AS CombinedData;

-- Aggregating data
-- Tip 17: use columnstore index for aggregation on large table
SELECT CustomerID, Count(OrderID) As OrderCount
FROM Sales.Orders
GROUP BY CustomerID;

CREATE CLUSTERED COLUMNSTORE INDEX idx_Orders_Columnstore ON Sales.Orders;

-- Tip 18: Pre-aggregate data and store it in new table for reporting
SELECT YEAR(OrderDate) OrderYear, SUM(Sales) AS TotalSales
INTO Sales.SalesSummary
FROM Sales.Orders
GROUP BY YEAR(OrderDate);

SELECT OrderYear, TotalSales FROM Sales.SalesSummary;

-- Subqueries
-- JOIN VS EXIST VS IN
-- JOIN (Best practice if performance equal to EXISTS)
SELECT o.OrderID, o.Sales
FROM Sales.Orders o
INNER JOIN Sales.Customers c
ON o.CustomerID = c.CustomerID
WHERE c.Country = 'USA';

-- EXISTS (Best Practice: Use for large tables)
-- stops at first match and avoids data duplication 
SELECT o.OrderID, o.Sales
FROM Sales.Orders o
WHERE EXISTS (
	SELECT 1
	FROM Sales.Customers c
	WHERE c.CustomerID = o.CustomerID
	AND c.Country = 'USA'
);

-- IN (Bad Pratice: lacks an early exit mechanism)
SELECT o.OrderID, o.Sales
FROM Sales.Orders o
WHERE o.CustomerID IN (
	SELECT CustomerID 
	FROM Sales.Customers
	WHERE Country = 'USA'
);

-- Tip 20: Avoid Redundant Logic in query
-- bad
SELECT EmployeeID, FirstName, 'Above Avg' status
FROM Sales.Employees
WHERE Salary > (SELECT AVG(Salary) FROM Sales.Employees)
UNION ALL
SELECT EmployeeID, FirstName, 'Below Avg' status
FROM Sales.Employees
WHERE Salary < (SELECT AVG(Salary) FROM Sales.Employees);

-- good
SELECT 
	EmployeeID,
	FirstName,
	CASE 
		WHEN Salary > AVG(Salary) OVER() THEN 'Above AVG'
		WHEN Salary < AVG(Salary) OVER() THEN 'Below AVG'
		ELSE 'AVG'
	END AS Status
FROM Sales.Employees;

-- DDL Tips
-- Tip 21: Avoid data types VARCHAR and TEXT
CREATE TABLE CustomerInfo (
	CustomerID INT,
	FirstName VARCHAR(MAX),
	LastName TEXT,
	Country VARCHAR(255),
	TotalPurchases FLOAT,
	Score VARCHAR(255),
	BirthDate VARCHAR(255),
	EmployeeID INT,
	CONSTRAINT FK_CustomersInfo_EmployeeID FOREIGN KEY (EmployeeID)
		REFERENCES Sales.Employees(EmployeeID)
)