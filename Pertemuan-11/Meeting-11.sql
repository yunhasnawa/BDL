USE TSQL2012;
GO

-- -----
-- PIVOT
-- -----
-- This feature is used to change the representation of a SELECT result from row-based
-- into the column one.
-- Or in the other words, to create a summary, or 'rekap' (in Indonesian)
-- To use PIVOT first we have to make our SELECT statement to become a Derived Table
-- It is needed because PIVOT operator processes SELECT results behind the FROM clause.

-- First, we need to create a View containing sample data to be pivoted
-- We have to create a PIVOT, using Derived Table. If not, then it will be error
-- Below syntax is wrong:
SELECT categoryname, qty, orderyear FROM Sales.CategoryOrderYear -- No DT
PIVOT(
	SUM(qty)                   -- [Element-1] Aggregation,
	FOR orderyear              -- [Element-2] Groupping,
	IN([2006], [2007], [2008]) -- [Element-3] Spreading
) AS pvt;

-- With Derived Table
SELECT * FROM (SELECT categoryname, qty, orderyear FROM Sales.CategoryOrderYear) AS dt
PIVOT(
	SUM(dt.qty)                            -- [Element-1] Aggregation,
	FOR orderyear                          -- [Element-2] Groupping,
	IN([2006], [2007], [2008]/*, [2024]*/) -- [Element-3] Spreading, 2024 will be NULL
) AS pvt;


-- -------
-- UNPIVOT
-- -------
-- Is the opposite of PIVOT. It changes the data that is represented in columnar form
-- into row-based.
-- But remember, it cannot always turn the pivoted data to 100% equal as before.
-- Because SQL Server does not know how to break down the data before it is aggregated.
-- Important note: UNPIVOT should be useful only if we have data that naturally in the
--                 form of PIVOTed ones.

-- Example of UNPIVOT:
-- Because we pivoted data does not exist in our TSQL2012 database,
-- So let us create one, by making the previous PIVOT result into a VIEW.
-- But remember! This is just for a simulation purposes.
GO
CREATE VIEW Sales.YearlyQtyRecap AS
SELECT * FROM (SELECT categoryname, qty, orderyear FROM Sales.CategoryOrderYear) AS dt
PIVOT(
	SUM(dt.qty)                            -- [Element-1] Aggregation,
	FOR orderyear                          -- [Element-2] Groupping,
	IN([2006], [2007], [2008]/*, [2024]*/) -- [Element-3] Spreading, 2024 will be NULL
) AS pvt;

-- Check the data
SELECT * FROM Sales.YearlyQtyRecap;

-- Now, let's display the data in the form of unpivoted format.
SELECT 
	categoryname AS category,
	orderyear,		-- At first, this does not exist
	qty             -- This one also
FROM
	Sales.YearlyQtyRecap
UNPIVOT (
	qty
	FOR orderyear
	IN ([2006], [2007], [2008])
) AS unpvt;


-- -------------
-- GROUPING SETS
-- -------------
-- Is a feature that we can use as a 'shortcut' if we want to show the results of
-- aggregations grupped by different columns into a single result.
-- Example: Displaying the aggregation details from the column CategoryName and OrderYear
--          in Sales.CategoryOrderYear VIEW.

-- Originally, if we dont use GROUPPING SETS, we have to type the following lines
-- of SQL:

SELECT
	categoryname,
	orderyear,
	SUM(qty) AS total
FROM 
	Sales.CategoryOrderYear
GROUP BY
	categoryname,
	orderyear
-- ORDER BY 
	-- categoryname, orderyear

UNION ALL  -- Yang categoryname saja

SELECT
	categoryname,
	NULL AS  orderyear,
	SUM(qty) AS total
FROM 
	Sales.CategoryOrderYear
GROUP BY
	categoryname
-- ORDER BY 
	-- categoryname, orderyear

UNION ALL

SELECT
	NULL AS categoryname,
	orderyear,
	SUM(qty) AS total
FROM 
	Sales.CategoryOrderYear
GROUP BY
	orderyear
-- ORDER BY 
	-- categoryname, orderyear

UNION ALL  -- SEMUANYAAAAA

SELECT
	NULL AS categoryname,
	NULL AS orderyear,
	SUM(qty) AS total
FROM 
	Sales.CategoryOrderYear
ORDER BY 
	categoryname, orderyear;


-- Now, with GROUPING SETS we just need a (lot) less lines.
SELECT
	categoryname,
	orderyear,
	SUM(qty) AS total
FROM 
	Sales.CategoryOrderYear
GROUP BY
	GROUPING SETS(
		(categoryname, orderyear),
		categoryname,
		orderyear
	)
ORDER BY categoryname, orderyear;