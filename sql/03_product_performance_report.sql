-- ============================================================================
-- PRODUCT REPORT: This report consolidates key product metrics and behaviors. |
-- ============================================================================

/* 
HIGHLIGHTS:
1. GATHERS essential fields such as product name, category, subcategory, and cost.
2. SEGMENTS products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
3. AGGREGATES product-level metrics:
   - total orders
   - total sales
   - total quantity sold
   - total customers (unique)
   - lifespan (in months)
4. CALCULATES valuable KPIs:
   - recency (months since last sale)
   - average order revenue (AOR)
   - average monthly revenue
*/

IF OBJECT_ID('gold.report_product', 'v') IS NOT NULL
DROP VIEW gold.report_product;
GO

CREATE VIEW gold.report_product AS 

WITH BASE_QUERY AS
(
-- Retrieves core columns from fact_sales and dim_products
SELECT
S.order_number,
S.customer_key,
S.order_date, 
S.sales_amount, 
S.quantity,
P.product_key,
P.product_name,
P.category,
P.sub_category,
P.product_cost
FROM gold.fact_sales AS S 
LEFT JOIN gold.dim_products AS P
ON S.product_key = P.product_key
WHERE order_date IS NOT NULL
)
, PRODUCT_AGGREGATION AS 
(
-- Summarizes key metrics at the product level
SELECT 
product_key,
product_name,
category, 
sub_category,
product_cost,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS LIFESPAN,
MAX(order_date) AS LAST_SALE_DATE,
COUNT(DISTINCT order_number) AS TOTAL_ORDERS,
COUNT(DISTINCT customer_key) AS TOTAL_CUSTOMERS,
SUM(sales_amount) AS TOTAL_SALES,
SUM(quantity) AS TOTAL_QUANTITY,
ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS AVG_SELLING_PRICE
FROM BASE_QUERY
GROUP BY product_key,
		 product_name,
		 category, 
		 sub_category,
		 product_cost
)
-- Final Metrics: Combines all product results into one output
SELECT 
product_key,
product_name,
category,
sub_category,
product_cost,
LAST_SALE_DATE,
DATEDIFF(MONTH, LAST_SALE_DATE, GETDATE()) AS RECENCY,
CASE
	WHEN TOTAL_SALES > 50000 THEN 'HIGH PERFORMER'
	WHEN TOTAL_SALES > 10000 THEN 'AVG PERFORMER'
	ELSE 'LOW PERFORMER'
END AS PRODUCT_SEGMENT,
LIFESPAN,
TOTAL_ORDERS,
TOTAL_CUSTOMERS,
TOTAL_SALES,
TOTAL_QUANTITY,
AVG_SELLING_PRICE,
-- Average Order Revenue (AOR)
CASE 
	WHEN TOTAL_ORDERS = 0 THEN 0
	ELSE TOTAL_SALES / TOTAL_ORDERS
END AS AVG_ORDER_REVENUE,
-- Average Monthly Revenue
CASE
	WHEN LIFESPAN = 0 THEN TOTAL_SALES
	ELSE TOTAL_SALES / LIFESPAN
END AS AVG_MONTHLY_REVENUE
FROM PRODUCT_AGGREGATION;

-- VERIFY (Report)
SELECT *
FROM gold.report_product;
