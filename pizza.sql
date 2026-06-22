select*from pizzahut.pizzas;
-- ==========================================
-- PIZZA SALES SQL PROJECT
-- ==========================================

-- 1. Total Number of Orders Placed

SELECT COUNT(order_id) AS total_orders
FROM orders;

-- ==========================================

-- 2. Total Revenue Generated

SELECT ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id;

-- ==========================================

-- 3. Highest Priced Pizza

SELECT
    pt.name AS pizza_name,
    p.size,
    p.price
FROM pizzas p
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- ==========================================

-- 4. Most Common Pizza Size Ordered

SELECT
    p.size,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_quantity DESC
LIMIT 1;

-- ==========================================

-- 5. Top 5 Most Ordered Pizza Types

SELECT
    pt.name,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- ==========================================

-- 6. Total Quantity of Each Pizza Category Ordered

SELECT
    pt.category,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- ==========================================

-- 7. Distribution of Orders by Hour

SELECT
    HOUR(time) AS order_hour,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_hour
ORDER BY order_hour;

-- ==========================================

-- 8. Category-wise Distribution of Pizzas

SELECT
    category,
    COUNT(*) AS total_pizza_types
FROM pizza_types
GROUP BY category
ORDER BY total_pizza_types DESC;

-- ==========================================

-- 9. Average Number of Pizzas Ordered Per Day

SELECT
    ROUND(AVG(daily_quantity), 2) AS avg_pizzas_per_day
FROM
(
    SELECT
        o.date,
        SUM(od.quantity) AS daily_quantity
    FROM orders o
    JOIN order_details od
    ON o.order_id = od.order_id
    GROUP BY o.date
) AS daily_orders;

-- ==========================================

-- 10. Top 3 Pizza Types Based on Revenue

SELECT
    pt.name,
    ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- ==========================================

-- 11. Percentage Contribution of Each Pizza Type to Total Revenue

SELECT
    pt.name,
    ROUND(
        SUM(od.quantity * p.price) * 100 /
        (
            SELECT SUM(od2.quantity * p2.price)
            FROM order_details od2
            JOIN pizzas p2
            ON od2.pizza_id = p2.pizza_id
        ),
        2
    ) AS revenue_percentage
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue_percentage DESC;

-- ==========================================

-- 12. Cumulative Revenue Over Time

SELECT
    order_date,
    revenue,
    SUM(revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM
(
    SELECT
        o.date AS order_date,
        ROUND(SUM(od.quantity * p.price), 2) AS revenue
    FROM orders o
    JOIN order_details od
    ON o.order_id = od.order_id
    JOIN pizzas p
    ON od.pizza_id = p.pizza_id
    GROUP BY o.date
) AS daily_revenue;

-- ==========================================

-- 13. Top 3 Pizza Types by Revenue in Each Category

WITH pizza_revenue AS
(
    SELECT
        pt.category,
        pt.name,
        ROUND(SUM(od.quantity * p.price), 2) AS revenue,
        RANK() OVER
        (
            PARTITION BY pt.category
            ORDER BY SUM(od.quantity * p.price) DESC
        ) AS rank_no
    FROM order_details od
    JOIN pizzas p
    ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt
    ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
)

SELECT
    category,
    name,
    revenue
FROM pizza_revenue
WHERE rank_no <= 3
ORDER BY category, revenue DESC;

-- ==========================================
-- END OF PROJECT
-- ==========================================

