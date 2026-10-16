-- Index Management & Monitoring
/*
Index Management
1. Monitor Index Usage
2. Missing Indexes
3. Monitor duplicate indexes
4. Update statistics
5. Monitor Fragmentation

*/

-- Use database
USE SalesDB;

-- list all indexes on a spcific table
sp_helpindex 'Sales.DBCustomers';

-- monitoring index usage
SELECT * FROM sys.tables;
SELECT * FROM sys.indexes;
SELECT * FROM sys.dm_db_index_usage_stats;

SELECT
	tbl.name as TableName,
	idx.name as IndexName,
	idx.type_desc as IndexType,
	idx.is_primary_key as IsPrimaryKey,
	idx.is_unique as IsUnique,
	idx.is_disabled as IsDisabled,
	s.user_seeks,
	s.user_scans,
	s.user_lookups,
	s.user_updates,
	s.last_user_seek,
	s.last_user_scan
FROM sys.indexes idx
JOIN sys.tables tbl
ON idx.object_id = tbl.object_id
LEFT JOIN sys.dm_db_index_usage_stats s
ON s.object_id = idx.object_id
AND s.index_id = idx.index_id
ORDER BY tbl.name, idx.name;


-- Missing indexes
SELECT * FROM sys.dm_db_missing_index_details;

USE AdventureWorksDW2025;

SELECT 
	fs.SalesOrderNUmber,
	dp.EnglishProductName,
	dp.color
FROM FactInternetSales fs
INNER JOIN DimProduct dp
ON fs.ProductKey = dp.productKey
WHERE dp.color  = 'Black'
AND fs.OrderDateKey BETWEEN 20101229 AND 20101231;

-- Note: use the recommendations to evaluate necessary indexes

-- Monitor duplicate indexes
USE SalesDB;
SELECT * FROM sys.index_columns;
SELECT * FROM sys.columns;

SELECT 
	tbl.name as TableName,
	c.name as IndexColumn,
	idx.name as IndexName,
	idx.Type_desc as IndexType,
	COUNT(*) OVER (Partition By tbl.name, c.name) ColumnCount 
FROM sys.indexes idx
JOIN sys.tables tbl ON idx.object_id = tbl.object_id
JOIN sys.index_columns idc on idx.object_id = idc.object_id and idx.index_id = idc.index_id
JOIN sys.columns c on idc.object_id = c.object_id and idc.column_id = c.column_id
ORDER BY ColumnCount DESC;

-- Update statistics of the Tables
SELECT 
	SCHEMA_NAME(t.schema_id) AS SchemaName,
	t.name as TableName,
	s.name as StatisticName,
	sp.last_updated as LastUpdated,
	DATEDIFF(day, sp.Last_updated, GETDATE()) AS LastUpdateDay,
	sp.rows as 'Rows',
	sp.modification_counter as AModificationsSinceLastUpdate
FROM sys.stats as s
JOIN sys.tables t
ON s.object_id = t.object_id
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) as sp
ORDER By t.name DESC, sp.modification_counter DESC;
-- cross apply works like a for each loop sending each row of the left table (outer table) into a subquery / function and output the combined result

-- update statisctics
UPDATE STATISTICS Sales.Products PK_products; -- updates a single statistics
UPDATE STATISTICS Sales.OrdersArchive; -- updates all the table statistics
EXEC sp_updatestats; -- updates all the database statistics

-- Monitor Fragmentation
/* 
Fragmnetation
- unused space in data pages
- data pages out of order 

Fragmentation Methods
1. Reorganise
	- defragment the lead nodes to keep them sorted
	- light operation
2. Rebuild
	- recreated indexes from scratch
	- heavy operation 

When to defragment
< 10% -> No action
10-30% -> reorganise
> 30% -> rebuild
*/

-- check fragmentation 
SELECT *
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, 'LIMITED');

-- avg_fragmentation_in_percent : indicated how much out of order pages are within the index
-- 0% -> no fragmentation

SELECT 
	tbl.name as TableName,
	idx.name as IndexName,
	s.avg_fragmentation_in_percent,
	s.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, 'LIMITED') s
INNER JOIN sys.tables tbl ON s.object_id = tbl.object_id
INNER JOIN sys.indexes idx ON s.object_id = idx.object_id and s.index_id = idx.index_id
ORDER BY s.avg_fragmentation_in_percent DESC;

-- reorganise index
ALTER INDEX idx_Customers_Country ON Sales.Customers REORGANIZE;

-- rebuild index 
ALTER INDEX idx_Customers_Country ON Sales.Custoemrs REBUILD;


