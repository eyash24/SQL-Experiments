-- Joining Data

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

-- Anti Left Join
-- returns rows from left that have no match in right

-- retrieve all customers who havent placed any order
SELECT 
	*
FROM customers 
LEFT JOIN orders
ON customers.id = orders.customer_id
WHERE orders.customer_id is NUll;
