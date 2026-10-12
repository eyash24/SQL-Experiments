-- Function Part 2
-- Date & Time Funtions
USE SalesDB;

SELECT 
	OrderID,
	OrderDate,
	ShipDate,
	CreationTime
FROM Sales.Orders;

-- 1. GETDATE
SELECT 
	OrderID,
	CreationTime,
	GETDATE() Today
FROM Sales.Orders;

/*
Date and Time function Category
1. Part Extraction 
- DAY
- MONTH
- YEAR
- DATEPART
- DATENAME
- DATETRUNC
- EOMONTH

2. Format and Casting 
- FORMAT
- CONVERT
- CAST

3. Calculations
- DATEDIFF
- DATEADD

4. Validation
- ISDATE
*/

-- Part Extraction 
-- 1. DAY, MONTH, YEAR 
SELECT 
	OrderID,
	CreationTime,
	YEAR(CreationTime) AS year_of_creation,
	MONTH(CreationTime) AS month_of_creation,
	DAY(CreationTime) AS day_of_creation
FROM Sales.Orders;

-- 2. DATEPART
-- output -> Integer
SELECT 
	OrderID,
	CreationTime,
	DATEPART(YEAR, CreationTime) AS year_of_creation,
	DATEPART(MONTH, CreationTime) AS month_of_creation,
	DATEPART(DAY, CreationTime) AS day_of_creation,
	DATEPART(HOUR, CreationTime) AS hour_of_creation,
	DATEPART(MINUTE, CreationTime) AS minute_of_creation,
	DATEPART(SECOND, CreationTime) AS second_of_creation,
	DATEPART(WEEK, CreationTime) AS week_of_creation,
	DATEPART(QUARTER, CreationTime) AS quarter_of_creation
FROM Sales.Orders;

-- 3. DATENAME
-- Output -> String
SELECT
	CreationTime, 
	DATENAME(Month, CreationTime) AS month_name,
	DATENAME(WEEKDAY, CreationTime) AS weekday_name,
	DATENAME(day, creationTime) as day_name
FROM Sales.Orders;

-- 4. DATETRUNC
-- output -> DATETIME
SELECT 
	CreationTime,
	DATETRUNC(YEAR, CreationTime) AS year_of_creation,
	DATETRUNC(MONTH, CreationTime) AS month_of_creation,
	DATETRUNC(DAY, CreationTime) AS day_of_creation,
	DATETRUNC(HOUR, CreationTime) AS hour_of_creation,
	DATETRUNC(MINUTE, CreationTime) AS minute_of_creation,
	DATETRUNC(SECOND, CreationTime) AS second_of_creation
FROM Sales.Orders;

SELECT 
	DATETRUNC(month, CreationTime) as month,
	COUNT(*)
FROM Sales.Orders
GROUP BY DATETRUNC(month, CreationTime);

-- 5. EOMONTH
-- returns the last day of the month
-- output -> DATE
SELECT 
	OrderID,
	CreationTime,
	EOMONTH(CreationTime) as EO_month
FROM Sales.Orders;

-- how many orders where placed each year
SELECT * FROM Sales.Orders;

SELECT 
	DATETRUNC(year, CreationTime),
	COUNT(*)
FROM Sales.Orders
GROUP BY DATETRUNC(year, CreationTime);

SELECT 
YEAR(OrderDate),
COUNT(*) AS No_of_orders
FROM Sales.Orders
GROUP BY YEAR(OrderDate);

-- how many orders were placed each month
SELECT
	MONTH(OrderDate) AS Month,
	COUNT(*) AS No_of_orders
FROM Sales.Orders
GROUP BY MONTH(OrderDate);

SELECT
	DATENAME(MONTH,OrderDate) AS Month,
	COUNT(*) AS No_of_orders
FROM Sales.Orders
GROUP BY DATENAME(MONTH,OrderDate);

-- show all orders placed during month of february
SELECT 
	*
FROM Sales.Orders
WHERE
	DATENAME(MONTH, OrderDate) = 'February';

-- Observation: filtering is faster when filtering using intergers than string
SELECT 
	*
FROM Sales.Orders
WHERE
	DATEPART(MONTH, OrderDate) = 2;

-- Date Format & Casting
/*
Different Standards
1. Internation Standard (ISO 8601)
2026-02-07 12:23:08
YYYY-MM-dd HH:mm:ss

2. USA Standard
MM-dd-YYYY

3. European Standard
dd-MM-YYYY
*/

