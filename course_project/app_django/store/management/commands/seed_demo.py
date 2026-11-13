from datetime import datetime, timedelta, timezone
from decimal import Decimal

from django.core.management.base import BaseCommand
from django.db import transaction

from store.models import Address, Category, Customer, Order, OrderItem, Payment, Product


# Stable SKUs and example.com emails keep demo data separate from real contacts.
CATALOG = {
    "Аксесуари": [
        ("ACC-001", "Бездротова миша", "1299.00", 30),
        ("ACC-002", "USB-C адаптер", "899.00", 50),
        ("ACC-003", "Механічна клавіатура", "3299.00", 12),
        ("ACC-004", "Килимок для миші", "349.00", 80),
    ],
    "Ноутбуки": [
        ("LAP-001", "Ноутбук Office 14", "24999.00", 8),
        ("LAP-002", "Ноутбук Pro 16", "45999.00", 3),
        ("LAP-003", "Ноутбук Student 15", "18999.00", 15),
        ("LAP-004", "Ноутбук Travel 13", "32999.00", 0),
    ],
    "Монітори": [
        ("MON-001", "Монітор IPS 24", "5999.00", 20),
        ("MON-002", "Монітор QHD 27", "10999.00", 7),
        ("MON-003", "Монітор UltraWide 34", "17999.00", 2),
        ("MON-004", "Монітор Full HD 22", "4299.00", 0),
    ],
    "Аудіо": [
        ("AUD-001", "Навушники Bluetooth", "2499.00", 25),
        ("AUD-002", "Гарнітура USB", "1599.00", 18),
        ("AUD-003", "Колонки настільні", "2199.00", 9),
        ("AUD-004", "Мікрофон USB", "3999.00", 4),
    ],
    "Накопичувачі": [
        ("SSD-001", "SSD 500 ГБ", "1899.00", 35),
        ("SSD-002", "SSD 1 ТБ", "3299.00", 22),
        ("SSD-003", "Зовнішній SSD 2 ТБ", "6499.00", 6),
        ("SSD-004", "Флешнакопичувач 64 ГБ", "299.00", 60),
    ],
    "Мережеве обладнання": [
        ("NET-001", "Роутер Wi-Fi 6", "2899.00", 14),
        ("NET-002", "Комутатор 8 портів", "1199.00", 11),
        ("NET-003", "Кабель Ethernet 3 м", "149.00", 100),
        ("NET-004", "Wi-Fi адаптер USB", "699.00", 0),
    ],
}
CUSTOMERS = [
    ("anna", "Анна Коваль", "Київ", "вул. Хрещатик, 10", "01001"),
    ("bohdan", "Богдан Мельник", "Львів", "вул. Зелена, 25", "79001"),
    ("olena", "Олена Шевченко", "Одеса", "вул. Садова, 8", "65001"),
    ("dmytro", "Дмитро Бондар", "Дніпро", "вул. Центральна, 12", "49001"),
    ("iryna", "Ірина Ткаченко", "Вінниця", "вул. Соборна, 40", "21001"),
    ("maksym", "Максим Кравченко", "Полтава", "вул. Європейська, 15", "36001"),
    ("sofia", "Софія Олійник", "Чернівці", "вул. Головна, 22", "58001"),
    ("andrii", "Андрій Савченко", "Черкаси", "вул. Хрещатик, 35", "18001"),
    ("mariia", "Марія Романенко", "Луцьк", "вул. Лесі Українки, 7", "43001"),
    ("taras", "Тарас Мороз", "Тернопіль", "вул. Руська, 18", "46001"),
    ("natalia", "Наталія Лисенко", "Ужгород", "вул. Корзо, 9", "88001"),
    ("viktor", "Віктор Петренко", "Рівне", "вул. Соборна, 60", "33001"),
]


