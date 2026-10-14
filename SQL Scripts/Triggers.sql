-- Triggers
/*
- special Stored procedures that automatically runs in response to a specific event on a table or view 

Trigger Types 
1. DML Triggers
	- INSERT, UPDATE, DELETE
	1. AFTER Triggers
		- executed after the event
	2. INSTEAD OF Triggers
		- runs during the event

2. DDL Triggers 
	- CREATE, ALTER, DROP
3. LOGGING Triggers

*/

-- Create a logging trigger 
-- IDENTITY(Seed, Increment) 
	-- SEED : Starting value
	-- increment: value added for each new row

CREATE TABLE Sales.EmployeeLogs (
	LogID INT IDENTITY(1,1) PRIMARY KEY,
	EmployeeID INT,
	LogMessage VARCHAR(255),
	LogDate Date
);

CREATE TRIGGER trg_AfterInsertEmployee ON Sales.Employees
AFTER INSERT
AS 
BEGIN
	INSERT INTO Sales.EmployeeLogs (EmployeeID, LogMessage, LogDate)
	SELECT
		EmployeeID,
		'New Employee Added = ' + CAST(EmployeeID AS VARCHAR),
		GETDATE()
	-- virtual table that holds a copy of the rows that are being inserted into the target table
	FROM INSERTED 
END;

SELECT * FROM Sales.Employees; 
 
INSERT INTO Sales.Employees 
VALUES
(6, 'Andy', 'Deo', 'HR', '1995-03-02', 'F', 70000, 2);

SELECT * FROM Sales.Employees;
SELECT * FROM Sales.EmployeeLogs;