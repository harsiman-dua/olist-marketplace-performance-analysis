/*==============================================================
SELLER PERFORMANCE ANALYSIS
==============================================================*/

USE olist;


/*==============================================================
TOP SELLER REVENUE CONTRIBUTION
==============================================================*/

-- Top 10% Seller Revenue

SELECT ROUND(SUM(revenue),2) AS `Top 10% Seller Revenue`
FROM(
SELECT seller_id, SUM(price) AS revenue
FROM order_items
GROUP BY seller_id
ORDER BY SUM(price) DESC
LIMIT 310
) top_sellers;


-- Total Marketplace Revenue

SELECT ROUND(SUM(price),2) AS `Total Marketplace Revenue`
FROM order_items;


-- Top 5% Seller Revenue

SELECT ROUND(SUM(revenue),2) AS `Top 5% Seller Revenue`
FROM(
SELECT seller_id, SUM(price) AS revenue
FROM order_items
GROUP BY seller_id
ORDER BY SUM(price) DESC
LIMIT 155
) top_sellers;


/*==============================================================
SELLER REVENUE SEGMENTATION
==============================================================*/

CREATE TABLE 05_seller_revenue_analysis AS
SELECT seller_segment,
seller_count,
segment_revenue,
ROUND(segment_revenue / SUM(segment_revenue) OVER(),4) AS revenue_share
FROM(
SELECT seller_segment,
COUNT(DISTINCT seller_id) AS seller_count,
ROUND(SUM(revenue),2) AS segment_revenue
FROM(
SELECT seller_id,
revenue,
CASE
WHEN revenue > 50000 THEN 'High value'
WHEN revenue BETWEEN 10000 AND 50000 THEN 'Medium'
ELSE 'Long tail'
END AS seller_segment
FROM(
SELECT seller_id,
ROUND(SUM(price),2) AS revenue
FROM order_items
GROUP BY seller_id
) total_revenue
) seller_data
GROUP BY seller_segment
) seller_data_revenue;


/*==============================================================
SELLER ACTIVATION ANALYSIS
==============================================================*/

CREATE TABLE 06_seller_activation_analysis AS
SELECT *,
CASE
WHEN declared_monthly_revenue = 0
AND olist_revenue >= 10000 THEN 'Active Sellers (No Declaration)'

WHEN declared_monthly_revenue = 0
AND olist_revenue < 10000 THEN 'Low Activity (No Declaration)'

WHEN declared_monthly_revenue >= 50000
AND olist_revenue / declared_monthly_revenue < 0.25 THEN 'Inactive High Potential'

WHEN olist_revenue / declared_monthly_revenue >= 0.75 THEN 'Performing Well'

WHEN olist_revenue / declared_monthly_revenue >= 0.25 THEN 'Growth Opportunity'

ELSE 'Low Activity'
END AS seller_bucket

FROM(
SELECT
c.seller_id,
c.declared_monthly_revenue,
COALESCE(SUM(o.price),0) AS olist_revenue,
c.declared_monthly_revenue - COALESCE(SUM(o.price),0) AS revenue_gap
FROM closed_deals c
LEFT JOIN order_items o
ON c.seller_id=o.seller_id
GROUP BY c.seller_id,c.declared_monthly_revenue
) seller_analysis;


/*==============================================================
SELLER AOV ANALYSIS
==============================================================*/

CREATE TABLE 08_seller_aov_analysis AS

WITH seller_summary AS(
SELECT
seller_id,
SUM(price) AS total_revenue,
COUNT(DISTINCT order_id) AS total_orders
FROM order_items
GROUP BY seller_id
)

SELECT
CASE
WHEN total_revenue > 50000 THEN 'High value'
WHEN total_revenue BETWEEN 10000 AND 50000 THEN 'Medium'
ELSE 'Long tail'
END AS seller_segment,

COUNT(*) AS seller_count,

ROUND(AVG(total_revenue),2) AS avg_revenue_per_seller,

ROUND(AVG(total_orders),2) AS avg_orders_per_seller,

ROUND(
SUM(total_revenue) /
SUM(total_orders),
2
) AS avg_order_value

FROM seller_summary

GROUP BY
CASE
WHEN total_revenue > 50000 THEN 'High value'
WHEN total_revenue BETWEEN 10000 AND 50000 THEN 'Medium'
ELSE 'Long tail'
END

ORDER BY
CASE
WHEN seller_segment='High value' THEN 1
WHEN seller_segment='Medium' THEN 2
ELSE 3
END;


/*==============================================================
SELLER SUMMARY KPI
==============================================================*/

CREATE TABLE 09_seller_summary_kpis AS
SELECT ROUND(SUM(price)/COUNT(DISTINCT order_id),2) AS overall_aov
FROM order_items;