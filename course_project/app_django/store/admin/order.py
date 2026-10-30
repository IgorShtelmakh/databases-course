from django.contrib import admin

from store.models import Order, OrderItem


class OrderItemInline(admin.TabularInline):
    model = OrderItem
    fields = ("product", "quantity", "unit_price")
    extra = 1


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ("id", "customer", "status", "created_at")
    list_filter = ("status",)
    search_fields = ("customer__full_name", "customer__email")
    list_select_related = ("customer", "shipping_address")
    readonly_fields = ("created_at",)
    inlines = (OrderItemInline,)
