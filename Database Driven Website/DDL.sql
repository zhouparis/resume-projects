-- Authors: David Willner, Paris Zhou
-- Team #86
-- Date: 7/18/2024

SET FOREIGN_KEY_CHECKS=0;
SET AUTOCOMMIT = 0;

DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Warranties;
DROP TABLE IF EXISTS WarrantyDetails;
DROP TABLE IF EXISTS Vehicles;
DROP TABLE IF EXISTS Transactions;

-- Create Customers -- 

CREATE TABLE Customers(
    customerID int UNIQUE NOT NULL AUTO_INCREMENT,
    name varchar(145) NOT NULL,
    email varchar(145) NOT NULL,
    phoneNumber varchar(145) NOT NULL,
    patron boolean DEFAULT 0,
    PRIMARY KEY (customerID)
);

-- Create Vehicles -- 

Create Table Vehicles (
    VIN varchar(140) UNIQUE NOT NULL,
    make varchar(140) NOT NULL,
    model varchar(140) NOT NULL,
    year varchar(4) NOT NULL,
    engine varchar(140) NOT NULL,
    allWheelDrive boolean DEFAULT 0,
    4x4 boolean DEFAULT 0,
    electricDriveTrain boolean DEFAULT 0,
    color varchar(140) NOT NULL,
    PRIMARY KEY (VIN)
);

-- Create Orders -- 

CREATE TABLE Orders(
    orderID int AUTO_INCREMENT UNIQUE NOT NULL,
    customerID int UNIQUE NOT NULL,
    shipped boolean NOT NULL DEFAULT 0,
    vehicle_VIN varchar(145) NOT NULL,
    price float NOT NULL,
    warranty boolean DEFAULT 0,
    PRIMARY KEY (orderID),
    FOREIGN KEY (customerID) REFERENCES Customers(customerID) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_VIN) REFERENCES Vehicles(VIN) ON DELETE CASCADE
);


-- Create Warranties -- 

CREATE TABLE Warranties (
    warrantyID INT AUTO_INCREMENT NOT NULL,
    orderID INT NOT NULL,
    detailsID INT UNIQUE NOT NULL,
    FOREIGN KEY (orderID) REFERENCES Orders(orderID) ON DELETE CASCADE,
    PRIMARY KEY (warrantyID, orderID)
);


-- Create WarrantyDetails --

CREATE TABLE WarrantyDetails (
    id int UNIQUE NOT NULL,
    ItemToBeCovered varchar(145),
    endCoverageDate datetime NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id) REFERENCES Warranties(detailsID) ON DELETE CASCADE
);


-- Create Transactions --

CREATE TABLE Transactions (
    orderID int UNIQUE NOT NULL,
    orderAge int NOT NULL,
    transactionDate datetime NOT NULL,
    total float NOT NULL,
    shipped boolean NOT NULL DEFAULT 0,
    PRIMARY KEY (orderID),
    FOREIGN KEY (orderID) REFERENCES Orders(orderID) ON DELETE CASCADE
);


----------------------Inserts---------------------------


INSERT INTO Customers(
    name,
    email,
    phoneNumber,
    patron
) VALUES 
("David", "willnerd@oregonstate.edu", "7774442222", 0),
("Paris", "zhoudp@oregonstate.edu", "1112223333", 0),
("Greg", "atkinsg@oregonstate.edu", "6667778888", 1);

INSERT INTO Vehicles (
    VIN,
    make,
    model,
    year,
    engine,
    allWheelDrive,
    4x4,
    electricDriveTrain,
    color
) VALUES 
("JN6MD06S2BW031939", "Subaru", "Impreza", "2008", "4-CYL, 2.0L",1,0,0,"black"),
("JH4DB1550LS000111","Honda","Civic","2019","4-cyl, Turbo Gas, 1.5L",0,0,0,"white"),
("JH4KA4571LC033593","Tesla","Model 3", "2018", "electric",0,0,1,"blue"),
("1JCCM85E5BT001312", "Jeep","Wrangler", "2013","6-Cylinder, 3.6L",0,1,0,"grey");


-- Insert for customer 'Paris' and vehicle 'Subaru'
INSERT INTO Orders (customerID, price, vehicle_VIN, warranty)
SELECT 
    Customers.customerID, 
    30000, 
    Vehicles.VIN, 
    1
FROM 
    Customers
JOIN 
    Vehicles
ON 
    Customers.name = 'Paris' AND Vehicles.make = 'Subaru';

