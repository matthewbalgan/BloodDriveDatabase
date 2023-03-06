--Create view to find donors born prior to 1999 with the blood type o positive have donated more than 5 blood bags as bag count and the donors that are older than 55 who have experienced incident type 'fainted' at least once during the year 2022

CREATE VIEW vw_joindonor
AS
SELECT D.DonorID, COUNT(BG.BagID) AS BagCount, FaintedCount
FROM DONOR D
	JOIN BLOOD_TYPE BT ON D.BloodTypeID = BT.BloodTypeID
	JOIN VISIT V ON D.DonorID = V.DonorID
	JOIN BAG BG ON V.VisitID = BG.VisitID
	JOIN (SELECT D.DonorID, COUNT(IT.Inc_TypeID) AS FaintedCount
	           FROM DONOR D
		JOIN VISIT V ON D.DonorID = V.DonorID
		JOIN INCIDENT I ON V.IncidentID = I.IncidentID
		JOIN INCIDENT_TYPE IT ON I.Inc_TypeID = IT.Inc_TypeID
	          WHERE D.DonorDOB < DATEADD(year, -55, getdate())
		AND year(V.VisitDate) = 2022
		AND IT.IncTypeName = "Fainted"
	         GROUP BY D.DonorID
		HAVING COUNT(IT.Inc_TypeID) > = 1) AS subq1 ON D.DonorID = subq1.DonorID
WHERE BT.BloodTypeName = 'O+'
	AND year(D.DonorDOB) < 1999
GROUP BY D.DonorID
HAVING COUNT(BG.BagID) > 5

--Create view to find the donor with last name starting with letter 'A' who has visited at last 2 times during 2019 and find donors who visit 'clinic' at least 5 times after December 31st, 1999 that experienced a nerve damage incident type

CREATE VIEW vw_joindonor2
AS
SELECT D.DonorID, COUNT(V.VisitID) AS count2019Visit, countClinic
FROM DONOR D
	JOIN VISIT V ON D.DonorID = V.DonorID
	JOIN (SELECT D.DonorID, COUNT(V.VisitID) AS countClinic
	           FROM DONOR D
		JOIN VISIT V ON D.DonorID = V.DonorID
		JOIN FACILITY F ON V.FacilityID = F.FacilityID
		JOIN INCIDENT I ON V.IncidentID = I.IncidentID
		JOIN INCIDENT_TYPE IT ON I.Inc_TypeID = IT.Inc_TypeID
	           WHERE F.FacilityName = 'Clinic'
		AND V.VisitDate > 'December 31st, 1999'
		AND IT.IncTypeName = 'Nerve Damage'
	         GROUP BY D.DonorID
	         HAVING COUNT(V.VisitID) >= 5) subq1 ON D.DonorID = subq1.DonorID
WHERE year(V.VisitDate) = 2019
	AND D.DonorLname LIKE 'A%'
GROUP BY D.DonorID
HAVING COUNT(V.VisitID) >= 2

--Create view for donors that meet the following:
--1. Donated at least 3 pints of 'Oneg' blood in the last 3 years
--2. Made at least 5 visits to the 'Seattle Heart Center' in the past 5 years
--3. Had less than 2 incidents of 'fainting'(incid_type) in the past year

CREATE VIEW vw_bloodydonors
AS
SELECT D.DonorID, D.DonorFname, D.DonorLname, D.DonorDOB, SHCvisits, fainting, COUNT(B.BagID) as Obags
FROM Donor D
JOIN Visit V ON D.DonorID = V.DonorID
JOIN Bag B ON V.VisitID = B.VisitID
JOIN Measurement M ON B.MeasurementID = M.MeasurementID
JOIN Blood_Type BT ON D.BloodTypeID = BT.BloodTypeID

JOIN (SELECT D.DonorID, COUNT(V.VisitID) AS SHCvisits
FROM Donor D
JOIN Visit V ON D.DonorID = V.DonorID
JOIN Facility F ON V.FacilityID = F.FacilityID
WHERE F.FacilityName = 'Seattle Heart Center'
AND V.VisitDate > DATEADD(YEAR, -5, GETDATE())
GROUP BY D.DonorID
HAVING COUNT(V.VisitID) >= 5)AS subq1 ON D.DonorID = subq1.DonorID

JOIN (SELECT D.DonorID, COUNT(I.IncidentID) AS fainting
FROM Donor D
JOIN Visit V ON D.DonorID = V.DonorID
JOIN Incident I ON V.VisitID = I.VisitID JOIN Incident_Type IT ON I.IncidentTypeID = IT.IncidentTypeID
WHERE IT.IncidentTypeName = 'fainting'
AND V.VisitDate > DATEADD(YEAR, -1, GETDATE()) GROUP BY D.DonorID
HAVING COUNT(I.IncidentID) < 2)AS subq2 ON D.DonorID = subq2.DonorID

WHERE M.MeasurementName = 'Pint'
AND BT.BloodTypeName = 'O-'
GROUP BY D.DonorID, D.DonorFname, D.DonorLname, D.DonorDOB, SHCvisits, fainting
HAVING COUNT(B.BagID) >= 3
-- Create view for the top facility with the most operations that have also had:
-- At least 10 patients over 60 that have come in for 'Cancer Treatment' Operations in the past 2 months
-- More than 6 patients that have come in for 'Medical emergencies' needing any kind of O Blood
-- Has at least 10 nurses specializing in 'Urgent Care'
CREATE VIEW vw_facility
AS
SELECT TOP 1 F.FacilityID, F.FacilityName, MedEmer, nurseUrgentCare, cancerpatients, COUNT(O.OperationID) AS numOper
FROM Facility F
JOIN Visit V ON V.FacilityID = F.FacilityID
JOIN Operation O ON O.FacilityID = F.FacilityID

