-- Indexes
/*
- data structure that provides quick access to data optimizing speed of query

Index Type
1. Structure
	1. Clustered Index
	2. Non-clustered index
2. Storage
	1. Rowstore index
	2. Columnstore index
3. Functions
	1. Unique index
	2. Filtered index

Pages
- smallest unit of data storage in a database (8kb)
- stored anything (data, metadata, index...)
Types 
	1. Data Page
	2. Index Page

Data Page
Header : File Id: Page Number
	row	...

Offset : where each row begins 

Default Stucture of storing data in databases -> Heap structure 
- tables w/o any clustered index
- Fast Write, Slow Read
- full scan done to read a particular value 

Clustered Index
- reorganises data into a B-tree 
- B-Tree or balanced tree -> hierarchical structure storing data at leaves to help quickly locate data 

B-Tree 
root node -> intermediate nodes -> leaf node
data stored at leaf nodes

Index Page
- stores key value (Pointers) to another page.
- doesnt store actual rows

Non clustered Index
- wont reorganise or change anything on the data page
- Index page stores a RID for each ID
- RID : FileID, Page Number, Offset
- create a B-tree of Index pages where the leaf nodes are index pages consisting of RID for ID

Note
- multiple non clustered index allowed but only 1 clustered index allowed 
- by default nonclustered index is produced and 
- primary key used for creating a clustered index at the table creation using DDL command CREATE

Index Syntax
CREATE [CLUSTERERD | NONCLUSTERED]  INDEX index_name ON table_name (col1, col2...)
*/

-- Use Database 
USE SalesDB;

-- Index: Structure Type
-- Clustered / Non-clustered Index

SELECT *
INTO Sales.DBCustomers
FROM Sales.Customers;

SELECT *
FROM Sales.DBCustomers;

-- create Index
CREATE CLUSTERED INDEX idx_DBCsutomers_CustomerID 
ON Sales.DBCustomers (CustomerID);

-- drop index
DROP INDEX idx_DBCsutomers_CustomerID ON Sales.DBCustomers;

CREATE NONCLUSTERED INDEX idx_DBCustomers_LastName 
ON Sales.DBCustomers (LastName ASC);

SELECT
*
FROM Sales.DBCustomers
WHERE LastName ='Adams';

SELECT 
*
FROM Sales.DBCustomers
WHERE FirstName = 'Kevin';

CREATE INDEX idx_DBCustomers_FirstName
ON Sales.DBCustomers (FirstName ASC); -- defaults to Nonclustered index

-- composite index
CREATE INDEX idx_DBCustomers_CountryScore
ON Sales.DBCustomers (Country, Score);

-- Note: In the select where clause the order of the composite key should be same to make use of the index
SELECT
*
FROM Sales.DBCustomers
WHERE Country = 'Germany' AND Score > 500;

DROP INDEX [idx_DBCsutomers_CustomerID] ON Sales.DBCustomers;

-- Note: SQL Server follows the Leftmost prefix rule
-- Index works only if query filters start from the first columns in the index and follow the order

-- Index: Storage Type
/*
1. Rowstore index
	- data stored row wise in the data page
2. Columnstore index
	- data stored column wise in the data page

- default: Rowstore

Columnstore Index
Process
1. Data is split into Row Groups to optimise query result
2. row groups split into column segments
3. column segment -> compressed to store the following
	- unique values -> dictionary
	- data stream -> [1,2,3,2,2,1....] -> index of unique value
4. Store results in LoB Page (Large Object Page)
LoB Page 
- Header: File Id: Page Number
- Segment Header
	- Segment ID
	- Row Group Id
	- Dictionary Id -> points to the dictionary page (contains the mapping of unique value to actual values)
- Data stream > sequence of id that represent value of the column 

Notes
- columnstore faster than the rowstore index
- in case of clustered - columnstore index, only the LoB pages ares stored in the B-Tree
- in case of non clustered columnstore index both rowstore heap and columnstore LoB pages are stored 

Syntax
Rowstore 
- CREATE NONCLUSTERED INDEX Idx_tablename_colname ON TableName (colname)
- CREATE CLUSTERED INDEX idx_tablename_colname ON TableName (colname)

Columnstore
- CREATE NONCLUSTERED COLUMNSTORE INDEX Idx_tablename_colname ON TableName (colname)
- CREATE CLUSTERED COLUMNSTORE INDEX Idx_tablename_colname ON TableName  

Rule
 - No colname required for clustered columnstore as all columns included in the new structure
 - no keyword for rowstore, by default it is rowstore
 - only one columnstore index is allowed for a table 
*/

-- create a clustered columnstore index
CREATE CLUSTERED COLUMNSTORE INDEX idx_DBCustomers_CS 
ON Sales.DBCustomers;

DROP INDEX idx_DBCustomers_CS ON Sales.DBCustomers;


USE AdventureWorksDW2025;

-- Heap structure 9.633 MB
SELECT *
INTO FactInternetSales_HP
FROM FactInternetSales;

-- rowstore > 9.633 MB
SELECT *
INTO FactInternelSales_RS
FROM FactInternetSales;

CREATE CLUSTERED INDEX idx_FactInternetSales_RS_PK 
ON FactInternelSales_RS (SalesOrderNUmber, SalesOrderLineNumber);

-- columnstore 1.451 MB
SELECT *
INTO FactInternelSales_CS
FROM FactInternetSales;

CREATE CLUSTERED COLUMNSTORE INDEX idx_FactInternetSales_CS_PK 
ON FactInternelSales_CS;

/*
Ranking based on storage ASC
1. Columnstore
2. Rowstore
3. Heap structure
*/

-- Index: Function Type
/*
1.Unique Index
- ensures no duplicate exist in specifc column
- writing slow, reading fast
- Syntax
- CREATE [UNIQUE] [ CLUSTERED | NONCLUSTERED ] [COLUMNSTORE] INDEX idx_name ON tableName (col1, col2 ...)
- default: Not unique (no keyword)
*/

USE SalesDB;

SELECT *
FROM Sales.Products;

CREATE UNIQUE NONCLUSTERED INDEX idx_Products_Product
ON Sales.Products (Product);

INSERT INTO Sales.Product (ProductID, Product) VALUES (106, 'Tire'); -- Error as unique index on product col

/*
2. Filtered Index
- An index that includes only rows meeting the specified conditions
 Benefits
	- Targeted optimisation 
	- Reduce storage space required 
Syntax
CREATE [UNIQUE] [NONCLUSTERED] INDEX idx_name 
ON tableName (col1, col2 ...)
WHERE [condition]

Rules:
- cannot use a filtered index on a clustered index
- cannot use a filtered index on a columnstore index
*/

SELECT * FROM Sales.Customers
WHERE Country = 'USA';

CREATE NONCLUSTERED INDEX idx_Customers_Country
ON Sales.Customers (Country)
WHERE Country = 'USA';
