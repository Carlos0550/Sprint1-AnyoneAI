-- TODO: This query will return a table with the revenue by month and year. It
-- will have different columns: month_no, with the month numbers going from 01
-- to 12; month, with the 3 first letters of each month (e.g. Jan, Feb);
-- Year2016, with the revenue per month of 2016 (0.00 if it doesn't exist);
-- Year2017, with the revenue per month of 2017 (0.00 if it doesn't exist) and
-- Year2018, with the revenue per month of 2018 (0.00 if it doesn't exist).

WITH months AS (
    SELECT '01' AS month_no, 'Jan' AS month UNION ALL
    SELECT '02', 'Feb' UNION ALL
    SELECT '03', 'Mar' UNION ALL
    SELECT '04', 'Apr' UNION ALL
    SELECT '05', 'May' UNION ALL
    SELECT '06', 'Jun' UNION ALL
    SELECT '07', 'Jul' UNION ALL
    SELECT '08', 'Aug' UNION ALL
    SELECT '09', 'Sep' UNION ALL
    SELECT '10', 'Oct' UNION ALL
    SELECT '11', 'Nov' UNION ALL
    SELECT '12', 'Dec'
),
revenue_data AS (
    SELECT
        STRFTIME('%m', o.order_purchase_timestamp) AS month_no,
        STRFTIME('%Y', o.order_purchase_timestamp) AS year,
        SUM(p.payment_value) AS revenue
    FROM
        olist_orders o
    JOIN
        olist_order_payments p ON o.order_id = p.order_id
    WHERE
        o.order_status = 'delivered'
        AND o.order_purchase_timestamp IS NOT NULL
    GROUP BY
        month_no, year
)

SELECT
    m.month_no,
    m.month,
    COALESCE(SUM(CASE WHEN rd.year = '2016' THEN rd.revenue END), 0.00) AS Year2016,
    COALESCE(SUM(CASE WHEN rd.year = '2017' THEN rd.revenue END), 0.00) AS Year2017,
    COALESCE(SUM(CASE WHEN rd.year = '2018' THEN rd.revenue END), 0.00) AS Year2018
FROM
    months m
LEFT JOIN
    revenue_data rd ON m.month_no = rd.month_no
GROUP BY
    m.month_no, m.month
ORDER BY
    m.month_no;