-- Index Part 3 Execution Plan
-- roadmap created by database on how the query will be executed step by step 

-- Use database
USE AdventureWorksDW2025;

SELECT *
INTO FactResellerSales_HP
FROM FactResellerSales;

SELECT *
FROM FactResellerSales_HP
ORDER BY SalesOrderNumber;

SELECT *
FROM FactResellerSales
ORDER BY SalesOrderNumber;

/*
Notes:
- Estimated Execution Plan: predicts the execution plan w/o actually running the query 
- Actual Execution Plan: shows execution plan after running the query 

Types of scans
- Live Execution Plan: shows real time execution flow as the query run 
- Table Scan: Reads the entire table, page by page, row by row -> slower performance on large table 
- Index Scan: Scan all data in an index to find matching rows
- Index Seek: A targeted seach within an index to retrieve only specific rows

Heap VS Clustered
In case of heap structure, the table is sorted after the table scan
In case of clustered index, no need for sort as table is already clustered by the Primary Key
Performance
Heap << Clustered Index
*/

-- Nonclustered index
SELECT *
FROM FactResellerSales_HP
WHERE CarrierTrackingNumber = '4911-403C-98';
-- table scan -> select

SELECT *
FROM FactResellerSales
WHERE CarrierTrackingNumber = '4911-403C-98';
-- clustered index scan -> select

-- nonclustered index 
CREATE NONCLUSTERED INDEX idx_FactResellerSales_HP_CarrierTrackingNumber 
ON FactResellerSales_HP (CarrierTrackingNumber);

-- after nonclustered index 
SELECT *
FROM FactResellerSales_HP
WHERE CarrierTrackingNumber = '4911-403C-98';


/*
Join Algorithm 
1. Nested Loop: cpmpares table row by row; best for small tables
2. Hash Match: Matches rows using a hash table; best for large table 
3. Merge Join: Merge two sorted tables; efficient when both are sorted 

RID Lookup: Table lookup conducted to the required columns from table 
*/

-- rowstore vs columnstore
SELECT * FROM FactResellerSales;
SELECT * FROM DimProduct;

SELECT 
	p.EnglishProductName,
	SUM(s.SalesAmount) AS TotalSales
FROM DimProduct p
JOIN FactResellerSales s
ON p.ProductKey = s.ProductKey
GROUP BY p.EnglishProductName;

CREATE CLUSTERED COLUMNSTORE INDEX idx_FactResellerSales_HP
ON FactResellerSales_HP;

SELECT 
	p.EnglishProductName,
	SUM(s.SalesAmount) AS TotalSales
FROM DimProduct p
JOIN FactResellerSales_HP s
ON p.ProductKey = s.ProductKey
GROUP BY p.EnglishProductName;

-- SQL Hints
-- commands to force the database to run a query in a specific way for better performance 

USE SalesDB;

SELECT * FROM Sales.Orders;
SELECT * FROM Sales.Customers;

SELECT 
	o.sales,
	c.country
FROM Sales.Orders o 
LEFT JOIN Sales.Customers c
ON o.CustomerID = c.CustomerID;
-- uses Nested Loop

SELECT 
	o.sales,
	c.country
FROM Sales.Orders o 
LEFT JOIN Sales.Customers c
ON o.CustomerID = c.CustomerID
OPTION (HASH JOIN);
-- uses Hash Match in place of Nested Loop

SELECT 
	o.sales,
	c.country
FROM Sales.Orders o 
LEFT JOIN Sales.Customers c WITH (FORCESEEK)
ON o.CustomerID = c.CustomerID;
-- uses index seek inplace of index scan on customer table 


SELECT 
	o.sales,
	c.country
FROM Sales.Orders o 
LEFT JOIN Sales.Customers c WITH (INDEX([PK_customers]))
ON o.CustomerID = c.CustomerID;
-- uses the pk_customers index on customers 

/*
Indexing Strategy
Golden Rule : Avoid Over indexing, Less is More

Phase 1: Indexing Stratergy
For OLAP (Online Analytical Processing)
data -ETL-> Data warehouse -READ-> Reporting
- data model consist of dim and fact tables

To optimise READ performance
- make large fact tables into Columnstore index

OLTP (Online Transaction Processing)
Server <-READ-WRITE-> Client
- lot of tables in database

To optimise write performance
- clustered index on primary key for each table

Phase 2: Usage Pattern Indexing 
1. Identify frequently used table and columns 
2. Choose the right index type using the Index Use Decision image
3. Test index

Phase 3: Scenario-Based Indexing
1. identify slow queries
2. check execution plan 
3. choose right index
4. Test and compare proposed execution plan with original one

Phase 4: Monitoring and Maintenance
1. Monitor Index usage
2. Monitor missing indexes
3. Monitor duplicate indexes
4. Update statistics
5. Monitor Fragmentation
*/




