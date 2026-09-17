-- Тема 6. Агрегування та групування
-- COUNT, SUM, AVG, GROUP BY, HAVING і умовна агрегація.
--
-- Теорія:
-- Агрегатні функції згортають багато рядків в одне значення. GROUP BY
-- утворює окремі групи, WHERE фільтрує рядки до групування, а HAVING — групи
-- після обчислення агрегатів. Неагреговані колонки мають входити до GROUP BY.

-- Обираємо навчальну БД.
USE online_store;

-- 1. Сума кожного замовлення.
SELECT o.order_id, o.status,
       SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.status
ORDER BY order_total DESC;

-- 2. Виручка за категоріями; скасовані замовлення не враховуються.
SELECT c.name AS category,
       SUM(oi.quantity) AS units_sold,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM categories AS c
JOIN products AS p ON p.category_id = c.category_id
JOIN order_items AS oi ON oi.product_id = p.product_id
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.status <> 'cancelled'
GROUP BY c.category_id, c.name
ORDER BY revenue DESC;

-- 3. HAVING фільтрує вже сформовані групи.
SELECT customer_id, COUNT(*) AS orders_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) >= 2;

-- 4. Зведення статусів в один рядок.
SELECT COUNT(*) AS total_orders,
       SUM(status = 'completed') AS completed,
       SUM(status = 'cancelled') AS cancelled,
       ROUND(100 * AVG(status = 'cancelled'), 2) AS cancellation_percent
FROM orders;

-- Вправа: знайдіть середній чек лише завершених замовлень.
