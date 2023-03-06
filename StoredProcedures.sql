CREATE OR ALTER PROCEDURE getFacilityID
@FacilityName varchar(99),
@FacilityID INT output
AS
SET @FacilityID = (SELECT FacilityID FROM FACILITY WHERE FacilityName = @FacilityName)
GO

CREATE PROCEDURE getDonorID
@Fname varchar(50),
@Lname varchar(50),
@DOB DATE,
@DonorID INT OUTPUT

AS
SET @DonorID = (SELECT DonorID FROM DONOR WHERE DonorFname = @Fname
AND DonorLname = @Lname AND DonorDOB = @DOB)
GO

CREATE PROCEDURE getVisitID
@Firsty varchar(50),
@Lasty varchar(50),
@Birth DATE,
@Facility varchar(50),
@Vist DATE,
@VisitID INT OUTPUT
AS
DECLARE @D_ID INT, @F_ID INT

EXEC getFacilityID
@FacilityName = @Facility
@FacilityID = @F_ID OUTPUT
IF @F_ID IS NULL
    BEGIN
        THROW 15561, "FacilityID is null", 1;
    END

EXEC getDonorID
@Fname = @Firsty,
@Lname = @Lasty,
@DOB = @Birth,
@DonorID = @D_ID OUTPUT
IF @D_ID IS NULL
    BEGIN
        THROW 15562, "DonorID is null", 1;
    END

SET @VisitID = (SELECT VisitID FROM VISIT WHERE FacilitytID = @F_ID
						AND DonorID = @D_ID
						AND VisitDate = @Visit)

Insert a New Visit
CREATE PROCEDURE insert_Visit
@Facility varchar(99),
@Firsty varchar(50),
@Lasty varchar(50),
@Birthy DATE,
@Visit DATE
AS
DECLARE @F_ID INT, @D_ID INT

EXEC getFacilityID
@FacilityName = @Facility,
@FacilityID = @F_ID OUTPUT
IF @F_ID IS NULL
    BEGIN
        THROW 15561, "FacilityID is null", 1;
    END

EXEC getDonorID
@Fname = @Firsty,
@Lname = @Lasty,
@DOB = @Birthy,
@DonorID = @D_ID OUTPUT
IF @D_ID IS NULL
    BEGIN
        THROW 15562, "DonorID is null", 1;
    END

BEGIN TRAN T1
INSERT INTO VISIT(FacilityID, DonorID, VisitDate)
VALUES (@F_ID, @D_ID @Visit)

IF @@ERROR <>0 OR @@TRANCOUNT <> 1
    BEGIN
        PRINT 'Something failed RIP'
        ROLLBACK TRANSACTION T1
    END
ELSE
    COMMIT TRANSACTION T1

GO

Insert a New Incident with a new Incident Type
CREATE PROCEDURE insert_NewIncident
@Fname varchar(50),
@Lname varchar(50),
@BirthDate DATE,
@FacilityName varchar(50),
@VistDate DATE,
@IncidentName varchar(50),
@IncidentTypeName varchar(50),
@IncidentDesc varchar(100)
AS
DECLARE @IT_ID INT, @V_ID INT

EXEC getVisit
@Firsty = @Fname,
@Lasty = @Lname,
@Birth = @BirthDate ,
@Facility = @FacilityName,
@Vist = @VistDate,
@VisitID = @V_ID OUTPUT
IF @V_ID IS NULL
    BEGIN
        THROW 15564, "VisitID is null", 1;
    END

BEGIN TRAN T1
INSERT INTO INCIDENT_TYPE(IncTypeName)
VALUES(@IncidentTypeName)

SET @IT_ID = (SELECT(SCOPE_IDENTITY))
IF @IT_ID IS NULL
    BEGIN
        THROW 15563, "IncidentTypeID is null", 1;
    END

INSERT INTO INCIDENT(VisitID, Inc_TypeID, IncidentName, IncidentDesc)
VALUES(@V_ID, @IT_ID, @IncidentName, @IncidentDesc)

IF @@ERROR <>0 OR @@TRANCOUNT <> 1
    BEGIN
        PRINT 'Something failed RIP'
        ROLLBACK TRANSACTION T1
    END
ELSE
    COMMIT TRANSACTION T1
get SPs
CREATE PROCEDURE getOperTypeID
@OTName VARCHAR(50),
@ODesc VARCHAR(150),
@OperTypeID INT OUTPUT
AS
SET @OperTypeID = (SELECT Operation_TypeID FROM Operation_Type
WHERE OperTypeName = @OTName
AND OperTypeDesc = @ODesc)
GO

