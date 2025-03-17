
-- Data manipulation queries

-- Temporary variables are surrounded by brackets as follows {{}}
-- Example variable would be as follows {{exampleVariable}}


---------------------------- Customers Table CRUD operations ------------------------------------------------------------------------------


------------------------------------------
-- SELECT for each table
-- search/filter with dynamically populated FK properties
------------------------------------------
-- Display all customers
SELECT * FROM Customers;

-- Search a customer
SELECT * FROM Customers WHERE Customers.name = {{searchCustomerInput}}

------------------------------------------
-- Insert operations 
------------------------------------------

-- Add a new customer
INSERT INTO Customers (name, email, phoneNumber, patron)
VALUES (
    {{addNewNameInput}}, 
    {{addNewEmailInput}}, 
    {{addNewPhoneNumberInput}}, 
    {{addNewPatronInput}}
    );

------------------------------------------------------------------------------------
-- UPDATE OPERATIONS --
------------------------------------------------------------------------------------
-- Update a customer's data based on submission of the Update Customer form

UPDATE Customers 
SET name = {{updateNameInput}}, email = {{updateEmailInput}}, phoneNumber = {{updatePhoneNumberInput}}, patron = {{updatePatronInput}} 
WHERE name = {{updateCustomerNameSearch}};

------------------------------------------
--  DELETE OPERATIONS  --
------------------------------------------

-- Delete a customer by name
DELETE FROM Customers
WHERE 
    name = {{deleteCustomerNameInput}};

-- Delete a customer by ID
SELECT customerID INTO delCustomer
FROM Customers 
WHERE Customers.name = {{searchDeleteCustomerInput}}

DELETE FROM Customers
WHERE 
    customerID = delCustomer;

---------------------------- Vehicles Table CRUD operations ------------------------------------------------------------------------------
-- Display all vehicles
SELECT * FROM Vehicles;

-- Search a vehicle
SELECT * 
FROM Vehicles 
JOIN Orders
ON Orders.vehicle_VIN = Vehicles.VIN
JOIN Customers
ON Customers.customerID = Orders.customerID
WHERE Customers.name = {{searchVehicleByCustomerNameInput}};
------------------------------------------
-- Insert operations 
------------------------------------------

-- Add a new customer
INSERT INTO Customers (name, email, phoneNumber, patron)
VALUES (
    {{addNewNameInput}}, 
    {{addNewEmailInput}}, 
    {{addNewPhoneNumberInput}}, 
    {{addNewPatronInput}}
    );

-- Add a new vehicle
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
)
VALUES (
    {{addNewVINInput}},
    {{addNewMakeInput}},
    {{addNewModelInput}},
    {{addNewYearInput}},
    {{addNewEngineInput}},
    {{addNewAllWheelDriveInput}},
    {{addNew4x4Input}},
    {{addNewElectricDriveTrainInput}},
    {{addNewColorInput}}
);
------------------------------------------------------------------------------------
-- UPDATE OPERATIONS --
------------------------------------------------------------------------------------
-- Update a vehicle by VIN
UPDATE Vehicles
SET 
    make = {{updateMakeInput}},
    model = {{updateModelInput}},
    year = {{updateYearInput}},
    engine = {{updateEngineInput}},
    allWheelDrive = {{updateAllWheelDriveInput}},
    4x4 = {{update4x4Input}},
    electricDriveTrain = {{updateElectricDriveTrainInput}},
    color = {{updateColorInput}}
WHERE 
    VIN = {{updateVINInput}};

------------------------------------------
--  DELETE OPERATIONS  --
------------------------------------------

-- Delete a vehicle by VIN
DELETE FROM Vehicles
WHERE 
    VIN = {{deleteVINInput}};

---------------------------- Orders Table CRUD operations ------------------------------------------------------------------------------

-- Display all orders
SELECT 
    (SELECT customerID FROM Customers WHERE Customers.customerID = Orders.customerID), 
    price, 
    (SELECT vehicle_VIN FROM Vehicles WHERE Vehicles.VIN = Orders.vehicle_VIN),
    (SELECT warrantyID FROM Warranties WHERE Orders.orderID = Warranties.orderID)
FROM Orders;
------------------------------------------
-- Insert operations 
------------------------------------------

