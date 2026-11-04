-- Read-only checks; run in the Gold warehouse database before reporting.
SELECT COUNT(*) AS sales_rows,
       COUNT(DISTINCT order_number) AS distinct_orders,
       COUNT(DISTINCT customer_key) AS purchasing_customers,
       COUNT(DISTINCT product_key) AS selling_products,
       SUM(quantity) AS units_sold,
       SUM(sales_amount) AS recorded_sales_amount
FROM gold.fact_sales;

SELECT MIN(order_date) AS first_order_date,
       MAX(order_date) AS last_order_date,
       SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS undated_sales_rows,
       SUM(CASE WHEN order_date IS NULL THEN sales_amount ELSE 0 END) AS undated_sales_amount
FROM gold.fact_sales;

SELECT (SELECT COUNT(*) FROM gold.dim_customers) AS customer_dimension_rows,
       (SELECT COUNT(*) FROM gold.dim_products) AS product_dimension_rows,
       (SELECT COUNT(DISTINCT product_key) FROM gold.fact_sales) AS products_with_sales;

SELECT COUNT(*) AS unmatched_customer_fact_rows
FROM gold.fact_sales AS f
WHERE f.customer_key IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM gold.dim_customers AS c
                  WHERE c.customer_key = f.customer_key);

SELECT COUNT(*) AS unmatched_product_fact_rows
FROM gold.fact_sales AS f
WHERE f.product_key IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM gold.dim_products AS p
                  WHERE p.product_key = f.product_key);

SELECT customer_key, COUNT(*) AS key_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

SELECT product_key, COUNT(*) AS key_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- Compare view totals with dated fact sales after creating the reporting views.
SELECT SUM(sales_amount) AS dated_sales_amount
FROM gold.fact_sales WHERE order_date IS NOT NULL;
