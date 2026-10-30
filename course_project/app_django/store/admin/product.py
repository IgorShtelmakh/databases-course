from django.contrib import admin
from store.models import Product


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ("id", "sku", "name", "price", "stock_quantity", "is_active")
    search_fields = ("name", "sku")
    list_filter = ("category", "is_active")
    list_select_related = ("category",)
