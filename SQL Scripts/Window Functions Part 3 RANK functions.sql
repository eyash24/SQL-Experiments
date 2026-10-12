-- Window Function Part 3 

/*
Rank Functions

Interger Based Ranking 
- Top / Bottom N Analysis
- discrete values
- ROW_NUMBER(), RANK(), DENSE_RANK(), NTILE()

Percentage Based Ranking
- Distribution Analysis
- CUME_DIST(), PERCENT_RANK()

Rules
-- Order By Over clause is req, partition by is optional
-- Frame clause not allowed
*/

-- use database
USE SalesDB;


-- 1. Row_Number
-- assigns each row a row number
-- does not handle ties
-- unique ranking w/o gaps/skipping


-- rank orders based on sales from highest to lowest
SELECT 
	orderID,
	Sales,
	ROW_NUMBER() OVER(Order By Sales DESC) AS Rank
FROM Sales.Orders;

-- 2. RANK
-- assigns a rank to each row
-- handles the ties
-- it leaves gaps in ranking

-- rank orders based on sales from highest to lowest
SELECT 
	orderID,
	Sales,
	RANK() OVER(Order By Sales DESC) AS Rank
FROM Sales.Orders;

-- 3. Dense_RANK
-- assigns rank to each row
-- handles ties,
-- doesnot leave gaps

-- rank orders based on sales from highest to lowest
SELECT 
	orderID,
	Sales,
	DENSE_RANK() OVER(Order By Sales DESC) AS Rank
FROM Sales.Orders;

-- find the top highest sale for each product
SELECT 
*
FROM (
	SELECT 
		productID,
		Sales,
		RANK() OVER(PARTITION BY ProductID ORDER BY Sales) RANK
	FROM Sales.Orders
) t 
WHERE RANK = 1;

-- find the lowest 2 customers based on their total sales
SELECT 
*
FROM (
SELECT 
	CustomerID,
	SUM(Sales) TotalSUM,
	ROW_NUMBER() OVER(ORDER BY SUM(Sales) ASC) Rank
FROM Sales.Orders
GROUP BY CustomerID
) t
WHERE Rank <= 2;

-- assign unique ids to Order Archive table
SELECT 
	ROW_NUMBER() OVER(ORDER BY OrderID, OrderDate) ID,
	*
FROM Sales.OrdersArchive;

-- identify the duplicate rows from orderArchive and return a clean version w/o duplicates
SELECT 
*
FROM (
	SELECT 
		ROW_NUMBER() OVER(PARTITION BY OrderID ORDER BY CreationTime DESC) rn,
		*
	FROM Sales.OrdersArchive
) t
WHERE rn = 1;


/*
ROW_NUMBER Use Cases
1. TOP N
2. BOTTOM N
3. Assign unique ids
4. Quality check: Identity duplicates
*/

-- 4. NTILE
-- divides the rows into a specified number of approximately equal groups (buckets)
-- bucket size = no of rows / no of buckets
-- rule for odd bucket size: Larger grp comes first

SELECT 
	OrderID,
	Sales,
	NTILE(1) OVER (ORDER BY Sales DESC) OneBucket,
	NTILE(2) OVER (ORDER BY Sales DESC) twoBucket,
	NTILE(3) OVER (ORDER BY Sales DESC) threeBucket,
	NTILE(4) OVER (ORDER BY Sales DESC) fourBucket
FROM Sales.Orders;

/*
NTILE Use Case
1. Data Segmentation
	- divide dataset into distinct subsets 
2. Equalizing Load
*/

-- segment orders into 3 categories: High, Medium, Low
SELECT 
*,
CASE 
	WHEN Buckets = 1 THEN 'HIGH'
	WHEN Buckets = 2 THEN 'MEDIUM'
	WHEN Buckets = 3 THEN 'LOW'
END AS Salecategory
FROM (
SELECT 
	OrderID,
	Sales,
	NTILE(3) OVER(ORDER BY Sales DESC) Buckets
FROM Sales.Orders
) t;

-- inorder to export data divide orders into 2 grps
SELECT 
*,
NTILE(2) OVER(ORDER BY OrderID, OrderDate) Grp
FROM Sales.Orders;


/*
-- Percentage Based ranking
-- 1. CUME_DIST
-- cumulative distribution calculate the distribution of data points within a window
-- formula: position nr / nr of rows
-- tie rule: position nr -> position of the last occurence of the same value

-- 2. Percent_RANK
-- calculates the relative position of each row
-- formula = (position nr -1 ) / (nr of row -1)
-- tie rule: position nr -> position of the first occurence of the same value 

Difference
CUME_DIST							|	Percent_RANK
- inclusive current row included	 - exclusive (current row not included
*/

-- find the products that fall within highest 40% of the prices
SELECT * FROM Sales.Products;


SELECT
*,
CONCAT( DistRank * 100, '%') AS DistRankPercentage
FROM (
SELECT
	ProductID,
	Product,
	Price,
	CUME_DIST() OVER(ORDER BY Price DESC) AS DistRank
FROM Sales.Products
) t
WHERE DistRank <= 0.4;

SELECT
	ProductID,
	Product,
	Price,
	PERCENT_RANK() OVER(ORDER BY Price DESC) AS DistRank
FROM Sales.Products;

SELECT
*,
CONCAT( DistRank * 100, '%') AS DistRankPercentage
FROM (
SELECT
	ProductID,
	Product,
	Price,
	PERCENT_RANK() OVER(ORDER BY Price DESC) AS DistRank
FROM Sales.Products
) t
WHERE DistRank <= 0.4;










