from decimal import Decimal

from django.core.validators import MinValueValidator
from django.db import models


class OrderItem(models.Model):
    order = models.ForeignKey(
        "store.Order",
        on_delete=models.PROTECT,
        related_name="items",
        verbose_name="Замовлення",
    )
    product = models.ForeignKey(
        "store.Product",
        on_delete=models.PROTECT,
        related_name="order_items",
        verbose_name="Товар",
    )
    quantity = models.PositiveIntegerField(
        "Кількість", validators=[MinValueValidator(1)]
    )
    unit_price = models.DecimalField(
        "Ціна продажу, грн",
        max_digits=12,
        decimal_places=2,
        validators=[MinValueValidator(Decimal("0.01"))],
    )

    class Meta:
        db_table = "order_items"
        verbose_name = "позиція замовлення"
        verbose_name_plural = "позиції замовлень"
        constraints = [
            models.UniqueConstraint(
                fields=["order", "product"], name="order_product_unique"
            ),
            models.CheckConstraint(
                condition=models.Q(quantity__gt=0), name="item_quantity_positive"
            ),
            models.CheckConstraint(
                condition=models.Q(unit_price__gt=0), name="item_price_positive"
            ),
        ]

    def __str__(self):
        return f"{self.product} × {self.quantity}"
