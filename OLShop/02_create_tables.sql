USE OLShop;
GO

IF OBJECT_ID('Sales', 'U') IS NOT NULL DROP TABLE Sales;
IF OBJECT_ID('Customer', 'U') IS NOT NULL DROP TABLE Customer;
IF OBJECT_ID('Product', 'U') IS NOT NULL DROP TABLE Product;
GO

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    CustomerBirth DATE,
    CustomerAddr NVARCHAR(200)
);
GO

CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    ProductCode NVARCHAR(50) NOT NULL
);
GO

CREATE TABLE Sales (
    SalesID INT PRIMARY KEY,
    SalesNumber NVARCHAR(50) NOT NULL,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    SalesAmount DECIMAL(18, 2) NOT NULL,
    CONSTRAINT FK_Sales_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    CONSTRAINT FK_Sales_Product FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
GO

PRINT 'Tables created successfully in OLShop.';
GO
