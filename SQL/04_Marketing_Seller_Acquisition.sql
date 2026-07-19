/*==============================================================
MARKETING & SELLER ACQUISITION ANALYSIS
==============================================================*/

USE olist;


/*==============================================================
LEAD CONVERSION ANALYSIS
==============================================================*/

CREATE TABLE 07_lead_conversion_analysis AS
SELECT
CASE
WHEN m.origin IN ('','unknown') THEN 'Unknown'
ELSE m.origin
END AS lead_source,

COUNT(DISTINCT m.mql_id) AS total_leads,

COUNT(DISTINCT c.seller_id) AS closed_deals,

ROUND(
COUNT(DISTINCT c.seller_id) /
COUNT(DISTINCT m.mql_id),
4
) AS conversion_rate

FROM marketing_qualified_leads m
LEFT JOIN closed_deals c
ON m.mql_id=c.mql_id

GROUP BY
CASE
WHEN m.origin IN ('','unknown') THEN 'Unknown'
ELSE m.origin
END;


/*==============================================================
SELLER ACQUISITION ANALYSIS
==============================================================*/

CREATE TABLE 10_seller_acquisition_analysis AS
SELECT
c.seller_id,
m.mql_id,

CASE
WHEN m.origin IN ('','unknown') THEN 'Unknown'
ELSE m.origin
END AS lead_source,

c.business_segment,
c.business_type,
c.lead_type,
c.won_date

FROM closed_deals c
LEFT JOIN marketing_qualified_leads m
ON c.mql_id=m.mql_id;


/*==============================================================
LEAD SOURCE × BUSINESS SEGMENT
==============================================================*/

CREATE TABLE 11_leadsource_businesssegment AS
SELECT
lead_source,
business_segment,
COUNT(DISTINCT seller_id) AS sellers

FROM 10_seller_acquisition_analysis

GROUP BY
lead_source,
business_segment

ORDER BY
lead_source,
sellers DESC;


/*==============================================================
BUSINESS TYPE DISTRIBUTION
==============================================================*/

CREATE TABLE 12_business_type_distribution AS
SELECT
CASE
WHEN business_type='' THEN 'Unknown'
ELSE business_type
END AS business_type,

COUNT(DISTINCT seller_id) AS seller_count

FROM 10_seller_acquisition_analysis

GROUP BY
CASE
WHEN business_type='' THEN 'Unknown'
ELSE business_type
END

ORDER BY seller_count DESC;


/*==============================================================
MONTHLY SELLER ACQUISITION TREND
==============================================================*/

CREATE TABLE 13_seller_acquisition_trend AS
SELECT
DATE_FORMAT(won_date,'%Y-%m') AS month_key,
DATE_FORMAT(won_date,'%b %Y') AS acquisition_month,
COUNT(DISTINCT seller_id) AS sellers_acquired

FROM 10_seller_acquisition_analysis

GROUP BY
DATE_FORMAT(won_date,'%Y-%m'),
DATE_FORMAT(won_date,'%b %Y')

ORDER BY
DATE_FORMAT(won_date,'%Y-%m');