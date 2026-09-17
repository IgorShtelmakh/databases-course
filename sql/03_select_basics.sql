-- Тема 3. Базові SELECT-запити
-- Вибір колонок, псевдоніми, фільтрація, сортування, CASE, NULL.
--
-- Теорія:
-- SELECT читає дані й не змінює їх. FROM визначає джерело, WHERE відбирає
-- рядки, SELECT формує результат, ORDER BY сортує, LIMIT обмежує кількість.
-- CASE створює значення за умовою, а COALESCE повертає перше не-NULL значення.

-- Обираємо навчальну БД.
USE online_store;

-- 1. Активні товари в заданому ціновому діапазоні.
SELECT product_id, sku, name, price
FROM products
WHERE is_active = TRUE AND price BETWEEN 1000 AND 15000
ORDER BY price DESC, name;

-- 2. Пошук без урахування регістру залежить від collation бази.
SELECT product_id, name
FROM products
WHERE name LIKE '%монітор%';

-- 3. Обчислюване поле та категоризація залишку.
SELECT name, price, stock_quantity,
       price * stock_quantity AS stock_value,
       CASE
           WHEN stock_quantity = 0 THEN 'немає в наявності'
           WHEN stock_quantity < 5 THEN 'закінчується'
           ELSE 'достатній запас'
       END AS stock_status
FROM products
ORDER BY stock_value DESC;

-- 4. DISTINCT усуває дублікати міст.
SELECT DISTINCT city FROM addresses ORDER BY city;

-- 5. COALESCE замінює NULL зрозумілим значенням.
SELECT payment_id, status, COALESCE(CAST(paid_at AS CHAR), 'ще не сплачено') AS paid_at
FROM payments;

-- Вправа: виведіть п'ять найдорожчих активних товарів.
