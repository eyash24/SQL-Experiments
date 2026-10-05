-- Data Definition Language

USE MyDatabase;

-- Create new table persons with columns id, person_name, birth_date, and phone
CREATE TABLE person(
	id INT NOT NULL,
	person_name VARCHAR(50) NOT NULL,
	birth_date DATE,
	phone VARCHAR(15) NOT NULL,
	CONSTRAINT pk_person PRIMARY KEY (id)
)

-- add new column emails to the person table
ALTER TABLE person
ADD email VARCHAR(50) NOT NULL

SELECT * FROM person;

-- remove the phone columns from the person table 
ALTER TABLE person
DROP COLUMN phone;

SELECT * FROM person;

-- delete table person from the database
DROP TABLE person


-- Data Manipulation Language
SELECT * FROM customers;

-- Insert Case 1 : Manual Value Insertion
INSERT INTO customers (id, first_name, country, score)
VALUES 
	(6, 'Anna', 'USA', NULL),
	(7, 'Charlie', 'Canada', 400);

INSERT INTO customers (id, first_name, country, score)
VALUES 
	(8, 'SAM', NULL, 100),
	(9, 'Andreas', 'Germany', NULL),
	(10, 'Sahra', NULL, NULL);

INSERT INTO customers (id, first_name, country, score)
VALUES 
	(11, 'Jun Jung', 'South Korea', NULL),
	(12, 'Arun', NULL, NULL);

SELECT * FROM customers;

-- Insert Case 2: Insertion from another Table
-- Copy data from customers to person table
SELECT * FROM customers;

INSERT INTO person (id, person_name, birth_date, phone)
SELECT 
	id,
	first_name,
	NULL,
	'Unknown'
FROM customers

SELECT * FROM person;

-- change the score of customer 6 to 0
SELECT * FROM customers;

UPDATE customers 
SET score = 0
WHERE id = 6;

SELECT * FROM customers;

-- change the score of customer 10 to 0 and update the country to UK
UPDATE customers
SET 
	score = 0,
	country = 'UK'
WHERE 
	id = 10;

SELECT *
FROM customers

-- update all customers with null score by setting their score to 0
SELECT * 
FROM customers
WHERE 
	score is NULL;

UPDATE customers
SET
	score = 0
WHERE 
	score is NULL;

SELECT * 
FROM customers

-- Delete all customers with an id greater than 5
SELECT *
FROM customers
WHERE
	id > 5;

DELETE FROM customers
WHERE 
	id > 5;

SELECT * 
FROM customers;

-- Delete all data from table person
SELECT * FROM person;

DELETE FROM person;

-- or 
-- faster than DELETE commands as it only logs the page deallocation rather then logging the deletion of every single row in the transaction log
TRUNCATE TABLE person; 

SELECT * FROM person;






