-- Common Table Expression (CTE)
/*
Difference btw SubQuery and CTE
Subquery						|	CTE
- written from bottom to top	 - written from top to bottom
- subquery used only once		 - subquery acts like a virtual table, can be used multiple times
- might introduce redundancy	 - solves redundancy by reusing subquery
- less readibility				 - more readable code
- less modular					 - more modular

Types of CTE
1. Non-recursive CTE
	1. Standalone CTE
	2. Nested CTE
2. Recursive CTE

Rules
- Cannot user Order by clause in the sub query

*/

-- Use Database
USE SalesDB;

-- Non Recursive CTE
-- Standalone CTE
-- Defined and used independently 

-- find the total sales per customer
SELECT * FROM Sales.Orders;

WITH CTE_total_sales AS (
SELECT 
	customerID,
	SUM(Sales) as Total_sales
FROM Sales.Orders
GROUP BY customerID
)

-- SELECT * FROM CTE_total_sales;

SELECT 
	c.customerID,
	c.firstName,
	c.LastName,
	cte.Total_sales
FROM Sales.Customers c
LEFT JOIN CTE_total_sales cte 
ON cte.customerId = c.CustomerID;

-- find the last order date for each customer
SELECT * FROM Sales.Orders;

WITH CTE_base AS (
SELECT 
	customerID,
	OrderDate,
	RANK() OVER (PARTITION BY customerID ORDER BY OrderDate DESC) as OrderRank
FROM Sales.Orders
)

SELECT 
	customerID,
	OrderDate
FROM CTE_base
WHERE OrderRank = 1;

WITH CTE_total_sales AS (
SELECT 
	customerID,
	SUM(Sales) as Total_sales
FROM Sales.Orders
GROUP BY customerID
),
CTE_last_order AS (
SELECT 
	customerId,
	MAX(OrderDate) as LastOrderDate
FROM Sales.Orders
GROUP BY CustomerID
)

SELECT 
	c.customerID,
	c.firstName,
	c.LastName,
	cte_ts.Total_sales,
	cte_lo.LastOrderDate
FROM Sales.Customers c
LEFT JOIN CTE_total_sales cte_ts 
ON cte_ts.customerId = c.CustomerID
LEFT JOIN CTE_last_order cte_lo
ON cte_lo.CustomerID = c.CustomerID;
	
-- Nested CTE
-- cannot run independently

-- rank customers based on total sales per customer
with CTE_total_sales AS (
SELECT 
	customerID,
	SUM(Sales) as TotalSales
FROM Sales.Orders
GROUP BY customerID
),
CTE_customer_rank AS (
SELECT 
	customerID,
	TotalSales,
	RANK() OVER (ORDER BY TotalSales DESC) as CustomerRank
FROM CTE_total_sales
)

SELECT 
	c.customerId,
	c.FirstName,
	c.LastName,
	cte_cr.CustomerRank,
	cte_ts.TotalSales
FROM Sales.Customers c
LEFT JOIN CTE_total_sales cte_ts
ON c.customerID = cte_ts.customerID
LEFT JOIN CTE_customer_rank cte_cr
ON c.CustomerID = cte_cr.CustomerID;

-- segment customer total sales into high, medium, low based 
WITH CTE_Total_Sales AS (
SELECT 
	customerID,
	SUM(Sales) as TotalSales
FROM Sales.Orders
GROUP BY customerID
),
CTE_Customer_Segment AS (
SELECT 
	CustomerID,
	CASE
		WHEN TotalSales > 100 THEN 'HIGH'
		WHEN TotalSales > 50 THEN 'MEDIUM'
		ELSE 'LOW'
	END CustomerSegment
FROM CTE_Total_Sales
)

SELECT 
	c.customerId,
	c.FirstName,
	c.LastName,
	cte_ts.TotalSales,
	cte_cs.CustomerSegment
FROM Sales.Customers c
LEFT JOIN CTE_total_sales cte_ts
ON c.customerID = cte_ts.customerID
LEFT JOIN CTE_Customer_Segment cte_cs
ON c.CustomerID = cte_cs.CustomerID;

-- Recursive CTE
-- self referencing query that repeatedly process data until a specific condition is met

-- generate a sequence of numbers from 1 to 20
WITH Series AS (
-- Anchor query
SELECT 
	1 AS MyNum

UNION ALL
-- Recursive query
SELECT
	MyNum + 1
FROM Series 
WHERE MyNum < 20
)

SELECT *
FROM Series
OPTION (MAXRECURSION 10); -- add maxrecursion allowed 

-- show the employee hierarchy by displaying each employee level within	the org
WITH CTE_EMP_hierarchy AS (
	-- Anchor Query
	SELECT 
		EmployeeID,
		FirstName,
		ManagerID,
		1 AS Level
	FROM Sales.Employees
	UNION ALL 
	-- Recursive query
	SELECT 
		e.EmployeeID,
		e.FirstName,
		e.ManagerID,
		Level+1
	FROM Sales.Employees e
	INNER JOIN CTE_EMP_hierarchy cte_eh
	ON e.ManagerID = cte_eh.EmployeeID
)
-- Main Query
SELECT * FROM CTE_EMP_hierarchy;