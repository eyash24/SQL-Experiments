-- Functions Part 4
-- Case Statements

-- Use Database
USE SalesDB;

-- categorise sales into High (> 50) Meidum (21-50) low (<= 20 )
-- show total sales for each of the categorises and sort from highest to lowest
SELECT * FROM Sales.Orders;

SELECT 
	Category,
	SUM(Sales) AS Total_Sales
FROM (
	SELECT 
		OrderID,
		Sales,
		CASE 
			WHEN Sales > 50 THEN 'High'
			WHEN Sales BETWEEN 21 AND 50 THEN 'Medium'
			ELSE 'Low'
		END Category
	FROM Sales.Orders
) t
GROUP BY Category
ORDER BY Total_Sales DESC;

-- retrieve employee details with gender displayed as full text
SELECT * FROM Sales.Employees;

SELECT 
	EmployeeID,
	FirstName,
	LastName,
	Department,
	BirthDate,
	CASE 
		WHEN Gender = 'M' THEN 'Male'
		WHEN Gender = 'F' THEN 'Female'
		ELSE 'Not Available'
	END AS Gender_details,
	Salary,
	ManagerID
FROM Sales.Employees;

-- retrieve customer details with abbreviated country code
SELECT * FROM Sales.Customers;
SELECT DISTINCT Country FROM Sales.Customers;

SELECT 
	CustomerID,
	FirstName,
	LastName,
	Country,
	CASE 
		WHEN Country = 'USA' THEN 'US'
		WHEN Country = 'Germany' THEN 'DE'
		ELSE 'N\A'
	END CountryAbbrie
FROM Sales.Customers;

SELECT 
	CustomerID,
	FirstName,
	LastName,
	Country,
	CASE Country
		WHEN 'USA' THEN 'US'
		WHEN 'Germany' THEN 'DE'
		ELSE 'N\A'
	END CountryAbbrie
FROM Sales.Customers;


-- find the avg score of customers and treat null as 0
-- provide customerID and lastname
SELECT * FROM Sales.Customers;

SELECT 
	CustomerID,
	LastName,
	Score,
	AVG(Score) Over() AvgCustomers,
	CASE 
		WHEN Score IS NULL THEN 0
		ELSE Score
	END AS NewScore,
	AVG(
		CASE 
			 WHEN Score IS NULL THEN 0
			ELSE Score
		END
	) Over() AvgCustomerClean
FROM Sales.Customers;

-- count how mnay times each customer has made an order with sale greater than 30
SELECT
	CustomerID,
	SUM(
		CASE
			WHEN Sales > 30 THEN 1
			ELSE 0
		END
	) TotalHighSaleOrders,
	Count(*) TotalOrders
FROM Sales.Orders
GROUP BY CustomerID;

SELECT 
	CustomerID,
	COUNT(*)
FROM Sales.Orders
WHERE Sales > 30
GROUP BY CustomerID;