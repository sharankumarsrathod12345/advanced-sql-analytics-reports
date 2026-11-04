# Advanced SQL Analytics | Customer & Product Intelligence

**SQL Server • T-SQL • Business Intelligence • Window Functions • Cohort Retention • Customer Segmentation**

An end-to-end **analytical reporting project** built on the Gold layer of a SQL Server Medallion data warehouse. The project answers commercial questions about revenue trends, repeat purchasing, customer value, category concentration and product performance.

> **Portfolio project, not a production deployment.** This repository contains the original course-capstone SQL scripts with documented assumptions and quality limitations. No client impact or production performance claims are made.

## Business context

Retail teams need a trustworthy view of revenue performance and customer/product behavior. Transaction tables alone make it difficult to compare periods, understand returning customers, identify high-value segments and prepare reusable BI reporting datasets.

**Objective:** Use a modeled sales warehouse to create advanced SQL analyses and reusable customer and product reporting views.

## What the project covers

| Workstream | Business question | SQL techniques |
| --- | --- | --- |
| Trend analysis | How do sales, units and purchasing customers change across years and months? | `DATETRUNC`, `GROUP BY`, distinct counts |
| Cumulative analysis | How does revenue accumulate across time? | `SUM() OVER`, `AVG() OVER`, ordered frames |
| Product performance | How does each product compare with its historical average and preceding observed year? | Multi-stage CTEs, `LAG`, window averages, `CASE` |
| Segmentation | Which customers are VIP/regular/new and which products fall in cost tiers? | Aggregations, CTEs, `CASE` |
| Revenue mix | Which product categories contribute most to recorded sales? | Joins, percentage of total, window aggregates |
| Annual retention | How many customers buy in consecutive calendar years? | Distinct customer-year pairs, self-join, date arithmetic |
| Cohort analysis | How does monthly activity change after a customer's first observed purchase? | First-purchase cohorts, offsets, distinct customer counts |
| Customer report | Which customers contribute the most sales and how recently did they buy? | Reusable view, multiple CTEs, AOV, recency, segmentation |
| Product report | Which selling products drive volume and revenue? | Reusable view, distinct orders/customers, performance groups |

## Repository structure

```text
advanced-sql-analytics-reports/
├── README.md
├── PORTFOLIO_ENTRY.md
├── sql/
│   ├── 00_preflight_checks.sql
│   ├── 01_advanced_sql_analytics.sql
│   ├── 02_customer_analytics_report.sql
│   └── 03_product_performance_report.sql
└── docs/
    ├── business-case-and-method.md
    └── metric-definitions-and-limitations.md
```

## Requirements and run instructions

- Microsoft SQL Server **2022 or later** for `DATETRUNC`, and SQL Server Management Studio (SSMS).
- An existing SQL Server database with `gold.fact_sales`, `gold.dim_customers` and `gold.dim_products` from the related [Medallion warehouse project](https://github.com/sharankumarsrathod12345/sql-data-warehouse-project).
- Run from the correct warehouse database context, not `master`.

1. Execute `sql/00_preflight_checks.sql` and examine exceptions.
2. Execute individual sections in `sql/01_advanced_sql_analytics.sql` for exploratory analysis.
3. Review definitions and assumptions before deploying the views.
4. Execute `sql/02_customer_analytics_report.sql` and `sql/03_product_performance_report.sql` **in a development database**. The supplied original scripts drop and recreate existing views named `gold.report_customers` and `gold.report_product`.
5. Inspect `SELECT * FROM gold.report_customers` and `SELECT * FROM gold.report_product` results in SSMS; validate totals and categories before connecting a BI tool.

**Data sources:** The three analytical SQL scripts are included. The original dataset is not redistributed here. Use the companion warehouse/source data where access and redistribution rights permit.

## Snapshot-level observations

The supplied local CSV snapshot contains **60,398 sales rows**, **27,659 distinct order numbers**, **18,484 customer dimension records** and **295 product dimension records**. The sales amount field totals **29,356,250 units of unspecified currency**; this is source-recorded sales amount, not verified profit or collected cash. Only **130 products have observed fact sales**.

Recorded order dates span **2010-12-29 to 2014-01-28**. There are **19 undated sales records representing 4,992 sales units**, so date-restricted reports will not reconcile to unrestricted totals unless exclusions are explained. The dataset's first and last calendar years are partial.

See [metric definitions and limitations](docs/metric-definitions-and-limitations.md) for measurement assumptions and validation gaps.

## Demonstrated skills

`SQL Server` · `T-SQL` · `CTEs` · `Window Functions` · `LAG` · `DATETRUNC` · `Cohort Retention` · `Customer Segmentation` · `Aggregations` · `Views` · `Exploratory Data Analysis` · `Data Validation`

## Evidence and status

- **Included:** Source SQL, business-question map, data limitations, and initial preflight checks.
- **Not claimed:** Full SQL Server execution validation of these uploaded scripts, BI dashboard delivery, query-performance benchmarking, historical profit analysis, or deployed client outcomes.
- **Recommended before client use:** Confirm live-schema references, reconcile view totals to the fact table, define an as-of date, validate denominators and date coverage, and investigate data-quality exceptions.

**Project author:** Sharan Kumar Rathod  
**Related work:** [Medallion Warehouse & EDA](https://github.com/sharankumarsrathod12345/medallion-warehouse-eda-analytics)