CREATE PROCEDURE getBloodTypeID
@BTName VARCHAR(50),
@BDesc VARCHAR(150),
@BloodTypeID INT OUTPUT
AS
SET @BloodTypeID = (SELECT BloodTypeID FROM Blood_Type
WHERE BloodTypeName = @BTName
AND BloodTypeDesc = @BDesc)
GO

CREATE PROCEDURE getPatientID
@Fname VARCHAR(50),
@Lname VARCHAR(50),
@Birth DATE,
@PatientID INT OUTPUT
AS
SET @PatientID = (SELECT PatientID FROM Patient
WHERE PatientFName = @Fname
AND PatientLName = @Lname
AND PatientBirth = @Birth)
GO

Insert a New Operation with a New Operation Type
CREATE or ALTER PROCEDURE cfeng_OperSP
@Opery VARCHAR(50),
@OTName VARCHAR(50),
@OTDescr VARCHAR(150),
@Firsty VARCHAR(50),
@Lasty VARCHAR(50),
@Birthy DATE,
@Bloody VARCHAR(50),
@BloodDescy VARCHAR(150),
@Facily VARCHAR(50),
@FacilyT VARCHAR(50)
AS
DECLARE @F_ID INT, @OT_ID INT, @P_ID INT

EXEC getFacilityID
@FacilityName = @Facily,
@FacilityID = @F_ID OUTPUT

IF @F_ID IS NULL
BEGIN
PRINT 'Hey..your facility isnt valid';
THROW 55520, '@F_ID cannot be null',1;
END

EXEC getPatientID
@Fname = @Firsty,
@Lname = @Lasty,
@Birth = @Birthy,
@PatientID = @P_ID OUTPUT

IF @P_ID IS NULL
BEGIN
PRINT 'Hey...your Patient isnt valid';
THROW 55521, '@P_ID cannot be null',1;
END
BEGIN TRANSACTION T1
INSERT INTO Operation_Type(OperTypeName, OperTypeDesc)
VALUES(@OTName, @OTDescr)

SET @OT_ID = (SELECT(SCOPE_IDENTITY))
IF @OT_ID IS NULL
BEGIN
PRINT 'Hey..your oper type isnt valid';
THROW 55522, '@OT_ID cannot be null',1;
END

INSERT INTO OPERATION(Operation_TypeID, FacilityID, PatientID, OperationName) VALUES(@OT_ID, @F_ID, @P_ID, @Opery)
IF @@ERROR <> 0 OR @@TRANCOUNT <> 1
BEGIN
PRINT 'something wrong'
ROLLBACK TRANSACTION T1
END
ELSE
COMMIT TRANSACTION T1
GO


Insert a New Patient
CREATE PROCEDURE insert_NewPatient
@Fname VARCHAR(50),
@Lname VARCHAR(50),
@DOB DATE,
@BloodyName VARCHAR(50)
AS
DECLARE @BT_ID INT

EXEC getBloodTypeID
@BTName = @BloodyName,
@BloodTypeID = @BT_ID OUTPUT

IF @BT_ID IS NULL
BEGIN
PRINT 'Hey...your Blood type is not valid';
THROW 55523, '@BT_ID cannot be null', 1;
END

INSERT INTO Patient(BloodTypeID, PatientFName, PatientLName, PatientBirth) VALUES(@BT_ID, @Fname, @Lname, @DOB)
IF @@ERROR <> 0 OR @@TRANCOUNT <> 1
BEGIN
PRINT 'somethangg wrongg'
ROLLBACK TRANSACTION T1
END
ELSE
COMMIT TRANSACTION T1
GO


– get measurement id
CREATE OR ALTER PROCEDURE GetMeasurementID
@MeasurementName VARCHAR(50),
@MeasurementID INT OUTPUT
AS
SET @MeasurementID = (SELECT MeasurementID FROM MEASUREMENT WHERE
                                                MeasurementName = @MeasurementName
)
GO


— get bag type id
CREATE OR ALTER PROCEDURE GetBagTypeID
@BagTypeName VARCHAR(50),
@M_Name VARCHAR(50),
@BagTypeID INT OUTPUT
AS
DECLARE @MS_ID INT


EXEC GetMeasurementID
@MeasurementName = @M_Name,
@MeasurementID = @M_ID OUTPUT
IF @M_ID IS NULL
    BEGIN
        PRINT 'Hey measurement id is null';
        THROW 55480, 'MeasurementID is null, cannot get bag type id',1;
    END


