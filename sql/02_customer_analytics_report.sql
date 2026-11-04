-- =============================================================================
-- CUSTOMER REPORT: This report consolidates key customer metrics and behaviors |
-- =============================================================================

/*
HIGHLIGHTS:
1. GATHERS essential fields such as names, ages, and transaction details.
2. SEGMENTS customers into categories (VIP, Regular, New) and age groups.
3. AGGREGATES customer-level metrics:
   - total orders
   - total sales
   - total quantity purchased
   - total products
   - lifespan (in months)
4. CALCULATES valuable KPIs:
   - recency (months since last order)
   - average order value
   - average monthly spend
*/

IF OBJECT_ID('gold.report_customers', 'v') IS NOT NULL
DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS 

WITH BASE_QUERY AS 
(
-- Retrieves core columns from fact_sales and dim_customers
SELECT 
S.order_number,
S.product_key, 
S.order_date,
S.sales_amount,
S.quantity,
C.customer_key,
C.customer_number,
CONCAT(C.first_name, ' ', C.last_name) AS CUSTOMER_NAME,
DATEDIFF(YEAR, birth_date, GETDATE()) AS AGE
FROM gold.fact_sales AS S 
LEFT JOIN gold.dim_customers AS C
ON S.customer_key = C.customer_key
WHERE order_date IS NOT NULL
)
, CUSTOMER_AGGREGATION AS
(
-- Summarizes key metrics at the customer level 
SELECT 
customer_key,
customer_number,
CUSTOMER_NAME,
AGE,
COUNT(DISTINCT order_number) AS TOTAL_ORDERS,
SUM(sales_amount) AS TOTAL_SALES,
SUM(quantity) AS TOTAL_QUANTITY,
COUNT(DISTINCT product_key) AS TOTAL_PRODUCTS,
MAX(order_date) AS LAST_ORDERDATE,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS LIFESPAN
FROM BASE_QUERY 
GROUP BY customer_key,
		 customer_number,
		 CUSTOMER_NAME,
		 AGE
)
-- Final Metrics: Combines all customer results into one output
SELECT 
customer_key,
customer_number,
CUSTOMER_NAME,
AGE,
CASE
	WHEN AGE < 20 THEN 'UNDER 20'
	WHEN AGE BETWEEN 20 AND 29 THEN '20-29'
	WHEN AGE BETWEEN 30 AND 39 THEN '30-39'
	WHEN AGE BETWEEN 40 AND 49 THEN '40-40'
	ELSE '50 AND ABOVE'
END AS AGE_GROUP,
CASE
	WHEN LIFESPAN >= 12 AND TOTAL_SALES > 5000 THEN 'VIP'
	WHEN LIFESPAN >= 12 AND TOTAL_SALES <= 5000 THEN 'REGULAR'
	ELSE 'NEW'
END AS CUSTOMER_SEGMENT,
LAST_ORDERDATE,
DATEDIFF(MONTH, LAST_ORDERDATE, GETDATE()) AS RECENCY,
TOTAL_ORDERS,
TOTAL_SALES,
TOTAL_QUANTITY, 
TOTAL_PRODUCTS, 
LIFESPAN,
-- Average order value (AVO)
CASE
	WHEN TOTAL_SALES = 0 THEN 0
	ELSE TOTAL_SALES / TOTAL_ORDERS
END AS AVG_ORDER_VALUE,
-- Average monthly spend 
CASE
	WHEN LIFESPAN = 0 THEN TOTAL_SALES
	ELSE TOTAL_SALES / LIFESPAN
END AS AVG_MONTHLY_SPEND
FROM CUSTOMER_AGGREGATION;

-- VERIFY (Report)
SELECT *
FROM GOLD.report_customers;

