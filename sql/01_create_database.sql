-- Тема 1. Створення бази даних і реляційної схеми
-- СУБД: MySQL 8.0 / 8.4
-- Запускайте цей файл першим. Він створює порожню навчальну БД.
--
-- Теорія:
-- DDL (Data Definition Language) описує структуру даних. CREATE DATABASE
-- створює БД, а CREATE TABLE — таблиці, колонки та правила цілісності.
-- PRIMARY KEY однозначно визначає рядок, FOREIGN KEY зв'язує таблиці,
-- UNIQUE забороняє дублікати, CHECK перевіряє умову, INDEX пришвидшує пошук.

-- Створюємо БД лише тоді, коли вона ще не існує.
CREATE DATABASE IF NOT EXISTS online_store
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

-- Робимо online_store активною БД для наступних команд.
USE online_store;

-- Довідник категорій; назва кожної категорії має бути унікальною.
CREATE TABLE IF NOT EXISTS categories (
    category_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
) ENGINE = InnoDB;

-- Клієнти; email використовується як альтернативний унікальний ключ.
CREATE TABLE IF NOT EXISTS customers (
    customer_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(254) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_customers_email_not_blank CHECK (TRIM(email) <> '')
) ENGINE = InnoDB;

-- Адреси мають зв'язок «багато до одного» з клієнтами.
CREATE TABLE IF NOT EXISTS addresses (
    address_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT UNSIGNED NOT NULL,
    city VARCHAR(100) NOT NULL,
    street VARCHAR(200) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    CONSTRAINT fk_addresses_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE = InnoDB;

-- Товари належать категоріям і мають унікальний артикул SKU.
CREATE TABLE IF NOT EXISTS products (
    product_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT UNSIGNED NOT NULL,
    sku VARCHAR(40) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    stock_quantity INT UNSIGNED NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_products_price CHECK (price > 0),
    CONSTRAINT fk_products_category FOREIGN KEY (category_id)
        REFERENCES categories(category_id) ON DELETE RESTRICT,
    INDEX idx_products_category (category_id)
) ENGINE = InnoDB;

-- Замовлення посилаються на клієнта та вибрану адресу доставки.
CREATE TABLE IF NOT EXISTS orders (
    order_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT UNSIGNED NOT NULL,
    shipping_address_id BIGINT UNSIGNED NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'new',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_orders_status CHECK (
        status IN ('new', 'paid', 'shipped', 'completed', 'cancelled')
    ),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id) ON DELETE RESTRICT,
    CONSTRAINT fk_orders_address FOREIGN KEY (shipping_address_id)
        REFERENCES addresses(address_id) ON DELETE RESTRICT,
    INDEX idx_orders_customer (customer_id),
    INDEX idx_orders_created_at (created_at)
) ENGINE = InnoDB;

-- Позиції реалізують зв'язок «багато до багатьох» замовлень і товарів.
CREATE TABLE IF NOT EXISTS order_items (
    order_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_items_price CHECK (unit_price > 0),
    CONSTRAINT fk_items_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_items_product FOREIGN KEY (product_id)
        REFERENCES products(product_id) ON DELETE RESTRICT,
    INDEX idx_items_product (product_id)
) ENGINE = InnoDB;

-- Платежі відокремлено, бо одне замовлення може мати кілька спроб оплати.
CREATE TABLE IF NOT EXISTS payments (
    payment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    paid_at TIMESTAMP NULL,
    CONSTRAINT chk_payments_amount CHECK (amount > 0),
    CONSTRAINT chk_payments_status CHECK (
        status IN ('pending', 'successful', 'failed', 'refunded')
    ),
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id) ON DELETE RESTRICT,
    INDEX idx_payments_order (order_id)
) ENGINE = InnoDB;

-- Перевірка: має бути 7 таблиць.
SHOW TABLES;
