from django.db import models


class Category(models.Model):
    name = models.CharField("Назва", max_length=100, unique=True)

    class Meta:
        db_table = "categories"
        verbose_name = "категорія"
        verbose_name_plural = "категорії"
        ordering = ["name"]

    def __str__(self):
        return self.name
