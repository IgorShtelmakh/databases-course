from django.core.exceptions import ValidationError
from django.db import models


class Order(models.Model):
    class Status(models.TextChoices):
        NEW = "new", "Нове"
        PAID = "paid", "Оплачене"
        SHIPPED = "shipped", "Відправлене"
        COMPLETED = "completed", "Завершене"
        CANCELLED = "cancelled", "Скасоване"

    customer = models.ForeignKey(
        "store.Customer",
        on_delete=models.PROTECT,
        related_name="orders",
        verbose_name="Клієнт",
    )
    shipping_address = models.ForeignKey(
        "store.Address",
        on_delete=models.PROTECT,
        related_name="orders",
        verbose_name="Адреса доставки",
    )
    status = models.CharField(
        "Статус", max_length=20, choices=Status.choices, default=Status.NEW
    )
    created_at = models.DateTimeField("Створено", auto_now_add=True)

    class Meta:
        db_table = "orders"
        verbose_name = "замовлення"
        verbose_name_plural = "замовлення"
        ordering = ["-created_at", "-pk"]
        indexes = [models.Index(fields=["created_at"], name="orders_created_idx")]
        constraints = [
            models.CheckConstraint(
                condition=models.Q(
                    status__in=["new", "paid", "shipped", "completed", "cancelled"]
                ),
                name="order_status_valid",
            )
        ]

    def clean(self):
        super().clean()
        if self.shipping_address_id and self.customer_id:
            from .address import Address

            if not Address.objects.filter(
                pk=self.shipping_address_id, customer_id=self.customer_id
            ).exists():
                raise ValidationError(
                    {"shipping_address": "Адреса не належить цьому клієнту."}
                )

    def __str__(self):
        return f"Замовлення №{self.pk}"
