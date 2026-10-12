-- Aggregate & Analytical Functions

-- Aggregation Functions
-- SUM, MIN,MAX, AVG, COUNT

-- Use database
USE SalesDB;

-- find the total numbers of orders
SELECT * FROM Sales.Orders;

SELECT
	COUNT(OrderID) AS Total_no_orders
FROM Sales.Orders;

-- find the total sales of all orders
SELECT 
	SUM(Sales) AS Total_sales
FROM Sales.Orders;

-- find the avg sales of all orders
SELECT 
	AVG(Sales) AS Avg_sales
FROM Sales.Orders;

-- find the highest sales of all order
SELECT 
	MAX(Sales) AS Max_sale
FROM Sales.Orders;

-- find the lowest sale of all order
SELECT 
	MIN(Sales) AS Min_sale
FROM Sales.Orders;

-- find sale stats for each customer
SELECT 
	customerID,
	SUM(Sales) AS Total_Sales,
	Count(Sales) nr_orders,
	MIN(Sales) min_sale,
	AVG(Sales) avg_sale,
	MAX(Sales) max_sale
FROM Sales.Orders
GROUP BY CustomerID;

