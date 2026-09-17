-- Тема 2. Створення записів: INSERT
-- Перед запуском виконайте 01_create_database.sql.
-- Фіксовані ID роблять результати наступних прикладів відтворюваними.
--
-- Теорія:
-- INSERT додає нові рядки. Один оператор може додати одразу багато рядків.
-- Значення мають відповідати типам, CHECK-, UNIQUE- та FOREIGN KEY-обмеженням.
-- ON DUPLICATE KEY UPDATE перетворює приклади на повторювані: при конфлікті
-- первинного або унікального ключа наявний рядок оновлюється (upsert).

-- Обираємо БД, до якої додаватимемо записи.
USE online_store;

-- Наповнюємо незалежний довідник категорій.
INSERT INTO categories (category_id, name) VALUES
(1, 'Ноутбуки'), (2, 'Смартфони'), (3, 'Аксесуари'),
(4, 'Побутова техніка'), (5, 'Монітори')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Додаємо клієнтів; унікальний email не дозволить створити дубль.
INSERT INTO customers (customer_id, full_name, email, created_at) VALUES
(1, 'Анна Коваль', 'anna@example.com', '2025-11-01'),
(2, 'Богдан Мельник', 'bohdan@example.com', '2025-11-03'),
(3, 'Вікторія Шевченко', 'viktoriia@example.com', '2025-11-10'),
(4, 'Гліб Бондар', 'hlib@example.com', '2025-12-01'),
(5, 'Дарина Лисенко', 'daryna@example.com', '2025-12-15'),
(6, 'Євген Ткаченко', 'yevhen@example.com', '2026-01-05'),
(7, 'Жанна Мороз', 'zhanna@example.com', '2026-01-20'),
(8, 'Захар Савчук', 'zakhar@example.com', '2026-02-01')
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name);

-- Додаємо адреси після клієнтів, оскільки customer_id є зовнішнім ключем.
INSERT INTO addresses (address_id, customer_id, city, street, postal_code) VALUES
(1, 1, 'Київ', 'вул. Хрещатик, 10', '01001'),
(2, 2, 'Львів', 'просп. Свободи, 20', '79000'),
(3, 3, 'Одеса', 'вул. Дерибасівська, 5', '65000'),
(4, 4, 'Дніпро', 'просп. Яворницького, 15', '49000'),
(5, 5, 'Харків', 'вул. Сумська, 30', '61000'),
(6, 6, 'Чернівці', 'вул. Головна, 50', '58000'),
(7, 7, 'Полтава', 'вул. Соборності, 12', '36000'),
(8, 8, 'Вінниця', 'вул. Соборна, 25', '21000'),
(9, 1, 'Київ', 'вул. Велика Васильківська, 8', '02000')
ON DUPLICATE KEY UPDATE city = VALUES(city), street = VALUES(street);

-- Додаємо каталог товарів після категорій.
INSERT INTO products
    (product_id, category_id, sku, name, price, stock_quantity, is_active)
VALUES
(1, 1, 'LAP-001', 'Ноутбук Pro 14', 45999, 8, TRUE),
(2, 1, 'LAP-002', 'Ноутбук Air 13', 32999, 5, TRUE),
(3, 2, 'PHN-001', 'Смартфон X', 21999, 15, TRUE),
(4, 2, 'PHN-002', 'Смартфон Mini', 14999, 0, TRUE),
(5, 3, 'ACC-001', 'Бездротова миша', 1299, 30, TRUE),
(6, 3, 'ACC-002', 'USB-C адаптер', 899, 50, TRUE),
(7, 4, 'HOM-001', 'Робот-пилосос', 12499, 4, TRUE),
(8, 3, 'ACC-003', 'Чохол для смартфона', 599, 20, TRUE),
(9, 5, 'MON-001', 'Монітор 27 IPS', 10999, 7, TRUE),
(10, 5, 'MON-002', 'Монітор 24 IPS', 7499, 10, TRUE),
(11, 3, 'ACC-004', 'Механічна клавіатура', 2899, 12, TRUE),
(12, 4, 'HOM-002', 'Електрочайник', 1599, 18, TRUE),
(13, 3, 'ACC-OLD', 'Дротова миша Legacy', 499, 0, FALSE)
ON DUPLICATE KEY UPDATE
    price = VALUES(price), stock_quantity = VALUES(stock_quantity),
    is_active = VALUES(is_active);

