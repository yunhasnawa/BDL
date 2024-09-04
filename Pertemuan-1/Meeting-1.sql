-- Try to create our own database
-- Use bacth separator (Go) to make sure CREATE finishes first
CREATE DATABASE TestTI2I;
go -- batch 1

USE TestTI2I;
go -- batch 2

-- Database context.
-- Change database context by using USE statement;
-- Or by selecting from top-left corner combo-box
SELECT * FROM HR.Employees;

-- Predicates and Operator
-- Example of one pridicate (IN)
-- Show orders data from certain City
SELECT * FROM Sales.Orders 
WHERE shipcity IN ('Lyon', 'Rio de Janeiro'); -- This is predicate

-- Operator
-- Operator is something between 2 words and/or value.
-- When it is evaluated, it will returns another value.
-- Example of operator * and -
-- Show the total price from each item in Sales.OrderDeatils
-- TP = UP * Qty * (1 - discount)
SELECT 
	*,
	unitprice * qty * (1 - discount) AS totalprice
FROM Sales.OrderDetails;

-- Concatenation Operator
-- This is to combine 2 or more strings
-- By using plus (+) sign.
-- Example:
-- Show full name of the employees!
SELECT 
	*,
	(titleofcourtesy + ' ' + firstname + ' ' + lastname ) AS fullname
FROM HR.Employees;


-- Function
-- It is somthing that processes input to become output.
-- It is marked with () at its end.
-- Several examples of function:

-- String function to take certain number of chars from the right side.
-- Case: Show only the customers that are managers!
SELECT * FROM Sales.Customers
WHERE RIGHT(contacttitle, 7) = 'Manager'; -- Built-in function RIGHT()
-- We can also show the result:
SELECT RIGHT(contacttitle, 7) AS  manager FROM Sales.Customers;

-- Another example of function (Date function)
-- To get current system time
SELECT SYSDATETIME() AS currenttime;

-- Another example of function, the SUM() aggregation function
-- Example Case: Count the total number of ALL sold items!
SELECT SUM(qty) AS TotalSold FROM Sales.OrderDetails;

-- Variables: Something that we can use to store temporary value
-- Declaring variable:
DECLARE @Year AS INT = 2007;
-- Showing the value of a variable:
SELECT @Year;
-- We can also use variable in a SELECT statement.
-- Example case: Show the orders data based on the year in variable!
SELECT * FROM Sales.Orders
WHERE YEAR(shippeddate) = @Year;

-- Control of Flow
-- Is a kind of T-SQL elements that allows us to use it like programming
-- languages (declarative)
-- Example: BEGIN..END
-- Example case: Create a function to count total weight of sales based
-- on certain given year.
CREATE FUNCTION CalculateTotalFreight(@Year INT) RETURNS FLOAT AS
BEGIN
	DECLARE @Total AS FLOAT;
	SELECT @Total = SUM(freight) FROM Sales.Orders WHERE YEAR(shippeddate) = @Year;
	RETURN @Total;
END

-- Use the function
SELECT dbo.CalculateTotalFreight(2006);
-- Another way to use function
SELECT
	dbo.CalculateTotalFreight(2006) AS Total2006,
	dbo.CalculateTotalFreight(2007) AS Total2007;

-- CASE: This is like branching but it is used as an expression
--       in a SELECT statement.
-- CASE is not a type of control flow
-- Example:
-- Show the category name of products based on the category id.
SELECT 
	*,
	CASE categoryid
		WHEN 1 THEN 'Food'
		WHEN 2 THEN 'Medicine'
		WHEN 3 THEN 'Drinks'
		ELSE 'Unknown Category'
	END
	AS CategoryName
FROM Production.Products;






















