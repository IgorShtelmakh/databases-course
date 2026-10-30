from decimal import Decimal

from django.core.management.base import BaseCommand
from django.db import transaction

from store.models import Address, Category, Customer, Product


class Command(BaseCommand):
    help = "Додати навчальні довідники, не перезаписуючи наявні записи."

    @transaction.atomic
    def handle(self, *args, **options):
        category, _ = Category.objects.get_or_create(name="Аксесуари")
        customer, _ = Customer.objects.get_or_create(
            email="anna@example.com",
            defaults={"full_name": "Анна Коваль"},
        )
        Address.objects.get_or_create(
            customer=customer,
            city="Київ",
            street="вул. Хрещатик, 10",
            postal_code="01001",
        )
        for sku, name, price, stock in [
            ("ACC-001", "Бездротова миша", "1299.00", 30),
            ("ACC-002", "USB-C адаптер", "899.00", 50),
        ]:
            Product.objects.get_or_create(
                sku=sku,
                defaults={
                    "category": category,
                    "name": name,
                    "price": Decimal(price),
                    "stock_quantity": stock,
                },
            )
        self.stdout.write(
            self.style.SUCCESS(
                "Довідники готові. Створіть замовлення в адмінпанелі /admin/."
            )
        )
