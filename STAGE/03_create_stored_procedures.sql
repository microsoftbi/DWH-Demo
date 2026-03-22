USE STAGE;
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

IF OBJECT_ID('sp_Load_Customer_From_OLShop', 'P') IS NOT NULL DROP PROCEDURE sp_Load_Customer_From_OLShop;
GO

CREATE PROCEDURE sp_Load_Customer_From_OLShop
AS
BEGIN
    SET NOCOUNT ON;
    
    TRUNCATE TABLE STAGE.STG_Customer;
    
    INSERT INTO STAGE.STG_Customer (
        CustomerID, CustomerName, CustomerBirth, CustomerAddr, 
        LOAD_DTS, LOAD_END_DTS, RECORD_SOURCE, HK, HASH_DIFF
    )
    SELECT 
        CustomerID, CustomerName, CustomerBirth, CustomerAddr,
        GETDATE(),
        NULL,
        'OLShop',
        dbo.fn_GetHashKey(CAST(CustomerID AS NVARCHAR(50))),
        dbo.fn_GetHashKey(CONCAT(
            ISNULL(CustomerName, ''), '|',
            ISNULL(CONVERT(NVARCHAR(10), CustomerBirth, 120), ''), '|',
            ISNULL(CustomerAddr, '')
        ))
    FROM OLShop.dbo.Customer;
    
    PRINT 'Customer data loaded successfully from OLShop to STAGE.';
END
GO

IF OBJECT_ID('sp_Load_Product_From_OLShop', 'P') IS NOT NULL DROP PROCEDURE sp_Load_Product_From_OLShop;
GO

CREATE PROCEDURE sp_Load_Product_From_OLShop
AS
BEGIN
    SET NOCOUNT ON;
    
    TRUNCATE TABLE STAGE.STG_Product;
    
    INSERT INTO STAGE.STG_Product (
        ProductID, ProductName, ProductCode, 
        LOAD_DTS, LOAD_END_DTS, RECORD_SOURCE, HK, HASH_DIFF
    )
    SELECT 
        ProductID, ProductName, ProductCode,
        GETDATE(),
        NULL,
        'OLShop',
        dbo.fn_GetHashKey(CAST(ProductID AS NVARCHAR(50))),
        dbo.fn_GetHashKey(CONCAT(
            ISNULL(ProductName, ''), '|',
            ISNULL(ProductCode, '')
        ))
    FROM OLShop.dbo.Product;
    
    PRINT 'Product data loaded successfully from OLShop to STAGE.';
END
GO

IF OBJECT_ID('sp_Load_Sales_From_OLShop', 'P') IS NOT NULL DROP PROCEDURE sp_Load_Sales_From_OLShop;
GO

CREATE PROCEDURE sp_Load_Sales_From_OLShop
AS
BEGIN
    SET NOCOUNT ON;
    
    TRUNCATE TABLE STAGE.STG_Sales;
    
    INSERT INTO STAGE.STG_Sales (
        SalesID, SalesNumber, CustomerID, ProductID, SalesAmount, 
        LOAD_DTS, LOAD_END_DTS, RECORD_SOURCE, HK, HASH_DIFF
    )
    SELECT 
        SalesID, SalesNumber, CustomerID, ProductID, SalesAmount,
        GETDATE(),
        NULL,
        'OLShop',
        dbo.fn_GetHashKey(CAST(SalesID AS NVARCHAR(50))),
        dbo.fn_GetHashKey(CONCAT(
            ISNULL(SalesNumber, ''), '|',
            ISNULL(CAST(CustomerID AS NVARCHAR(50)), ''), '|',
            ISNULL(CAST(ProductID AS NVARCHAR(50)), ''), '|',
            ISNULL(CAST(SalesAmount AS NVARCHAR(50)), '')
        ))
    FROM OLShop.dbo.Sales;
    
    PRINT 'Sales data loaded successfully from OLShop to STAGE.';
END
GO

IF OBJECT_ID('sp_Load_All_From_OLShop', 'P') IS NOT NULL DROP PROCEDURE sp_Load_All_From_OLShop;
GO

CREATE PROCEDURE sp_Load_All_From_OLShop
AS
BEGIN
    SET NOCOUNT ON;
    
    EXEC sp_Load_Customer_From_OLShop;
    EXEC sp_Load_Product_From_OLShop;
    EXEC sp_Load_Sales_From_OLShop;
    
    PRINT 'All data loaded successfully from OLShop to STAGE.';
END
GO

PRINT 'Stored procedures created successfully in STAGE.';
GO
