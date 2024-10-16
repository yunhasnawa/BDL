USE TSQL2012;
GO

-- Scalar function vs Aggregation function.
-- Example of a scalar function using CAST()
-- In a scalar function the input is one value, or multiple values but from
-- the same line/row.
SELECT 
	productname,
	unitprice AS [Original Unit Price],
	CAST(unitprice AS INT) AS [Casted Unit Price]
FROM Production.Products;

-- Aggregate function or 'Groupped Aggregate'
-- It ingests one or more values from different rows to become a single
-- output value
SELECT
	categoryid,
	AVG(unitprice) AS [Average Price] -- One example of aggregate function
FROM
	Production.Products
GROUP BY categoryid
ORDER BY categoryid;

--
-- Conversion functions
--
-- 1. CAST() -> to convert any data type ot another data type
-- CAST() is the simplest one among the 4 examples of conversion functions
-- Example: Convert some variables
DECLARE @NumberStr AS NVARCHAR(10) = '305.29';
DECLARE @NumberFloat AS FLOAT = CAST(@NumberStr AS FLOAT);
-- CAST is simpler compare to CONVERT, so converting the @NumberStr to INT
-- will cause error:
--DECLARE @NumberInt AS INT = CAST(@NumberStr AS INT);
SELECT
	@NumberStr,
	@NumberFloat AS NumberFloat--,
	--@NumberInt AS NumberInt;

-- 2. CONVERT() --> More powerful alternative of CAST(), it is good to use
-- it to convert date/datetime/money (non-trivial data types).
DECLARE @IndependenceDay AS NVARCHAR(10) = '19450817'; -- 101
DECLARE @Converted AS DATETIME = CONVERT(DATETIME, @IndependenceDay, 101);
SELECT @IndependenceDay, @Converted;
-- What if:
DECLARE @IndependenceDay2 AS NVARCHAR(10) = '17-08-1945'; -- 105 (Italian)
-- If we have different date format, we have to choose the suitable format code
DECLARE @Converted2 AS DATETIME = CONVERT(DATETIME, @IndependenceDay2, 105);
SELECT @IndependenceDay2, @Converted2;

-- 3. PARSE(): To sepcifically convert STRING to any other data types
DECLARE @MoneyStr AS NVARCHAR(10) = '150.000';
DECLARE @MoneyDollar AS MONEY = PARSE(@MoneyStr AS MONEY USING 'en-US');
DECLARE @MoneyPounds AS MONEY = PARSE(@MoneyStr AS MONEY USING 'en-UK');
DECLARE @MoneyRupiah AS MONEY = PARSE(@MoneyStr AS MONEY USING 'id-ID');
SELECT
	@MoneyStr AS String,
	@MoneyDollar AS USD,
	@MoneyPounds AS GBP,
	@MoneyRupiah AS IDR;

-- 4. TRY_PARSE(): Similar to PARSE but it will return NULL instead of error,
-- if the value to be converted is wrong.
DECLARE @GPAString AS NVARCHAR(10) = '3 point 5';
-- This will result in error:
--DECLARE @GPAParse AS FLOAT = PARSE(@GPAString AS FLOAT);
-- Using TRY_PARSE will not give any error.
DECLARE @GPATryParse AS FLOAT = TRY_PARSE(@GPAString AS FLOAT);
SELECT @GPATryParse;

--
-- Conversion functions
--
-- 1. IIF(): A function to give certain value whenever its predicate returns 
-- true and another value if false.
-- Example: Show 'Expensive' if a unitprice of products is more than $20, 
-- and 'Not expensive' if otherwise.
SELECT 
	productid, 
	productname, 
	unitprice,
	IIF(unitprice > 20, 'Expensive', 'Not Expensive') AS pricelevel
FROM
	Production.Products
ORDER BY unitprice;


-- 2. CHOOSE(): Select certain value based on the given index on the first param.
SELECT CHOOSE(3, 'Malang', 'Surabaya', 'Semarang');
SELECT CHOOSE(0, 'Malang', 'Surabaya', 'Semarang');
SELECT CHOOSE(4, 'Malang', 'Surabaya', 'Semarang');
-- Example (Case Study):
-- There are several employees in the company. The company wants to send all
-- of the employees to 2 different cities: (A) Malang and (B) Surabaya.
-- To be fair, all employees with odd empid will go to Malang, and the other
-- will go to Surabaya. How to show the data?
SELECT empid, firstname,
	CHOOSE((empid % 2) + 1, 'Surabaya', 'Malang') -- empid: 2 = 2 % 2 = 0 + 1 = 1
FROM HR.Employees;


--
-- NULL-checking functions
--
-- 1. COALESCE(): Returns the FIRST values that is not null
-- Example:
DECLARE @A AS NVARCHAR(10);
DECLARE @B AS NVARCHAR(10) = NULL;
DECLARE @C AS NVARCHAR(10) = '';
DECLARE @D AS NVARCHAR(10) = 'NULL';
DECLARE @E AS NVARCHAR(10) = 0;
SELECT COALESCE(@A, @B, @C, @D, @E);

-- 2. ISNULL(): Returns 1st param if it is not NULL, and 2nd param otherwise.
-- EXAMPLE:
SELECT 
	empid, 
	firstname,
	ISNULL(region, 'UNKNOWN') AS region
FROM HR.Employees;

--
-- String functions
--
-- 1. LEN(): To calculate the number of characters within a string.
-- Example: Show the length of each employee fullname!
SELECT
	CONCAT(firstname, ' ', lastname) AS fullname,
	LEN(CONCAT(firstname, ' ', lastname)) AS [length]
FROM HR.Employees;

-- 2. REPLACE(): This is to replace certain string in a string, with other char/
-- string.
-- Example: Change all occurences of 'Ship to' to 'Destination' to make values
-- in shipname column more uniform.
SELECT
	orderid,
	shipname AS [original],
	REPLACE(shipname, 'Ship to', 'Destination') AS [replaced]
FROM Sales.Orders;