-- Add a new order --
SELECT customerID AS new_customer FROM Customers WHERE Customers.name = {{insertOrderCustomerNameSearch}}} 
SELECT VIN AS new_vehicle FROM Vehicles WHERE Vehicles.VIN = {{insertVehicleCustomerNameSearch}}
INSERT INTO Orders (customerID, price, vehicle_VIN, warranty)
SELECT 
    (new_customer), 
    {{addNewPriceInput}} AS price, 
    (new_vehicle), 
    {{addNewWarrantyInput}} AS warranty
FROM 
    Customers
JOIN 
    Vehicles
ON 
    Customers.name = {{addNewCustomerNameInput}} AND Vehicles.VIN = {{addNewVehicleVINInput}};

------------------------------------------------------------------------------------
-- UPDATE OPERATIONS --
------------------------------------------------------------------------------------

-- Update an order by order ID and customer name, FK are friendly because updates are by make and name

UPDATE Orders
SET 
    price = {{updatePriceInput}},
    warranty = {{updateWarrantyInput}},
    customerID = (SELECT customerID FROM Customers WHERE name = {{updateCustomerNameInput}}),
    vehicle_VIN = (SELECT VIN FROM Vehicles WHERE make = {{updateVehicleMakeInput}})
WHERE 
    orderID = {{updateOrderIDInput}};

------------------------------------------
--  DELETE OPERATIONS  --
------------------------------------------

-- Delete an order by order ID
DELETE FROM Orders
WHERE 
    orderID = {{deleteOrderIDInput}};


-- Delete orders by customer name and vehicle make
DELETE FROM Orders
WHERE 
    customerID = (SELECT customerID FROM Customers WHERE name = {{deleteCustomerNameInput}})
    AND vehicle_VIN = (SELECT VIN FROM Vehicles WHERE make = {{deleteVehicleMakeInput}});


---------------------------- Warranties Table CRUD operations ------------------------------------------------------------------------------
-- Display all warranties
SELECT 
    warrantyID, 
    (SELECT orderID FROM Orders WHERE Orders.orderID = Warranties.orderID),
    detailsID
FROM Warranties;
------------------------------------------
-- Insert operations 
------------------------------------------
INSERT INTO Warranties (detailsID, orderID)
SELECT 
    {{addNewDetailsIDInput}} AS detailsID,
    Orders.orderID
FROM 
    Orders
WHERE 
    Orders.vehicle_VIN = {{addNewVehicleVINInput}};

------------------------------------------------------------------------------------
-- UPDATE OPERATIONS --
------------------------------------------------------------------------------------
-- Update a warranty by details ID
UPDATE Warranties
SET 
    orderID = (SELECT orderID FROM Orders WHERE vehicle_VIN = {{updateVehicleVINInput}})
WHERE 
    detailsID = {{updateDetailsIDInput}};

------------------------------------------
--  DELETE OPERATIONS  --
------------------------------------------
-- Delete a warranty by details ID
DELETE FROM Warranties
WHERE 
    detailsID = {{deleteDetailsIDInput}};

-- Delete warranties by vehicle VIN
DELETE FROM Warranties
WHERE 
    orderID IN (SELECT orderID FROM Orders WHERE vehicle_VIN = {{deleteVehicleVINInput}});


---------------------------- WarrantyDetails Table CRUD operations ------------------------------------------------------------------------------
-- Display all warranty details
SELECT 
    (SELECT detailsID FROM Warranties WHERE Warranties.detailsID = WarrantyDetails.id),
    ItemToBeCovered,
    endCoverageDate
FROM WarrantyDetails;
------------------------------------------
-- Insert operations 
------------------------------------------

INSERT INTO WarrantyDetails (id, ItemToBeCovered, endCoverageDate)
SELECT 
    Warranties.detailsID AS id,
    {{addNewItemToBeCoveredInput}} AS ItemToBeCovered,
    {{addNewEndCoverageDateInput}} AS endCoverageDate
FROM 
    Warranties
JOIN 
    Orders ON Warranties.orderID = Orders.orderID
WHERE 
    Orders.vehicle_VIN = {{addNewVehicleVINInput}};


------------------------------------------------------------------------------------
-- UPDATE OPERATIONS --
------------------------------------------------------------------------------------
-- Update warranty details by ID
UPDATE WarrantyDetails
SET 
    ItemToBeCovered = {{updateItemToBeCoveredInput}},
    endCoverageDate = {{updateEndCoverageDateInput}}
WHERE 
    id = {{updateWarrantyDetailsIDInput}};

------------------------------------------
--  DELETE OPERATIONS  --
------------------------------------------

