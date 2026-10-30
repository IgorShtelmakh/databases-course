from decimal import Decimal

from django.core.validators import MinValueValidator
from django.db import models


class Product(models.Model):
    category = models.ForeignKey(
        "store.Category",
        on_delete=models.PROTECT,
        related_name="products",
        verbose_name="Категорія",
    )
    sku = models.CharField("Артикул", max_length=40, unique=True)
    name = models.CharField("Назва", max_length=200)
    price = models.DecimalField(
        "Ціна, грн",
        max_digits=12,
        decimal_places=2,
        validators=[MinValueValidator(Decimal("0.01"))],
    )
    stock_quantity = models.PositiveIntegerField("Залишок", default=0)
    is_active = models.BooleanField("Активний", default=True)

    class Meta:
        db_table = "products"
        verbose_name = "товар"
        verbose_name_plural = "товари"
        ordering = ["name"]
        constraints = [
            models.CheckConstraint(
                condition=models.Q(price__gt=0), name="product_price_positive"
            ),
        ]

    def __str__(self):
        return f"{self.name} ({self.sku})"
