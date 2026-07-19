/*==============================================================
PRODUCT CATEGORY ANALYSIS
==============================================================*/

USE olist;


/*==============================================================
CATEGORY REVENUE ANALYSIS
==============================================================*/

CREATE TABLE 04_category_revenue_analysis AS
WITH category_revenue AS (
SELECT COALESCE(p.product_category_name,'Unknown') AS product_category,
ROUND(SUM(o.price),2) AS revenue_by_category,
COUNT(DISTINCT o.order_id) AS total_orders
FROM order_items o
LEFT JOIN products p
ON o.product_id=p.product_id
GROUP BY COALESCE(p.product_category_name,'Unknown')
)

SELECT product_category,
revenue_by_category,
total_orders,
ROUND(revenue_by_category / SUM(revenue_by_category) OVER(),4) AS revenue_share,
ROW_NUMBER() OVER(ORDER BY revenue_by_category DESC) AS revenue_rank,
ROUND(
SUM(revenue_by_category) OVER(
ORDER BY revenue_by_category DESC
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
),2) AS cumulative_revenue,
ROUND(
SUM(revenue_by_category) OVER(
ORDER BY revenue_by_category DESC
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) / SUM(revenue_by_category) OVER(),4) AS cumulative_revenue_share
FROM category_revenue
ORDER BY revenue_by_category DESC;


/*==============================================================
PARETO ANALYSIS (80% REVENUE)
==============================================================*/

SELECT MIN(revenue_rank) AS categories_for_80_percent
FROM 04_category_revenue_analysis
WHERE cumulative_revenue_share >= 0.80;