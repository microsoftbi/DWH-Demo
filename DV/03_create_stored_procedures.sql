USE DV;
GO

IF OBJECT_ID('fn_GetHashKey', 'FN') IS NOT NULL DROP FUNCTION fn_GetHashKey;
GO

CREATE FUNCTION fn_GetHashKey(@input NVARCHAR(MAX))
RETURNS BINARY(16)
AS
BEGIN
    DECLARE @hash BINARY(16);
    SET @hash = HASHBYTES('MD5', @input);
    RETURN @hash;
END
GO

IF OBJECT_ID('sp_Load_Hub_Customer', 'P') IS NOT NULL DROP PROCEDURE sp_Load_Hub_Customer;
GO

CREATE PROCEDURE sp_Load_Hub_Customer
AS
BEGIN
    SET NOCOUNT ON;
    
    TRUNCATE TABLE DV.dbo.Hub_Customer;
    
    INSERT INTO DV.dbo.Hub_Customer (Customer_HK, CustomerID, LOAD_DTS, LOAD_END_DTS, RECORD_SOURCE)
    SELECT 
        HK,
        CustomerID,
        GETDATE(),
        NULL,
        'OLShop'
    FROM STAGE.dbo.STG_Customer;
    
    PRINT 'Hub_Customer loaded successfully.';
END
GO

IF OBJECT_ID('sp_Load_Hub_Product', 'P') IS NOT NULL DROP PROCEDURE sp_Load_Hub_Product;
GO

CREATE PROCEDURE sp_Load_Hub_Product
AS
BEGIN
    SET NOCOUNT ON;
    
    TRUNCATE TABLE DV.dbo.Hub_Product;
    
    INSERT INTO DV.dbo.Hub_Product (Product_HK, ProductID, LOAD_DTS, LOAD_END_DTS, RECORD_SOURCE)
    SELECT 
        HK,
        ProductID,
        GETDATE(),
        NULL,
        'OLShop'
    FROM STAGE.dbo.STG_Product;
    
    PRINT 'Hub_Product loaded successfully.';
END
GO

IF OBJECT_ID('sp_Load_Hub_Sales', 'P') IS NOT NULL DROP PROCEDURE sp_Load_Hub_Sales;
GO

CREATE PROCEDURE sp_Load_Hub_Sales
AS
BEGIN
    SET NOCOUNT ON;
    
    TRUNCATE TABLE DV.dbo.Hub_Sales;
    
    INSERT INTO DV.dbo.Hub_Sales (Sales_HK, SalesID, LOAD_DTS, LOAD_END_DTS, RECORD_SOURCE)
    SELECT 
        HK,
        SalesID,
        GETDATE(),
        NULL,
        'OLShop'
    FROM STAGE.dbo.STG_Sales;
    
    PRINT 'Hub_Sales loaded successfully.';
END
GO

IF OBJECT_ID('sp_Load_Link_Sales', 'P') IS NOT NULL DROP PROCEDURE sp_Load_Link_Sales;
GO

CREATE PROCEDURE sp_Load_Link_Sales
AS
BEGIN
    SET NOCOUNT ON;
    
    TRUNCATE TABLE DV.dbo.Link_Sales;
    
    INSERT INTO DV.dbo.Link_Sales (Link_Sales_HK, Sales_HK, Customer_HK, Product_HK, LOAD_DTS, LOAD_END_DTS, RECORD_SOURCE)
    SELECT 
        dbo.fn_GetHashKey(CONCAT(s.SalesID, '-', s.CustomerID, '-', s.ProductID)),
        s.HK AS Sales_HK,
        c.HK AS Customer_HK,
        p.HK AS Product_HK,
        GETDATE(),
        NULL,
        'OLShop'
    FROM STAGE.dbo.STG_Sales s
    INNER JOIN STAGE.dbo.STG_Customer c ON s.CustomerID = c.CustomerID
    INNER JOIN STAGE.dbo.STG_Product p ON s.ProductID = p.ProductID;
    
    PRINT 'Link_Sales loaded successfully.';
END
GO

IF OBJECT_ID('sp_Load_Sat_Customer', 'P') IS NOT NULL DROP PROCEDURE sp_Load_Sat_Customer;
GO

CREATE PROCEDURE sp_Load_Sat_Customer
AS
BEGIN
    SET NOCOUNT ON;
    
    TRUNCATE TABLE DV.dbo.Sat_Customer;
    
    INSERT INTO DV.dbo.Sat_Customer (Customer_HK, LOAD_DTS, LOAD_END_DTS, CustomerName, CustomerBirth, CustomerAddr, RECORD_SOURCE, HASH_DIFF)
    SELECT 
        HK,
        GETDATE(),
        NULL,
        CustomerName,
        CustomerBirth,
        CustomerAddr,
        'OLShop',
        HASH_DIFF
    FROM STAGE.dbo.STG_Customer;
    
    PRINT 'Sat_Customer loaded successfully.';
END
GO

IF OBJECT_ID('sp_Load_Sat_Product', 'P') IS NOT NULL DROP PROCEDURE sp_Load_Sat_Product;
GO

CREATE PROCEDURE sp_Load_Sat_Product
AS
BEGIN
    SET NOCOUNT ON;
    
    TRUNCATE TABLE DV.dbo.Sat_Product;
    
    INSERT INTO DV.dbo.Sat_Product (Product_HK, LOAD_DTS, LOAD_END_DTS, ProductName, ProductCode, RECORD_SOURCE, HASH_DIFF)
    SELECT 
        HK,
        GETDATE(),
        NULL,
        ProductName,
        ProductCode,
        'OLShop',
        HASH_DIFF
    FROM STAGE.dbo.STG_Product;
    
    PRINT 'Sat_Product loaded successfully.';
END
GO

IF OBJECT_ID('sp_Load_Sat_Sales', 'P') IS NOT NULL DROP PROCEDURE sp_Load_Sat_Sales;
GO

CREATE PROCEDURE sp_Load_Sat_Sales
AS
BEGIN
    SET NOCOUNT ON;
    
    TRUNCATE TABLE DV.dbo.Sat_Sales;
    
    INSERT INTO DV.dbo.Sat_Sales (Sales_HK, LOAD_DTS, LOAD_END_DTS, SalesNumber, SalesAmount, RECORD_SOURCE, HASH_DIFF)
    SELECT 
        HK,
        GETDATE(),
        NULL,
        SalesNumber,
        SalesAmount,
        'OLShop',
        HASH_DIFF
    FROM STAGE.dbo.STG_Sales;
    
    PRINT 'Sat_Sales loaded successfully.';
END
GO

IF OBJECT_ID('sp_Load_All_From_STAGE', 'P') IS NOT NULL DROP PROCEDURE sp_Load_All_From_STAGE;
GO

CREATE PROCEDURE sp_Load_All_From_STAGE
AS
BEGIN
    SET NOCOUNT ON;
    
    EXEC sp_Load_Hub_Customer;
    EXEC sp_Load_Hub_Product;
    EXEC sp_Load_Hub_Sales;
    EXEC sp_Load_Link_Sales;
    EXEC sp_Load_Sat_Customer;
    EXEC sp_Load_Sat_Product;
    EXEC sp_Load_Sat_Sales;
    
    PRINT 'All data loaded successfully from STAGE to DV.';
END
GO

PRINT 'Stored procedures created successfully in DV.';
GO
