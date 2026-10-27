USE ecommerce;

-- 1. Combine both retail datasets into one table

CREATE TABLE RetailCombined AS

-- First dataset: 2009-2010
SELECT
    Invoice, StockCode, Description, Quantity,
    
    -- Convert InvoiceDate from text to datetime
    STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i') AS InvoiceDate,
    
    -- Convert Price to decimal with 2 decimal places
    CAST(Price AS DECIMAL(10,2)) AS Price,
    
    `Customer ID`, Country,
    
    -- Identify the source dataset (new col)
    '2009-2010' AS SourceSheet
FROM ikea_retail_1

UNION ALL

-- Second dataset: 2010-2011
SELECT
    Invoice, StockCode, Description, Quantity,

    -- Convert InvoiceDate from text to datetime
    STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i') AS InvoiceDate,

    -- Convert Price to decimal with 2 decimal places
    CAST(Price AS DECIMAL(10,2)) AS Price,

    `Customer ID`, Country,

    -- Identify the source dataset (new col)
    '2010-2011' AS SourceSheet
FROM ikea_retail_2;


-- 2. Confirm the conversion worked cleanly
SELECT COUNT(*) AS Total_Rows FROM RetailCombined;
SELECT COUNT(*) AS Failed_Dates FROM RetailCombined WHERE InvoiceDate IS NULL;
SELECT COUNT(*) AS Failed_Prices FROM RetailCombined WHERE Price IS NULL;


-- 3. Check missing customer id
SELECT COUNT(*) AS Missing_Customer_ID
FROM RetailCombined WHERE `Customer ID` IS NULL;

-- 4. Check negative or zero quantity
SELECT COUNT(*) AS Negative_Qty
FROM RetailCombined WHERE Quantity <= 0;

-- 5. Check exact duplicate rows
SELECT Invoice, StockCode, Description, Quantity, InvoiceDate, Price, `Customer ID`, Country, SourceSheet, 
COUNT(*) AS DuplicateCount
FROM ecommerce.RetailCombined
GROUP BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, `Customer ID`, Country, SourceSheet
HAVING COUNT(*) > 1;


-- 6. Remove duplicate rows and produce the final cleaned table
CREATE TABLE RetailCleaned AS
SELECT DISTINCT Invoice, StockCode, Description, Quantity, InvoiceDate, Price, `Customer ID`, Country, SourceSheet
FROM RetailCombined;
