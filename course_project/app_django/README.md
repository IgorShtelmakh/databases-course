# Навчальний магазин на Django

Базовий результат — стандартна адміністративна панель магазину на Django 5.2 та MySQL 8.4. Сервіс замовлень, власна форма та вебзвіт — необов’язковий Advanced level. Повний розбір — у [методичці](../instructions_django.md).

Потрібні Python 3.12, MySQL 8.4 (InnoDB) і бібліотеки для `mysqlclient`, якщо для вашої системи немає готового wheel. Кожна модель зберігається в окремому файлі `store/models/`.

## Запуск

Із кореня репозиторію:

```bash
cd course_project/app_django
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
```

Windows PowerShell: створення середовища — `py -3.12 -m venv .venv`, активація — `.venv\Scripts\Activate.ps1`.

У DBeaver від адміністратора створіть окрему навчальну БД. Замініть пароль своїм:

```sql
CREATE DATABASE store_django CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'store_django'@'localhost' IDENTIFIED BY 'replace-with-local-password';
GRANT ALL PRIVILEGES ON store_django.* TO 'store_django'@'localhost';
```

Скопіюйте `.env.example` у `.env` через редактор. Заповніть пароль MySQL і `DJANGO_SECRET_KEY`, згенерований командою:

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Не додавайте `.env` до Git. Далі:

```bash
python manage.py migrate
python manage.py seed_demo
python manage.py createsuperuser
python manage.py check
python manage.py runserver
```

- Адмінпанель: <http://127.0.0.1:8000/admin/>
- Власна форма (Advanced level): <http://127.0.0.1:8000/store/orders/new/>
- SQL-звіт (додатково): <http://127.0.0.1:8000/store/reports/orders/>

Увійдіть створеним superuser. У розділі «Замовлення» натисніть «Додати», оберіть Анну та її адресу. У рядках позицій введіть дві миші за ціною 1299,00 і один адаптер за 899,00. У базовій панелі ціну продажу вводять вручну. Контрольна сума — **3497,00 грн**; її можна перевірити SQL-запитом із методички. Навчальне наповнення повторюване й не перезаписує відредаговані ціни.

## Advanced level (необов’язково)

Готовий код також містить сервіс `store/services/create_order.py`, власну форму й SQL-звіт. Вони не потрібні для виконання базового завдання. Сервіс автоматично бере ціну з каталогу та створює замовлення з позиціями в транзакції.

Для переходу на оформлення лише через сервіс замініть у `store/admin/__init__.py` імпорт `from .order import OrderAdmin` на `from .advanced_order import OrderAdmin`. Не імпортуйте обидві реєстрації одночасно. Перезапустіть сервер: стандартне додавання буде вимкнено, а в списку замовлень з’являться кнопки власної форми та звіту. У цьому варіанті позиції доступні лише для читання.

## Перевірка

```bash
python manage.py check
python manage.py makemigrations --check --dry-run
```

Для тестів потрібні права на окрему базу, яку Django створює і видаляє сам. Не зберігайте власні дані у `test_store_django`. Адміністратор MySQL виконує:

```sql
GRANT ALL PRIVILEGES ON test_store_django.* TO 'store_django'@'localhost';
```

```bash
python manage.py test
```

Тести перевіряють транзакційний відкат, історичну ціну, обмеження БД, оформлення через HTTP, дозволи, CSRF та SQL-звіт. Використовуйте MySQL; SQLite не перевіряє еквівалентно блокування та специфіку MySQL.

## Межі прикладу

Залишок інформаційний: замовлення не резервує і не списує товар. Платежі вводять вручну, без банківської інтеграції та автоматичної зміни статусу замовлення. Належність адреси перевіряється `Order.clean()` у формі адмінпанелі, а в Advanced level — також сервісом, а не складеним FK. Прямий SQL може обійти це правило. Адреса доставки не зберігається як історичний знімок. Базова адмінпанель допускає чернетку без позицій і ручне редагування ціни продажу. Сервіс Advanced level допускає 1–10 позицій, власна форма показує три рядки.

Міграції збережено у репозиторії. Не імпортуйте сюди SQL-схему з іншого прикладу. `runserver` і `DEBUG=True` призначені для локального навчання; розгортання публічного сервісу потребує окремої конфігурації.
