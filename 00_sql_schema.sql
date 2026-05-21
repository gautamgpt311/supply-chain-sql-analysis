-- ============================================================
-- Project  : DataCo Supply Chain Analysis
-- File     : 00_sql_schema.sql
-- Tool     : MySQL 8.0
-- Dataset  : Kaggle — DataCo Smart Supply Chain Dataset
-- Rows     : 180,519 orders | 53 columns | 1 table
-- ============================================================

-- Create the database
CREATE DATABASE supply_chain;
USE supply_chain;

-- Create the order_list table
-- 53 columns covering orders, customers, products,
-- shipping and delivery across 5 global markets
CREATE TABLE order_list (
    Type                        VARCHAR(20),
    Days_for_shipping_real      INT,
    Days_for_shipment_scheduled INT,
    Benefit_per_order           DECIMAL(10,2),
    Sales_per_customer          DECIMAL(10,2),
    Delivery_Status             VARCHAR(50),
    Late_delivery_risk          INT,
    Category_Id                 INT,
    Category_Name               VARCHAR(100),
    Customer_City               VARCHAR(100),
    Customer_Country            VARCHAR(100),
    Customer_Fname              VARCHAR(50),
    Customer_Id                 INT,
    Customer_Lname              VARCHAR(50),
    Customer_Segment            VARCHAR(50),
    Customer_State              VARCHAR(50),
    Department_Id               INT,
    Department_Name             VARCHAR(100),
    Market                      VARCHAR(50),
    Order_City                  VARCHAR(100),
    Order_Country               VARCHAR(100),
    Order_Customer_Id           INT,
    Order_Date                  DATETIME,
    Order_Id                    INT,
    Order_Item_Discount         DECIMAL(10,2),
    Order_Item_Discount_Rate    DECIMAL(10,4),
    Order_Item_Id               INT,
    Order_Item_Product_Price    DECIMAL(10,2),
    Order_Item_Profit_Ratio     DECIMAL(10,4),
    Order_Item_Quantity         INT,
    Sales                       DECIMAL(10,2),
    Order_Item_Total            DECIMAL(10,2),
    Order_Profit_Per_Order      DECIMAL(10,2),
    Order_Region                VARCHAR(100),
    Order_State                 VARCHAR(100),
    Order_Status                VARCHAR(50),
    Product_Card_Id             INT,
    Product_Category_Id         INT,
    Product_Name                VARCHAR(200),
    Product_Price               DECIMAL(10,2),
    Product_Status              INT,
    Shipping_Date               DATETIME,
    Shipping_Mode               VARCHAR(50)
);

-- Load the supply chain data
-- Why @skip variables are used:
--   CSV contains sensitive columns (email, password,
--   street address) that are not needed for analysis.
--   These are loaded into @skip variables and discarded.
--
-- Why STR_TO_DATE is used:
--   Date columns are stored in US format MM/DD/YYYY HH:MM
--   which MySQL cannot parse directly. STR_TO_DATE converts
--   them to proper DATETIME format during import.
-- ------------------------------------------------------------
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/DataCoSupplyChainDataset.csv'
INTO TABLE order_list
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Type, Days_for_shipping_real, Days_for_shipment_scheduled,
 Benefit_per_order, Sales_per_customer, Delivery_Status,
 Late_delivery_risk, Category_Id, Category_Name,
 Customer_City, Customer_Country, @skip_email,
 Customer_Fname, Customer_Id, Customer_Lname,
 @skip_password, Customer_Segment, Customer_State,
 @skip_street, @skip_zipcode, Department_Id,
 Department_Name, @skip_lat, @skip_long,
 Market, Order_City, Order_Country,
 Order_Customer_Id, @order_date, Order_Id,
 @skip_cardprod, Order_Item_Discount,
 Order_Item_Discount_Rate, Order_Item_Id,
 Order_Item_Product_Price, Order_Item_Profit_Ratio,
 Order_Item_Quantity, Sales, Order_Item_Total,
 Order_Profit_Per_Order, Order_Region, Order_State,
 Order_Status, @skip_zipcode2, Product_Card_Id,
 Product_Category_Id, @skip_desc, @skip_image,
 Product_Name, Product_Price, Product_Status,
 @shipping_date, Shipping_Mode)
SET
 Order_Date    = STR_TO_DATE(@order_date,    '%m/%d/%Y %H:%i'),
 Shipping_Date = STR_TO_DATE(@shipping_date, '%m/%d/%Y %H:%i');