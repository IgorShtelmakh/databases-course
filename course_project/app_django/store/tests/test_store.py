from decimal import Decimal
from unittest.mock import patch

from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError
from django.core.management import call_command
from django.db import DataError, IntegrityError, transaction
from django.test import TestCase, Client
from django.urls import reverse

from store.models import Address, Customer, Order, OrderItem, Product, Payment
from store.queries.order_report import order_report
from store.services.create_order import create_order


class StoreTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        call_command("seed_demo", verbosity=0)
        cls.customer = Customer.objects.get(email="anna@example.com")
        cls.address = Address.objects.get(customer=cls.customer)
        cls.mouse = Product.objects.get(sku="ACC-001")
        cls.adapter = Product.objects.get(sku="ACC-002")
        cls.admin = get_user_model().objects.create_superuser(
            "teacher", "teacher@example.com", "test-password-123"
        )

    def make_order(self, **changes):
        data = {
            "customer_id": self.customer.pk,
            "address_id": self.address.pk,
            "items": [(self.mouse.pk, 2), (self.adapter.pk, 1)],
        }
        data.update(changes)
        return create_order(**data)

    def test_price_snapshot_and_report_total(self):
        order = self.make_order()
        Product.objects.filter(pk=self.mouse.pk).update(price=Decimal("9999.00"))
        self.assertEqual(
            order.items.get(product=self.mouse).unit_price, Decimal("1299.00")
        )
        self.assertEqual(order_report(Decimal("0"))[0]["total"], Decimal("3497.00"))
        self.assertEqual(order_report(Decimal("3497.01")), [])
        order.status = Order.Status.CANCELLED
        order.save()
        self.assertEqual(order_report(Decimal("0")), [])

    def test_input_rejected_without_partial_order(self):
        stranger = Customer.objects.create(
            full_name="Інший клієнт", email="other@example.com"
        )
        invalid_inputs = [
            {"customer_id": stranger.pk},
            {"items": []},
            {"items": [(self.mouse.pk, 0)]},
            {"items": [(self.mouse.pk, True)]},
            {"items": [(self.mouse.pk, 1), (self.mouse.pk, 2)]},
            {"items": [(2147483647, 1)]},
        ]
        for changes in invalid_inputs:
            with self.subTest(changes=changes), self.assertRaises(ValidationError):
                self.make_order(**changes)
        self.assertEqual(Order.objects.count(), 0)
        self.assertEqual(OrderItem.objects.count(), 0)

    def test_inactive_product_rejected(self):
        self.mouse.is_active = False
        self.mouse.save()
        with self.assertRaises(ValidationError):
            self.make_order()
        self.assertEqual(Order.objects.count(), 0)

    def test_failure_after_first_item_rolls_back_everything(self):
        original_save = OrderItem.save

        def fail_second(item, *args, **kwargs):
            if item.product_id == self.adapter.pk:
                raise RuntimeError("Імітація збою під час другої позиції")
            return original_save(item, *args, **kwargs)

        with (
            patch.object(OrderItem, "save", fail_second),
            self.assertRaises(RuntimeError),
        ):
            self.make_order()
        self.assertEqual(Order.objects.count(), 0)
        self.assertEqual(OrderItem.objects.count(), 0)

    def test_database_constraints_without_form_validation(self):
        order = self.make_order()
        operations = [
            lambda: Product.objects.filter(pk=self.mouse.pk).update(price=-1),
            lambda: Product.objects.filter(pk=self.adapter.pk).update(
                sku=self.mouse.sku
            ),
            lambda: Order.objects.filter(pk=order.pk).update(status="invalid"),
            lambda: OrderItem.objects.filter(order=order).update(quantity=0),
            lambda: OrderItem.objects.create(
                order=order, product=self.mouse, quantity=1, unit_price=1
            ),
            lambda: Payment.objects.create(order=order, amount=0),
        ]
        for operation in operations:
            with self.subTest(operation=operation), self.assertRaises(IntegrityError):
                with transaction.atomic():
                    operation()

    def test_unsigned_stock_rejects_negative_value(self):
        with self.assertRaises(DataError), transaction.atomic():
            Product.objects.filter(pk=self.mouse.pk).update(stock_quantity=-1)

    def test_seed_is_repeatable_and_preserves_edits(self):
        self.mouse.price = Decimal("1300.00")
        self.mouse.save()
        call_command("seed_demo", verbosity=0)
        self.assertEqual(Product.objects.count(), 2)
        self.assertEqual(Address.objects.count(), 1)
        self.mouse.refresh_from_db()
        self.assertEqual(self.mouse.price, Decimal("1300.00"))

    def test_auth_permissions_validation_and_escaping(self):
        report_url = reverse("store:order_report")
        create_url = reverse("store:order_create")
        self.assertEqual(self.client.get(report_url).status_code, 302)
        self.assertEqual(self.client.get(create_url).status_code, 302)
        staff = get_user_model().objects.create_user("staff", is_staff=True)
        self.client.force_login(staff)
        self.assertEqual(self.client.get(report_url).status_code, 403)
        self.assertEqual(self.client.get(create_url).status_code, 403)
        self.client.force_login(self.admin)
        for value in ["-1", "NaN", "1 OR 1=1", "1.234", "10000000000"]:
            self.assertEqual(
                self.client.get(report_url, {"min_total": value}).status_code, 400
            )
        self.customer.full_name = "<script>alert(1)</script>"
        self.customer.save()
        self.make_order()
        response = self.client.get(report_url)
        self.assertContains(response, "&lt;script&gt;")
        self.assertNotContains(response, "<script>alert")
        self.assertIn("no-store", response.headers["Cache-Control"])

    def test_advanced_order_form(self):
        self.client.force_login(self.admin)
        url = reverse("store:order_create")
        self.assertContains(self.client.get(url), "items-TOTAL_FORMS")
        payload = {
            "customer": self.customer.pk,
            "shipping_address": self.address.pk,
            "items-TOTAL_FORMS": "3",
            "items-INITIAL_FORMS": "0",
            "items-0-product": self.mouse.pk,
            "items-0-quantity": "2",
            "items-1-product": self.adapter.pk,
            "items-1-quantity": "1",
        }
        self.assertRedirects(self.client.post(url, payload), url)
        order = Order.objects.get()
        self.assertEqual(order.items.count(), 2)
        self.assertEqual(
            self.client.get(reverse("admin:store_order_add")).status_code, 200
        )
        response = self.client.get(reverse("admin:store_order_change", args=[order.pk]))
        self.assertContains(response, "1299")
        csrf_client = Client(enforce_csrf_checks=True)
        csrf_client.force_login(self.admin)
        self.assertEqual(csrf_client.post(url, payload).status_code, 403)

    def test_standard_admin_creates_order_with_inline_items(self):
        self.client.force_login(self.admin)
        url = reverse("admin:store_order_add")
        self.assertContains(self.client.get(url), "items-TOTAL_FORMS")
        payload = {
            "customer": self.customer.pk,
            "shipping_address": self.address.pk,
            "status": "new",
            "items-TOTAL_FORMS": "2",
            "items-INITIAL_FORMS": "0",
            "items-0-product": self.mouse.pk,
            "items-0-quantity": "2",
            "items-0-unit_price": "1299.00",
            "items-1-product": self.adapter.pk,
            "items-1-quantity": "1",
            "items-1-unit_price": "899.00",
            "_save": "Зберегти",
        }
        # Невалідна позиція не повинна зберегти навіть основне замовлення.
        bad_payload = {**payload, "items-1-quantity": "0"}
        self.assertEqual(self.client.post(url, bad_payload).status_code, 200)
        self.assertEqual(Order.objects.count(), 0)
        self.assertRedirects(
            self.client.post(url, payload), reverse("admin:store_order_changelist")
        )
        order = Order.objects.get()
        self.assertEqual(order.items.count(), 2)
        self.assertEqual(order_report(Decimal("0"))[0]["total"], Decimal("3497.00"))
        self.assertNotContains(
            self.client.get(reverse("admin:store_order_changelist")), "SQL-звіт"
        )
