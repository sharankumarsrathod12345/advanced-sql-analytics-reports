# Business case & analytical method

## Context
The dataset models a retail business with a sales fact table and two dimensions. It supports exploratory analytics and the development of reporting views, but is not a live transaction system.

## Analytical goals
1. **Trend:** Evaluate how recorded sales, units and purchasing customers change across periods.
2. **Customer:** Compare purchasing behavior by total spend, frequency and first observed purchase cohort.
3. **Product:** Distinguish sales amount, units and unique buying customers by product and category.
4. **Repeat purchase:** Explore consecutive-year purchasing and activity in months after the first observed purchase.
5. **Self-service reporting:** Offer customer-level and product-level views for BI analysis.

## Architecture and grain

`CRM/ERP → Bronze → Silver → gold.fact_sales + gold.dim_customers + gold.dim_products → analytics + customer/product views`

The fact table contains order/product records and is **not** at one-row-per-order grain. Use distinct order numbers for order count, while customer and product populations should be explicitly distinguished from purchasing populations.

## Analysis modules
- Trends by year and month (avoid interpreting incomplete first/last years as full periods).
- Cumulative sales/price metrics (be clear when averages are weighted versus averages of monthly averages).
- Product-year historical performance comparison (group by stable keys where required).
- Customer spending and product cost segmentation.
- Category sales share.
- Consecutive-year repeat purchasing and monthly cohorts from first observed purchase.

## Business interpretation
The project's purpose is descriptive analysis, not causal attribution. A high sales share suggests concentration, but cannot establish demand drivers. A product with no recorded sale may be inactive, unlaunched, out of stock or absent due to source scope. Any recommendations require context beyond the snapshot.

## Supporting controls
Optional SQL diagnostics are in [`../tests/data_quality_checks.sql`](../tests/data_quality_checks.sql). Analytical definitions, known quality issues and review limitations are in [`metric-definitions-and-limitations.md`](metric-definitions-and-limitations.md).
