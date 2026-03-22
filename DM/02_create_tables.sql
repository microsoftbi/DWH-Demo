USE DM;
GO

IF OBJECT_ID('Sales_Wide_Table', 'U') IS NOT NULL DROP TABLE Sales_Wide_Table;
GO

CREATE TABLE Sales_Wide_Table (
    Sales_SK INT PRIMARY KEY,
    SalesID INT NOT NULL,
    SalesNumber NVARCHAR(50),
    SalesAmount DECIMAL(18, 2),
    Customer_SK INT,
    CustomerID INT,
    CustomerName NVARCHAR(100),
    CustomerBirth DATE,
    CustomerAddr NVARCHAR(200),
    CustomerAge INT,
    Product_SK INT,
    ProductID INT,
    ProductName NVARCHAR(100),
    ProductCode NVARCHAR(50),
    LOAD_DTS DATETIME DEFAULT GETDATE(),
    LOAD_END_DTS DATETIME,
    RECORD_SOURCE NVARCHAR(100),
    HK BINARY(16),
    HASH_DIFF BINARY(16)
);
GO

CREATE INDEX IX_Sales_Wide_CustomerID ON Sales_Wide_Table(CustomerID);
CREATE INDEX IX_Sales_Wide_ProductID ON Sales_Wide_Table(ProductID);
CREATE INDEX IX_Sales_Wide_CustomerName ON Sales_Wide_Table(CustomerName);
CREATE INDEX IX_Sales_Wide_ProductName ON Sales_Wide_Table(ProductName);
GO

PRINT 'Data Mart tables created successfully.';
GO
