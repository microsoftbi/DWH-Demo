USE DM;
GO

IF OBJECT_ID('sp_Load_Sales_Wide_Table', 'P') IS NOT NULL DROP PROCEDURE sp_Load_Sales_Wide_Table;
GO

CREATE PROCEDURE sp_Load_Sales_Wide_Table
AS
BEGIN
    SET NOCOUNT ON;
    
    TRUNCATE TABLE DM.dbo.Sales_Wide_Table;
    
    INSERT INTO DM.dbo.Sales_Wide_Table (
        Sales_SK, SalesID, SalesNumber, SalesAmount,
        Customer_SK, CustomerID, CustomerName, CustomerBirth, CustomerAddr, CustomerAge,
        Product_SK, ProductID, ProductName, ProductCode,
        LOAD_DTS, LOAD_END_DTS, RECORD_SOURCE, HK, HASH_DIFF
    )
    SELECT 
        f.Sales_SK,
        f.SalesID,
        f.SalesNumber,
        f.SalesAmount,
        dc.Customer_SK,
        dc.CustomerID,
        dc.CustomerName,
        dc.CustomerBirth,
        dc.CustomerAddr,
        dc.CustomerAge,
        dp.Product_SK,
        dp.ProductID,
        dp.ProductName,
        dp.ProductCode,
        GETDATE(),
        NULL,
        'OLShop',
        f.HK,
        f.HASH_DIFF
    FROM STAR.dbo.Fact_Sales f
    INNER JOIN STAR.dbo.Dim_Customer dc ON f.Customer_SK = dc.Customer_SK
    INNER JOIN STAR.dbo.Dim_Product dp ON f.Product_SK = dp.Product_SK;
    
    PRINT 'Sales_Wide_Table loaded successfully.';
END
GO

IF OBJECT_ID('sp_Load_All_From_STAR', 'P') IS NOT NULL DROP PROCEDURE sp_Load_All_From_STAR;
GO

CREATE PROCEDURE sp_Load_All_From_STAR
AS
BEGIN
    SET NOCOUNT ON;
    
    EXEC sp_Load_Sales_Wide_Table;
    
    PRINT 'All data loaded successfully from STAR to DM.';
END
GO

PRINT 'Stored procedures created successfully in DM.';
GO