-- 1. Format
SELECT
	OrderID,
	CreationTime,
	FORMAT(CreationTime, 'MM-dd-yyyy') USA_format,
	FORMAT(CreationTime, 'dd-MM-yyyy') EU_format,
	FORMAT(CreationTime, 'dd') dd,
	FORMAT(CreationTime, 'ddd') ddd,
	FORMAT(CreationTime, 'dddd') dddd,
	FORMAT(CreationTime, 'MM') MM,
	FORMAT(CreationTime, 'MMM') MMM,
	FORMAT(CreationTime, 'MMMM') MMMM
FROM Sales.Orders;

-- Show creationtime using following format
-- Day WED JAN Q1 2025 12:34:56 PM
SELECT 
	orderID,
	CreationTime,
	'DAY ' + FORMAT(CreationTime, 'ddd MMM') + 
	' Q' + DATENAME(quarter, CreationTime) + 
	' ' + FORMAT(CreationTime, 'yyyy hh:mm:ss tt') AS CustomFormat
FROM Sales.Orders;

SELECT 
	FORMAT(CreationTime, 'MMM yy'),
	COUNT(*) AS Order_count
FROM Sales.Orders
GROUP BY FORMAT(CreationTime, 'MMM yy');

-- Convert
SELECT
	CONVERT(INT, '1234') AS [STRING to INT CONVERT],
	CONVERT(DATE, '2025-03-24') AS [String to Date Convert];

SELECT
	CreationTime,
	CONVERT(Date, CreationTime) AS [Datetime to Date Convert],
	CONVERT(VARCHAR, CreationTime, 32) AS [USA std. Style: 32],
	CONVERT(VARCHAR, CreationTime, 34) AS [EURO std. Style: 34]
FROM Sales.Orders;

-- CAST
-- only converting between datatypes
-- no style format can be specified

SELECT 
	CAST('1234' AS INT) AS [String to Int],
	CAST(124 AS VARCHAR) AS [Int to String],
	CAST('2026-07-23' AS DATE) AS [String to Date],
	CAST('2026-07-23' AS DATETIME2) AS [String to Date];

SELECT 
	CreationTime,
	CAST(CreationTime AS DATE) as Creattime_date
FROM Sales.Orders;

-- Date Calculations
-- DATEADD
-- Add and Subtract specific time interval to/from date
SELECT
	OrderID,
	OrderDate,
	DATEADD(year, 2, OrderDate) as year_add_2,
	DATEADD(month, -4, OrderDate) as month_sub_3
FROM Sales.Orders;

-- DATEDIFF
-- Calculate the age of Employee
SELECT * FROM Sales.Employees;

SELECT 
	employeeID,
	FirstName,
	BirthDate,
	DATEDIFF(year, BirthDate, GETDATE()) AS Age
FROM Sales.Employees;

-- find the avg shipping duration in days for each month
SELECT * FROM Sales.Orders;

SELECT 
	OrderID,
	OrderDate,
	ShipDate,
	DATEDIFF(day, OrderDate, ShipDate) AS Shipping_duration
FROM Sales.Orders;

SELECT 
	Month(OrderDate) as Month,
	AVG(DATEDIFF(day, OrderDate, ShipDate)) AS AvgShip
FROM Sales.Orders
GROUP BY Month(OrderDate);

-- Time Gap Analysis
-- find the number of days between each order and previous order
SELECT 
	OrderID,
	OrderDate CurrentOrderDate,
	LAG(OrderDate) Over (Order by OrderDate) PreviousOrderDate,
	DATEDIFF(
		day,
		LAG(OrderDate) Over (Order by OrderDate),
		OrderDate
	) AS Date_diff
FROM Sales.Orders;

-- Date Validation 
-- ISDATE()
-- returns 1 if is standard date format else 0
SELECT 
	ISDATE('2025-03-24') as dateCheck1, -- 1
	ISDATE('468239') as dateCheck2, -- 0
	ISDATE('123') as dateCheck3, -- 0
	ISDATE('20-09-2026') as dateCheck4,--0
	ISDATE('2026') as dateCheck5, -- 1
	ISDATE('26') as dateCheck5; -- 0

SELECT 
	OrderDate,
	ISDATE(OrderDate),
	CASE WHEN ISDATE(OrderDate) = 1 THEN OrderDate 
	ELSE '9999-01-01'
	END AS NewOrderDate
FROM (
	SELECT '2026-01-08' AS OrderDate UNION
	SELECT '2024-07-12' UNION
	SELECT '2001-08-23' UNION
	SELECT '2032-02'
) t;
-- WHERE ISDATE(OrderDate) = 0;