SET @BagTypeID = (SELECT BagTypeID FROM BAG_TYPE WHERE
                                        BagTypeName = @BagTypeName AND MeasurementID = @MS_ID)
GO


–get bag id
CREATE OR ALTER PROCEDURE GetBagID
@Fname varchar(50),
@Lname varchar(50),
@DOB DATE,
@FacilityName VARCHAR(50),
@VisitDate DATE,
@BagName varchar(50),
@M_Name varchar(50),
@BT_Name varchar(50),
@BagID INT OUTPUT
AS
DECLARE @M_ID INT, @BT_ID INT, @V_ID INT


EXEC GetMeasurementID
@MeasurementName = @M_Name,
@MeasurementID = @M_ID OUTPUT
IF @M_ID IS NULL
    BEGIN
        PRINT 'Hey measurement id is null';
        THROW 55461, 'MeasurementID is null, process terminate',1;
    END


EXEC GetBagTypeID
@BagTypeName = @BT_Name,
@MeasurementName = @M_Name,
@BagTypeID = @BT_ID OUTPUT
IF @BT_ID IS NULL
    BEGIN
        PRINT 'Hey bag type id is null';
        THROW 55462, 'BagTypeID is null, process terminate',1;
    END


EXEC getVisitID
@Firsty = @Fname,
@Lasty = @Lname,
@Birthy = @DOB,
@Facility = @FacilityName,
@Visit = @VisitDate,
@VisitID = @V_ID OUTPUT
IF @V_ID IS NULL
    BEGIN
        PRINT 'Hey visit id is null';
        THROW 55463, 'VisitID is null, process terminate',1;
    END


SET @BagID = (SELECT BagID FROM BAG WHERE
                    BagTypeID = @BT_ID AND
                    MeasurementID = @M_ID AND
                    VisitID = @V_ID)
IF @BagID IS NULL
    BEGIN
        PRINT 'Hey bag id is null';
        THROW 55463, 'Bag id is null, cannot find a bag id idk',1;
    END
GO



-- get helper functions
CREATE OR ALTER PROCEDURE getEmployeeID
	@EmployeeFname varchar(99),
	@EmployeeLname varchar(99),
	@EmployeeDOB date,
	@EmployeeID int OUTPUT
	AS
	SET @EmployeeID = (select EmployeeID from Employee where EmployeeFname = @EmployeeFname and
			EmployeeLname = @EmployeeLname and EmployeeDOB = @EmployeeDOB)
GO


CREATE OR ALTER PROCEDURE getEmployeeTypeID
@EmployeeTypeName varchar(99),
@EmployeeTypeID INT OUTPUT
AS
SET @EmployeeTypeID = (SELECT EmployeeTypeID from EMPLOYEE_TYPE where EmployeeTypeName = @EmployeeTypename)
GO


CREATE OR ALTER PROCEDURE getFacilityID
	@FacilityName varchar(99),
	@FacilityID INT output
	AS
	SET @FacilityID = (SELECT FacilityID from FACILITY where FacilityName = @FacilityName)
GO


CREATE OR ALTER PROCEDURE getFacilityTypeID
	@FacilityTypeName varchar(99),
	@FacilityTypeID INT output
	AS
	SET @FacilityTypeID = (SELECT FacilityTypeID from FACILITY_TYPE where FacilityTypeName = @FacilityTypename)


GO


Insert into Employee
CREATE PROCEDURE InsertEmployee
@EmployeeFname2 varchar(99),
@EmployeeLname2 varchar(99),
@EmployeeDOB2 date,
@EmployeeTypeName2 varchar(99),
@FacilityName2 varchar(99)
AS
DECLARE @ET_ID2 INT, @F_ID2 INT


EXEC getEmployeeTypeID
@EmployeeTypeName = @EmployeeTypeName2,
@EmployeeTypeID = @ET_ID2 OUTPUT
	IF @ET_ID2 IS NULL
		BEGIN
			PRINT 'EmployeeType_ID is invalid';
			THROW 55461, 'EmployeeTypeID cannot be null',1;
		END
EXEC getFacilityID
@FacilityName = @FacilityName2,
@FacilityID = @F_ID2 OUTPUT
	IF @F_ID2 IS NULL
		BEGIN
			PRINT '@Facility_ID is invalid';
			THROW 55461, '@FacilityID cannot be null',1;
		END
