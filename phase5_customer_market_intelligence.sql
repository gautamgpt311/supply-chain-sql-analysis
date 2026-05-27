-- Phase 5 Customer & Market Intelligence --

-- Who are the top 10 customers by revenue? Do any high-value customers also have fraud orders? --
WITH customer_analysis AS (
	SELECT
		Customer_Id,
		CONCAT(Customer_Fname,' ',Customer_Lname) AS customer_name,
		COUNT(*) AS total_orders,
		ROUND(SUM(Sales), 2) AS total_revenue,
		ROUND(SUM(Order_Profit_Per_Order), 2) AS total_profit,
		ROUND(AVG(Sales), 2) AS avg_order_value,
		COUNT(CASE WHEN Order_Status = 'SUSPECTED_FRAUD' THEN 1 ELSE NULL END) AS total_fraud
	FROM order_list
    GROUP BY Customer_Id, Customer_Fname, Customer_Lname
)
SELECT
	Customer_Id,
    customer_name,
    total_orders,
    total_revenue,
    total_profit,
    avg_order_value,
    total_fraud,
    ROW_NUMBER() OVER(ORDER BY total_revenue DESC) AS rank_revenue
FROM customer_analysis
ORDER BY rank_revenue
LIMIT 10;

-- Build a complete market scorecard combining revenue, profit margin, delivery performance and fraud rate in one view. --
WITH market_analysis AS (
	SELECT
		Market,
		COUNT(*) AS total_orders,
		ROUND(SUM(Sales), 2) AS total_revenue,
		ROUND(SUM(Order_Profit_Per_Order), 2) AS total_profit,
		ROUND(SUM(Order_Profit_Per_Order) * 100.0 / SUM(Sales), 2) AS profit_margin,
		ROUND(SUM(CASE WHEN Delivery_Status = 'Late delivery' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_rate,
		ROUND(SUM(CASE WHEN Order_Status = 'SUSPECTED_FRAUD' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate,
		ROUND(AVG(Sales), 2) AS avg_order_value
	FROM order_list
    GROUP BY Market
)
SELECT
	Market,
    total_orders,
    total_revenue,
    total_profit,
    profit_margin,
    late_rate,
    fraud_rate,
    avg_order_value,
    RANK() OVER (ORDER BY total_profit DESC) AS profit_rank
FROM market_analysis;

-- Which shipping mode does each customer segment prefer? Build a pivot table showing the breakdown. --
SELECT
    Customer_Segment,
    COUNT(*) AS total_orders,
    COUNT(CASE WHEN Shipping_Mode = 'Standard Class' 
        THEN 1 END) AS standard_class,
    COUNT(CASE WHEN Shipping_Mode = 'First Class'   
        THEN 1 END) AS first_class,
    COUNT(CASE WHEN Shipping_Mode = 'Second Class'  
        THEN 1 END) AS second_class,
    COUNT(CASE WHEN Shipping_Mode = 'Same Day'      
        THEN 1 END) AS same_day,
    -- Most used shipping mode
    CASE
        WHEN COUNT(CASE WHEN Shipping_Mode = 'Standard Class' THEN 1 END) =
             GREATEST(
                COUNT(CASE WHEN Shipping_Mode = 'Standard Class' THEN 1 END),
                COUNT(CASE WHEN Shipping_Mode = 'First Class' THEN 1 END),
                COUNT(CASE WHEN Shipping_Mode = 'Second Class' THEN 1 END),
                COUNT(CASE WHEN Shipping_Mode = 'Same Day' THEN 1 END))
        THEN 'Standard Class'
        WHEN COUNT(CASE WHEN Shipping_Mode = 'First Class' THEN 1 END) =
             GREATEST(
                COUNT(CASE WHEN Shipping_Mode = 'Standard Class' THEN 1 END),
                COUNT(CASE WHEN Shipping_Mode = 'First Class' THEN 1 END),
                COUNT(CASE WHEN Shipping_Mode = 'Second Class' THEN 1 END),
                COUNT(CASE WHEN Shipping_Mode = 'Same Day' THEN 1 END))
        THEN 'First Class'
        WHEN COUNT(CASE WHEN Shipping_Mode = 'Second Class' THEN 1 END) =
             GREATEST(
                COUNT(CASE WHEN Shipping_Mode = 'Standard Class' THEN 1 END),
                COUNT(CASE WHEN Shipping_Mode = 'First Class' THEN 1 END),
                COUNT(CASE WHEN Shipping_Mode = 'Second Class' THEN 1 END),
                COUNT(CASE WHEN Shipping_Mode = 'Same Day' THEN 1 END))
        THEN 'Second Class'
        ELSE 'Same Day'
    END AS most_used_mode
FROM order_list
GROUP BY Customer_Segment
ORDER BY total_orders DESC;

-- Show profit and revenue by customer segment and market with automatic subtotals per segment and a grand total. --
SELECT
	COALESCE(Customer_Segment, 'ALL SEGMENTS') AS segment,
    COALESCE(Market, 'ALL MARKETS') AS market,
    COUNT(*) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Order_Profit_Per_Order), 2) AS total_profit,
    ROUND(SUM(Order_Profit_Per_Order) * 100.0 / SUM(Sales), 2) AS profit_margin
FROM order_list
GROUP BY Customer_Segment, Market WITH ROLLUP;