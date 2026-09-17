-- Тема 13. Контроль якості даних і пошук аномалій
-- Хороший результат для більшості перевірок — порожня вибірка.
--
-- Теорія:
-- Контроль якості перевіряє не лише типи й ключі, а й міжтабличні бізнесові
-- правила. Діагностичний запит повертає проблемні рядки; автоматизована
-- перевірка повертає прапорець passed та фактичне значення actual.
-- Такі запити корисно запускати після міграції або імпорту даних.

-- Обираємо навчальну БД.
USE online_store;

-- 1. Замовлення без позицій.
SELECT o.order_id
FROM orders AS o
LEFT JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE oi.order_id IS NULL;

-- 2. Адреса доставки належить іншому клієнту.
SELECT o.order_id, o.customer_id AS order_customer,
       a.customer_id AS address_customer
FROM orders AS o
JOIN addresses AS a ON a.address_id = o.shipping_address_id
WHERE a.customer_id <> o.customer_id;

-- 3. Вартість, чиста оплата і борг.
WITH order_totals AS (
    SELECT order_id, SUM(quantity * unit_price) AS order_total
    FROM order_items GROUP BY order_id
), payment_totals AS (
    SELECT order_id,
           SUM(CASE
               WHEN status = 'successful' THEN amount
               WHEN status = 'refunded' THEN -amount
               ELSE 0
           END) AS net_paid
    FROM payments GROUP BY order_id
)
SELECT ot.order_id, ot.order_total,
       COALESCE(pt.net_paid, 0) AS net_paid,
       ot.order_total - COALESCE(pt.net_paid, 0) AS balance_due
FROM order_totals AS ot
LEFT JOIN payment_totals AS pt ON pt.order_id = ot.order_id
ORDER BY ot.order_id;

-- 4. Машиночитані перевірки з очікуваними значеннями.
SELECT 'categories_count' AS check_name,
       COUNT(*) = 5 AS passed, COUNT(*) AS actual
FROM categories
UNION ALL
SELECT 'orphan_order_items', COUNT(*) = 0, COUNT(*)
FROM order_items AS oi
LEFT JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.order_id IS NULL;
