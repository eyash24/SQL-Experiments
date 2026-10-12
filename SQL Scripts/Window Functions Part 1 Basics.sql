-- Window Functions Part 1
-- doesnot change the granularity unlike GROUP BY that changes granularity
-- Aggregation + Details
/*
Types of window functions
1. Aggregate Functions
- COUNT, MIN, MAX, SUM, AVG

2. RANK Functions
- ROW_NUMBER
- RANK
- DENSE_RANK
- CUME_DIST
- PERCENT_RANK
- NTILE

3. Value Functions
- LEAD
- LAG
_ FIRST_VALUE
- LAST_VALUE


Difference 
- Group By: Used for Simple Data Analysis
- Window: Advance Data Analytics

GROUP BY limit: Cannot do aggregation and provide details at the same time
*/

-- find the total sales across all orders
SELECT 
	SUM(Sales) AS Total_sales
FROM Sales.Orders;

-- find the total sales for each product
SELECT * FROM Sales.Orders;

SELECT 
	productID,
	SUM(Sales) AS TotalSales
FROM Sales.Orders
GROUP BY ProductID;

/*
Window fn Over Clause
- Partition by
- Order
- Frame
*/

-- PARTITION BY
-- Divides result set into partitions (window)

-- find total sales across all orders
-- provide additional details such as OrderID, orderDate
SELECT
	orderID,
	OrderDate,
	SUM(Sales) OVER() TotalSales
FROM Sales.Orders;

-- find the total sales for each product
-- additionally find details such as orderID, OrderDate
SELECT 
	OrderID,
	OrderDate,
	productID,
	SUM(Sales) OVER(PARTITION BY ProductID) TotalSalesByProduct
FROM Sales.Orders;

-- find the total sales for each product, across all orders
-- additionally find details such as orderID, OrderDate
SELECT 
	OrderID,
	OrderDate,
	productID,
	Sales,
	SUM(sales) OVER() TotalSales,
	SUM(Sales) OVER(PARTITION BY ProductID) TotalSalesByProduct
FROM Sales.Orders;

-- find total sales for each combination of product and order status
SELECT 
	orderID,
	OrderDate,
	Sales,
	OrderStatus,
	productId,
	SUM(Sales) OVER(PARTITION BY ProductID, OrderStatus) TotalSalesByProductOrderStatus
FROM Sales.Orders;

-- ORDER BY 
-- rank each order based on their sales from highest to lowest 
-- additionally provide details such as orderId, orderDate
SELECT 
	OrderID,
	OrderDate,
	sales,
	RANK() OVER(ORDER BY Sales DESC) Rank
FROM Sales.Orders;

-- FRAME
-- Define subset of rows within each window that is relevant for calculation

SELECT 
	OrderID,
	OrderDate,
	OrderStatus,
	Sales,
	SUM(Sales) OVER (
		PARTITION BY OrderStatus 
		ORDER BY OrderDate
		ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING
	) TotalSales2following
FROM Sales.Orders;


SELECT 
	OrderID,
	OrderDate,
	OrderStatus,
	Sales,
	SUM(Sales) OVER (
		PARTITION BY OrderStatus 
		ORDER BY OrderDate
		ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
	) TotalSales2preceding
FROM Sales.Orders;

-- Short form of above query
-- for only preceding curent row can be skipped
SELECT 
	OrderID,
	OrderDate,
	OrderStatus,
	Sales,
	SUM(Sales) OVER (
		PARTITION BY OrderStatus 
		ORDER BY OrderDate
		ROWS 2 PRECEDING
	) TotalSales2preceding
FROM Sales.Orders;

SELECT 
	OrderID,
	OrderDate,
	OrderStatus,
	Sales,
	SUM(Sales) OVER (
		PARTITION BY OrderStatus 
		ORDER BY OrderDate
		ROWS UNBOUNDED PRECEDING
	) TotalSales2preceding
FROM Sales.Orders;

/*
Default frame
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
*/
SELECT 
	OrderID,
	OrderDate,
	OrderStatus,
	Sales,
		SUM(Sales) OVER (
		PARTITION BY OrderStatus 
		ORDER BY OrderDate
	) TotalSales,
	SUM(Sales) OVER (
		PARTITION BY OrderStatus 
		ORDER BY OrderDate
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	) TotalSalesPrecedingLongForm,
	SUM(Sales) OVER (
		PARTITION BY OrderStatus 
		ORDER BY OrderDate
		ROWS UNBOUNDED PRECEDING
	) TotalSalesPrecedingShortForm
FROM Sales.Orders;


/*
Window Fn Rules
1. Used only in select and order by clause
2. Nesting window function is not allowed 
3. SQL executes Window fn after the where clause
4. Window fn canbe used together with Group in same query iff same columns are used
*/

SELECT 
	OrderID,
	OrderDate,
	OrderStatus,
	Sales,
	SUM(Sales) OVER(PARTITION BY OrderStatus) TotalSales
FROM Sales.Orders
ORDER BY SUM(Sales) OVER(PARTITION BY OrderStatus) DESC;

SELECT 
	OrderID,
	OrderDate,
	OrderStatus,
	productID,
	Sales,
	SUM(Sales) OVER(PARTITION BY OrderStatus) TotalSales
FROM Sales.Orders
WHERE ProductID in (101, 102);

-- rank customers based on total sales
SELECT * FROM Sales.Orders;

SELECT 
	customerID,
	SUM(Sales) TotalSales,
	RANK() OVER(ORDER BY SUM(Sales) DESC) Rank
FROM Sales.Orders
GROUP BY customerID;





