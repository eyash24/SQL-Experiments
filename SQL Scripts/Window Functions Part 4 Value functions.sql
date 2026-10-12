-- Window Functions Part 4

/*
-- Value Window Functions
- PARTITION BY -> optional
- ORDER BY -> required 

1. Lead()
- Access a value from next row in the window

2. LAG()
- Access a value from the previous row in the window

LEAD(expression, offset, default)
- expression : required, can be any data type
- offset: no of rows forward or backward, default 1
- default: value to use when next/previous not available, default NULL
*/

-- Use database
USE SalesDB;

-- Time Series Analysis
-- MOM: Month-over-month analysis
-- YOY: Year-over-year analysis
-- analyse the month-over-month (MoM) performance by finding the percentage change in sales between current and previous month
SELECT * FROM Sales.Orders;

SELECT 
*,
LAG(TotalMonthSales, 1, 0) OVER(ORDER BY Month) as PrevMonthSales
FROM (
	SELECT 
		MONTH(OrderDate) as Month,
		SUM(Sales) as TotalMonthSales
	FROM Sales.Orders
	GROUP BY MONTH(OrderDate)
)t ;

SELECT 
	*,
	CurrentMonthSale - PreviousMonthSale AS MOM_Change,
	ROUND(CAST((CurrentMonthSale - PreviousMonthSale) AS FLOAT) / PreviousMonthSale * 100, 2) AS MOM_PercentageChange
FROM 
(
	SELECT 
		MONTH(OrderDate) as OrderMonth,
		SUM(Sales) as CurrentMonthSale,
		LAG(SUM(Sales)) OVER(ORDER BY MONTH(OrderDate)) AS PreviousMonthSale
	FROM Sales.Orders
	GROUP BY MONTH(OrderDate)
) t;

-- analyze customer retention by ranking the customers based on the avg days between their orders
SELECT * FROM Sales.Orders;

SELECT 
	CustomerID,
	AVG(DaysUntillNextOrder) AS AvgDaysBtwOrders,
	RANK() OVER(ORDER BY COALESCE(AVG(DaysUntillNextOrder), 999)) AS customerRank
FROM (
	SELECT 
	customerID,
	OrderDate AS CurrentOrderDate,
	LEAD(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS NextOrderDate,
	DATEDIFF(day, OrderDate, LEAD(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate)) AS DaysUntillNextOrder
	FROM Sales.Orders
) t
GROUP BY CustomerID;

-- First_value / last_value
-- access a value from first / last row within the window
-- default window frame: ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

-- find the lowest and highest sale of each product
SELECT * FROM Sales.Orders;

SELECT 
	ProductID,
	Sales,
	FIRST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales ASC) AS LowestSales,
	MIN(Sales) OVER (PARTITION BY PRODUCTID) AS LowestSalesV2,
	LAST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales ASC ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS HighestSalesV1,
	FIRST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales DESC) AS HighestSalesV2,
	MAX(Sales) OVER (PARTITION BY ProductID) AS HighestSalesV3
FROM Sales.Orders
ORDER BY ProductID, Sales;

-- find the difference btw current sales and the lowest sales for each product
SELECT 
	productID,
	sales,
	lowestSales,
	Sales - LowestSales AS SaleDiff
FROM (
SELECT 
	productID,
	Sales,
	FIRST_VALUE(Sales) OVER (Partition BY ProductID Order BY Sales ASC) As LowestSales
FROM Sales.Orders
) t;