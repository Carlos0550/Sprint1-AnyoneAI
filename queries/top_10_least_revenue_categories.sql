-- TODO: This query will return a table with the top 10 least revenue categories 
-- in English, the number of orders and their total revenue. The first column 
-- will be Category, that will contain the top 10 least revenue categories; the 
-- second one will be Num_order, with the total amount of orders of each 
-- category; and the last one will be Revenue, with the total revenue of each 
-- catgory.
-- HINT: All orders should have a delivered status and the Category and actual 
-- delivery date should be not null.

WITH translated_categories AS (
    SELECT 
        p.product_id,  
        p.product_category_name,
        t.product_category_name_english AS category
    FROM 
        products p
    JOIN 
        product_category_name_translation t
        ON p.product_category_name = t.product_category_name
),
order_details AS (
    SELECT
        oi.order_id,
        oi.product_id,
        (oi.price + oi.freight_value) AS total_value
    FROM 
        order_items oi
)
SELECT 
    tc.category AS Category,
    COUNT(DISTINCT o.order_id) AS Num_order,
    ROUND(SUM(od.total_value), 2) AS Revenue
FROM 
    orders o
JOIN 
    order_details od ON o.order_id = od.order_id
JOIN 
    translated_categories tc ON od.product_id = tc.product_id  
WHERE 
    o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND tc.category IS NOT NULL
GROUP BY 
    tc.category
ORDER BY 
    Revenue ASC
LIMIT 10;
