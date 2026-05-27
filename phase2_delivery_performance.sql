-- Phase 2 Delivery Performance -- 

-- Which shipping mode has the worst late delivery rate? How many days behind schedule does each mode run on average? --
SELECT
	Shipping_Mode,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN Delivery_Status = 'Late delivery' THEN 1 ELSE 0 END) AS late_orders,
    SUM(CASE WHEN Delivery_Status !='Late delivery' THEN 1 ELSE 0 END) AS ontime_orders,
    ROUND(SUM(CASE WHEN Delivery_Status = 'Late delivery' THEN 1 ELSE 0 END) 
		* 100.0 / COUNT(*), 2) AS late_delivery_rate,
	ROUND(AVG(Days_for_shipping_real), 2) AS avg_actual_days,
    ROUND(AVG(Days_for_shipment_scheduled), 2) AS avg_scheduled_days,
    ROUND(AVG(Days_for_shipping_real - Days_for_shipment_scheduled), 2) AS avg_delay_gap
FROM order_list
GROUP BY Shipping_Mode
ORDER BY late_delivery_rate DESC;

-- Classify orders by how late they actually arrived — 
-- early, on time, slightly late, moderately late or very late. Does being late affect profit? --
WITH gap_analysis AS (
	SELECT
		Sales,
		Days_for_shipping_real - Days_for_shipment_scheduled AS delay_gap,
        Order_Profit_Per_Order
	FROM order_list
)
SELECT
	CASE WHEN delay_gap < 0 THEN 'Early'
		WHEN delay_gap = 0 THEN 'On Time'
        WHEN delay_gap BETWEEN 1 AND 2 THEN 'Slightly Late'
        WHEN delay_gap BETWEEN 3 AND 5 THEN 'Moderately Late'
        ELSE 'Very Late'
	END AS delivery_analysis,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 /
		SUM(COUNT(*)) OVER(), 2) AS pct_of_total,
	ROUND(AVG(Sales), 2) AS avg_order_value,
    ROUND(AVG(Order_Profit_Per_Order), 2) AS avg_profit
FROM gap_analysis
GROUP BY delivery_analysis
ORDER BY avg_profit DESC;

-- Which global market has the worst delivery performance? Rank all 5 markets. --
WITH market_performance AS (
    SELECT
        Market,
        COUNT(*) AS total_orders,
        SUM(CASE WHEN Delivery_Status = 'Late delivery' THEN 1 ELSE 0 END) AS late_orders,
        ROUND(SUM(CASE WHEN Delivery_Status = 'Late delivery' THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*), 2) AS late_delivery_rate,
        ROUND(AVG(Days_for_shipping_real - 
            Days_for_shipment_scheduled), 2) AS avg_delay_gap,
        ROUND(AVG(Order_Profit_Per_Order), 2) AS avg_profit_per_order
    FROM order_list
    GROUP BY Market
)
SELECT
    Market,
    total_orders,
    late_orders,
    late_delivery_rate,
    avg_delay_gap,
    avg_profit_per_order,
    RANK() OVER(ORDER BY late_delivery_rate DESC) AS late_delivery_rank
FROM market_performance
ORDER BY late_delivery_rank;

-- Is the late delivery problem getting better or worse over time? Track the trend month by month across all years. --
WITH monthly_trend AS (
    SELECT
        YEAR(Order_Date) AS order_year,
        MONTH(Order_Date) AS order_month,
        COUNT(*) AS total_orders,
        SUM(CASE WHEN Delivery_Status = 'Late delivery' 
            THEN 1 ELSE 0 END) AS late_orders,
        ROUND(SUM(CASE WHEN Delivery_Status = 'Late delivery' 
            THEN 1 ELSE 0 END) * 100.0 
            / COUNT(*), 2) AS late_rate
    FROM order_list
    WHERE Order_Date IS NOT NULL
    GROUP BY order_year, order_month
)
SELECT
    order_year,
    CASE order_month
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'MARCH'
        WHEN 4 THEN 'APRIL'
        WHEN 5 THEN 'MAY'
        WHEN 6 THEN 'JUNE'
        WHEN 7 THEN 'JULY'
        WHEN 8 THEN 'AUGUST'
        WHEN 9 THEN 'SEPTEMBER'
        WHEN 10 THEN 'OCTOBER'
        WHEN 11 THEN 'NOVEMBER'
        WHEN 12 THEN 'DECEMBER'
    END AS month_name,
    total_orders,
    late_orders,
    late_rate,
    LAG(late_rate) OVER(
        ORDER BY order_year, order_month) AS prev_month_rate,
    ROUND(late_rate - LAG(late_rate) OVER(
        ORDER BY order_year, order_month), 2) AS rate_change
FROM monthly_trend
ORDER BY order_year, order_month;

-- Which product department suffers most from late deliveries — 
-- and how much does a late delivery reduce profit in each department? --
WITH dept_analysis AS (
    SELECT
        Department_Name,
        COUNT(*) AS total_orders,
        SUM(CASE WHEN Delivery_Status = 'Late delivery'
            THEN 1 ELSE 0 END) AS late_orders,
        ROUND(SUM(CASE WHEN Delivery_Status = 'Late delivery'
            THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_rate,
        ROUND(AVG(CASE WHEN Delivery_Status = 'Late delivery'
            THEN Order_Profit_Per_Order END), 2) AS avg_late_profit,
        ROUND(AVG(CASE WHEN Delivery_Status != 'Late delivery'
            THEN Order_Profit_Per_Order END), 2) AS avg_ontime_profit,
        ROUND(AVG(CASE WHEN Delivery_Status = 'Late delivery'
            THEN Order_Profit_Per_Order END) -
            AVG(CASE WHEN Delivery_Status != 'Late delivery'
            THEN Order_Profit_Per_Order END), 2) AS profit_gap
    FROM order_list
    GROUP BY Department_Name
)
SELECT
    Department_Name,
    total_orders,
    late_orders,
    late_rate,
    avg_late_profit,
    avg_ontime_profit,
    profit_gap,
    RANK() OVER(ORDER BY profit_gap ASC) AS profit_impact_rank
FROM dept_analysis
ORDER BY profit_impact_rank;