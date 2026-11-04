--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ADVANCED ANALYTICS PROJECT ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

-- =================================================================================================================================================
-- #1 CHANGES-OVER-TIME ANALYSIS (TREND ANALYSIS): Analyse how a measure evolves over time.Helps track trends and identify seasonality in your data. 
-- =================================================================================================================================================

-- -------------------------------------------------------------------------------------------------------------------------
-- TASK: Analyse sales performance over time. also analyse customer retension over time. and items(quantity) sold over time.|
-- -------------------------------------------------------------------------------------------------------------------------
SELECT TOP 2 *
FROM gold.fact_sales
-- CHANGES-OVER-YEARS: A high-level overview insights that helps with strategic decision-making.
SELECT 
DATETRUNC(YEAR, order_date) AS YEAR,
SUM(sales_amount) AS TOTAL_SALES,	--> Revenue
COUNT(DISTINCT customer_key) AS TOTAL_CUSTOMERS,
SUM(quantity) AS TOTAL_QUANTITY
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR, order_date)
ORDER BY DATETRUNC(YEAR, order_date) ASC;

-- CHANGES-OVER-MONTHS: Detailed insight to discover seasonality in your data.
SELECT 
DATETRUNC(MONTH, order_date) AS MONTH,
SUM(sales_amount) AS TOTAL_SALES,	--> Revenue
COUNT(DISTINCT customer_key) AS TOTAL_CUSTOMERS,
SUM(quantity) AS TOTAL_QUANTITY
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date) ASC;

-- CHANGES-OVER-MONTHS WITH YEARS: Above query also shows changes over month with year due to the retention of year by using DATETRUNC() function.
-- BUSINESS INSIGHT: Helps to discover seasonality in your data and also helps to compare sales performance year-on-year.
--                 : In addition, it also helps to discover customer retention and quantity sold year-on-year.

-- =============================================================================================================================================
-- #2 CUMULATIVE ANALYSIS: It aggregate the data progressively over time which helps to understand whether our business is growing or declining.
-- =============================================================================================================================================

