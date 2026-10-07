-- SET Operators
/*
Rules
1. SQL Clauses
	- it can be used in almost all clauses
	WHERE , JOIN , GROUP BY , HAVING
	- ORDER BY is only allowed at the end of query
2. Number of columns in each query must be same
3. Data types of columns in each query must be compatible
4. Order of columns in each query must be the same
5. Columns names in result set determined by column names in first query and its alias
6. Mapping correct columns
*/

-- Use database
USE SalesDB;

-- Rule 2
SELECT * FROM Sales.Customers;
SELECT * FROM Sales.Employees;

SELECT 
	FirstName,
	LastName
FROM Sales.Customers

UNION

SELECT 
	FirstName,
	LastName
FROM Sales.Employees


-- Union
-- returns all distinct rows from both the queries
-- removes all duplicate rows from the result

-- combine data from employee and customers into 1 table
SELECT 
	FirstName,
	LastName
FROM Sales.Customers

UNION

SELECT 
	FirstName,
	LastName
FROM Sales.Employees;

-- Union ALL
-- returns all rows from both queries including duplicates 
-- union all faster than union as it does not perform the duplicate check operation 

-- combine data from employee and customers into 1 table including duplicates
SELECT 
	FirstName,
	LastName
FROM Sales.Customers

UNION ALL

SELECT 
	FirstName,
	LastName
FROM Sales.Employees;


-- Except
-- return all distinct row from the first query that are not found in the second query
 

-- find employees who are not customers 
SELECT 
	FirstName,
	LastName
FROM Sales.Employees

EXCEPT

SELECT 
	FirstName,
	LastName
FROM Sales.Customers;


-- Intersect
-- returns only the rows that are common in both queries

-- find employee who are also customers
-- find employees who are not customers 
SELECT 
	FirstName,
	LastName
FROM Sales.Employees

INTERSECT

SELECT 
	FirstName,
	LastName
FROM Sales.Customers;

-- Union Use Case: Combine Information
-- combine all orders data from orders and ordersArchive into a single table for reporting without duplicates
SELECT * FROM Sales.Orders;
SELECT * FROM Sales.OrdersArchive;

SELECT 
[OrderID]
,[ProductID]
,[CustomerID]
,[SalesPersonID]
,[OrderDate]
,[ShipDate]
,[OrderStatus]
,[ShipAddress]
,[BillAddress]
,[Quantity]
,[Sales]
,[CreationTime]
FROM Sales.Orders
UNION
SELECT 
[OrderID]
,[ProductID]
,[CustomerID]
,[SalesPersonID]
,[OrderDate]
,[ShipDate]
,[OrderStatus]
,[ShipAddress]
,[BillAddress]
,[Quantity]
,[Sales]
,[CreationTime]
FROM Sales.OrdersArchive;

SELECT 
'Orders' AS source_table,
[OrderID]
,[ProductID]
,[CustomerID]
,[SalesPersonID]
,[OrderDate]
,[ShipDate]
,[OrderStatus]
,[ShipAddress]
,[BillAddress]
,[Quantity]
,[Sales]
,[CreationTime]
FROM Sales.Orders
UNION
SELECT 
'ordersArchive' AS source_table,
[OrderID]
,[ProductID]
,[CustomerID]
,[SalesPersonID]
,[OrderDate]
,[ShipDate]
,[OrderStatus]
,[ShipAddress]
,[BillAddress]
,[Quantity]
,[Sales]
,[CreationTime]
FROM Sales.OrdersArchive
ORDER BY OrderID;


-- Except Use Case: 
/* 
1. Delta Detection: Identifing the difference / changes between two batches of data
2. Data Completeness checks: Compare tables to check discrepancies between databases
*/