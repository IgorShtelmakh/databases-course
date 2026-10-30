from django.db import models


class Customer(models.Model):
    full_name = models.CharField("ПІБ", max_length=150)
    email = models.EmailField("Email", unique=True)
    created_at = models.DateTimeField("Створено", auto_now_add=True)

    class Meta:
        db_table = "customers"
        verbose_name = "клієнт"
        verbose_name_plural = "клієнти"
        ordering = ["full_name"]

    def __str__(self):
        return self.full_name
