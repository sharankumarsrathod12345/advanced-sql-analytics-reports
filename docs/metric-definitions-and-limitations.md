# Metric definitions & analytical boundaries

## Key measures

| Measure | Definition | Boundary |
| --- | --- | --- |
| Recorded sales | `SUM(sales_amount)` | Not historical profit, verified net revenue, or cash received |
| Fact rows | `COUNT(*)` from `gold.fact_sales` | Not equivalent to distinct orders |
| Distinct orders | `COUNT(DISTINCT order_number)` | Records without an order number need separate review |
| Purchasing customers | `COUNT(DISTINCT customer_key)` from sales facts | Not the complete customer dimension |
| Units sold | `SUM(quantity)` | Reflects source-recorded quantity |
| Product participation | Distinct product keys observed in fact sales | Not the entire product catalog |
| Category sales share | Category sales / eligible population sales | Must use consistent filters and preserved join grain |
| Monthly cohort | Month of first **observed** purchase | Earlier purchase history may be unavailable |
| Annual returning customers | Customers seen in two consecutive years | Last year may lack follow-up observation |

## Independently checked CSV snapshot

| Check | Result |
| --- | ---: |
| Sales rows | 60,398 |
| Distinct order numbers | 27,659 |
| Units | 60,423 |
| Recorded sales amount | 29,356,250 |
| Customer dimension rows | 18,484 |
| Product dimension rows | 295 |
| Product keys appearing in sales | 130 |
| Sales rows with missing order date | 19 |
| Sales amount without an order date | 4,992 |
| Dated sales amount | 29,351,258 |

Order dates range from 2010-12-29 through 2014-01-28. The first and final calendar years are incomplete. Snapshot currency has not been confirmed.

Approximate category contribution to recorded sales: Bikes **96.46%**, Accessories **2.39%**, Clothing **1.16%** (rounded). Accessories account for about **59.77%** of recorded units; these are descriptive findings, not evidence of a cause.

## Considerations when reusing the original SQL

The author's original three SQL scripts are preserved byte-for-byte. Analysts adapting them for a real client should review these definitions and environmental dependencies:

- `GETDATE()`-based recency and age change with the date of execution and may not suit a historical snapshot. `DATEDIFF(YEAR, birth_date, GETDATE())` is not a completed-birthday age.
- Customer age classification groups records with missing birth dates into a fallback branch; the label `40-40` appears where the stated boundaries are 40–49.
- `DATEDIFF(MONTH, first_order, last_order)` measures month boundaries, not necessarily a customer's number of active months; review averages calculated using this denominator. For fractional metrics, review integer division and guard zero denominators.
- An average of observed monthly averages is not necessarily a transaction-weighted mean or a fixed-size moving average.
- Product name may not be a globally unique key. Confirm grouping by stable product identity where needed.
- The product reporting view is based on fact sales, so products without recorded sales do not appear.
- Cohort and retention interpretations require a documented observation window, consistent denominators and missing-period treatment.
- Current product cost from a dimension is not necessarily historical cost of goods sold.
- The reporting scripts use `DROP VIEW` followed by `CREATE VIEW`; run in a development copy and assess dependencies before execution.

## Verification boundary

The CSV snapshot statistics above were recalculated independently. The original SQL scripts have **not** been executed or performance benchmarked against the user's live SQL Server instance by this assistant. The repository presents a documented learning capstone, not certified production SQL or measured client outcomes.