-- Delete warranty details by ID
DELETE FROM WarrantyDetails
WHERE 
    id = {{deleteWarrantyDetailsIDInput}};

-- Delete warranty details by vehicle VIN
DELETE FROM WarrantyDetails
WHERE 
    id IN (SELECT detailsID FROM Warranties WHERE orderID IN (SELECT orderID FROM Orders WHERE vehicle_VIN = {{deleteVehicleVINInput}}));

---------------------------- Transactions Table CRUD operations ------------------------------------------------------------------------------
-- Display all transactions
SELECT 
    (SELECT orderID FROM Orders WHERE Transactions.orderID = Orders.orderID),
    orderAge,
    transactionDate,
    total,
    shipped
FROM Transactions;
------------------------------------------
-- Insert operations 
------------------------------------------
-- Insert a new transaction
INSERT INTO Transactions (orderID, orderAge, transactionDate, total, shipped)
SELECT 
    Orders.orderID,
    {{addNewOrderAgeInput}} AS orderAge,
    {{addNewTransactionDateInput}} AS transactionDate,
    {{addNewTotalInput}} AS total,
    {{addNewShippedInput}} AS shipped
FROM 
    Orders
WHERE 
    Orders.vehicle_VIN = {{addNewVehicleVINInput}};

------------------------------------------------------------------------------------
-- UPDATE OPERATIONS --
------------------------------------------------------------------------------------
-- Update a transaction by order ID
UPDATE Transactions
SET 
    orderAge = {{updateOrderAgeInput}},
    transactionDate = {{updateTransactionDateInput}},
    total = {{updateTotalInput}},
    shipped = {{updateShippedInput}}
WHERE 
    orderID = {{updateOrderIDInput}};

------------------------------------------
--  DELETE OPERATIONS  --
------------------------------------------

-- Delete a transaction by order ID
DELETE FROM Transactions
WHERE 
    orderID = {{deleteTransactionOrderIDInput}};

-- Delete transactions by vehicle VIN
DELETE FROM Transactions
WHERE 
    orderID IN (SELECT orderID FROM Orders WHERE vehicle_VIN = {{deleteVehicleVINInput}});





























----------------------------- ALL CRUD OPERATIONS ---------------------------------------



--  CREATE OPERATIONS -- 

-- Add a new customer
INSERT INTO Customers (name, email, phoneNumber, patron)
VALUES (
    {{addNewNameInput}}, 
    {{addNewEmailInput}}, 
    {{addNewPhoneNumberInput}}, 
    {{addNewPatronInput}}
    );

-- Add a new vehicle
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
)
VALUES (
    {{addNewVINInput}},
    {{addNewMakeInput}},
    {{addNewModelInput}},
    {{addNewYearInput}},
    {{addNewEngineInput}},
    {{addNewAllWheelDriveInput}},
    {{addNew4x4Input}},
    {{addNewElectricDriveTrainInput}},
    {{addNewColorInput}}
);

-- Add a new order -- Requires vehicle to be inserted prior
INSERT INTO Customers (name, email, phoneNumber, patron)
VALUES (
    {{addNewNameInput}}, 
    {{addNewEmailInput}}, 
    {{addNewPhoneNumberInput}}, 
    {{addNewPatronInput}}
    );

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
)
VALUES (
    {{addNewVINInput}},
    {{addNewMakeInput}},
    {{addNewModelInput}},
    {{addNewYearInput}},
    {{addNewEngineInput}},
    {{addNewAllWheelDriveInput}},
    {{addNew4x4Input}},
    {{addNewElectricDriveTrainInput}},
    {{addNewColorInput}}
);

INSERT INTO Orders (customerID, price, vehicle_VIN, warranty)
SELECT 
    Customers.customerID, 
    {{addNewPriceInput}} AS price, 
    Vehicles.VIN, 
    {{addNewWarrantyInput}} AS warranty
FROM 
    Customers
JOIN 
    Vehicles
ON 
    Customers.name = {{addNewCustomerNameInput}} AND Vehicles.VIN = {{addNewVehicleVINInput}};

-- Add a new Warranty -- Match this to the above order input
INSERT INTO Warranties (detailsID, orderID)
SELECT 
    {{addNewDetailsIDInput}} AS detailsID,
    Orders.orderID
FROM 
    Orders
WHERE 
    Orders.vehicle_VIN = {{addNewVehicleVINInput}};

