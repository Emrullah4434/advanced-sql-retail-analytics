-- All revenue metrics below use COMPLETED orders only and subtract line discounts.
-- 1. Monthly net revenue and month-over-month growth (CTEs + LAG)
WITH monthly AS (
 SELECT substr(o.order_date,1,7) AS month, ROUND(SUM(oi.quantity*p.unit_price*(1-oi.discount_rate)),2) AS revenue
 FROM orders o JOIN order_items oi ON oi.order_id=o.order_id JOIN products p ON p.product_id=oi.product_id
 WHERE o.status='Completed' GROUP BY 1
), growth AS (
 SELECT month,revenue,LAG(revenue) OVER(ORDER BY month) AS prior_month FROM monthly
)
SELECT month,revenue,prior_month,ROUND(100.0*(revenue-prior_month)/NULLIF(prior_month,0),2) AS mom_pct FROM growth ORDER BY month;

-- 2. Category performance + revenue contribution
WITH category_sales AS (
 SELECT p.category, SUM(oi.quantity*p.unit_price*(1-oi.discount_rate)) AS revenue
 FROM orders o JOIN order_items oi ON oi.order_id=o.order_id JOIN products p ON p.product_id=oi.product_id
 WHERE o.status='Completed' GROUP BY p.category
)
SELECT category,ROUND(revenue,2) AS revenue,ROUND(100.0*revenue/NULLIF(SUM(revenue) OVER(),0),2) AS share_pct,
 DENSE_RANK() OVER(ORDER BY revenue DESC) AS revenue_rank FROM category_sales ORDER BY revenue_rank;

-- 3. Top 3 customers per segment (window function)
WITH spend AS (
 SELECT c.segment,c.customer_id,ROUND(SUM(oi.quantity*p.unit_price*(1-oi.discount_rate)),2) AS lifetime_value
 FROM customers c JOIN orders o ON o.customer_id=c.customer_id
 JOIN order_items oi ON oi.order_id=o.order_id JOIN products p ON p.product_id=oi.product_id
 WHERE o.status='Completed' GROUP BY c.segment,c.customer_id
), ranked AS (
 SELECT *, ROW_NUMBER() OVER(PARTITION BY segment ORDER BY lifetime_value DESC,customer_id) AS rn FROM spend
)
SELECT * FROM ranked WHERE rn<=3 ORDER BY segment,rn;

-- 4. Monthly repeat purchaser rate (a repeat purchaser has a prior completed order)
WITH completed_orders AS (
 SELECT o.*, ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date,order_id) AS customer_order_number
 FROM orders o WHERE status='Completed'
), monthly_customers AS (
 SELECT substr(order_date,1,7) AS month,customer_id, MAX(CASE WHEN customer_order_number>1 THEN 1 ELSE 0 END) AS is_repeat
 FROM completed_orders GROUP BY 1,2
)
SELECT month,COUNT(*) AS active_customers,SUM(is_repeat) AS repeat_customers,
 ROUND(100.0*SUM(is_repeat)/NULLIF(COUNT(*),0),2) AS repeat_rate_pct
 FROM monthly_customers GROUP BY month ORDER BY month;

-- 5. Order status distribution (quality / operations)
SELECT status,COUNT(*) AS order_count,ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM orders),2) AS pct FROM orders GROUP BY status ORDER BY order_count DESC;
