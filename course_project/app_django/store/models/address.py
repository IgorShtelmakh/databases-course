from django.db import models


class Address(models.Model):
    customer = models.ForeignKey(
        "store.Customer",
        on_delete=models.PROTECT,
        related_name="addresses",
        verbose_name="Клієнт",
    )
    city = models.CharField("Місто", max_length=100)
    street = models.CharField("Вулиця та будинок", max_length=200)
    postal_code = models.CharField("Поштовий індекс", max_length=20)

    class Meta:
        db_table = "addresses"
        verbose_name = "адреса"
        verbose_name_plural = "адреси"

    def __str__(self):
        return f"{self.customer} — {self.city}, {self.street}"
