-- Donor can't be younger than 18 cannot donate at facility named 'Seattle Heart Center'
CREATE FUNCTION no18inclinic
RETURNS INT
AS
BEGIN

DECLARE @RET INT = 0

IF
EXISTS (SELECT *
	FROM DONOR D
		JOIN VISIT V ON D.DonorID = V.DonorID
		JOIN FACILITY F ON V.FacilityID = F.FacilityID
	WHERE DonorDOB > DATEADD(year, -18, getDATE()
 		AND F.FacilityName = 'Seattle Heart Center')
	BEGIN
		SET @RET = 1
	END
RETURN @RET
END
GO

ALTER TABLE(VISIT)
ADD CONSTRAINT(checkageinclinic)
CHECK(dbo.no18inclinic() = 0)
GO

-- Donor with the blood type o can only donate at facility named 'clinic' and after January1st, 2021
CREATE FUNCTION fn_oclinic2021
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0

IF
EXISTS (SELECT *
	FROM DONOR D
		JOIN VISIT V ON D.DonorID = V.DonorID
		JOIN Facility F ON V.FacilityID = F.FaciltyID
		JOIN BLOOD_TYPE BT ON D.BloodTypeID = BT.BloodTypeID
	WHERE F.FacilityName != 'clinic'
		AND Blood_Type = 'o'
		AND V.VisitDate > '2021-01-01')
	BEGIN
		SET @RET = 1
	END
RETURN @RET
END
GO
ALTER TABLE(VISIT)
ADD CONSTRAINT(checkovisit)
CHECK(dbo.fn_oclinic2021() = 0)

-- No operations of type 'blood transfusions' can be performed on patients older than 80 with blood type AB+
CREATE FUNCTION fn_noBloodTransf()
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0
IF EXISTS (SELECT *
FROM Patient P
JOIN Operation O ON P.PatientID = O.PatientID
JOIN Operation_Type OT ON O.Operation_TypeID = OT.Operation_TypeID
JOIN Blood_Type BT ON P.BloodTypeID = BT.BloodTypeID
WHERE OT.OperTypeName = 'Blood Transfusion'
AND P.PatientDOB < DATEADD(YEAR, -80, GETDATE())
AND BT.BloodTypeName = 'AB+')
SET @RET = 1
RETURN @RET
END
GO

ALTER TABLE Operation
ADD CONSTRAINT CK_fn_noBloodTransf
CHECK(dbo.fn_noBloodTransf() = 0)
GO

-- no operations of type 'surgery' can take place in 'dialysis center' facilities
CREATE FUNCTION fn_noSurgery()
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0
IF EXISTS (SELECT *
FROM Operation O
JOIN Operation_Type OT ON O.Operation_TypeID = OT.Operation_TypeID
JOIN Facility F ON O.FacilityID = F.FacilityID
JOIN Facility_Type FT ON F.Facility_TypeID = FT.Facility_TypeID
WHERE OT.OperTypeName = 'Surgery'
AND FT.FacilityTypeName = 'Dialysis Center')
SET @RET = 1
RETURN @RET
END
GO

ALTER TABLE Operation
ADD CONSTRAINT CK_fn_noSurgery
CHECK(dbo.fn_noSurgery() = 0)
GO

-- no bag from the Pop-up @ Central District can be inputted with a quantity greater than 100
CREATE OR ALTER FUNCTION fn_noBagMoreThan100()
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0
IF EXISTS (SELECT * FROM BAG B
                        JOIN  BAG_TYPE BT ON B.BagTypeID = BT.BagTypeID
				JOIN VISIT V ON B.VisitID = V.VisitID
				JOIN FACILITY F ON V.FacilityId = F.FacilityID
                   WHERE BT.Quantity > 100
AND F.FacilityName = ‘Pop-up @ Central District’)
SET @RET = 1
RETURN @RET
END
GO


ALTER TABLE BAG ADD CONSTRAINT CK_maxQuantity CHECK (dbo.fn_noBagMoreThan100() = 0)
GO


-- no small bags can have more than 10 pints of blood
CREATE OR ALTER FUNCTION fn_noSmallOver10()
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0
IF
    EXISTS (SELECT * FROM BAG B
                    JOIN BAG_TYPE BT ON B.BagTypeID = BT.BagTypeID
                    JOIN MEASUREMENT M ON BT.MeasurementID = M.MeasurementID
                    WHERE BagTypeName = 'Small' AND QUANTITY > 10)
    SET @RET = 1
RETURN @RET
END
GO


ALTER TABLE BAG ADD CONSTRAINT CK_noSmallOver10 CHECK (dbo.fn_noSmallOver10() = 0)
GO

-- No employee with the first name Greg and employee type Volunteer can work in a Facility type Hospital
CREATE FUNCTION fn_No_Volunteers_Greg_Hospital()
 RETURNS INT
 AS
 BEGIN
      DECLARE @RET INT = 0
      IF EXISTS (SELECT *
                 FROM EMPLOYEE E
                    JOIN EMPLOYEE_TYPE ET ON ET.EmployeeTypeID = E.EmployeeTypeID
			JOIN FACILITY F ON F.FacilityID = E.FacilityID
			JOIN FACILITY_TYPE FT ON FT.FacilityTypeID = F.FacilityTypeID
                    WHERE E.EmployeeFname = 'Greg'
				AND ET.EmployeeTypeName = 'Volunteer'
				AND FT.FacilityTypeName = 'Hospital'
                            )
     SET @RET =1
 RETURN @RET
 END
 GO

 ALTER TABLE tblEmployee
 ADD CONSTRAINT CK_NoGregVolunteersHospital
 CHECK (dbo.fn_No_Volunteers_Greg_Hospital() = 0)
 GO

-- No Facility can have an Employee named Nate with type Doctor and is younger than 21 work there.
CREATE FUNCTION fn_No_Employee_Nate_Doctor_21()
 RETURNS INT
 AS
 BEGIN
      DECLARE @RET INT = 0
      IF EXISTS (SELECT *
                 FROM FACILITY F
			JOIN FACILITY_TYPE FT ON FT.FacilityTypeID = F.FacilityTypeID
			JOIN EMPLOYEE E ON E.FacilityID = F.FacilityID
			JOIN EMPLOYEE_TYPE ET ON ET.EmployeeTypeID = E.EmployeeTypeID
                    WHERE E.EmployeeFname = 'Nate'
				AND ET.EmployeeTypeName = 'Doctor'
				AND E.EmployeeDOB > (DATEADD(YEAR, -21, GETDATE()))

     SET @RET =1
 RETURN @RET
 END
 GO

 ALTER TABLE tblFacility
 ADD CONSTRAINT CK_NoDoctorNate21
 CHECK (dbo.fn_No_Employee_Nate_Doctor_21() = 0)
 GO

