-- Functions Part 1
/*
Built-in sql code that 
- accepts an input value
- processes it 
- returns an output value


Types
1. Single Row function 
2. Multi Row Functions

Functions can be nested 
LEN(LOWER(LEFT('Maria', 4)))

Single Row Function Types
1. String fn
2. Numeric fn
3. Date & Time fn
4. Null fn

Multi-Row Function Types
1. Aggregate
2. Window


String Functions 
Types 
1. Manipulation
	- CONCAT
	- UPPER
	- LOWER
	- TRIM
	- REPLACE
2. Calculation : LEN
3. String Extraction:
	- Left
	- Right
	- SUBSTRING
*/


-- Use Database
USE MyDatabase;

-- Row Level Functions
-- String Functions
-- Manipulation
-- 1. Concat
-- combine customers first name with their country in one column
SELECT * FROM customers;

SELECT 
	CONCAT(first_name, '-', country)
FROM customers;

-- 2. LOWER & UPPER Functions
-- transform the customer's first name to lower case and country to upper case
SELECT 
	LOWER(first_name),
	UPPER(country)
FROM customers;

-- 3. TRIM
-- Removes the leading and trailing spaces

-- find customers whoes first name contains trailing / leading spaces
SELECT 
	first_name,
	LEN(first_name) AS len_name
FROM customers;

SELECT 
	first_name
FROM customers
WHERE
	TRIM(first_name) != first_name;

SELECT 
	first_name,
	LEN(first_name) as len_name,
	LEN(TRIM(first_name)) as len_trim_name,
	LEN(first_name) - LEN(TRIM(first_name)) as flag
FROM customers
WHERE LEN(first_name) != LEN(TRIM(first_name));

-- 4. REPLACE
-- Remove dashes from a phone number
SELECT
	'123-456-9087' as phone,
	REPLACE('123-456-9087', '-','') AS clean_phone;

-- replace .txt extension with .csv
SELECT 
	'file.txt' as file_name,
	REPLACE('file.txt', '.txt', '.csv');

-- Calculation
-- 1. LEN
-- 1 based indexing 

-- Calculate the len of each customers's first name
SELECT
	first_name,
	LEN(first_name) as len_name
FROM customers;


-- String Extraction
-- 1. LEFT
-- retrieve the first two characters of each first name
SELECT 
	first_name,
	LEFT(first_name, 2) as left_2_name,
	LEFT(TRIM(first_name), 2) as left_trim_2_name
FROM customers;

-- 2. RIGHT
-- retrieve last 2 characters of first_name
SELECT 
	first_name,
	RIGHT(first_name, 2) as right_2_name
FROM customers;


-- SUBSTRING
-- retrieve customers first_name after removing first character
SELECT
	first_name,
	SUBSTRING(first_name, 2, LEN(first_name)-1) as substring_name,
	SUBSTRING(TRIM(first_name), 2, LEN(TRIM(first_name))-1) as substring_trim_name
FROM customers;


-- Number Functions
-- 1. Round
SELECT 
	3.516 AS num,
	ROUND(3.516, 2) as precision_2,
	ROUND(3.516, 1) as precision_1,
	ROUND(3.516, 0) as precision_0
;

SELECT 
	3.506 AS num,
	ROUND(3.506, 2) as precision_2,
	ROUND(3.506, 1) as precision_1,
	ROUND(3.506, 0) as precision_0
;

-- 2. ABS Abssolute
SELECT 
-10 as num,
ABS(-10) as absolute_num
