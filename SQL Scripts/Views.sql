-- Views
/*
- DDL command 
- virtual table that stores data w/o storing it physically
- persisted sql queries in the database 
- if a table or view is created w/o a schema it default to the dbo schema
- Stored in Disk Catalog Section of the Database
- Stores only metadata and the view query

Difference 
Views							| Tables
- no persistence in databse		 - Persisted data
- easy to maintain / update		 - hard to maintain / update
- slow response					 - fast response
- only read allowed				 - read and write allowed 

Views										| CTE
- reduce redundancy in multiple queries		 - reduce redundancy in a single query
- improve readability in multi-queries		 - improve readability in 1 query
- persisted logic							 - temporary logic on the fly
- need to be maintained (CREATE / DROP)		 - No maintenence - autocleanup
- less easy to use							 - easier to use
*/

-- find the running total of sales for each month
SELECT * FROM Sales.Orders;

WITH CTE_Monthly_summary AS (
	SELECT 
	DATETRUNC(Month, OrderDate) As OrderMonth,
	SUM(Sales) Total_sales
	FROM Sales.Orders
	GROUP BY DATETRUNC(Month, OrderDate)
)

SELECT 
	OrderMonth,
	Total_sales,
	SUM(Total_Sales) OVER(ORDER BY OrderMonth) AS RunningTotal
FROM CTE_Monthly_summary;

CREATE VIEW V_Monthly_Summary AS (
	SELECT 
	DATETRUNC(Month, OrderDate) As OrderMonth,
	SUM(Sales) Total_sales,
	SUM(Quantity) Total_Qunatity,
	COUNT(OrderID) Total_Orders
	FROM Sales.Orders
	GROUP BY DATETRUNC(Month, OrderDate)
)

SELECT 
	OrderMonth,
	Total_sales,
	SUM(Total_Sales) OVER(ORDER BY OrderMonth) AS RunningTotal
FROM V_Monthly_Summary;

-- Dropping view
DROP VIEW V_Monthly_Summary;

/*
T-SQL
Transact-SQL is an extension of SQL that adds programming features
*/

-- update logic of views
IF OBJECT_ID ('Sales.V_Monthly_Summary', 'V') IS NOT NULL
	DROP VIEW Sales.V_Monthly_Summary
GO
CREATE VIEW Sales.V_Monthly_Summary AS (
	SELECT 
	DATETRUNC(Month, OrderDate) As OrderMonth,
	SUM(Sales) Total_sales,
	SUM(Quantity) Total_Qunatity,
	COUNT(OrderID) Total_Orders
	FROM Sales.Orders
	GROUP BY DATETRUNC(Month, OrderDate)
);

-- provide a view that combines details from orders, product, customers, employee
CREATE VIEW Sales.V_Order_Details AS (
	SELECT
		o.OrderId,
		o.OrderDate,
		o.Quantity,
		o.Sales,
		p.product,
		p.Category,
		COALESCE(c.FirstName, '') + ' ' + COALESCE(c.LastName, '') AS CustomerName,
		c.Country as CustomerCountry,
		COALESCE(e.FirstName,'') + ' ' + COALESCE(e.LastName, '') AS EmployeeName,
		e.Department AS EmployeeDepartment
	FROM Sales.Orders o
	LEFT JOIN Sales.Products p
	ON p.productID = o.productID
	LEFT JOIN Sales.Customers c
	ON c.CustomerID = o.CustomerID
	LEFT JOIN Sales.Employees e
	ON e.EmployeeID = o.SalesPersonID
);

SELECT 
*
FROM Sales.V_Order_Details;


-- Provide view for EU Sales Team combining data from all tables excluding US related Data
SELECT * FROM Sales.Employees;
SELECT * FROM Sales.Orders;
SELECT * FROM Sales.Customers;

CREATE VIEW Sales.V_Order_Details_EU AS (
	SELECT
		o.OrderId,
		o.OrderDate,
		o.Quantity,
		o.Sales,
		p.product,
		p.Category,
		COALESCE(c.FirstName, '') + ' ' + COALESCE(c.LastName, '') AS CustomerName,
		c.Country as CustomerCountry,
		COALESCE(e.FirstName,'') + ' ' + COALESCE(e.LastName, '') AS EmployeeName,
		e.Department AS EmployeeDepartment
	FROM Sales.Orders o
	LEFT JOIN Sales.Products p
	ON p.productID = o.productID
	LEFT JOIN Sales.Customers c
	ON c.CustomerID = o.CustomerID
	LEFT JOIN Sales.Employees e
	ON e.EmployeeID = o.SalesPersonID
	WHERE c.country != 'USA'
);

SELECT * FROM Sales.V_Order_Details_EU;