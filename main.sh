#!/bin/bash

# Database credentials
DB_HOST="localhost"
DB_USER="your_user"
DB_PASS="your_password"
DB_NAME="your_database"

# Function to execute SQL commands
execute_sql() {
    mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME -e "$1"
}

# Create Users Table
execute_sql "
CREATE TABLE IF NOT EXISTS Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    UserName VARCHAR(100) NOT NULL,
    UserEmail VARCHAR(100) UNIQUE NOT NULL,
    UserPassword VARCHAR(255) NOT NULL,
    UserRole ENUM('Admin', 'Staff') NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"

# Create Products Table
execute_sql "
CREATE TABLE IF NOT EXISTS Products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(255) NOT NULL,
    ProductDescription TEXT,
    ProductPrice DECIMAL(10, 2) NOT NULL,
    ProductCategory ENUM('Retail', 'Restaurant', 'Hospital') NOT NULL,
    StockQuantity INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"

# Create Transactions Table
execute_sql "
CREATE TABLE IF NOT EXISTS Transactions (
    TransactionID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    TransactionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
"

# Create TransactionItems Table
execute_sql "
CREATE TABLE IF NOT EXISTS TransactionItems (
    TransactionItemID INT PRIMARY KEY AUTO_INCREMENT,
    TransactionID INT,
    ProductID INT,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    TotalPrice DECIMAL(10, 2) AS (Quantity * UnitPrice),
    FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
"

# Create Inventory Table
execute_sql "
CREATE TABLE IF NOT EXISTS Inventory (
    InventoryID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT,
    Quantity INT NOT NULL,
    LastUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
"

# Create AccountingEntries Table
execute_sql "
CREATE TABLE IF NOT EXISTS AccountingEntries (
    EntryID INT PRIMARY KEY AUTO_INCREMENT,
    EntryDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Description VARCHAR(255) NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    EntryType ENUM('Debit', 'Credit') NOT NULL,
    TransactionID INT,
    FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID)
);
"

# Create ReplicationStatus Table
execute_sql "
CREATE TABLE IF NOT EXISTS ReplicationStatus (
    ReplicationID INT PRIMARY KEY AUTO_INCREMENT,
    TransactionID INT,
    Status ENUM('Pending', 'Successful', 'Failed') DEFAULT 'Pending',
    LastAttempt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID)
);
"

# Create SendTransactionToExternalEndpoint Stored Procedure
execute_sql "
DELIMITER $$
CREATE PROCEDURE SendTransactionToExternalEndpoint (
    IN p_TransactionID INT
)
BEGIN
    DECLARE v_ResponseCode INT;
    
    -- Placeholder for external API call
    SET v_ResponseCode = 200; -- Simulate a successful API call

    IF v_ResponseCode = 200 THEN
        UPDATE ReplicationStatus 
        SET Status = 'Successful', LastAttempt = NOW() 
        WHERE TransactionID = p_TransactionID;
    ELSE
        UPDATE ReplicationStatus 
        SET Status = 'Failed', LastAttempt = NOW() 
        WHERE TransactionID = p_TransactionID;
    END IF;
END$$
DELIMITER ;
"

# Create AfterTransactionInsert Trigger
execute_sql "
DELIMITER $$
CREATE TRIGGER AfterTransactionInsert
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    -- Insert into ReplicationStatus table
    INSERT INTO ReplicationStatus (TransactionID) VALUES (NEW.TransactionID);
    
    -- Call the stored procedure to replicate the transaction
    CALL SendTransactionToExternalEndpoint(NEW.TransactionID);
END$$
DELIMITER ;
"

# Create RetryFailedReplications Event (Optional)
execute_sql "
DELIMITER $$
CREATE EVENT IF NOT EXISTS RetryFailedReplications
ON SCHEDULE EVERY 5 MINUTE
DO
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_TransactionID INT;
    DECLARE cur CURSOR FOR 
        SELECT TransactionID FROM ReplicationStatus WHERE Status = 'Failed';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_TransactionID;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        CALL SendTransactionToExternalEndpoint(v_TransactionID);
    END LOOP;

    CLOSE cur;
END$$
DELIMITER ;
"

echo "Database setup completed."