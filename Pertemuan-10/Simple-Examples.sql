-- VIEW
CREATE VIEW HR.EmployeesNoRegion AS
SELECT * FROM HR.Employees WHERE region is NULL;

-- Panggil
SELECT * FROM HR.EmployeesNoRegion;

-- Filter
SELECT * FROM HR.EmployeesNoRegion WHERE empid = 5;

-- INSERT
INSERT INTO HR.EmployeesNoRegion 
	(lastname, firstname) VALUES ('Tes', 'Coba');

GO

-- TVF
CREATE FUNCTION HR.fn_EmployeesNoRegion (@empid AS INT)
RETURNS TABLE -- ada 's'-nya
AS
RETURN 
	SELECT * FROM HR.EmployeesNoRegion WHERE empid = @empid;

GO

GO


-- DT 
SELECT empid, firstname FROM 
(
	SELECT * FROM HR.Employees WHERE region is NULL
) AS dt_employeesNoRegion;


-- CTE
WITH cte_employeesNoRegion AS (
	SELECT * FROM HR.Employees WHERE region is NULL)
SELECT empid, firstname FROM cte_employeesNoRegion;




SELECT * FROM dt_employeesNoRegion;
SELECT * FROM cte_employeesNoRegion;

GO