# DataCo Supply Chain Analysis — SQL Project

## About This Project

Global supply chains generate millions of orders daily and even small inefficiencies in delivery or fraud detection translate into significant revenue loss. I wanted to understand how a data analyst approaches these operational problems using nothing but SQL.

Working with 180,519 real orders across 5 global markets I investigated three core business problems — why more than half of all orders arrive late, where profit is being lost silently through discounts, and whether SQL queries alone can identify patterns that indicate fraudulent orders.

The analysis revealed that 54.8% late delivery rate is not a random problem — it traces directly to Standard Class shipping mode. Discounts above 20% reduce profit by 39% with zero increase in order value. And 4,062 suspected fraud orders worth $730,000 show a consistent pattern of higher than average order values across all markets.

These are the kind of findings that operations and finance teams in logistics companies act on directly.

## Dataset
- Source: Kaggle — DataCo Smart Supply Chain Dataset
- Size: 180,519 orders | 53 columns | 1 table
- Markets: 5 global markets across 164 countries
- Period: 2015 to 2018
- Tool: MySQL 8.0, MySQL Workbench

## What I Investigated

- Why are 54% of orders arriving late?
- Which shipping mode and market has worst delivery performance?
- Are discounts actually helping revenue or hurting profit?
- Which products are losing money on every sale?
- Can SQL detect patterns in suspected fraud orders?
- Which markets have highest fraud risk and revenue at risk?

## Key Findings

**Delivery Crisis**
54.8% of all orders arrive late — more than half. Standard Class shipping is the main culprit with a 60% late delivery rate despite being the most used shipping mode carrying over 107,000 orders. Only 17.8% of orders ship exactly on time.

**Discounts Are Hurting Profit**
Orders with no discount average $26.67 profit. Orders with 21%+ discount average only $19.13 profit — a 39% reduction. The order value stays the same around $203 regardless of discount level, meaning discounts are purely giving away profit with no benefit in return.

**Fraud Detection**
4,062 orders are flagged as suspected fraud — 2.2% of all orders — putting approximately $730,000 of revenue at risk. Fraud orders have a higher average value than normal orders which matches known fraud patterns where fraudsters place larger than average orders.

**Market Performance**
LATAM generates the highest profit despite not being the largest market by order volume. All five markets show consistent profit margins around 28-30% suggesting a uniform global pricing strategy.

## Challenges I Faced

The most interesting debugging challenge in this project was discovering that the Shipping_Mode column had hidden carriage return characters at the end of every value. All my CASE WHEN comparisons were returning zero even though the values looked correct on screen.

I diagnosed the issue using MySQL's HEX() function which showed every value ending in 0D — the hex code for carriage return. I fixed it permanently across all 180,519 rows using TRIM combined with REPLACE to remove the hidden character.

This taught me that data quality issues are not always visible — sometimes you need to inspect the raw bytes to understand what is really stored in the database.

The dataset also had date values in US format (MM/DD/YYYY HH:MM) which MySQL could not parse directly. I converted them during import using STR_TO_DATE() with the correct format mask.

## SQL Skills Demonstrated

- DATEDIFF and date functions for delivery gap analysis
- YEAR() and MONTH() for time series analysis
- Fraud detection using conditional aggregation
- LAG() window function for month over month trends
- RANK() and ROW_NUMBER() for performance rankings
- Multi-level chained CTEs
- CASE WHEN pivoting for cross-tab analysis
- UNION ALL for combining top and bottom performers
- STDDEV() for consistency analysis
- ROLLUP for automatic subtotals and grand totals
- STR_TO_DATE() for date format conversion

## Project Structure

```
├── 00_sql_schema.sql
├── phase1_data_exploration.sql
├── phase2_delivery_performance.sql
├── phase3_profit_revenue_analysis.sql
├── phase4_fraud_detection_analysis.sql
├── phase5_customer_market_intelligence.sql
└── README.md
```

## How to Run

1. Run 00_sql_schema.sql to create database and table
2. Download dataset from Kaggle
3. Place CSV in MySQL uploads folder
4. Run LOAD DATA INFILE from 00_sql_schema.sql
5. Execute phases 1 through 5 in order
