USE TSQL2012;
GO

-- Window Function Example: Running Totals
-- Example: We want to show the running totals of sales quantity year by year
--          based on certain products' category.

-- Check the data
SELECT * FROM Sales.Orders;          -- Year
SELECT * FROM Sales.OrderDetails;    -- Qty
SELECT * FROM Production.Products;   -- Category ID
SELECT * FROM Production.Categories; -- Category Name (It needs Category ID)
GO

-- Join the data and make it as a view
CREATE VIEW Sales.DailyQtyOrders AS
SELECT
	o.orderdate, od.qty, c.categoryname, YEAR(o.orderdate) AS orderyear
FROM Sales.Orders AS o
	INNER JOIN Sales.OrderDetails AS od ON od.orderid = o.orderid
	INNER JOIN Production.Products AS p ON p.productid = od.productid
	INNER JOIN Production.Categories AS c ON c.categoryid = p.categoryid;
Go

-- Test the view
SELECT * FROM Sales.DailyQtyOrders;
GO

-- Summarize the sales of each category in every whole year.
-- Make it a view
CREATE VIEW Sales.CategoryQtyYears AS
SELECT
	categoryname,
	orderyear,
	SUM(qty) AS totalqty
FROM
	Sales.DailyQtyOrders
GROUP BY categoryname, orderyear
-- ORDER BY categoryname, orderyear;
GO

SELECT * FROM Sales.CategoryQtyYears ORDER BY categoryname, orderyear;

-- WINDOW Function usage!
SELECT *,
	SUM(totalqty) OVER (PARTITION BY categoryname) AS runnigtotal_wrong, -- Without Order By
	SUM(totalqty) OVER (PARTITION BY categoryname ORDER BY orderyear) AS runnigtotal_correct
FROM Sales.CategoryQtyYears;

-- Window function: Moving Average
SELECT *,
	SUM(totalqty) OVER (PARTITION BY categoryname) AS runnigtotal_wrong, -- Without Order By
	SUM(totalqty) OVER (PARTITION BY categoryname ORDER BY orderyear) AS runnigtotal_correct,
	AVG(totalqty) OVER (PARTITION BY categoryname ORDER BY orderyear) AS movingaverage
FROM Sales.CategoryQtyYears;

-- Window function for ranking orders
-- Example: We want to rank the data based on the highest qty in each category, 
--          so we can understand in which year the sales are highest and lowest in the category
SELECT *,
	SUM(totalqty) OVER (PARTITION BY categoryname) AS runnigtotal_wrong, -- Without Order By
	SUM(totalqty) OVER (PARTITION BY categoryname ORDER BY orderyear) AS runnigtotal_correct,
	AVG(totalqty) OVER (PARTITION BY categoryname ORDER BY orderyear) AS movingaverage,
	RANK() OVER (PARTITION BY categoryname ORDER BY totalqty DESC) AS salesrank, -- Ranked by category
	RANK() OVER (ORDER BY totalqty DESC) AS salesrank -- No partition, ranked as whole
FROM Sales.CategoryQtyYears;
GO

-- Case study: Daily revenue from entire sales
-- Make it view first
CREATE VIEW Sales.DailyRevenue AS
SELECT
	o.orderdate,
	SUM((od.qty * od.unitprice) * (1 - od.discount)) AS revenue
FROM
	Sales.Orders AS o
		INNER JOIN Sales.OrderDetails AS od ON od.orderid = o.orderid
GROUP BY (o.orderdate);

-- --------------
-- Practice Task:
-- --------------
-- 1. Display the running total for daily revenue in May 2007 only.
-- 2. Display the moving average from question number 1.
-- 3. Display the running total for MONTHLY revenue in 2007 only.
-- 4. Display the ranking of products from the most expensive to the least expensive.

-- * Write the queries, take a screenshot of the results, place them in a Word file,
--   convert it to PDF, and submit!
-- * I will provide the submission link to the class representative.

