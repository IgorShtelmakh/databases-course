-- Тема 10. Індекси та аналіз плану виконання
-- На малому наборі даних оптимізатор може обрати повне сканування — це нормально.
--
-- Теорія:
-- Індекс — додаткова структура, що прискорює пошук і сортування, але займає
-- місце та уповільнює INSERT/UPDATE/DELETE. У складеному індексі важливий
-- порядок колонок. EXPLAIN показує план оптимізатора, а EXPLAIN ANALYZE ще й
-- виконує запит та порівнює оцінені показники з фактичними.

-- Обираємо навчальну БД.
USE online_store;

-- Аналіз фактичного плану та кількості оброблених рядків.
EXPLAIN ANALYZE
SELECT order_id, customer_id, status, created_at
FROM orders
WHERE customer_id = 1
ORDER BY created_at DESC;

-- Складений індекс відповідає фільтру та сортуванню цього запиту.
-- Створюємо індекс: спочатку колонка рівності, потім колонка сортування.
CREATE INDEX idx_orders_customer_created
    ON orders (customer_id, created_at DESC);

-- Повторюємо аналіз, щоб порівняти план до і після створення індексу.
EXPLAIN ANALYZE
SELECT order_id, customer_id, status, created_at
FROM orders
WHERE customer_id = 1
ORDER BY created_at DESC;

-- Перегляд індексів.
-- Перевіряємо склад і порядок колонок усіх індексів таблиці.
SHOW INDEX FROM orders;

-- Повторний запуск CREATE INDEX завершиться помилкою, бо MySQL не підтримує
-- IF NOT EXISTS для CREATE INDEX. Перед повтором перевірте SHOW INDEX.
