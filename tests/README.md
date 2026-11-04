# Data quality diagnostics

`data_quality_checks.sql` contains read-only checks for the Gold-layer warehouse. It examines source row counts, missing order dates, fact-to-dimension references and duplicate dimension keys to support trustworthy analytical reporting. No source data is modified.

**Why it is separate:** These are supporting data-quality checks; the three original capstone scripts remain in `sql/` unchanged.

Run diagnostics in SSMS using the same warehouse snapshot as the report scripts, and investigate any exceptions before using the results for business decisions. These queries are not a full automated test suite and do not certify production readiness.
