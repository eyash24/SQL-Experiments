-- Stored Procedure

-- USE Database
USE SalesDB;

-- for us customers find the total number of customers and the avg score
SELECT 
count(*) as totalCustomers,
AVG(Score) as AvgScore
FROM Sales.Customers
WHERE Country = 'USA';

CREATE PROCEDURE GetCustomerSummary AS 
BEGIN
SELECT 
count(*) as totalCustomers,
AVG(Score) as AvgScore
FROM Sales.Customers
WHERE Country = 'USA'
END;

EXEC GetCustomerSummary;

/*
Parameters
- placeholders used to pass value as input from the caller to the procedure, 
  allowing dynamic data to be processed

*/

-- alter procedure add parameter
ALTER PROCEDURE GetCustomerSummary @Country NVARCHAR(50)
AS 
BEGIN
SELECT 
count(*) as totalCustomers,
AVG(Score) as AvgScore,
@Country as Country
FROM Sales.Customers
WHERE Country = @Country
END;

EXEC GetCustomerSummary @Country='Germany';

-- Dropping Procedures
DROP PROCEDURE GetCustomerSummaryV2;

-- alter procedure add default parameter
ALTER PROCEDURE GetCustomerSummary @Country NVARCHAR(50) = 'USA'
AS 
BEGIN
SELECT 
count(*) as totalCustomers,
AVG(Score) as AvgScore,
@Country as Country
FROM Sales.Customers
WHERE Country = @Country
END;

EXEC GetCustomerSummary;

-- Multiple query 
-- find total number of order and total sale
ALTER PROCEDURE GetCustomerSummary @Country NVARCHAR(50) = 'USA'
AS 
BEGIN

SELECT 
count(*) as totalCustomers,
AVG(Score) as AvgScore,
@Country as Country
FROM Sales.Customers
WHERE Country = @Country;

SELECT 
COUNT(o.OrderId) TotalOrders,
SUM(o.Sales) TotalSale
FROM Sales.Orders o
JOIN Sales.Customers c 
ON o.CustomerID = c.CustomerID
WHERE c.Country = @Country;

END;

EXEC GetCustomerSummary;

-- Variables
-- placeholder to store values to be used later in the procedure
ALTER PROCEDURE GetCustomerSummary @Country NVARCHAR(50) = 'USA'
AS 
BEGIN

	DECLARE @TotalCustomers INT, @AvgScore FLOAT;

	SELECT 
		@TotalCustomers = count(*),
		@AvgScore = AVG(Score)
	FROM Sales.Customers
	WHERE Country = @Country;

	PRINT 'Total customers from ' + @Country + ' :' + CAST(@TotalCustomers AS NVARCHAR);
	PRINT 'Average score from ' + @Country + ' :' + CAST(@AvgScore AS NVARCHAR);
END;

EXEC GetCustomerSummary;

-- Control Flow
ALTER PROCEDURE GetCustomerSummary @Country NVARCHAR(50) = 'USA'
AS 
BEGIN
DECLARE @TotalCustomers INT, @AvgScore FLOAT;

	-- Prepare and Clean Up data
	IF EXISTS (SELECT 1 FROM Sales.Customers WHERE Score IS NULL AND Country=@Country)
	BEGIN
		PRINT 'Updating Null Scores to 0';
		UPDATE Sales.Customers
		SET Score = 0 
		WHERE Score IS NULL AND Country= @Country;
	END

	ELSE
	BEGIN
		PRINT 'No Null Scores Found';
	END;

	-- Generate Reports
	SELECT 
		@TotalCustomers = count(*),
		@AvgScore = AVG(Score)
	FROM Sales.Customers
	WHERE Country = @Country;

	PRINT 'Total customers from ' + @Country + ' :' + CAST(@TotalCustomers AS NVARCHAR);
	PRINT 'Average score from ' + @Country + ' :' + CAST(@AvgScore AS NVARCHAR);

END;

EXEC GetCustomerSummary;
EXEC GetCustomerSummary @Country='Germany';

-- Error Handling
ALTER PROCEDURE GetCustomerSummary @Country NVARCHAR(50) = 'USA'
AS 
BEGIN
	BEGIN TRY

		SELECT 
			COUNT(o.OrderId) TotalOrders,
			SUM(o.Sales) TotalSale,
			1/0
		FROM Sales.Orders o
		JOIN Sales.Customers c 
		ON o.CustomerID = c.CustomerID
		WHERE c.Country = @Country;

	END TRY
	BEGIN CATCH
		PRINT('An Error Occured');
		PRINT('Error Message: ' + ERROR_MESSAGE());
		PRINT('Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR));
		PRINT('Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR));
		PRINT('Error Procedure: ' + ERROR_PROCEDURE());
	END CATCH
END;

EXEC GetCustomerSummary;
EXEC GetCustomerSummary @Country='Germany';
