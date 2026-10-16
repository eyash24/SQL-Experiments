-- Partitioning
-- technique to divide large tables into smaller partitions 

-- 1.Create partition function 
-- partition function: defines the logic on how to divide data into partitions

CREATE PARTITION FUNCTION PartitionByYear (DATE)
AS RANGE LEFT FOR VALUES ('2023-12-31', '2024-12-31', '2025-12-31');

-- query list all existing partition function
SELECT 
	name, 
	function_id,
	type,
	type_desc,
	boundary_value_on_right
FROM sys.partition_functions;

-- 2. Create Filegroup
-- file groups: logical container of one / more data files to help organise the partitions
ALTER DATABASE SalesDB ADD FILEGROUP FG_2023;
ALTER DATABASE SalesDB ADD FILEGROUP FG_2024;
ALTER DATABASE SalesDB ADD FILEGROUP FG_2025;
ALTER DATABASE SalesDB ADD FILEGROUP FG_2026;

-- drop filegroup 
ALTER DATABASE SalesDB REMOVE FILEGROUP FG_2023;

-- query existing filegroup 
SELECT *
FROM sys.filegroups
WHERE type = 'FG';

-- Primary: Default filegroup where all objects of datbase are stored 

-- Create Data Files
-- file format: .ndf 

-- Step 3: Add .ndf files to Each File Group
ALTER DATABASE  SalesDB ADD FILE 
(
	NAME = P_2023,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\P_2023.ndf'
) TO FILEGROUP FG_2023;

ALTER DATABASE  SalesDB ADD FILE 
(
	NAME = P_2024,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\P_2024.ndf'
) TO FILEGROUP FG_2024;

ALTER DATABASE  SalesDB ADD FILE 
(
	NAME = P_2025,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\P_2025.ndf'
) TO FILEGROUP FG_2025;

ALTER DATABASE  SalesDB ADD FILE 
(
	NAME = P_2026,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\P_2026.ndf'
) TO FILEGROUP FG_2026;

-- query file groups and their physical paths
SELECT * FROM sys.filegroups;
SELECT * FROM sys.master_files;

SELECT 
	fg.name AS FileGroupName,
	mf.name AS LogicalFileName,
	mf.physical_name AS PhysicalFilePath,
	mf.size / 128 AS SizeInMB
FROM sys.filegroups fg
JOIN sys.master_files mf ON fg.data_space_id = mf.data_space_id
WHERE 
	mf.database_id = DB_ID('SalesDB');

-- Step 4: Create partition Schema 
CREATE PARTITION SCHEME SchemePartitionByYear
AS PARTITION PartitionByYear
TO (FG_2023, FG_2024, FG_2025, FG_2026);

-- query list all the partition scheme
SELECT * FROM sys.partition_schemes;
SELECT * FROM sys.partition_functions;
SELECT * FROM sys.destination_data_spaces;
SELECT * FROM sys.filegroups;

SELECT 
	ps.name as PartitionSchemeName,
	pf.name as PartitionFunctionName,
	ds.destination_id as PartitionNumber,
	fg.name as FilegroupName
FROM sys.partition_schemes ps
JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
JOIN sys.destination_data_spaces ds ON ps.data_space_id = ds.partition_scheme_id
JOIN sys.filegroups fg ON ds.data_space_id = fg.data_space_id;

-- Step 5: Create Partitioned Table
CREATE TABLE Sales.Orders_Partitioned
(
	OrderID INT,
	OrderDate DATE,
	Sales INT
) ON SchemePartitionByYear (OrderDate);

-- Step 6: Insert Data into the Partitioned Table
INSERT INTO Sales.Orders_Partitioned VALUES (1, '2023-05-12', 100);
INSERT INTO Sales.Orders_Partitioned VALUES (2, '2024-02-04', 185);
INSERT INTO Sales.Orders_Partitioned VALUES (3, '2025-08-23', 150);
INSERT INTO Sales.Orders_Partitioned VALUES (4, '2025-12-31', 150);
INSERT INTO Sales.Orders_Partitioned VALUES (5, '2026-02-01', 150);

SELECT * FROM Sales.Orders_Partitioned;

-- query lists the number of rows in each partition 
SELECT 
	p.partition_number AS PartitionNumber,
	f.name as PartitionFileGroup,
	p.rows as NumberOfRows
FROM sys.partitions p
JOIN sys.destination_data_spaces dds ON p.partition_number = dds.destination_id
JOIN sys.filegroups f ON dds.data_space_id = f.data_space_id
WHERE OBJECT_NAME(p.object_id) = 'Orders_Partitioned';

-- performance comparision
SELECT *
INTO Sales.Orders_NoPartitioned
FROM Sales.Orders_Partitioned;

SELECT * 
FROM Sales.Orders_Partitioned
WHERE OrderDate = '2026-02-01';
-- no of rows read = 1 (only the 2026 partition is scaned)

SELECT * 
FROM Sales.Orders_NoPartitioned
WHERE OrderDate = '2026-02-01';
-- no of rows read = 5 (full table scan)