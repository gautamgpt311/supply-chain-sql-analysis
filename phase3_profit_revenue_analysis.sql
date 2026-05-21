-- Phase 3 Profit & Revenue Analysis --

-- Which global market generates the most revenue and profit? What is the profit margin per market? --
WITH market_analysis AS (
	SELECT
		Market,
		COUNT(*) AS total_orders,
		ROUND(SUM(Sales), 2) AS total_revenue,
		ROUND(SUM(Order_Profit_Per_Order), 2) AS total_profit,
		ROUND(SUM(Order_Profit_Per_Order) * 100.0 /
			SUM(Sales), 2) AS profit_margin_pct,
		ROUND(AVG(Sales), 2) AS avg_order_value
	FROM order_list
	GROUP BY Market
)
SELECT
	Market,
    total_orders,
    total_revenue,
    total_profit,
    profit_margin_pct,
    avg_order_value,
    RANK() OVER(ORDER BY total_profit DESC) AS rank_profit
FROM market_analysis
ORDER BY rank_profit;

-- Are discounts helping or hurting the business? Analyze how different discount levels affect profit. --
SELECT
    CASE 
        WHEN Order_Item_Discount_Rate = 0 THEN '0% No Discount'
        WHEN Order_Item_Discount_Rate <= 0.10 THEN '1-10% Low'
        WHEN Order_Item_Discount_Rate <= 0.20 THEN '11-20% Medium'
        ELSE '21%+ High'
    END AS discount_bucket,
    COUNT(*) AS total_orders,
    ROUND(AVG(Order_Item_Discount_Rate)*100.0, 2) AS avg_discount_pct,
    ROUND(AVG(Order_Profit_Per_Order), 2) AS avg_profit,
    ROUND(AVG(Sales), 2) AS avg_sales,
    ROUND(SUM(CASE WHEN Order_Profit_Per_Order < 0 
        THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 2) AS negative_profit_pct
FROM order_list
GROUP BY discount_bucket
ORDER BY avg_discount_pct;

-- Which are the 5 most profitable and 5 least profitable products? --
(SELECT
	Product_Name,
    COUNT(*) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Order_Profit_Per_Order), 2) as total_profit,
	ROUND(SUM(Order_Profit_Per_Order) * 100.0 / SUM(Sales), 2) as profit_margin,
    'Top Performer' AS category
FROM order_list
GROUP BY Product_Name
ORDER BY total_profit DESC
LIMIT 5)

UNION ALL

(SELECT
	Product_Name,
    COUNT(*) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Order_Profit_Per_Order), 2) as total_profit,
	ROUND(SUM(Order_Profit_Per_Order) * 100.0 / SUM(Sales), 2) as profit_margin,
    'Bottom Performer' AS category
FROM order_list
GROUP BY Product_Name
ORDER BY total_profit ASC
LIMIT 5)

ORDER BY category DESC, total_profit DESC;

-- Which customer segment — Consumer, Corporate or Home Office — is most profitable? --
WITH customer_analysis AS (
	SELECT
		Customer_Segment,
		COUNT(*) AS total_orders,
		ROUND(SUM(Sales), 2) AS total_revenue,
		ROUND(SUM(Order_Profit_Per_Order), 2) AS total_profit,
		ROUND(SUM(Order_Profit_Per_Order) * 100.0 / SUM(Sales), 2) AS profit_margin,
		ROUND(AVG(Sales), 2) AS avg_order_value
	FROM order_list
	GROUP BY Customer_Segment
)
SELECT
	Customer_Segment,
    total_orders,
    total_revenue,
    total_profit,
    profit_margin,
    avg_order_value,
    CASE WHEN profit_margin >= 30 THEN 'HIGH'
		WHEN profit_margin >= 20 THEN 'MEDIUM'
        ELSE 'LOW'
	END AS margin_category,
    RANK() OVER(ORDER BY profit_margin DESC) AS profit_rank
FROM customer_analysis
ORDER BY profit_rank;

-- Track monthly revenue and profit trends across all years. Which months show growth and which show decline? --
WITH monthly_analysis AS (
	SELECT
		YEAR(Order_Date) AS order_year,
		MONTH(Order_Date) AS order_month,
		ROUND(SUM(Sales), 2) AS monthly_revenue,
		ROUND(SUM(Order_Profit_Per_Order), 2) AS monthly_profit
	FROM order_list
	GROUP BY order_year, order_month
)
SELECT
	order_year,
    order_month,
    monthly_revenue,
    monthly_profit,
    LAG(monthly_revenue) OVER(ORDER BY order_year, order_month) AS prev_month_revenue,
    ROUND((monthly_revenue - LAG(monthly_revenue) OVER(ORDER BY order_year, order_month)), 2) AS revenue_change,
    ROUND((monthly_revenue - LAG(monthly_revenue) OVER(ORDER BY order_year, order_month)) * 100.0 /
		LAG(monthly_revenue) OVER(ORDER BY order_year, order_month), 2) AS revenue_pct
FROM monthly_analysis
ORDER BY order_year, order_month;