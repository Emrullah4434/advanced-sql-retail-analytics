# Advanced SQL Retail Analytics

A reproducible **SQLite / SQL analytics portfolio project** using **synthetic retail transactions**. Demonstrates relational modeling, multi-table joins, CTEs, window functions, KPI logic, customer segmentation and practical indexing.

> **Data disclaimer:** All customer, product and transaction records are synthetically generated for demonstration. They do not represent real customers or company performance.

## Business questions
1. How does completed-order net revenue change month over month?
2. Which product categories contribute most to revenue?
3. Who are the top three customers by spend in each customer segment?
4. What share of active customers are repeat purchasers each month?
5. How are order statuses distributed?

## Technical highlights
- **SQL:** CTEs, joins, `LAG`, `DENSE_RANK`, `ROW_NUMBER`, partitioning, `NULLIF`, conditional aggregation
- **Data modeling:** normalized customer, product, order and line-item tables with primary/foreign keys
- **Optimization:** indexes on order dates, customer IDs and join keys; inspect using `EXPLAIN QUERY PLAN`
- **Business definitions:** revenue excludes cancelled/returned orders and accounts for line-item discounts

## Repository structure
```text
advanced-sql-retail-analytics/
├── data/                 # Synthetic CSV source tables
├── sql/01_schema.sql     # Schema, relationships, indexes
├── sql/02_analysis.sql   # Five analytical reports
├── docs/                 # KPI and interpretation notes
├── run_analysis.py       # Standard-library SQLite runner
└── README.md
```

## Run locally
Python 3.10+ required; no additional libraries.
```bash
python run_analysis.py
```
Run in a **fresh checkout**, since the script creates `retail_analytics.sqlite` and intentionally does not overwrite existing tables. The generated database is local and should not be committed.

To check performance, open the SQLite database and try:
```sql
EXPLAIN QUERY PLAN
SELECT * FROM orders WHERE customer_id = 15;
```

## Methodological notes
- Month-over-month growth starts with `NULL` because there is no prior month.
- Revenue uses the synthetic list price and recorded discount, not actual payment or cost data.
- Monthly repeat customers are defined as customers with at least one **earlier completed order** (including within the month).
- This is a technical demonstration, not a production deployment or validated business recommendation.