-- Add a new Warranty Details -- 
INSERT INTO WarrantyDetails (id, ItemToBeCovered, endCoverageDate)
SELECT 
    Warranties.detailsID AS id,
    {{addNewItemToBeCoveredInput}} AS ItemToBeCovered,
    {{addNewEndCoverageDateInput}} AS endCoverageDate
FROM 
    Warranties
JOIN 
    Orders ON Warranties.orderID = Orders.orderID
WHERE 
    Orders.vehicle_VIN = {{addNewVehicleVINInput}};


-- Add a new transaction
INSERT INTO Transactions (orderID, orderAge, transactionDate, total, shipped)
SELECT 
    Orders.orderID,
    {{addNewOrderAgeInput}} AS orderAge,
    {{addNewTransactionDateInput}} AS transactionDate,
    {{addNewTotalInput}} AS total,
    {{addNewShippedInput}} AS shipped
FROM 
    Orders
WHERE 
    Orders.vehicle_VIN = {{addNewVehicleVINInput}};

-- READ OPERATIONS --

-- Read a customer by name
SELECT 
    name, 
    email, 
    phoneNumber, 
    patron
FROM 
    Customers
WHERE 
    name = {{readCustomerNameInput}};

-- Read all customers
SELECT 
    customerID, 
    name, 
    email, 
    phoneNumber, 
    patron
FROM 
    Customers;

-- Read a vehicle by VIN
SELECT 
    VIN, 
    make, 
    model, 
    year, 
    engine, 
    allWheelDrive, 
    4x4, 
    electricDriveTrain, 
    color
FROM 
    Vehicles
WHERE 
    VIN = {{readVINInput}};


-- Read all vehicles
SELECT 
    VIN, 
    make, 
    model, 
    year, 
    engine, 
    allWheelDrive, 
    4x4, 
    electricDriveTrain, 
    color
FROM 
    Vehicles;

-- Read orders by customer name and vehicle make
SELECT 
    Orders.orderID, 
    Orders.customerID, 
    Orders.price, 
    Orders.vehicle_VIN, 
    Orders.warranty
FROM 
    Orders
JOIN 
    Customers ON Orders.customerID = Customers.customerID
JOIN 
    Vehicles ON Orders.vehicle_VIN = Vehicles.VIN
WHERE 
    Customers.name = {{readCustomerNameInput}} AND Vehicles.make = {{readVehicleMakeInput}};

-- Read all orders
SELECT 
    orderID, 
    customerID, 
    price, 
    vehicle_VIN, 
    warranty
FROM 
    Orders;

-- Read warranties by vehicle VIN
SELECT 
    Warranties.detailsID, 
    Warranties.orderID
FROM 
    Warranties
JOIN 
    Orders ON Warranties.orderID = Orders.orderID
WHERE 
    Orders.vehicle_VIN = {{readVehicleVINInput}};

-- Read all warranties
SELECT 
    detailsID, 
    orderID
FROM 
    Warranties;

-- Read warranty details by vehicle VIN
SELECT 
    WarrantyDetails.id, 
    WarrantyDetails.ItemToBeCovered, 
    WarrantyDetails.endCoverageDate
FROM 
    WarrantyDetails
JOIN 
    Warranties ON WarrantyDetails.id = Warranties.detailsID
JOIN 
    Orders ON Warranties.orderID = Orders.orderID
WHERE 
    Orders.vehicle_VIN = {{readVehicleVINInput}};


-- Read all warranty details
SELECT 
    id, 
    ItemToBeCovered, 
    endCoverageDate
FROM 
    WarrantyDetails;

-- Read transactions by vehicle VIN
SELECT 
    Transactions.orderID, 
    Transactions.orderAge, 
    Transactions.transactionDate, 
    Transactions.total, 
    Transactions.shipped
FROM 
    Transactions
JOIN 
    Orders ON Transactions.orderID = Orders.orderID
WHERE 
    Orders.vehicle_VIN = {{readVehicleVINInput}};

-- Read all transactions
SELECT 
    orderID, 
    orderAge, 
    transactionDate, 
    total, 
    shipped
FROM 
    Transactions;

-- Get all orders and their associated customer name and vehicle VIN
SELECT Orders.orderID, Customers.name AS customerName, Orders.vehicle_VIN, Orders.price, Orders.shipped
FROM Orders
INNER JOIN Customers ON Orders.customerID = Customers.customerID;

-- Get a single order's data for the Update Order form
SELECT orderID, customerID, vehicle_VIN, price, warranty, shipped
FROM Orders 
WHERE orderID = {{readOrderIDInput}};

