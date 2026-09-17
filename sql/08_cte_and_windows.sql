-- Тема 8. CTE та віконні функції
-- WITH, ROW_NUMBER, DENSE_RANK, LAG і накопичувальний підсумок.
--
-- Теорія:
-- CTE (Common Table Expression) — іменований тимчасовий результат у межах
-- одного запиту; WITH допомагає розбити складну логіку на етапи.
-- Віконна функція обчислює значення для рядка з урахуванням пов'язаного
-- «вікна», але не згортає рядки як GROUP BY. PARTITION BY ділить вікно
-- на групи, ORDER BY задає порядок обчислення всередині них.

-- Обираємо навчальну БД.
USE online_store;

-- 1. Рейтинг товарів за виручкою в межах категорії.
WITH product_sales AS (
    SELECT p.product_id, p.category_id, p.name,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products AS p
    JOIN order_items AS oi ON oi.product_id = p.product_id
    JOIN orders AS o ON o.order_id = oi.order_id
    WHERE o.status <> 'cancelled'
    GROUP BY p.product_id, p.category_id, p.name
)
SELECT product_id, category_id, name, revenue,
       DENSE_RANK() OVER (
           PARTITION BY category_id ORDER BY revenue DESC
       ) AS category_rank
FROM product_sales
ORDER BY category_id, category_rank;

-- 2. Попереднє замовлення того самого клієнта.
SELECT customer_id, order_id, created_at,
       LAG(created_at) OVER (
           PARTITION BY customer_id ORDER BY created_at
       ) AS previous_order_at
FROM orders
ORDER BY customer_id, created_at;

-- 3. Денна та накопичувальна виручка.
WITH daily_revenue AS (
    SELECT DATE(o.created_at) AS sale_date,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders AS o
    JOIN order_items AS oi ON oi.order_id = o.order_id
    WHERE o.status <> 'cancelled'
    GROUP BY DATE(o.created_at)
)
SELECT sale_date, revenue,
       SUM(revenue) OVER (ORDER BY sale_date) AS running_revenue
FROM daily_revenue
ORDER BY sale_date;

-- Вправа: за допомогою ROW_NUMBER виведіть топ-2 товари кожної категорії.