-- ----------------------------------------------------------------------------------------
-- COMPLETE FIVE YEARS: MONTH_WISE														   |
-- TASK 1: Calculate the total sales per month and running total of sales over time.       |
-- TASK 2: Calcualte the average price per month and the moving average of price over time.|
-- ----------------------------------------------------------------------------------------
SELECT *,
SUM(TOTAL_SALES) OVER(ORDER BY MONTH ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RUNNING_TOTAL_SALES,
AVG(AVG_PRICE) OVER(ORDER BY MONTH ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS MOVING_AVG_PRICE
FROM(
SELECT 
DATETRUNC(MONTH, order_date) AS MONTH,
SUM(sales_amount) AS TOTAL_SALES,
AVG(price) AS AVG_PRICE
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date) 
)T;

-- ---------------------------------------------------------------------------------------
-- COMPLETE FIVE YEARS: YEAR_WISE														   |	
-- TASK 1: Calculate the total sales per month and running total of sales over time.       |
-- TASK 2: Calcualte the average price per month and the moving average of price over time.|
-- ----------------------------------------------------------------------------------------
SELECT *,
SUM(TOTAL_SALES) OVER(ORDER BY YEAR ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RUNNING_TOTAL_SALES,
AVG(AVG_PRICE) OVER(ORDER BY YEAR ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS MOVING_AVG_PRICE
FROM(
SELECT 
DATETRUNC(YEAR, order_date) AS YEAR,
SUM(sales_amount) AS TOTAL_SALES,
AVG(price) AS AVG_PRICE
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR, order_date) 
)T;

-- ======================================================================================================================
-- #3 PERFORMANCE ANALYSIS: Comparing the current value to a target value. Helps measure success and compare performance.
-- ======================================================================================================================

-- ----------------------------------------------------------------------------------
-- TASK: Analyse the yearly performance of products by comparing their sales to both |
--     : the average sales performance of the product and the previous years sales.  |
-- ----------------------------------------------------------------------------------
WITH YEARLY_PRODUCT_SALES AS
(
SELECT 
P.product_name,
DATETRUNC(YEAR, S.order_date) AS YEAR,
SUM(S.sales_amount) AS CURRENT_SALES
FROM gold.fact_sales AS S
LEFT JOIN gold.dim_products P
ON S.product_key = P.product_key
WHERE order_date IS NOT NULL
GROUP BY P.product_name, DATETRUNC(YEAR, order_date)
)
, PRODUCT_SALES_ANALYSIS AS 
(
SELECT 
product_name,
YEAR,
CURRENT_SALES,
AVG(CURRENT_SALES) OVER(PARTITION BY product_name) AS AVG_SALES,
LAG(CURRENT_SALES) OVER(PARTITION BY product_name ORDER BY YEAR ASC) AS PREVIOUS_SALES
FROM YEARLY_PRODUCT_SALES
)
SELECT 
product_name,
YEAR,
CURRENT_SALES,
AVG_SALES,
CURRENT_SALES - AVG_SALES AS AVG_DIFF,
CASE 
	WHEN CURRENT_SALES - AVG_SALES > 0 THEN 'ABOVE AVG'
	WHEN CURRENT_SALES - AVG_SALES < 0 THEN 'BELOW AVG'
	ELSE 'AVG'
END AS AVG_CHANGE,
PREVIOUS_SALES,
CURRENT_SALES - PREVIOUS_SALES AS DIFF_WITH_PREVIOUS_YEAR,
CASE
	WHEN PREVIOUS_SALES IS NULL THEN 'NO PREVIOUS YEAR'
	WHEN CURRENT_SALES - PREVIOUS_SALES > 0 THEN 'INCREASING'
	WHEN CURRENT_SALES - PREVIOUS_SALES < 0 THEN 'DECREASING'
	ELSE 'NO CHANGE'
END AS SALES_CHANGE
FROM PRODUCT_SALES_ANALYSIS
ORDER BY product_name, YEAR;

-- ======================================================================================================================================================================
-- #4 Data Segmentation Analysis: To group data into meaningful categories for targeted insights.For customer segmentation, product categorization, or regional analysis.
-- ======================================================================================================================================================================

-- -------------------------------------------------------------------------------------------
-- TASK: Segment products into cost ranges and count how many products fall into each segment.|
-- -------------------------------------------------------------------------------------------

WITH PRODUCT_COST_RANGE AS (
SELECT 
product_key,
product_name,
CASE 
	WHEN product_cost IS NULL THEN 'N/A'
	WHEN product_cost < 100 THEN 'BELOW 100'
	WHEN product_cost BETWEEN 100 AND 500 THEN '100-500'
	WHEN product_cost BETWEEN 500 AND 1000 THEN '500-1000'
	ELSE 'ABOVE 1000'
END AS PRODUCT_COST_SEGMENTATION
FROM gold.dim_products
)
SELECT 
PRODUCT_COST_SEGMENTATION,
COUNT(product_key) AS TOTAL_PRODUCTS
FROM PRODUCT_COST_RANGE
GROUP BY PRODUCT_COST_SEGMENTATION
ORDER BY TOTAL_PRODUCTS DESC;

-- ----------------------------------------------------------------------------------------
--  TASK: Group customers into three segments based on their spending behavior:            |   
--      - VIP: Customers with at least 12 months of history and spending more than 5,000.  |
--      - Regular: Customers with at least 12 months of history but spending 5,000 or less.|
--      - New: Customers with a lifespan less than 12 months.                              |
--        And find the total number of customers by each group                             |
-- ----------------------------------------------------------------------------------------

WITH CUSTOMER_SPENDING AS 
(
SELECT 
customer_key,
SUM(sales_amount) AS TOTAL_SPENDING,
MIN(order_date) AS FIRST_ORDER,
MAX(order_date) AS LAST_ORDER,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS LIFESPAN
FROM gold.fact_sales 
GROUP BY customer_key
)
SELECT 
CUSTOMER_SEGMENTATION,
COUNT(customer_key) AS TOTAL_CUSTOMERS	
FROM (

	SELECT 
	customer_key,
	CASE
		WHEN LIFESPAN >= 12 AND TOTAL_SPENDING > 5000 THEN 'VIP'
		WHEN LIFESPAN >= 12 AND TOTAL_SPENDING <= 5000 THEN 'REGULAR'
		ELSE 'NEW'
	END AS CUSTOMER_SEGMENTATION
	FROM CUSTOMER_SPENDING 
)T
GROUP BY CUSTOMER_SEGMENTATION
ORDER BY TOTAL_CUSTOMERS DESC;

-- ===============================================================================================
-- #5 Part-to-Whole Analysis: To compare performance or metrics across dimensions or time periods.
--                          : To evaluate differences between categories.                         
--						    : Useful for A/B testing or regional comparisons.                     
-- ===============================================================================================

-- -------------------------------------------------------------
-- TASK: Which categories contribute the most to overall sales? |
-- -------------------------------------------------------------

WITH CATEGORY_SALES AS 
(
SELECT 
P.category,
SUM(S.sales_amount) AS TOTAL_SALES
FROM gold.fact_sales AS S
LEFT JOIN gold.dim_products AS P
ON S.product_key = P.product_key
GROUP BY category
)
SELECT *,
ROUND(CAST(TOTAL_SALES AS FLOAT) / OVERALL_SALES * 100, 2) AS PERCENTAGE_OF_TOTAL
FROM(
	SELECT 
	category,
	TOTAL_SALES,
	SUM(TOTAL_SALES) OVER () AS OVERALL_SALES
	FROM CATEGORY_SALES
)T
ORDER BY TOTAL_SALES DESC;

-- ===========================================================================================================================
-- #6 CUSTOMER RETENTION ANALYSIS (YEAR-OVER-YEAR): Measures how many customers continue purchasing from a business over time.
--                                                : Retention Rate =  Returning Customers / Previous Period Customers � 100
-- ===========================================================================================================================
WITH CUSTOMER_YEAR AS 
(
-- Identify unique customers for each year
SELECT DISTINCT
customer_key,
DATETRUNC(YEAR, order_date) AS YEAR
FROM gold.fact_sales
WHERE order_date IS NOT NULL AND customer_key IS NOT NULL 
)
, YEARLY_CUSTOMERS AS 
(
-- Calculate total customers for each year
SELECT 
YEAR,
COUNT(customer_key) AS TOTAL_CUSTOMERS
FROM CUSTOMER_YEAR 
GROUP BY YEAR 
)
, RETAINED_CUSTOMERS AS 
(
-- Identify customers who returned in the following year
SELECT 
C1.YEAR,
COUNT(*) AS RETURNING_CUSTOMERS
FROM CUSTOMER_YEAR AS C1
INNER JOIN CUSTOMER_YEAR AS C2 
ON C1.customer_key = C2.customer_key AND C2.YEAR = DATEADD(YEAR, 1, C1.YEAR)
GROUP BY C1.YEAR
)
-- Final retention analysis
SELECT 
Y.YEAR,
Y.TOTAL_CUSTOMERS,
CASE	
	WHEN Y_NEXT.YEAR IS NULL THEN NULL 
	ELSE COALESCE(R.RETURNING_CUSTOMERS, 0)
END AS RETURNING_CUSTOMERS,
CAST(100.0 * R.RETURNING_CUSTOMERS / NULLIF(Y.TOTAL_CUSTOMERS,0) AS DECIMAL(10,2))  AS RETENTION_RATE
FROM YEARLY_CUSTOMERS AS Y
LEFT JOIN RETAINED_CUSTOMERS AS R
ON Y.YEAR = R.YEAR
LEFT JOIN YEARLY_CUSTOMERS AS Y_NEXT 
ON Y_NEXT.YEAR = DATEADD(YEAR, 1, Y.YEAR)
ORDER BY Y.YEAR;

-- ---------------------------------------------------------------------------------------
-- Returning customer validation: How many customers purchased in both consecutive years? |
-- ---------------------------------------------------------------------------------------
WITH CUSTOMER_YEAR AS 
(
-- Identify unique customers for each year
SELECT DISTINCT
customer_key,
DATETRUNC(YEAR, order_date) AS YEAR
FROM gold.fact_sales
WHERE order_date IS NOT NULL AND customer_key IS NOT NULL 
)
, YEARLY_CUSTOMERS AS 
(
-- Calculate total customers for each year
SELECT 
YEAR,
COUNT(customer_key) AS TOTAL_CUSTOMERS
FROM CUSTOMER_YEAR 
GROUP BY YEAR 
)
, RETAINED_CUSTOMERS AS 
(
-- Identify customers who returned in the following year
SELECT 
C1.YEAR,
COUNT(*) AS RETURNING_CUSTOMERS
FROM CUSTOMER_YEAR AS C1
INNER JOIN CUSTOMER_YEAR AS C2 
ON C1.customer_key = C2.customer_key AND C2.YEAR = DATEADD(YEAR, 1, C1.YEAR)
GROUP BY C1.YEAR
)
SELECT
C1.YEAR AS PREVIOUS_YEAR,
C2.YEAR AS CURRENT_YEAR,
COUNT(DISTINCT C1.customer_key) AS RETURNING_CUSTOMERS
FROM CUSTOMER_YEAR C1
INNER JOIN CUSTOMER_YEAR C2
ON C1.customer_key = C2.customer_key AND C2.YEAR = DATEADD(YEAR, 1, C1.YEAR)
GROUP BY C1.YEAR, C2.YEAR
ORDER BY C1.YEAR ASC;

-- =======================================================================================================================================================
-- #7 CUSTOMER RETENTION ANALYSIS (MONTHLY COHORT RETENTION): Helps us understand customer purchasing behaviour month by month after their first purchase.
--															: Retention Rate = Original Cohort Size/Retained Customers � 100                             
-- =======================================================================================================================================================

WITH CUSTOMER_FIRST_PURCHASE AS 
(
-- Find the first purchase month for each customer
SELECT 
customer_key,
DATETRUNC(MONTH, MIN(order_date)) AS COHORT_MONTH
FROM gold.fact_sales
WHERE order_date IS NOT NULL AND customer_key IS NOT NULL
GROUP BY customer_key
)
, CUSTOMER_ACTIVITY AS 
(
-- Identify customer purchasing activity each month
SELECT DISTINCT
customer_key,
DATETRUNC(MONTH, order_date) AS PURCHASE_MONTH
FROM gold.fact_sales
WHERE order_date IS NOT NULL AND customer_key IS NOT NULL
)
, COHORT_DATA AS 
(
-- Calculate the number of months since first purchase
SELECT 
F.COHORT_MONTH,
A.PURCHASE_MONTH,
DATEDIFF(MONTH, F.COHORT_MONTH, A.PURCHASE_MONTH) AS MONTH_NUMBER,
A.customer_key
FROM CUSTOMER_FIRST_PURCHASE AS F
LEFT JOIN CUSTOMER_ACTIVITY AS A
ON F.customer_key = A.customer_key
)
, COHORT_SIZE AS 
(
-- Calculate the original size of each cohort
SELECT 
COHORT_MONTH,
COUNT(*) AS TOTAL_CUSTOMERS
FROM CUSTOMER_FIRST_PURCHASE
GROUP BY COHORT_MONTH
)
, COHORT_RETENTION AS 
(
-- Count active customers in each cohort month
SELECT 
COHORT_MONTH,
MONTH_NUMBER,
COUNT(DISTINCT customer_key) AS RETAINED_CUSTOMERS
FROM COHORT_DATA
GROUP BY COHORT_MONTH, MONTH_NUMBER
)
-- Final retention calculation
SELECT 
R.COHORT_MONTH,
R.MONTH_NUMBER,
S.TOTAL_CUSTOMERS,
CAST(R.RETAINED_CUSTOMERS * 100.0 / NULLIF(S.TOTAL_CUSTOMERS, 0) AS DECIMAL(10,2)) AS RETENTION_RATE
FROM COHORT_RETENTION AS R
INNER JOIN COHORT_SIZE AS S 
ON R.COHORT_MONTH = S.COHORT_MONTH
ORDER BY R.COHORT_MONTH ASC,
         R.MONTH_NUMBER ASC;


