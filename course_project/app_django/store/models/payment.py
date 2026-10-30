from decimal import Decimal

from django.core.validators import MinValueValidator
from django.db import models


class Payment(models.Model):
    class Status(models.TextChoices):
        PENDING = "pending", "Очікується"
        SUCCESSFUL = "successful", "Успішний"
        FAILED = "failed", "Невдалий"
        REFUNDED = "refunded", "Повернений"

    order = models.ForeignKey(
        "store.Order",
        on_delete=models.PROTECT,
        related_name="payments",
        verbose_name="Замовлення",
    )
    amount = models.DecimalField(
        "Сума, грн",
        max_digits=12,
        decimal_places=2,
        validators=[MinValueValidator(Decimal("0.01"))],
    )
    status = models.CharField(
        "Статус", max_length=20, choices=Status.choices, default=Status.PENDING
    )
    created_at = models.DateTimeField("Створено", auto_now_add=True)

    class Meta:
        db_table = "payments"
        verbose_name = "платіж"
        verbose_name_plural = "платежі"
        constraints = [
            models.CheckConstraint(
                condition=models.Q(amount__gt=0), name="payment_amount_positive"
            ),
            models.CheckConstraint(
                condition=models.Q(
                    status__in=["pending", "successful", "failed", "refunded"]
                ),
                name="payment_status_valid",
            ),
        ]

    def __str__(self):
        return f"Платіж №{self.pk}: {self.amount} грн"
