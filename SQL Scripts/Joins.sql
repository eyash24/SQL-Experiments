-- Joining Data
USE MyDatabase;

-- No join
-- retreive all data from customers and orders as separate results
SELECT * FROM customers;
SELECT * FROM orders;

--Inner Join
-- Returns the matching rows of both the tables
-- retrieve all customers with their orders but only for customers who have placed an order
SELECT 
	a.*, 
	b.* 
FROM 
	customers AS a 
INNER JOIN orders AS b
ON
	a.id = b.customer_id;

SELECT *
FROM customers
INNER JOIN orders
ON id = customer_id;

-- Left JOIN 
-- all rows from left, matching ones from right
-- retreive customers with order including customers without orders
SELECT 
	c.id,
	c.first_name,
	o.order_id,
	o.sales
FROM customers AS c
LEFT JOIN orders AS o
ON c.id = o.customer_id;

-- Right Join
-- get all customers with their orders along with orders not matching any customer
-- retreive customers with order including customers without orders
SELECT 
	c.id,
	c.first_name,
	o.order_id,
	o.sales
FROM customers AS c
RIGHT JOIN orders AS o
ON c.id = o.customer_id;

SELECT 
	c.id,
	c.first_name,
	o.order_id,
	o.sales
FROM orders AS o 
LEFT JOIN customers AS c
ON c.id = o.customer_id;

-- get all customers and all order even if they dont match
SELECT 
*
FROM customers
FULL JOIN orders
ON customers.id = orders.customer_id;

-- Left Anti Join
-- returns rows from left that have no match in right

-- retrieve all customers who havent placed any order
SELECT 
	*
FROM customers 
LEFT JOIN orders
ON customers.id = orders.customer_id
WHERE orders.customer_id is NUll;

-- Right Anti Join
-- returns rows from right that has no match in left

-- retrieve all orders without matching customers
SELECT 
*
FROM customers AS c
RIGHT JOIN orders AS o
ON c.id = o.customer_id
WHERE c.id is NULL;


SELECT 
*
FROM orders AS o
LEFT JOIN customers AS c
ON c.id = o.customer_id
WHERE c.id is NULL;

-- Full Anti Join 
-- Returns rows that do not match in either tables

-- retrieve customers without orders and orders without customers
SELECT *
FROM customers AS c
FULL JOIN orders AS o
ON c.id = o.customer_id
WHERE 
	c.id is NUll or o.customer_id is NUll;

-- retrieve customers along with their orders but only for customers who have placed an order (wo inner join)
SELECT *
FROM customers AS c
FULL JOIN orders AS o
ON c.id = o.customer_id
WHERE 
	c.id is not NULL and o.customer_id is not NULL;

SELECT *
FROM customers AS c
LEFT JOIN orders AS o
ON c.id = o.customer_id
WHERE o.customer_id is not NULL;

-- Cross Join
-- combines every row from left with every row from right, all possible combination
-- cartesian join 

-- generate all possible combinations of customers and orders
SELECT *
FROM customers 
CROSS JOIN orders;


-- Using salesDB retrieve list of all orders along with their customer, product and employee details 
USE SalesDB;

SELECT * FROM Sales.Customers;
SELECT * FROM Sales.Employees;
SELECT * FROM Sales.Products;
SELECT * FROM Sales.Orders;
SELECT * FROM Sales.OrdersArchive;

SELECT 
o.OrderID,
c.FirstName AS Customer_name,
p.Product,
o.Sales,
p.price,
e.FirstName AS Saleperson_name
FROM Sales.Orders AS o
LEFT JOIN Sales.Products AS p
ON o.ProductID = p.ProductID
LEFT JOIN Sales.Customers AS c
ON o.CustomerID = c.CustomerID
LEFT JOIN Sales.Employees AS e
ON o.SalesPersonID = e.EmployeeID
