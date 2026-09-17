-- Тема 9. Транзакції та конкурентний доступ
-- Приклад оформлення замовлення як однієї атомарної операції.
--
-- Теорія:
-- Транзакція — неподільна послідовність операцій. COMMIT фіксує всі зміни,
-- ROLLBACK скасовує їх. InnoDB забезпечує властивості ACID. SELECT ...
-- FOR UPDATE блокує вибрані рядки до завершення транзакції та допомагає
-- уникнути конфліктного паралельного оновлення залишку.

-- Обираємо БД і починаємо транзакцію.
USE online_store;
START TRANSACTION;

-- Блокуємо товар до завершення транзакції, щоб два покупці не продали
-- одну й ту саму останню одиницю одночасно.
SELECT product_id, price, stock_quantity
FROM products
WHERE product_id = 12
FOR UPDATE;

-- У прикладному коді тут необхідно перевірити stock_quantity >= 1.
INSERT INTO orders (customer_id, shipping_address_id, status, created_at)
VALUES (8, 8, 'new', CURRENT_TIMESTAMP);
-- Зберігаємо номер нового замовлення для вставлення його позицій.
SET @new_order_id = LAST_INSERT_ID();

-- Додаємо позицію лише за наявності товару на складі.
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT @new_order_id, product_id, 1, price
FROM products
WHERE product_id = 12 AND stock_quantity >= 1;

-- Списуємо ту саму кількість зі складського залишку.
UPDATE products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 12 AND stock_quantity >= 1;

-- Для демонстрації дані не зберігаємо. У реальному сценарії тут COMMIT.
ROLLBACK;

-- Дослід: відкрийте два SQL Editor, виконайте SELECT ... FOR UPDATE
-- в першому та спостерігайте очікування блокування в другому.
