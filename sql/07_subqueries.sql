-- Тема 7. Вкладені та корельовані запити
-- Скалярні підзапити, IN, EXISTS і NOT EXISTS.
--
-- Теорія:
-- Підзапит — SELECT усередині іншого оператора. Скалярний підзапит повертає
-- одне значення, IN перевіряє належність множині, EXISTS — факт наявності
-- рядка. Корельований підзапит залежить від поточного рядка зовнішнього SELECT
-- і логічно перевіряється для кожного такого рядка.

-- Обираємо навчальну БД.
USE online_store;

-- 1. Товари дорожчі за середню ціну.
SELECT product_id, name, price
FROM products
WHERE is_active = TRUE
  AND price > (SELECT AVG(price) FROM products WHERE is_active = TRUE)
ORDER BY price DESC;

-- 2. Товари дорожчі за середнє у власній категорії.
SELECT p.product_id, p.name, p.price
FROM products AS p
WHERE p.price > (
    SELECT AVG(p2.price)
    FROM products AS p2
    WHERE p2.category_id = p.category_id
);

-- 3. Клієнти, які мають хоча б одне завершене замовлення.
SELECT c.customer_id, c.full_name
FROM customers AS c
WHERE EXISTS (
    SELECT 1 FROM orders AS o
    WHERE o.customer_id = c.customer_id AND o.status = 'completed'
);

-- 4. Активні товари, які ніколи не замовляли.
SELECT p.product_id, p.name
FROM products AS p
WHERE p.is_active = TRUE
  AND NOT EXISTS (
      SELECT 1 FROM order_items AS oi
      WHERE oi.product_id = p.product_id
  );

-- 5. IN: товари з категорій, середня ціна яких перевищує 10 000 грн.
SELECT product_id, name, price
FROM products
WHERE category_id IN (
    SELECT category_id FROM products
    GROUP BY category_id
    HAVING AVG(price) > 10000
);

-- NOT EXISTS зазвичай безпечніший за NOT IN, якщо підзапит може містити NULL.
