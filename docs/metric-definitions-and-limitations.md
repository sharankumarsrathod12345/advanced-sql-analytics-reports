# Metrics and quality limitations

## Metric dictionary

| Metric | Meaning |
| --- | --- |
| Recorded sales amount | Sum of `gold.fact_sales.sales_amount`; not profit or verified cash collected |
| Fact rows | Count of sales records; not unique orders |
| Distinct orders | `COUNT(DISTINCT order_number)` |
| Purchasing customers | `COUNT(DISTINCT customer_key)` within sales |
| Units | `SUM(quantity)` |
| Category share | Category sales / sales in the defined eligible population |
| First-purchase cohort | Month of first **observed** dated order |
| Annual returning buyer | Customer with orders in consecutive observed calendar years, subject to chosen eligibility |

## Local CSV snapshot profile (not live SQL Server execution)
- 60,398 sales fact rows; 27,659 distinct order numbers; 18,484 customer dimension rows; 295 products.
- Recorded sales amount: 29,356,250 (currency **unspecified**); quantity: 60,423.
- 130 distinct product keys appear in sales.
- Order dates observed from 2010-12-29 to 2014-01-28.
- 19 missing order dates represent a recorded sales amount of 4,992; dated sales total 29,351,258.
- Missing dimensions include 337 customer countries and 7 product categories.
- First and final calendar years are incomplete, so year-over-year comparisons require caution.

## Original-script limitations to review before delivery
- `GETDATE()` makes historical recency/age values change whenever views are queried.
- `DATEDIFF(YEAR, birth_date, GETDATE())` isn't a completed-birthday age and NULL age requires its own group.
- Customer view age label `40-40` is inconsistent with the implied 40–49 range.
- Some average-order/month metrics may be subject to integer division or incomplete denominator definitions; cast values and protect zero denominators.
- Average of monthly averages differs from a transaction-weighted mean.
- Product view starts from sales facts: products without sales are omitted.
- Retention denominators should distinguish zero returning customers from years for which follow-up is unobserved.
- Current product cost cannot establish historical cost of goods sold or historical profitability.
- Date-limited reports do not automatically reconcile to all-row sales totals.
- The original scripts create reporting views through DROP/CREATE. Run in a **development** database first; review dependent objects and permissions.

## Verification status
The attached capstone scripts and exported CSVs were inspected; the packaged scripts have **not** been executed against a live SQL Server instance by this assistant. Treat the figures as snapshot-derived evidence, not as validated client deliverables.
