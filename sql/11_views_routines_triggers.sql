-- Тема 11. Представлення, процедури та тригери
-- Програмовані об'єкти приховують повторювану логіку на рівні БД.
--
-- Теорія:
-- VIEW зберігає запит під іменем і поводиться як віртуальна таблиця.
-- PROCEDURE — іменована програма, яку явно запускають через CALL.
-- TRIGGER автоматично виконується до або після зміни рядка. DELIMITER
-- тимчасово змінює роздільник, щоб тіло BEGIN ... END містило крапки з комою.

-- Обираємо навчальну БД.
USE online_store;

-- Представлення із сумами замовлень.
CREATE OR REPLACE VIEW v_order_totals AS
SELECT o.order_id, o.customer_id, o.status, o.created_at,
       SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.customer_id, o.status, o.created_at;

-- Читаємо представлення так само, як звичайну таблицю.
SELECT * FROM v_order_totals ORDER BY order_id;

-- Видаляємо стару версію процедури, щоб скрипт можна було запустити повторно.
DROP PROCEDURE IF EXISTS get_customer_orders;
DELIMITER $$
CREATE PROCEDURE get_customer_orders(IN p_customer_id BIGINT UNSIGNED)
BEGIN
    SELECT *
    FROM v_order_totals
    WHERE customer_id = p_customer_id
    ORDER BY created_at DESC;
END$$
DELIMITER ;

-- Викликаємо процедуру для першого клієнта.
CALL get_customer_orders(1);

-- Тригер перевіряє бізнес-правило, яке не забезпечує звичайний FK:
-- адреса доставки повинна належати клієнту замовлення.
-- Видаляємо попередню версію тригера перед його повторним створенням.
DROP TRIGGER IF EXISTS trg_orders_address_owner_insert;
DELIMITER $$
CREATE TRIGGER trg_orders_address_owner_insert
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM addresses AS a
        WHERE a.address_id = NEW.shipping_address_id
          AND a.customer_id = NEW.customer_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Shipping address belongs to another customer';
    END IF;
END$$
DELIMITER ;

-- Самостійно створіть аналогічний BEFORE UPDATE тригер.
