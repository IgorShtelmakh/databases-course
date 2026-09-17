-- Тема 4. Маніпулювання записами: INSERT, UPDATE, DELETE
-- Демонстраційні зміни виконуються у транзакції та скасовуються наприкінці.
--
-- Теорія:
-- DML (Data Manipulation Language) змінює вміст таблиць: INSERT додає,
-- UPDATE змінює, DELETE видаляє рядки. WHERE обмежує цільові рядки;
-- UPDATE або DELETE без WHERE може торкнутися всієї таблиці.
-- Транзакція дозволяє застосувати зміни разом або повністю їх скасувати.

-- Обираємо БД і починаємо атомарну групу змін.
USE online_store;
START TRANSACTION;

-- Додавання одного клієнта. Ідентифікатор генерує AUTO_INCREMENT.
INSERT INTO customers (full_name, email)
VALUES ('Тестовий Клієнт', 'temporary@example.com');
-- Зберігаємо AUTO_INCREMENT ідентифікатор доданого клієнта у змінній сесії.
SET @new_customer_id = LAST_INSERT_ID();

-- Додаємо залежну адресу, використовуючи збережений ідентифікатор клієнта.
INSERT INTO addresses (customer_id, city, street, postal_code)
VALUES (@new_customer_id, 'Київ', 'вул. Навчальна, 1', '01000');

-- Масове оновлення: знижка 5% лише для активних аксесуарів.
UPDATE products
SET price = ROUND(price * 0.95, 2)
WHERE category_id = 3 AND is_active = TRUE;

-- Безпечніше спочатку виконати аналогічний SELECT і перевірити рядки.
SELECT product_id, name, price
FROM products
WHERE category_id = 3 AND is_active = TRUE;

-- Видалення щойно створеного клієнта також видалить його адресу (CASCADE).
DELETE FROM customers WHERE customer_id = @new_customer_id;

-- Скасовуємо навчальні зміни, щоб наступні теми бачили базові дані.
ROLLBACK;

-- Вправа: у транзакції деактивуйте товари без залишку та перевірте результат.
