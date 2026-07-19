/*==============================================================

                OLIST MARKETPLACE PERFORMANCE ANALYSIS
                      Business Intelligence Project

Author      : Harsiman Kaur Dua
Dataset     : Olist Brazilian E-commerce Dataset (Kaggle)
Date        : July 2026

Description:
SQL queries used for Order & Delivery Analysis.

==============================================================*/

USE olist;


/*==============================================================
ORDER STATUS ANALYSIS
==============================================================*/

CREATE TABLE 01_order_status_analysis AS
SELECT order_status, COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY order_status;


/*==============================================================
DELIVERY PERFORMANCE
==============================================================*/

CREATE TABLE 02_delivery_performance AS
SELECT delivery_status, order_count,
ROUND(order_count / SUM(order_count) OVER(),4) AS delivery_share
FROM(
SELECT delivery_status, COUNT(order_id) AS order_count
FROM(
SELECT order_id, order_status, order_purchase_timestamp,
order_delivered_customer_date,
order_estimated_delivery_date,
DATEDIFF(order_delivered_customer_date,order_estimated_delivery_date) AS delivery_delay_days,
CASE
WHEN DATEDIFF(order_delivered_customer_date,order_estimated_delivery_date)<=0 THEN 'On Time'
ELSE 'Late'
END AS delivery_status
FROM orders
WHERE order_status='delivered'
AND order_delivered_customer_date IS NOT NULL
AND order_delivered_customer_date<>''
AND order_estimated_delivery_date IS NOT NULL
AND order_estimated_delivery_date<>''
) o
GROUP BY delivery_status
) d;


/*==============================================================
CATEGORY DELIVERY ANALYSIS
==============================================================*/

CREATE TABLE 03_category_delivery_analysis AS
SELECT product_category,total_orders,late_orders,
ROUND(late_orders / total_orders,4) AS late_percentage
FROM(
SELECT COALESCE(late.product_category,'Unknown') AS product_category,
COUNT(DISTINCT order_id) AS total_orders,
COUNT(DISTINCT CASE WHEN delivery_status='Late' THEN order_id END) AS late_orders
FROM(
SELECT category.order_id,
category.product_id,
products.product_category_name AS product_category,
delivery_delay_days,
delivery_status
FROM(
SELECT delivery.order_id,
order_items.product_id,
delivery_delay_days,
delivery_status
FROM(
SELECT order_id,
order_status,
order_purchase_timestamp,
order_delivered_customer_date,
order_estimated_delivery_date,
DATEDIFF(order_delivered_customer_date,order_estimated_delivery_date) AS delivery_delay_days,
CASE
WHEN DATEDIFF(order_delivered_customer_date,order_estimated_delivery_date)<=0 THEN 'On Time'
ELSE 'Late'
END AS delivery_status
FROM orders
WHERE order_status='delivered'
AND order_delivered_customer_date IS NOT NULL
AND order_delivered_customer_date<>''
AND order_estimated_delivery_date IS NOT NULL
AND order_estimated_delivery_date<>''
) delivery
LEFT JOIN order_items
ON delivery.order_id=order_items.order_id
) category
LEFT JOIN products
ON products.product_id=category.product_id
) late
GROUP BY late.product_category
) l;