USE STAR;
GO

IF OBJECT_ID('sp_Load_Dim_Customer', 'P') IS NOT NULL DROP PROCEDURE sp_Load_Dim_Customer;
GO

CREATE PROCEDURE sp_Load_Dim_Customer
AS
BEGIN
    SET NOCOUNT ON;
    
    TRUNCATE TABLE STAR.dbo.Dim_Customer;
    
    INSERT INTO STAR.dbo.Dim_Customer (
        CustomerID, CustomerName, CustomerBirth, CustomerAddr, CustomerAge, 
        LOAD_DTS, LOAD_END_DTS, RECORD_SOURCE, HK, HASH_DIFF
    )
    SELECT 
        hc.CustomerID,
        sc.CustomerName,
        sc.CustomerBirth,
        sc.CustomerAddr,
        DATEDIFF(YEAR, sc.CustomerBirth, GETDATE()) - 
        CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, sc.CustomerBirth, GETDATE()), sc.CustomerBirth) > GETDATE() 
             THEN 1 ELSE 0 END AS CustomerAge,
        GETDATE(),
        NULL,
        'OLShop',
        hc.Customer_HK AS HK,
        sc.HASH_DIFF
    FROM DV.dbo.Hub_Customer hc
    INNER JOIN DV.dbo.Sat_Customer sc ON hc.Customer_HK = sc.Customer_HK;
    
    PRINT 'Dim_Customer loaded successfully.';
END
GO

IF OBJECT_ID('sp_Load_Dim_Product', 'P') IS NOT NULL DROP PROCEDURE sp_Load_Dim_Product;
GO

CREATE PROCEDURE sp_Load_Dim_Product
AS
BEGIN
    SET NOCOUNT ON;
    
    TRUNCATE TABLE STAR.dbo.Dim_Product;
    
    INSERT INTO STAR.dbo.Dim_Product (
        ProductID, ProductName, ProductCode, 
        LOAD_DTS, LOAD_END_DTS, RECORD_SOURCE, HK, HASH_DIFF
    )
    SELECT 
        hp.ProductID,
        sp.ProductName,
        sp.ProductCode,
        GETDATE(),
        NULL,
        'OLShop',
        hp.Product_HK AS HK,
        sp.HASH_DIFF
    FROM DV.dbo.Hub_Product hp
    INNER JOIN DV.dbo.Sat_Product sp ON hp.Product_HK = sp.Product_HK;
    
    PRINT 'Dim_Product loaded successfully.';
END
GO

IF OBJECT_ID('sp_Load_Fact_Sales', 'P') IS NOT NULL DROP PROCEDURE sp_Load_Fact_Sales;
GO

CREATE PROCEDURE sp_Load_Fact_Sales
AS
BEGIN
    SET NOCOUNT ON;
    
    TRUNCATE TABLE STAR.dbo.Fact_Sales;
    
    INSERT INTO STAR.dbo.Fact_Sales (
        SalesID, SalesNumber, Customer_SK, Product_SK, SalesAmount, 
        LOAD_DTS, LOAD_END_DTS, RECORD_SOURCE, HK, HASH_DIFF
    )
    SELECT 
        hs.SalesID,
        ss.SalesNumber,
        dc.Customer_SK,
        dp.Product_SK,
        ss.SalesAmount,
        GETDATE(),
        NULL,
        'OLShop',
        hs.Sales_HK AS HK,
        ss.HASH_DIFF
    FROM DV.dbo.Hub_Sales hs
    INNER JOIN DV.dbo.Sat_Sales ss ON hs.Sales_HK = ss.Sales_HK
    INNER JOIN DV.dbo.Link_Sales ls ON hs.Sales_HK = ls.Sales_HK
    INNER JOIN DV.dbo.Hub_Customer hc ON ls.Customer_HK = hc.Customer_HK
    INNER JOIN DV.dbo.Hub_Product hp ON ls.Product_HK = hp.Product_HK
    INNER JOIN STAR.dbo.Dim_Customer dc ON hc.CustomerID = dc.CustomerID
    INNER JOIN STAR.dbo.Dim_Product dp ON hp.ProductID = dp.ProductID;
    
    PRINT 'Fact_Sales loaded successfully.';
END
GO

IF OBJECT_ID('sp_Load_All_From_DV', 'P') IS NOT NULL DROP PROCEDURE sp_Load_All_From_DV;
GO

CREATE PROCEDURE sp_Load_All_From_DV
AS
BEGIN
    SET NOCOUNT ON;
    
    EXEC sp_Load_Dim_Customer;
    EXEC sp_Load_Dim_Product;
    EXEC sp_Load_Fact_Sales;
    
    PRINT 'All data loaded successfully from DV to STAR.';
END
GO

PRINT 'Stored procedures created successfully in STAR.';
GO