class Command(BaseCommand):
    help = "Додати навчальний каталог, клієнтів, замовлення та платежі без перезапису."

    def add_arguments(self, parser):
        parser.add_argument(
            "--catalog-only", action="store_true",
            help="Додати лише категорії, товари, клієнтів та адреси.",
        )

    @transaction.atomic
    def handle(self, *args, **options):
        products = []
        for category_name, rows in CATALOG.items():
            category, _ = Category.objects.get_or_create(name=category_name)
            for sku, name, price, stock in rows:
                product, _ = Product.objects.get_or_create(
                    sku=sku,
                    defaults={
                        "category": category, "name": name, "price": Decimal(price),
                        "stock_quantity": stock,
                        "is_active": sku not in {"MON-004", "NET-004"},
                    },
                )
                products.append((product, Decimal(price)))

        customers = []
        for index, (email, name, city, street, postal_code) in enumerate(CUSTOMERS):
            customer, created = Customer.objects.get_or_create(
                email=f"{email}@example.com", defaults={"full_name": name},
            )
            if created:
                Customer.objects.filter(pk=customer.pk).update(
                    created_at=datetime(2026, 1, 1, 9, tzinfo=timezone.utc)
                    + timedelta(days=index * 3)
                )
            address, _ = Address.objects.get_or_create(
                customer=customer, city=city, street=street, postal_code=postal_code,
            )
            customers.append((customer, address))
            if index in (1, 4, 7):
                Address.objects.get_or_create(
                    customer=customer, city=city,
                    street="вул. Шкільна, 5, кв. 12", postal_code=postal_code,
                )

        added_orders = 0
        if not options["catalog_only"]:
            # Fixed timestamps identify demo orders across runs without hard-coded PKs.
            # Existing orders (including edited items/payments) are left untouched.
            statuses = list(Order.Status.values)
            sale_products = [p for p in products if p[0].sku not in {
                "LAP-004", "MON-004", "NET-004", "SSD-004",
            }]
            for index in range(30):
                customer, address = customers[index % 10]
                placed_at = datetime(2026, 3, 1, 10, tzinfo=timezone.utc) + timedelta(days=index * 7)
                if Order.objects.filter(created_at=placed_at).exists():
                    continue
                status = statuses[(index // 10 + index) % len(statuses)]
                order = Order.objects.create(
                    customer=customer, shipping_address=address, status=status,
                )
                Order.objects.filter(pk=order.pk).update(created_at=placed_at)
                total = Decimal("0.00")
                for offset in range(1 + index % 4):
                    product, catalog_price = sale_products[(index * 3 + offset) % len(sale_products)]
                    quantity = 1 + (index + offset) % 3
                    # Some historical sales have a 10% discount.
                    price = (catalog_price * (Decimal("0.90") if index % 3 == 0 else Decimal("1"))).quantize(Decimal("0.01"))
                    OrderItem.objects.create(
                        order=order, product=product, quantity=quantity, unit_price=price,
                    )
                    total += price * quantity
                if status == Order.Status.NEW:
                    payments = [] if index % 2 == 0 else [(total / 2, Payment.Status.SUCCESSFUL), (total / 2, Payment.Status.PENDING)]
                elif status == Order.Status.CANCELLED:
                    payments = [(total, Payment.Status.FAILED if index % 2 == 0 else Payment.Status.REFUNDED)]
                elif index % 2 == 0:
                    half = (total / 2).quantize(Decimal("0.01"))
                    payments = [(half, Payment.Status.SUCCESSFUL), (total - half, Payment.Status.SUCCESSFUL)]
                else:
                    payments = [(total, Payment.Status.SUCCESSFUL)]
                for offset, (amount, payment_status) in enumerate(payments):
                    payment = Payment.objects.create(
                        order=order, amount=amount.quantize(Decimal("0.01")), status=payment_status,
                    )
                    Payment.objects.filter(pk=payment.pk).update(
                        created_at=placed_at + timedelta(hours=offset + 1)
                    )
                added_orders += 1

        counts = ", ".join(f"{model._meta.verbose_name_plural}: {model.objects.count()}" for model in (
            Category, Product, Customer, Address, Order, OrderItem, Payment,
        ))
        self.stdout.write(self.style.SUCCESS(
            f"Навчальні дані готові; додано замовлень: {added_orders}. Усього в БД: {counts}."
        ))
