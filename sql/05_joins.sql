-- Тема 5. З'єднання таблиць
-- INNER JOIN, LEFT JOIN, self-join та антиз'єднання.
--
-- Теорія:
-- JOIN поєднує рядки різних таблиць за умовою ON. INNER JOIN залишає лише
-- відповідності, LEFT JOIN також зберігає всі рядки лівої таблиці й підставляє
-- NULL за відсутності пари. Self-join — це з'єднання таблиці із самою собою.

-- Обираємо навчальну БД.
USE online_store;

-- 1. Деталізація замовлення.
SELECT o.order_id, o.created_at, c.full_name,
       p.name AS product, oi.quantity, oi.unit_price,
       oi.quantity * oi.unit_price AS line_total
FROM orders AS o
JOIN customers AS c ON c.customer_id = o.customer_id
JOIN order_items AS oi ON oi.order_id = o.order_id
JOIN products AS p ON p.product_id = oi.product_id
ORDER BY o.order_id, p.name;

-- 2. LEFT JOIN зберігає навіть клієнтів без замовлень.
-- COUNT(o.order_id), на відміну від COUNT(*), дає для них 0.
SELECT c.customer_id, c.full_name, COUNT(o.order_id) AS orders_count
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY orders_count DESC, c.full_name;

-- 3. Товари, які ніколи не входили до замовлень.
SELECT p.product_id, p.name
FROM products AS p
LEFT JOIN order_items AS oi ON oi.product_id = p.product_id
WHERE oi.product_id IS NULL;

-- 4. Self-join: пари товарів, які купували разом.
SELECT p1.name AS product_1, p2.name AS product_2,
       COUNT(*) AS orders_together
FROM order_items AS oi1
JOIN order_items AS oi2
  ON oi2.order_id = oi1.order_id
 AND oi2.product_id > oi1.product_id
JOIN products AS p1 ON p1.product_id = oi1.product_id
JOIN products AS p2 ON p2.product_id = oi2.product_id
GROUP BY p1.product_id, p1.name, p2.product_id, p2.name
ORDER BY orders_together DESC, product_1, product_2;