JOIN (SELECT F.FacilityID, FacilityName, COUNT(P.PatientID) AS cancerpatients
FROM Facility F JOIN Visit V ON V.FacilityID = F.FacilityID
JOIN Operation O ON O.FacilityID = F.FacilityID
JOIN Patient P ON O.PatientID = P.PatientID
JOIN Operation_Type OT ON O.Operation_TypeID = OT.Operation_TypeID
WHERE OT.OperTypeName = 'Cancer Treatment'
AND P.PatientBirth < DATEADD(YEAR, -60, GETDATE())
AND V.VisitDate > DATEADD(MONTH, -2, GETDATE())
GROUP BY F.FacilityID, F.FacilityName
HAVING COUNT(P.PatientID) >= 10) AS subq1 ON F.FacilityID = subq1.FacilityID

JOIN(SELECT F.FacilityID, COUNT(P.PatientID) AS MedEmer
FROM Facility F
JOIN Operation O ON O.FacilityID = F.FacilityID
JOIN Patient P ON O.PatientID = P.PatientID
JOIN Operation_Type OT ON O.Operation_TypeID = OT.Operation_TypeID
JOIN Blood_Type BT ON P.BloodTypeID = BT.BloodTypeID
WHERE OT.OperTypeName = 'Medical Emergency'
AND BT.BloodTypeName LIKE 'O%'
GROUP BY F.FacilityID
HAVING COUNT(P.PatientID) > 6) AS subq2 ON F.FacilityID = subq2.FacilityID

JOIN(SELECT F.FacilityID, COUNT(E.EmployeeID) AS nurseUrgentCare
FROM Facility F
JOIN Employee E ON F.FacilityID = F.FacilityID
JOIN Employee_Type ET ON E.EmployeeTypeID = ET. EmployeeTypeID
WHERE ET.EmployeeTypeName = 'Nurse' AND ET.EmployeeTypeDesc = 'Urgent Care'
GROUP BY F.FacilityID
HAVING COUNT(E.EmployeeID) >= 10) AS subq3 ON F.FacilityID = subq3.FacilityID
GROUP BY F.FacilityID, F.FacilityName, MedEmer, nurseUrgentCare, cancerpatients
ORDER BY COUNT(O.OperationID) DESC
GO
Create view to find bags that start with B and have a quantity that is between 30 and 50 that were donated before January 1 1998
CREATE VIEW vw_joinbag1
AS
SELECT B.BagID, Count(B.BagID) as BagCount
FROM BAG B
    JOIN BAG_TYPE BT ON B.BagTypeID = BT.BagTypeID
WHERE B.BagName LIKE '%B' AND BT.Quantity BETWEEN 30 AND 50
GROUP BY B.BagID
GO


-- Create view to find bags of bag_type 'small' that were donated by donors between 20 and 30 years old


CREATE OR ALTER VIEW vw_smallbags
AS
SELECT B.BagID, Count(B.BagID) as BagCount
FROM BAG B
    JOIN BAG_TYPE BT ON B.BagTypeID = BT.BagTypeID
    JOIN VISIT V ON B.VisitID = V.VisitID
    JOIN DONOR D ON V.DonorID = D.DonorID
WHERE BT.BagTypeName LIKE 'small'
    AND DonorDOB BETWEEN DATEADD(year, -30, getDATE()) AND DATEADD(year, -20, getDATE())
GROUP BY B.BagID
GO
-- Create a view of the employees that are involved with any visit with the incident type Fainted in a clinic in the past 10 years.
CREATE VIEW FaintedEmployeeIncident
AS
SELECT E.EmployeeID, E.EmployeeFname, E.EmployeeLname, COUNT(E.EmployeeID) AS NumEmp
FROM EMPLOYEE E
	JOIN EMPLOYEE_TYPE ET ON ET.EmployeeTypeID = E.EmployeeTypeID
	JOIN FACILITY F ON F.FacilityID = E.FacilityID
	JOIN FACILITY_TYPE FT ON FT.FacilityTypeID = F.FacilityTypeID
	JOIN VISIT V ON V.FacilityID = F.FacilityID
	JOIN INCIDENT I ON I.VisitID = V.VisitID
	JOIN INCIDENT_TYPE IT ON IT.IncidentTypeID = I.IncidentTypeID
WHERE FT.FacilityTypeName = 'Clinic'
	AND IT.IncidentTypeName = 'Fainted'
	AND YEAR(V.VisitDate) > 2002
GROUP BY E.EmployeeID, E.EmployeeFname, E.EmployeeLname
HAVING COUNT(E.EmployeeID) > 1
GO
-- Find all Donors with O+ blood that has had a visit with a Doctor in a clinic and they visited within the last year.
CREATE VIEW donorbloodDoctorlastyear
AS
SELECT D.DonorID, D.DonorFname, D.DonorLname
FROM EMPLOYEE E
	JOIN EMPLOYEE_TYPE ET ON ET.EmployeeTypeID = E.EmployeeTypeID
	JOIN FACILITY F ON F.FacilityID = E.FacilityID
	JOIN FACILITY_TYPE FT ON FT.FacilityTypeID = F.FacilityTypeID
	JOIN VISIT V ON V.FacilityID = F.FacilityID
	JOIN DONOR D ON D.DonorID = V.DonorID
	JOIN BLOOD_TYPE BT ON BT.BloodTypeID = D.BloodTypeID
WHERE FT.FacilityTypeName = 'Clinic'
	AND ET.EmployeeTypeName = 'Doctor'
	AND BT.BloodTypeName = 'O+'
	AND YEAR(V.VisitDate) > 2021
GROUP BY D.DonorID, D.DonorFname, D.DonorLname







