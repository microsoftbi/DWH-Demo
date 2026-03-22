USE STAR;
GO

IF OBJECT_ID('Fact_Sales', 'U') IS NOT NULL DROP TABLE Fact_Sales;
IF OBJECT_ID('Dim_Product', 'U') IS NOT NULL DROP TABLE Dim_Product;
IF OBJECT_ID('Dim_Customer', 'U') IS NOT NULL DROP TABLE Dim_Customer;
GO

CREATE TABLE Dim_Customer (
    Customer_SK INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    CustomerName NVARCHAR(100),
    CustomerBirth DATE,
    CustomerAddr NVARCHAR(200),
    CustomerAge INT,
    LOAD_DTS DATETIME DEFAULT GETDATE(),
    LOAD_END_DTS DATETIME,
    RECORD_SOURCE NVARCHAR(100),
    HK BINARY(16),
    HASH_DIFF BINARY(16)
);
GO

CREATE TABLE Dim_Product (
    Product_SK INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    ProductName NVARCHAR(100),
    ProductCode NVARCHAR(50),
    LOAD_DTS DATETIME DEFAULT GETDATE(),
    LOAD_END_DTS DATETIME,
    RECORD_SOURCE NVARCHAR(100),
    HK BINARY(16),
    HASH_DIFF BINARY(16)
);
GO

CREATE TABLE Fact_Sales (
    Sales_SK INT IDENTITY(1,1) PRIMARY KEY,
    SalesID INT NOT NULL,
    SalesNumber NVARCHAR(50),
    Customer_SK INT NOT NULL,
    Product_SK INT NOT NULL,
    SalesAmount DECIMAL(18, 2),
    LOAD_DTS DATETIME DEFAULT GETDATE(),
    LOAD_END_DTS DATETIME,
    RECORD_SOURCE NVARCHAR(100),
    HK BINARY(16),
    HASH_DIFF BINARY(16),
    CONSTRAINT FK_Fact_Sales_Customer FOREIGN KEY (Customer_SK) REFERENCES Dim_Customer(Customer_SK),
    CONSTRAINT FK_Fact_Sales_Product FOREIGN KEY (Product_SK) REFERENCES Dim_Product(Product_SK)
);
GO

CREATE INDEX IX_Fact_Sales_Customer_SK ON Fact_Sales(Customer_SK);
CREATE INDEX IX_Fact_Sales_Product_SK ON Fact_Sales(Product_SK);
GO

PRINT 'Star Schema tables created successfully.';
GO