BEGIN TRAN T1
	INSERT INTO EMPLOYEE(EmployeeFname, EmployeeLname, EmployeeDOB, EmployeeTypeID, FacilityID)
	Values(@EmployeeFname2,@EmployeeLname2,@EmployeeDOB2,@ET_ID2,@F_ID2)
	if @@error <> 0
		BEGIN
			print 'error'
			ROLLBACK T1
		END
	ELSE
		COMMIT TRAN T1
GO


Insert into Facility
CREATE PROCEDURE InsertFacility
@FacilityTypeName2 varchar(99),
@FacilityName varchar(99)
AS
DECLARE @FT_ID2 INT


EXEC getFacilityTypeID
@FacilityTypeName = @FacilityTypeName2,
@FacilityTypeID = @FT_ID2 OUTPUT
	IF @FT_ID2 IS NULL
		BEGIN
			PRINT '@FacilityType_ID is invalid';
			THROW 55462, '@FacilityTypeID cannot be null',1;
		END
BEGIN TRAN T1
	INSERT INTO FACILITY(FacilityName,FacilityTypeID)
	VALUES(@FacilityName, @FT_ID2)


	IF @@error <> 0
		BEGIN
			PRINT 'error'
			ROLLBACK T1
		END
	ELSE
		COMMIT TRAN T1
GO




insert new bag
CREATE OR ALTER PROCEDURE Insert_newBag
@Fname varchar(50),
@Lname varchar(50),
@DOB DATE,
@FacilityName VARCHAR(50),
@VisitDate DATE,
@BagName varchar(50),
@M_Name varchar(50),
@BT_Name varchar(50),
@BagID INT OUTPUT
AS
DECLARE @M_ID INT, @BT_ID INT, @V_ID INT


EXEC GetMeasurementID
@MeasurementName = @M_Name,
@MeasurementID = @M_ID OUTPUT
IF @M_ID IS NULL
    BEGIN
        PRINT 'Hey measurement id is null';
        THROW 55461, 'MeasurementID is null, process terminate',1;
    END
EXEC GetBagTypeID
@BagTypeName = @BT_Name,
@M_Name = @M_Name,
@BagTypeID = @BT_ID OUTPUT
IF @BT_ID IS NULL
    BEGIN
        PRINT 'Hey bag type id is null';
        THROW 55462, 'BagTypeID is null, process terminate',1;
    END
EXEC getVisitID
@Firsty = @Fname,
@Lasty = @Lname,
@Birthy = @DOB,
@Facility = @FacilityName,
@Visit = @VisitDate,
@VisitID = @V_ID OUTPUT
IF @V_ID IS NULL
    BEGIN
        PRINT 'Hey visit id is null';
        THROW 55463, 'VisitID is null, process terminate',1;
    END
SET @BagID = (SELECT SCOPE_IDENTITY())


BEGIN TRANSACTION T1
    INSERT INTO BAG(BagID, BagTypeID, MeasurementID, VisitID, BagName)
    VALUES (@BagID, @BT_ID, @M_ID, @V_ID, @BagName)
    IF @@ERROR <> 0 OR @@TRANCOUNT <> 1
        BEGIN
            PRINT 'Something went wrong inputting a bag'
            ROLLBACK TRANSACTION T1
        END
    ELSE
        COMMIT TRANSACTION T1
GO


insert bag type
CREATE OR ALTER PROCEDURE Insert_Bag_Type
@BagTypeName VARCHAR(50),
@Quantity INT,
@MeasurementName VARCHAR(50)
AS
DECLARE @M_ID INT, @BT_ID INT


EXEC GetMeasurementID
@MeasurementName = @MeasurementName,
@MeasurementID = @M_ID OUTPUT
IF @M_ID IS NULL
    PRINT 'error, measurement id is null(attempting to insert new bag type';
    THROW 55490, 'measurement id is null, process terminate',1;
SET @BT_ID = (SELECT SCOPE_IDENTITY())


BEGIN TRANSACTION T1
INSERT INTO BAG_TYPE(BagTypeID, MeasurementID, BagTypeName, Quantity)
VALUES (@BT_ID, @M_ID, @BT_ID, @Quantity)
  IF @@ERROR <> 0 OR @@TRANCOUNT <> 1
   	  BEGIN
            PRINT 'Something went wrong inputting a measurement'
            ROLLBACK TRANSACTION T1
        END
    ELSE
        COMMIT TRANSACTION T1


GO

