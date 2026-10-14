-- CTAS: Create table as Select AND Temporary Table 

/*
Table Types in Databases
1. Permanent table 
	1. Create/Select 
	2. CTAS
2. Temporary Table


CTAS 
- Create table based on the result oF an SQL query

Difference 
CTAS										| Views
- sql query already executed and stored		 - only sql query stored not the result
- faster then views							 - slower then CTAS
*/

-- USE Database
USE SalesDB;

-- retreive total number of orders for each month
SELECT
	DATENAME(Month, OrderDate) as OrderMonth,
	COUNT(OrderID) TotalOrders
INTO Sales.MonthlyOrder
FROM Sales.Orders
GROUP BY DATENAME(Month, OrderDate);

SELECT * FROM Sales.MonthlyOrder;

-- Drop CTAS
DROP TABLE Sales.MonthlyOrder;


-- use T-SQL to refresh monthly order ctas
IF OBJECT_ID('Sales.MonthlyOrder','U') IS NOT NULL
	DROP TABLE Sales.MonthlyOrder
GO 
	SELECT
		DATENAME(Month, OrderDate) as OrderMonth,
		COUNT(OrderID) TotalOrders
	INTO Sales.MonthlyOrder
	FROM Sales.Orders
	GROUP BY DATENAME(Month, OrderDate);


-- Temporary Table or Temp Tables
-- stores immediate results in temporary storage within the database during the session 
-- automatically all temp table once the session ends
-- use INTO Clause with #Name
SELECT 
*
INTO #Orders
FROM Sales.Orders;

SELECT * FROM #Orders;

DELETE FROM #Orders
WHERE OrderStatus = 'Delivered';

SELECT 
*
INTO Sales.OrderShipped
FROM #Orders;

SELECT * FROM Sales.OrderShipped;



