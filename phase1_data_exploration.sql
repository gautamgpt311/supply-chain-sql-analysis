-- Data Exploration --

-- Get a complete business snapshot — 
-- total orders, unique customers, products, total revenue, total profit, profit margin and date range in one query. --
SELECT
	COUNT(*) AS total_orders,
    COUNT(DISTINCT Customer_id) AS unique_customers,
    COUNT(DISTINCT Product_Name) AS unique_product_name,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Order_Profit_Per_Order), 2) AS total_profit,
    ROUND(SUM(Order_Profit_Per_Order)
		* 100.0 / SUM(Sales), 2) AS overall_profit_margin_pct,
    DATE_FORMAT(MIN(Order_Date), '%Y-%m-%d') AS earliest_date,
    DATE_FORMAT(MAX(Order_Date), '%Y-%m-%d') AS latest_date,
    COUNT(DISTINCT Order_Country) AS unique_countries,
    COUNT(DISTINCT Market) AS total_markets
FROM order_list;

-- What percentage of orders arrived late, on time, early or were cancelled? Label each status as Good, Bad or Critical. --
SELECT
	Delivery_Status,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 2) AS total_delivery_pct,
    CASE WHEN Delivery_Status = 'Late delivery' THEN 'Bad'
		WHEN Delivery_Status = 'Shipping canceled' THEN 'Critical'
        ELSE 'Good'
	END AS delivery_status
FROM order_list
GROUP BY Delivery_Status
ORDER BY total_orders DESC;

-- Are there any data quality issues — NULL values, orders with negative profit, 
-- impossible dates where shipping happened before ordering, or zero-value sales? --
SELECT
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN Shipping_Date IS NULL THEN 1 ELSE 0 END) AS null_ship_date,
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN Order_Profit_Per_Order IS NULL THEN 1 ELSE 0 END) AS null_profit,
    SUM(CASE WHEN Customer_Id IS NULL THEN 1 ELSE 0 END) AS null_customer
FROM order_list;

SELECT COUNT(*) AS negative_profit_orders
FROM order_list
WHERE Order_Profit_Per_Order < 0;

SELECT COUNT(*) AS impossible_dates
FROM order_list
WHERE Shipping_Date < Order_Date;

SELECT COUNT(*) AS zero_sales
FROM order_list
WHERE Sales = 0;

-- Analyze the complete order pipeline — 
-- how many orders are in each status (Complete, Pending, Fraud, Cancelled etc.)? Which statuses are healthy vs problematic? --
SELECT
	Order_Status,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 
		/ SUM(COUNT(*)) OVER(), 2) AS Orders_status_pct,
    CASE WHEN Order_Status = 'COMPLETE' OR Order_Status = 'PROCESSING' THEN 'Healthy'
		WHEN Order_Status = 'PENDING' OR Order_Status = 'PENDING_PAYMENT' OR Order_Status = 'ON_HOLD' THEN 'At Risk'
        ELSE 'Problem' 
	END AS business_status
FROM order_list
GROUP BY Order_Status;