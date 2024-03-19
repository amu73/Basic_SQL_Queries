--  What is the count of distinct customers located in the city of 'Surat'?
SELECT 
	count(distinct customer_id) 
FROM gdb080.dim_customers
Where city = "Surat";

--  What is the highest quantity available for the product 'AM Tea 100'?
SELECT 
	p.product_id, 
	p.product_name,
	MIN(f.order_qty) as minimum_qty,
	MAX(f.order_qty) as maximum_qty
FROM gdb080.fact_order_lines f
JOIN gdb080.dim_products p ON f.product_id = p.product_id
GROUP BY p.product_id;

-- In which month were the unfulfilled orders the highest in number?
SELECT 
	MONTHNAME(order_placement_date) as month_name, 
	sum(order_qty-delivery_qty) as unfullfilled_orders
FROM fact_order_lines
GROUP By month_name
ORDER BY unfullfilled_orders DESC; 

-- What is the percentage of the total order quantity accounted for by the 'food' category? 
with total_order_qty_by_category as
(
	SELECT 
		p.category, 
		SUM(f.order_qty) as total_quantity
	FROM dim_products p
    JOIN fact_order_lines f ON p.product_id = f.product_id
	GROUP BY p.category
)
SELECT
        category,
        ROUND(100 * total_quantity / SUM(total_quantity) OVER (), 2) AS order_qty_pct
FROM total_order_qty_by_category
order by order_qty_pct DESC;

-- What is the count of customers falling under the 'Above 90' category based on their ontime_target_pct?
With count_cust as (
SELECT 
	c.customer_id,
	c.customer_name,
	t.ontime_target_pct,
    CASE 
		WHEN t.ontime_target_pct > 90 THEN "Above 90"
		WHEN t.ontime_target_pct > 80 THEN "Above 80"
		WHEN t.ontime_target_pct > 70 THEN "Above 70"
        ELSE "Below 70"
        END AS  percentage_category
 FROM gdb080.dim_targets_orders t
 JOIN gdb080.dim_customers c
 ON t.customer_id = c.customer_id
)
SELECT 
	count(customer_id)
FROM count_cust
WHERE percentage_category = "Above 90";

-- What is the count of distinct products available in the 'Dairy' category? 
SELECT 
	category, 
	GROUP_CONCAT(product_name) AS products, 
	COUNT(*) AS product_count
FROM gdb080.dim_products
GROUP BY  category;

-- What is the total order quantity (in millions) for the top 3 products in the Dairy Category? 
with sum_total_order_qty as
(
	SELECT 
        p.product_name,
        ROUND(SUM(f.order_qty) / 1000000,2) AS order_qty_mln
FROM dim_products p
JOIN fact_order_lines f ON
	p.product_id = f.product_id
WHERE p.category = 'Dairy'
GROUP BY p.product_name
ORDER BY order_qty_mln DESC
LIMIT 3
)
SELECT 
	sum(order_qty_mln) 
FROM sum_total_order_qty;

-- What is the OTIF percentage for the customer "Vijay Stores"?
SELECT 
        c.customer_name,
        ROUND((SUM(f.otif) / COUNT(f.order_id) * 100),2) AS OTIF_percentage
FROM fact_orders_aggregate f
JOIN dim_customers c 
ON c.customer_id = f.customer_id
WHERE c.customer_name = "Vijay Stores"
GROUP BY c.customer_name;

-- What is the percentage of 'in full' for each product and which product has the highest percentage, based on the data from the 'fact_order_lines' and 'dim_products' tables?
WITH product_if_target AS (
    SELECT 
        p.product_name,
        SUM(CASE WHEN f.in_full = 1 THEN 1 ELSE 0 END) AS if_count,
        COUNT(f.order_id) AS total_count
    FROM 
        fact_order_lines f
        JOIN dim_products p ON p.product_id = f.product_id
    GROUP BY p.product_name
)
SELECT 
    product_name,
    ROUND((if_count / total_count) * 100, 2) AS IF_percentage
FROM 
    product_if_target
order by IF_percentage DESC;


 













