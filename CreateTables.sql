CREATE TABLE FACILITY_TYPE
(
    FacilityTypeID INT IDENTITY (1,1) PRIMARY KEY,
    FacilityTypeName varchar (50) NOT NULL,
    FacilityTypeDesc varchar (50) NOT NULL
)

CREATE TABLE FACILITY
(
    FacilityID INT IDENTITY (1,1) PRIMARY KEY,
    FacilityName varchar (50) NOT NULL,
    FacilityTypeID INT FOREIGN KEY REFERENCES FACILITY_TYPE(FacilityTypeID)
)

CREATE TABLE EMPLOYEE_TYPE
(
    EmployeeTypeID INT IDENTITY (1,1) PRIMARY KEY,
    EmployeeTypeName varchar (50) NOT NULL,
    EmployeeTypeDesc varchar (50) NOT NULL
)

CREATE TABLE EMPLOYEE
(
    EmployeeID INT IDENTITY (1,1) PRIMARY KEY,
    EmployeeFname varchar (50) NOT NULL,
    EmployeeLname varchar (50) NOT NULL,
    EmployeeDOB Date NOT NULL,
    EmployeeTypeID INT FOREIGN KEY REFERENCES EMPLOYEE_TYPE(EmployeeTypeID),
    FacilityID INT FOREIGN KEY REFERENCES FACILITY(FacilityID)
)


CREATE TABLE OPERATION_TYPE
(Operation_TypeID INT IDENTITY(1,1) primary key,
OperTypeName VARCHAR(50) not null,
OperTypeDesc VARCHAR(150) not null)

CREATE TABLE BLOOD_TYPE
(BloodTypeID INT IDENTITY(1,1) primary key,
BloodTypeName VARCHAR(50) not null,
BloodTypeDesc VARCHAR(150) not null)

CREATE TABLE PATIENT
(PatientID INT IDENTITY(1,1) primary key,
BloodTypeID INT FOREIGN KEY REFERENCES Blood_Type(BloodTypeID) not null,
PatientFName VARCHAR(50) not null,
PatientLName VARCHAR(50) not null,
PatientBirth DATE not null)

CREATE TABLE INCIDENT_TYPE
(IncidentTypeID INT IDENTITY(1,1) primary key,
IncidentTypeName varchar(50),
IncidentTypeDescr varchar(100))

CREATE TABLE DONOR
(DonorID INT IDENTITY(1,1) primary key,
BloodTypeID INT FOREIGN KEY REFERENCES
BLOOD_TYPE(BloodTypeID) NOT NULL,
DonorFname varchar(50) NOT NULL,
DonorLname varchar(50) NOT NULL,
DonorDOB DATE NOT NULL)

CREATE TABLE VISIT
(VisitID INT IDENTITY(1,1) primary key,
FacilityID INT FOREIGN KEY REFERENCES
FACILITY(FacilityID) NOT NULL,
DonorID INT FOREIGN KEY REFERENCES
DONOR(DonorID) NOT NULL,
VisitDate DATE NOT NULL)

CREATE TABLE MEASUREMENT(
    MeasurementID INT IDENTITY(1,1) PRIMARY KEY,
    MeasurementName VARCHAR(50),
    MeasurementDesc VARCHAR(50)
)

CREATE TABLE INCIDENT
(IncidentID INT IDENTITY(1,1) primary key,
VisitID INT FOREIGN KEY REFERENCES
VISIT(VisitID) NOT NULL,
IncidentTypeID INT FOREIGN KEY REFERENCES
INCIDENT_TYPE(IncidentTypeID) NOT NULL,
IncidentName varchar(50),
IncidentDescr varchar(100))

CREATE TABLE BAG_TYPE(
    BagTypeID INT IDENTITY(1,1) PRIMARY KEY,
    MeasurementID INT FOREIGN KEY REFERENCES MEASUREMENT(MeasurementID),
    Quantity INT,
    BagTypeName VARCHAR(50)
)

CREATE TABLE BAG(
    BagID INT IDENTITY(1,1) PRIMARY KEY,
    BagTypeID INT FOREIGN KEY REFERENCES BAG_TYPE(BagTypeID),
    MeasurementID INT FOREIGN KEY REFERENCES MEASUREMENT(MeasurementID),
    VisitID INT FOREIGN KEY REFERENCES VISIT(VisitID),
    BagName VARCHAR(50)
)

GO

CREATE TABLE Operation
(OperationID INT IDENTITY(1,1) primary key,
Operation_TypeID INT FOREIGN KEY REFERENCES Operation_Type(Operation_TypeID) not null,
FacilityID INT FOREIGN KEY REFERENCES Facility(FacilityID) not null,
PatientID INT FOREIGN KEY REFERENCES Patient(PatientID) not null,
OperationName VARCHAR(50) not null)
GO