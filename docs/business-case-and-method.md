# Business case and analytical approach

## Business objective
Help retail decision-makers investigate **revenue change**, **repeat customer activity**, and **product/category sales concentration** using SQL Server.

## Source and grain
- `gold.fact_sales`: transaction records (a record does **not** necessarily equal an order).
- `gold.dim_customers`: customer-level descriptive attributes.
- `gold.dim_products`: product-level descriptive attributes, including current-state details.

The analysis uses the Gold layer of a companion Medallion warehouse. Distinct orders and distinct purchasing customers must be counted at their correct grains.

## Deliverables
- Advanced SQL trends, cumulative revenue, period comparisons, customer segmentation, category share, annual returning-customer behavior and monthly first-purchase cohort activity.
- `gold.report_customers`: customer attributes, purchase KPIs, time-based and segmentation fields for BI.
- `gold.report_product`: product performance, sales and purchase KPIs for BI.
- Data-quality preflight SQL and documented caveats.

## Questions for stakeholders
1. How did recorded sales change over the observed periods, accounting for incomplete periods?
2. Which customer cohorts returned in subsequent months?
3. Which product categories account for a high proportion of sales?
4. Which customer and product groups warrant further investigation?

**Interpretation:** These metrics describe the historical dataset; they do not demonstrate client impact, causal drivers, historical profit, or production deployment.

## Before client use
Verify query results in native SQL Server, record date coverage and source currency, reconcile totals, standardize an as-of date and investigate missing dates or dimension values. Do not publish identifying customer data.
