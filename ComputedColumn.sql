--Total incidents happened for each incident type involving a donor older than 45
CREATE FUNCTION fn_calcIncidentperType(@PK INT)
RETURNS INT
AS
BEGIN
DECLARE @RET INT = (SELECT COUNT(IncidentID)
		    FROM Incident I
			JOIN INCIDENT_TYPE IT ON I.IncidentTypeID = IT.IncidentTypeID
			JOIN VISIT V ON I.VisitID = V.VisitID
			JOIN DONOR D ON V.VisitID = D.VisitID
		    WHERE D.DonorDOB < DATEADD(year, -45, getDATE())
			AND IT.Inc_TypeID = @PK)
RETURN @RET
END
GO
ALTER TABLE INCIDENT_TYPE
ADD Total_Incident_45 AS (dbo.fn_calcIncidentperType(Inc_TypeID))
GO

--Total visit for each donor younger than 18 who visited in the 6 months with blood type A positive
CREATE FUNCTION fn_calcyoungdonor(@PK INT)
RETURNS INT
AS
BEGIN
DECLARE @RET INT = (SELECT COUNT(VisitID)
		    FROM DONOR D
			JOIN VISIT V ON D.DonorID = V.DonorID
			JOIN BLOOD_TYPE BT ON D.BloodTypeID = BT.BloodTypeID
		    WHERE D.DonorDOB < DATEADD(year, -18, getDATE())
			AND V.VisitDate >= DATEADD(month, -6, getDATE())
			AND BT.BloodTypeName = 'A+'
			AND D.DonorID = @PK)
RETURN @RET
END
GO
ALTER TABLE DONOR
ADD Total_A_Minor AS (dbo.fn_calcyoungdonor(DonorID))



-- Total number of patients needing B negative blood for each operation type
CREATE FUNCTION fn_totOrganTransp(@PK INT)
RETURNS INT
AS
BEGIN
DECLARE @RET INT = (SELECT COUNT(PatientID)
FROM Operation O
JOIN Operation_Type OT ON O.OperationID = OT.OperationID
JOIN Patient P ON O.PatientID = P.PatientID
JOIN Blood_Type BT ON P.BloodTypeID = BT.BloodTypeID
WHERE BT.BloodTypeName = "B-"
AND OT.Operation_TypeID = @PK)
RETURN @RET
END
GO

ALTER TABLE Operation_Type
ADD Total_Organ_Transplants AS (dbo.fn_totOrganTransp(Operation_TypeID))
GO

-- Total operations performed on Patients older than 70 for each blood type
CREATE FUNCTION fn_Bloodoverseventy(@PK INT)
RETURNS INT
AS
BEGIN
DECLARE @RET INT = (SELECT COUNT(OperationID)
FROM Operation O
JOIN Patient P ON O.PatientID = P.PatientID
JOIN Blood_Type BT ON P.BloodTypeID = BT.BloodTypeID
WHERE P.PatientDOB < DATEADD(YEAR, -70, GETDATE())
AND BT.BloodTypeID = @PK)
RETURN @RET
END
GO

ALTER TABLE Blood_Type
ADD Total_Bloodover70 AS (dbo.fn_Bloodoverseventy(BloodTypeID))
GO


-- Total number of bags donated by patients older than 65 years old for each bag type
CREATE OR ALTER FUNCTION fn_SeniorBags(@PK INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT COUNT(BagID)
                            FROM BAG B
                                JOIN VISIT V ON B.VisitID = V.VisitID
                                JOIN DONOR D ON V.DonorID = D.DonorID
                                JOIN BAG_TYPE BT ON B.BagTypeID = BT.BagTypeID
                            WHERE D.DonorDOB > DATEADD(YEAR, -65, GETDATE()) AND BT.BagTypeID = @PK)
    RETURN @RET
END
GO


ALTER TABLE BAG
ADD Senior_Bags AS (dbo.fn_SeniorBags(BagTypeID))
GO

-- Total number of bags donated by patients older than 65 years old for each bag type
CREATE OR ALTER FUNCTION fn_LargeBags(@PK INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT COUNT(BagID)
                            FROM BAG B
                                JOIN MEASUREMENT M ON M.MeasurementID = B.MeasurementID
                                JOIN BAG_TYPE BT ON B.BagTypeID = BT.BagTypeID
                            WHERE M.MeasurementName = 'Large' AND BT.BagTypeID = @PK
                        )
    RETURN @RET
END
GO


ALTER TABLE BAG_TYPE
ADD Large_Bags AS (dbo.fn_LargeBags(BagTypeID))
GO


-- Write the SQL to create a computed column to track the number of Employees that are older than 60 with type Doctor in each Facility
CREATE FUNCTION fn_Calc_Num_Old_Doctors(@PK INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT COUNT(*)
                    FROM FACILITY F
			JOIN FACILITY_TYPE FT ON FT.FacilityTypeID = F.FacilityTypeID
			JOIN EMPLOYEE E ON E.FacilityID = F.FacilityID
			JOIN EMPLOYEE_TYPE ET ON ET.EmployeeTypeID = E.EmployeeTypeID
                    WHERE E.EmployeeDOB > DATEADD(YEAR,-60,GETDATE())
						AND ET.EmployeeTypeID = 'Doctor'
						AND F.FacilityID = @PK)
RETURN @RET
END
GO

ALTER TABLE tblFacility
ADD Calc_Num_Old_Doctors AS (dbo.fn_Calc_Num_Old_Doctors(FacilityID))
GO

-- Write the SQL to create a computed column to track the number of Clinics with Volunteers
CREATE FUNCTION fn_Calc_Num_facilities_Volunteers(@PK INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT COUNT(*)
                    FROM FACILITY F
			JOIN FACILITY_TYPE FT ON FT.FacilityTypeID = F.FacilityTypeID
			JOIN EMPLOYEE E ON E.FacilityID = F.FacilityID
			JOIN EMPLOYEE_TYPE ET ON ET.EmployeeTypeID = E.EmployeeTypeID
                    WHERE FT.FacilityTypeName = 'Clinic'
						AND ET.EmployeeTypeID = 'Volunteer'
						AND F.FacilityID = @PK)
RETURN @RET
END
GO

ALTER TABLE tblFacility
ADD Calc_Num_facilities_Volunteers AS (dbo.fn_Calc_Num_facilities_Volunteers(FacilityID))