-- Додаємо замовлення з різними статусами та датами для аналітики.
INSERT INTO orders
    (order_id, customer_id, shipping_address_id, status, created_at)
VALUES
(1, 1, 1, 'completed', '2026-01-10 10:00:00'),
(2, 2, 2, 'completed', '2026-01-18 14:30:00'),
(3, 1, 9, 'completed', '2026-02-02 09:15:00'),
(4, 3, 3, 'cancelled', '2026-02-05 18:00:00'),
(5, 4, 4, 'shipped',   '2026-02-14 12:00:00'),
(6, 5, 5, 'paid',      '2026-02-20 16:20:00'),
(7, 2, 2, 'completed', '2026-03-01 11:10:00'),
(8, 6, 6, 'new',       '2026-03-04 08:40:00'),
(9, 1, 1, 'completed', '2026-03-07 19:00:00'),
(10, 7, 7, 'completed','2026-03-10 13:25:00'),
(11, 3, 3, 'paid',     '2026-03-12 17:50:00'),
(12, 5, 5, 'cancelled','2026-03-15 10:30:00')
ON DUPLICATE KEY UPDATE status = VALUES(status), created_at = VALUES(created_at);

-- Формуємо склад замовлень; unit_price фіксує історичну ціну продажу.
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 44999), (1, 5, 2, 1199),
(2, 3, 1, 21999), (2, 6, 1, 899),
(3, 7, 1, 12499), (3, 11, 1, 2699),
(4, 4, 1, 14999),
(5, 9, 1, 10599), (5, 6, 2, 899),
(6, 2, 1, 32999), (6, 5, 1, 1299),
(7, 3, 1, 20999), (7, 8, 2, 599),
(8, 12, 1, 1599),
(9, 10, 2, 7299), (9, 11, 1, 2899),
(10, 7, 1, 11999), (10, 5, 2, 1299),
(11, 1, 1, 45999), (11, 6, 1, 899),
(12, 4, 1, 14999)
ON DUPLICATE KEY UPDATE quantity = VALUES(quantity), unit_price = VALUES(unit_price);

-- Додаємо успішні, невдалі, очікувані та повернуті платежі.
INSERT INTO payments (payment_id, order_id, amount, status, paid_at) VALUES
(1, 1, 47397, 'successful', '2026-01-10 10:05:00'),
(2, 2, 22898, 'successful', '2026-01-18 14:35:00'),
(3, 3, 15198, 'successful', '2026-02-02 09:20:00'),
(4, 4, 14999, 'successful', '2026-02-05 18:05:00'),
(5, 5, 12397, 'successful', '2026-02-14 12:05:00'),
(6, 6, 20000, 'successful', '2026-02-20 16:25:00'),
(7, 6, 14298, 'pending',    NULL),
(8, 7, 22197, 'successful', '2026-03-01 11:15:00'),
(9, 9, 17497, 'successful', '2026-03-07 19:05:00'),
(10, 10, 14597, 'successful','2026-03-10 13:30:00'),
(11, 11, 10000, 'failed',   '2026-03-12 17:55:00'),
(12, 11, 46898, 'successful','2026-03-12 18:05:00'),
(13, 4, 14999, 'refunded',  '2026-02-06 11:00:00')
ON DUPLICATE KEY UPDATE amount = VALUES(amount), status = VALUES(status);

-- Контрольні кількості після першого або повторного запуску.
SELECT 'customers' AS entity, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments', COUNT(*) FROM payments;
