USE TSQL2012;
GO

-- INNER JOIN
-- Case: Show product name with the corresponding category name!
SELECT
	p.productid,
	p.productname,
	c.categoryname
FROM
	Production.Products AS p
		INNER JOIN Production.Categories AS c ON p.categoryid = c.categoryid;

-- INNER JOIN (more than 2 tables)
-- Case: Show product name with category name, and supplier name
SELECT
	p.productid,
	p.productname,
	c.categoryname,
	s.companyname
FROM
	Production.Products AS p
		INNER JOIN Production.Categories AS c ON p.categoryid = c.categoryid
		INNER JOIN Production.Suppliers AS s ON s.supplierid = p.supplierid;

-- OUTER JOIN
-- Case: Show categories that are existed on Product table as well as the ones 
--       that does not exist.
-- Add new sample categorie first
INSERT INTO Production.Categories (categoryname, description) VALUES
	('Jajan Pasar', 'Traditional food from Indonesia'),
	('Bumbu Dapur', 'Common ingrendients used to cook food');
-- Show the data
-- Using LEFT OUTER, all of the data in category table will be shown.
SELECT
	c.categoryid,
	c.categoryname,
	p.productname
FROM
	Production.Categories AS c
		LEFT OUTER JOIN Production.Products AS p ON p.categoryid = c.categoryid;
-- If we change LEFT to RIGHT, the the new categories will not be shown.
-- Because Products table will be the one that will show all of the data.
SELECT
	c.categoryid,
	c.categoryname,
	p.productname
FROM
	Production.Categories AS c
		RIGHT OUTER JOIN Production.Products AS p ON p.categoryid = c.categoryid;

-- CROSS JOIN
-- It will show all combination of the rows from two or more tables
-- Case: Show cross join of products and category!
SELECT 
	p.productname,
	c.categoryname
FROM
	Production.Products AS p
		CROSS JOIN Production.Categories AS c;
-- It will give the results -> N of Categories x N of Products

-- Self JOIN
-- Perform join on the same table.
-- Case: Show the employee and their respective managers!
SELECT
	emp.firstname AS empname,
	mgr.firstname AS mgrname
FROM
	HR.Employees AS emp
		INNER JOIN HR.Employees AS mgr ON emp.mgrid = mgr.empid;

-- ORDER BY
-- This is to show data in certain order based on the given column(s)
-- Case: Show the name of the products in descending order based on categoryid
--       and product name.
SELECT
	categoryid,
	productname
FROM Production.Products
ORDER BY categoryid DESC, productname DESC; -- Put DESC/ASC directive in each
                                            -- columns.

-- Filtering with WHERE
-- Case: Show only products that have categories of condiments, and beverages!
SELECT
	p.productid,
	p.productname,
	c.categoryname
FROM
	Production.Products AS p
		INNER JOIN Production.Categories AS c ON p.categoryid = c.categoryid
WHERE c.categoryname IN ('condiments', 'beverages');

-- TOP
-- To select certain number or percent of lines from a table
-- Case: Show the top 5 most expensive products!
SELECT TOP 5
	*
FROM Production.Products
ORDER BY unitprice DESC;
-- Case: Show the top 1% most expensive products!
SELECT TOP 1 PERCENT
	*
FROM Production.Products
ORDER BY unitprice DESC;

-- OFFSET-FETCH
-- To take some data from certain line number
-- OFFSET -> The data you dont want to include
-- FETCH -> How many rows you want to take
-- Case: Show the most expensive products with rank 5-10!
SELECT *
FROM Production.Products
ORDER BY unitprice DESC
OFFSET 4 ROWS FETCH NEXT 6 ROWS ONLY;
-- Compare
SELECT *
FROM Production.Products
ORDER BY unitprice DESC