-- Insert for customer 'Greg' and vehicle 'Honda'
INSERT INTO Orders (customerID, price, vehicle_VIN, warranty)
SELECT 
    Customers.customerID, 
    40000, 
    Vehicles.VIN, 
    1
FROM 
    Customers
JOIN 
    Vehicles
ON 
    Customers.name = 'Greg' AND Vehicles.make = 'Honda';

-- Insert for customer 'David' and vehicle 'Jeep'
INSERT INTO Orders (customerID, price, vehicle_VIN, warranty)
SELECT 
    Customers.customerID, 
    50000, 
    Vehicles.VIN, 
    1
FROM 
    Customers
JOIN 
    Vehicles
ON 
    Customers.name = 'David' AND Vehicles.make = 'Jeep';

-- Insert for vehicle VIN 'JN6MD06S2BW031939'
INSERT INTO Warranties (detailsID, orderID)
SELECT 
    111 AS detailsID,
    Orders.orderID
FROM Orders
WHERE Orders.vehicle_VIN = 'JN6MD06S2BW031939';

-- Insert for vehicle VIN 'JH4DB1550LS000111'
INSERT INTO Warranties (detailsID, orderID)
SELECT 
    222 AS detailsID,
    Orders.orderID
FROM Orders
WHERE Orders.vehicle_VIN = 'JH4DB1550LS000111';

-- Insert for vehicle VIN '1JCCM85E5BT001312'
INSERT INTO Warranties (detailsID, orderID)
SELECT 
    333 AS detailsID,
    Orders.orderID
FROM Orders
WHERE Orders.vehicle_VIN = '1JCCM85E5BT001312';



INSERT INTO WarrantyDetails (id, ItemToBeCovered, endCoverageDate)
SELECT 
    Warranties.detailsID AS id,
    'Engine' AS ItemToBeCovered,
    '2026-01-01 23:59:59' AS endCoverageDate
FROM Warranties
JOIN Orders ON Warranties.orderID = Orders.orderID
WHERE Orders.vehicle_VIN = 'JN6MD06S2BW031939';

-- Insert for vehicle VIN 'JH4DB1550LS000111'
INSERT INTO WarrantyDetails (id, ItemToBeCovered, endCoverageDate)
SELECT 
    Warranties.detailsID AS id,
    'Drive Train' AS ItemToBeCovered,
    '2027-01-01 23:59:59' AS endCoverageDate
FROM Warranties
JOIN Orders ON Warranties.orderID = Orders.orderID
WHERE Orders.vehicle_VIN = 'JH4DB1550LS000111';

-- Insert for vehicle VIN '1JCCM85E5BT001312'
INSERT INTO WarrantyDetails (id, ItemToBeCovered, endCoverageDate)
SELECT 
    Warranties.detailsID AS id,
    'Body' AS ItemToBeCovered,
    '2025-01-01 23:59:59' AS endCoverageDate
FROM Warranties
JOIN Orders ON Warranties.orderID = Orders.orderID
WHERE Orders.vehicle_VIN = '1JCCM85E5BT001312';

-- Insert for vehicle VIN 'JN6MD06S2BW031939'
INSERT INTO Transactions (orderID, orderAge, transactionDate, total, shipped)
SELECT 
    Orders.orderID,
    1 AS orderAge,
    '2026-01-01 23:59:59' AS transactionDate,
    2043.0 AS total,
    0 AS shipped
FROM Orders
WHERE Orders.vehicle_VIN = 'JN6MD06S2BW031939';

-- Insert for vehicle VIN 'JH4DB1550LS000111'
INSERT INTO Transactions (orderID, orderAge, transactionDate, total, shipped)
SELECT 
    Orders.orderID,
    2 AS orderAge,
    '2026-02-01 23:59:59' AS transactionDate,
    1928.0 AS total,
    0 AS shipped
FROM Orders
WHERE Orders.vehicle_VIN = 'JH4DB1550LS000111';

-- Insert for vehicle VIN '1JCCM85E5BT001312'
INSERT INTO Transactions (orderID, orderAge, transactionDate, total, shipped)
SELECT 
    Orders.orderID,
    3 AS orderAge,
    '2026-03-01 23:59:59' AS transactionDate,
    1043.0 AS total,
    0 AS shipped
FROM Orders
WHERE Orders.vehicle_VIN = '1JCCM85E5BT001312';



SET FOREIGN_KEY_CHECKS=1;
COMMIT;