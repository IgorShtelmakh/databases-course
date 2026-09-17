-- Тема 12. Імпорт та експорт даних
-- Шляхи, права FILE і local_infile залежать від інсталяції MySQL.
-- Тому небезпечні/системно залежні команди залишено закоментованими.
--
-- Теорія:
-- Імпорт переносить зовнішні дані до БД, експорт — із БД у файл.
-- LOAD DATA читає CSV значно ефективніше за окремі INSERT. Staging-таблиця
-- приймає сирі дані для перевірки перед перенесенням у робочі таблиці.
-- INTO OUTFILE пише файл на сервері, тому потребує спеціальних прав і шляху.

-- Обираємо навчальну БД.
USE online_store;

-- Створюємо проміжну таблицю, структура якої відповідає колонкам CSV.
CREATE TABLE IF NOT EXISTS product_import (
    sku VARCHAR(40) PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    stock_quantity INT UNSIGNED NOT NULL
);

-- Приклад CSV із заголовком:
-- sku,category_name,product_name,price,stock_quantity
-- ACC-100,Аксесуари,Підставка для ноутбука,1499.00,25

-- Клієнтський імпорт. У DBeaver потрібно дозволити local_infile драйверу.
-- LOAD DATA LOCAL INFILE '/absolute/path/products.csv'
-- INTO TABLE product_import
-- CHARACTER SET utf8mb4
-- FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES
-- (sku, category_name, product_name, price, stock_quantity);

-- Перевіряйте staging-таблицю до перенесення в основні таблиці.
SELECT * FROM product_import;

-- Серверний експорт потребує права FILE та дозволеного secure_file_priv.
-- Дізнаємося каталог, у який серверу дозволено записувати файли.
SHOW VARIABLES LIKE 'secure_file_priv';
-- SELECT product_id, sku, name, price, stock_quantity
-- FROM products
-- INTO OUTFILE '/allowed/path/products_export.csv'
-- CHARACTER SET utf8mb4
-- FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n';

-- Практичний варіант без серверних прав: у DBeaver виконайте SELECT,
-- натисніть правою кнопкою на результаті -> Export Data -> CSV.