-- Get all transactions and their associated order data
SELECT Transactions.orderID, Transactions.orderAge, Transactions.transactionDate, Transactions.total, Orders.price AS orderPrice, Orders.shipped
FROM Transactions
INNER JOIN Orders ON Transactions.orderID = Orders.orderID;


-- UPDATE OPERATIONS --

-- Update a customer's data based on submission of the Update Customer form
UPDATE Customers 
SET name = {{updateNameInput}}, email = {{updateEmailInput}}, phoneNumber = {{updatePhoneNumberInput}}, patron = {{updatePatronInput}} 
WHERE customerID = {{updateCustomerIDInput}};


-- Update a vehicle by VIN
UPDATE Vehicles
SET 
    make = {{updateMakeInput}},
    model = {{updateModelInput}},
    year = {{updateYearInput}},
    engine = {{updateEngineInput}},
    allWheelDrive = {{updateAllWheelDriveInput}},
    4x4 = {{update4x4Input}},
    electricDriveTrain = {{updateElectricDriveTrainInput}},
    color = {{updateColorInput}}
WHERE 
    VIN = {{updateVINInput}};

-- Update an order by order ID
UPDATE Orders
SET 
    price = {{updatePriceInput}},
    warranty = {{updateWarrantyInput}},
    customerID = (SELECT customerID FROM Customers WHERE name = {{updateCustomerNameInput}}),
    vehicle_VIN = (SELECT VIN FROM Vehicles WHERE make = {{updateVehicleMakeInput}})
WHERE 
    orderID = {{updateOrderIDInput}};

-- Update a warranty by details ID
UPDATE Warranties
SET 
    orderID = (SELECT orderID FROM Orders WHERE vehicle_VIN = {{updateVehicleVINInput}})
WHERE 
    detailsID = {{updateDetailsIDInput}};

-- Update warranty details by ID
UPDATE WarrantyDetails
SET 
    ItemToBeCovered = {{updateItemToBeCoveredInput}},
    endCoverageDate = {{updateEndCoverageDateInput}}
WHERE 
    id = {{updateWarrantyDetailsIDInput}};

-- Update a transaction by order ID
UPDATE Transactions
SET 
    orderAge = {{updateOrderAgeInput}},
    transactionDate = {{updateTransactionDateInput}},
    total = {{updateTotalInput}},
    shipped = {{updateShippedInput}}
WHERE 
    orderID = {{updateOrderIDInput}};

--  DELETE OPERATIONS  --

-- Delete a customer by name
DELETE FROM Customers
WHERE 
    name = {{deleteCustomerNameInput}};

-- Delete a customer by ID
DELETE FROM Customers
WHERE 
    customerID = {{deleteCustomerIDInput}};

-- Delete a vehicle by VIN
DELETE FROM Vehicles
WHERE 
    VIN = {{deleteVINInput}};

-- Delete an order by order ID
DELETE FROM Orders
WHERE 
    orderID = {{deleteOrderIDInput}};

-- Delete orders by customer name and vehicle make
DELETE FROM Orders
WHERE 
    customerID = (SELECT customerID FROM Customers WHERE name = {{deleteCustomerNameInput}})
    AND vehicle_VIN = (SELECT VIN FROM Vehicles WHERE make = {{deleteVehicleMakeInput}});

-- Delete a warranty by details ID
DELETE FROM Warranties
WHERE 
    detailsID = {{deleteDetailsIDInput}};

-- Delete warranties by vehicle VIN
DELETE FROM Warranties
WHERE 
    orderID IN (SELECT orderID FROM Orders WHERE vehicle_VIN = {{deleteVehicleVINInput}});

-- Delete warranty details by ID
DELETE FROM WarrantyDetails
WHERE 
    id = {{deleteWarrantyDetailsIDInput}};

-- Delete warranty details by vehicle VIN
DELETE FROM WarrantyDetails
WHERE 
    id IN (SELECT detailsID FROM Warranties WHERE orderID IN (SELECT orderID FROM Orders WHERE vehicle_VIN = {{deleteVehicleVINInput}}));

-- Delete a transaction by order ID
DELETE FROM Transactions
WHERE 
    orderID = {{deleteTransactionOrderIDInput}};

-- Delete transactions by vehicle VIN
DELETE FROM Transactions
WHERE 
    orderID IN (SELECT orderID FROM Orders WHERE vehicle_VIN = {{deleteVehicleVINInput}});
