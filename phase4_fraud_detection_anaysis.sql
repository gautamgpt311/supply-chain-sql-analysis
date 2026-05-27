-- Phase 4 Fraud Detection Analysis --

-- How many suspected fraud orders exist and what is their total financial impact on the business? --
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN Order_Status = 'SUSPECTED_FRAUD'
        THEN 1 ELSE 0 END) AS fraud_orders,
    ROUND(SUM(CASE WHEN Order_Status = 'SUSPECTED_FRAUD'
        THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 2) AS fraud_pct,
    ROUND(SUM(CASE WHEN Order_Status = 'SUSPECTED_FRAUD'
        THEN Sales ELSE 0 END), 2) AS fraud_revenue_at_risk,
    ROUND(AVG(CASE WHEN Order_Status = 'SUSPECTED_FRAUD'
        THEN Sales END), 2) AS avg_fraud_order_value,
    ROUND(AVG(CASE WHEN Order_Status != 'SUSPECTED_FRAUD'
        THEN Sales END), 2) AS avg_normal_order_value,
    ROUND(AVG(CASE WHEN Order_Status = 'SUSPECTED_FRAUD'
        THEN Sales END) -
        AVG(CASE WHEN Order_Status != 'SUSPECTED_FRAUD'
        THEN Sales END), 2) AS fraud_vs_normal_diff
FROM order_list;

-- Which markets have the highest fraud rates? Is fraud concentrated in specific regions? --
WITH market_fraud_analysis AS (
	SELECT
		Market,
		COUNT(*) AS total_orders,
		COUNT(CASE WHEN Order_Status = 'SUSPECTED_FRAUD' THEN 1 ELSE NULL END) AS total_fraud_orders,
		ROUND(COUNT(CASE WHEN Order_Status = 'SUSPECTED_FRAUD' THEN 1 ELSE NULL END) * 100.0 
			/ COUNT(*), 2) AS fraud_rate,
		ROUND(SUM(Sales), 2) AS total_revenue,
		ROUND(SUM(CASE WHEN Order_Status = 'SUSPECTED_FRAUD' THEN Sales ELSE 0 END), 2) AS fraud_revenue
	FROM order_list
	GROUP BY Market
)
SELECT
	Market,
    total_orders,
    total_fraud_orders,
    fraud_rate,
    total_revenue,
    fraud_revenue,
    RANK() OVER (ORDER BY fraud_rate DESC) AS fraud_rank
FROM market_fraud_analysis;

-- What do fraud orders look like compared to normal orders —
-- are they larger, use different shipping, have different discount patterns? --
SELECT
	ROUND(AVG(CASE WHEN Order_Status = 'SUSPECTED_FRAUD' THEN Order_Item_Quantity END), 2) AS avg_quantity,
    ROUND(AVG(CASE WHEN Order_Status = 'SUSPECTED_FRAUD' THEN Days_for_shipping_real END), 2) AS avg_shipping_days,
    ROUND(AVG(CASE WHEN Order_Status = 'SUSPECTED_FRAUD' THEN Order_Item_Discount_Rate END), 2) AS avg_discount_rate,
    ROUND(AVG(CASE WHEN Order_Status = 'SUSPECTED_FRAUD' THEN Sales END), 2) AS avg_sales,
    ROUND(AVG(CASE WHEN Order_Status = 'SUSPECTED_FRAUD' THEN Order_Profit_Per_Order END), 2) AS avg_profit
FROM Order_list;

-- Which customer segment is most associated with fraud orders? --
WITH customer_segment_analysis AS (
	SELECT
		Customer_Segment,
		COUNT(*) AS total_orders,
		COUNT(CASE WHEN Order_Status = 'SUSPECTED_FRAUD' THEN 1 ELSE NULL END) AS total_fraud_orders,
		ROUND(COUNT(CASE WHEN Order_Status = 'SUSPECTED_FRAUD' THEN 1 ELSE NULL END) * 100.0 
			/ COUNT(*), 2) AS fraud_rate,
		ROUND(AVG(CASE WHEN Order_Status = 'SUSPECTED_FRAUD' THEN Sales END), 2) AS avg_fraud_order_value,
        ROUND(SUM(CASE WHEN Order_Status = 'SUSPECTED_FRAUD' THEN Sales ELSE 0 END), 2) AS total_fraud_revenue
	FROM order_list
	GROUP BY Customer_Segment
)
SELECT
	Customer_Segment,
    total_orders,
    total_fraud_orders,
    fraud_rate,
    avg_fraud_order_value,
    total_fraud_revenue,
    RANK() OVER (ORDER BY fraud_rate DESC) AS fraud_rank
FROM customer_segment_analysis;