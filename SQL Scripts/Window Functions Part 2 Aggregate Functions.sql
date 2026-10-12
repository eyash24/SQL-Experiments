-- Aggregate Window Functions Part 2
/*
1. COUNT
- allows any datatype
- count(*) -> count only rows including null values
- count(column) -> count number of non-null values
- Count(1) works same as Count(*)
- count the total number of rows including duplicates, not unique values

-- Use Cases
1. Overall Analysis
2. Category Analysis
3. Quality Check: Identify NULL
4. Quality Check: Identify Duplicates
*/

-- count the total number of orders
SELECT 
COUNT(*) TotalOrders
FROM Sales.Orders;

-- count the total number of orders 
-- provide details such as orderID and OrderDate
SELECT
	OrderID,
	OrderDate,
	COUNT(OrderID) OVER() TotalNrOrders 
FROM Sales.Orders

-- find the total number of orders per customer
-- provide details such as OrderId, OrderaDate
SELECT
	OrderID,
	OrderDate,
	CustomerID,
	COUNT(OrderID) OVER(PARTITION BY CustomerId) OrdersByCustomers
FROM Sales.Orders;

-- find the total number of customers and provide all customers details 
SELECT 
	*,
	COUNT(*) OVER() TotalNrCustomers
FROM Sales.Customers;

-- find the total number of scores for the customer
SELECT 
	*,
	COUNT(*) OVER() TotalNrCustomers,
	COUNT(Score) OVER() TotalNrScore
FROM Sales.Customers;

SELECT 
	COUNT(*) - COUNT(score) AS Diff
FROM Sales.Customers;

-- check whether the table orders contains any duplicates
SELECT 
	OrderId,
	Count(*) OVER(PARTITION BY OrderID) CheckPK
FROM Sales.Orders;

-- check whether the table orders archive contains any duplicates
SELECT 
	OrderID,
	COUNT(*) OVER(PARTITION BY OrderID) checkPK
FROM Sales.OrdersArchive;

SELECT 
	*
FROM (
	SELECT 
		OrderId,
		COUNT(*) OVER(PARTITION BY OrderID) checkPK
	FROM Sales.OrdersArchive
) t 
WHERE checkPK > 1;

-- 2. SUM

-- find total sale of all orders
-- find total sale of each product
-- provide OrderId, OrderDate info
SELECT * FROM Sales.Orders;

SELECT
	OrderID,
	OrderDate,
	ProductID,
	Sales,
	SUM(Sales) OVER() TotalSales,
	SUM(Sales) OVER(PARTITION BY ProductID) TotalSalesByProduct
FROM Sales.Orders;

-- camparison analysis
-- find the percentage contribution of each product sales to the total sales
SELECT 
	OrderID,
	OrderDate,
	Sales,
	SUM(Sales) OVER() TotalSales,
	ROUND(CAST(Sales AS FLOAT) / SUM(Sales) OVER() * 100, 2) percentageTotal
FROM Sales.Orders;

-- 3. AVG
-- find avg sale across all orders
-- find avg sale for each product
-- provide OrderID, orderDate
SELECT 
	OrderID,
	OrderDate,
	ProductID,
	Sales,
	AVG(Sales) OVER() AvgSale,
	AVG(Sales) OVER(PARTITION BY ProductID) AvgSaleByProduct
FROM Sales.Orders;

-- find the avg score of customers
-- provide customerID, lastName
SELECT * FROM Sales.Customers;

SELECT 
	customerID,
	LasTName,
	Score,
	AVG(Score) OVER() AvgScore,
	COALESCE(Score, 0) ScoreClean,
	AvG(COALESCE(Score, 0)) OVER() AvgScore2
FROM Sales.Customers;

-- find all orders where the sales are higher than the average sales across all order
SELECT * FROM Sales.Orders;

SELECT 
*
FROM (
SELECT 
	OrderId,
	OrderDate,
	Sales,
	AVG(Sales) OVER() AvgSales,
	CASE 
		WHEN Sales > AVG(Sales) OVER() THEN 1
		ELSE 0
	END HighSaleFlag
FROM Sales.Orders
) t
WHERE HighSaleFlag = 1;

-- 3. MIN and MAX
-- find highest and lowest sale accross all products
-- find highest and lowest sale for each product
-- provide orderID, OrderDate
SELECT
	OrderID,
	OrderDate,
	Sales,
	MAX(Sales) OVER() highestSale,
	MIN(Sales) OVER() lowestSale,
	MAX(Sales) OVER(PARTITION By productID) HighestProductSale,
	MIN(Sales) OVER(PARTITION BY productID) LowestProductSale
FROM Sales.Orders;

-- show the employeew with the highest salary
SELECT
* 
FROM (
SELECT 
	employeeID,
	Salary,
	MAX(Salary) OVER() HighestSalary
FROM Sales.Employees
) t 
WHERE 
	Salary = HighestSalary;

-- find the deviation of each sales from min and max sale amount
SELECT
	OrderID,
	OrderDate,
	Sales,
	MAX(Sales) OVER() highestSale,
	MIN(Sales) OVER() lowestSale,
	MAX(Sales) OVER() - Sales max_deviation,
	Sales - MIN(Sales) OVER() min_deviation
FROM Sales.Orders;

-- Running and Rolling total
/*
Running total
- aggregate all values from beginning to current point w/o dropping off older data

Rolling total
- aggregate all values within a fixed time window 
- as new data is added, old data point is removed
*/

-- calculate the moving avg of sales for each product over time
SELECT 
	ProductID,
	orderDate,
	Sales,
	AVG(Sales) OVER(PARTITION BY ProductID ORDER BY OrderDate) AS MovingAvg
FROM Sales.Orders;

-- calculate the moving avg of sales for each product over time including only the next order
SELECT 
	ProductID,
	orderDate,
	Sales,
	AVG(Sales) OVER(PARTITION BY ProductID ORDER BY OrderDate ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) AS RollingAvg
FROM Sales.Orders;

