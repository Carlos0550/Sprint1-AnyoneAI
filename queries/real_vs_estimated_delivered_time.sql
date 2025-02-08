-- TODO: This query will return a table with the differences between the real 
-- and estimated delivery times by month and year. It will have different 
-- columns: month_no, with the month numbers going from 01 to 12; month, with 
-- the 3 first letters of each month (e.g. Jan, Feb); Year2016_real_time, with 
-- the average delivery time per month of 2016 (NaN if it doesn't exist); 
-- Year2017_real_time, with the average delivery time per month of 2017 (NaN if 
-- it doesn't exist); Year2018_real_time, with the average delivery time per 
-- month of 2018 (NaN if it doesn't exist); Year2016_estimated_time, with the 
-- average estimated delivery time per month of 2016 (NaN if it doesn't exist); 
-- Year2017_estimated_time, with the average estimated delivery time per month 
-- of 2017 (NaN if it doesn't exist) and Year2018_estimated_time, with the 
-- average estimated delivery time per month of 2018 (NaN if it doesn't exist).
-- HINTS
-- 1. You can use the julianday function to convert a date to a number.
-- 2. order_status == 'delivered' AND order_delivered_customer_date IS NOT NULL
-- 3. Take distinct order_id.

WITH delivery_data AS (
    SELECT
        order_id,
        COALESCE(CAST(STRFTIME('%m', order_purchase_timestamp) AS INTEGER), 0) AS month_no,
        COALESCE(CAST(STRFTIME('%Y', order_purchase_timestamp) AS INTEGER), 0) AS year,
        COALESCE(julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp), 0) AS real_time,
        COALESCE(julianday(order_estimated_delivery_date) - julianday(order_purchase_timestamp), 0) AS estimated_time,
        COALESCE(printf('%02d', CAST(STRFTIME('%m', order_purchase_timestamp) AS INTEGER)), '00') AS formatted_month
    FROM
        olist_orders
    WHERE
        order_status = 'delivered'
        AND order_delivered_customer_date IS NOT NULL
)

SELECT
    formatted_month as month_no,
    SUBSTR('JanFebMarAprMayJunJulAugSepOctNovDec', (month_no - 1) * 3 + 1, 3) AS month,
    AVG(CASE WHEN year = 2016 THEN real_time END) AS Year2016_real_time,
    AVG(CASE WHEN year = 2017 THEN real_time END) AS Year2017_real_time,
    AVG(CASE WHEN year = 2018 THEN real_time END) AS Year2018_real_time,
    AVG(CASE WHEN year = 2016 THEN estimated_time END) AS Year2016_estimated_time,
    AVG(CASE WHEN year = 2017 THEN estimated_time END) AS Year2017_estimated_time,
    AVG(CASE WHEN year = 2018 THEN estimated_time END) AS Year2018_estimated_time
FROM
    delivery_data
GROUP BY
    month_no
ORDER BY
    month_no



-- WITH delivery_data AS (
--     SELECT
--         DISTINCT order_id,
--         COALESCE(CAST(STRFTIME('%m', order_purchase_timestamp) AS INTEGER), 0) AS month_no,
--         COALESCE(CAST(STRFTIME('%Y', order_purchase_timestamp) AS INTEGER), 0) AS year,
--         COALESCE(julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp), 0) AS real_time,
--         COALESCE(julianday(order_estimated_delivery_date) - julianday(order_purchase_timestamp), 0) AS estimated_time,
--         -- Aquí formateamos el mes para que tenga siempre dos dígitos
--         COALESCE(printf('%02d', CAST(STRFTIME('%m', order_purchase_timestamp) AS INTEGER)), '00') AS formatted_month
--     FROM
--         olist_orders
--     WHERE
--         order_status = 'delivered'
--         AND order_delivered_customer_date IS NOT NULL;
-- )

-- SELECT
--     month_no,
--     SUBSTR('JanFebMarAprMayJunJulAugSepOctNovDec', (month_no - 1) * 3 + 1, 3) AS month,
--     AVG(CASE WHEN year = 2016 THEN real_time END) AS Year2016_real_time,
--     AVG(CASE WHEN year = 2017 THEN real_time END) AS Year2017_real_time,
--     AVG(CASE WHEN year = 2018 THEN real_time END) AS Year2018_real_time,
--     AVG(CASE WHEN year = 2016 THEN estimated_time END) AS Year2016_estimated_time,
--     AVG(CASE WHEN year = 2017 THEN estimated_time END) AS Year2017_estimated_time,
--     AVG(CASE WHEN year = 2018 THEN estimated_time END) AS Year2018_estimated_time
-- FROM
--     delivery_data
-- GROUP BY
--     month_no
-- ORDER BY
--     month_no;