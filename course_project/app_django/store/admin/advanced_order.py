from django.contrib import admin
from store.models import Order, OrderItem


class OrderItemInline(admin.TabularInline):
    model = OrderItem
    fields = ("product", "quantity", "unit_price")
    readonly_fields = fields
    extra = 0
    can_delete = False

    def has_add_permission(self, request, obj=None):
        return False

    def has_change_permission(self, request, obj=None):
        return False


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ("id", "customer", "status", "created_at")
    list_filter = ("status",)
    search_fields = ("customer__full_name", "customer__email")
    list_select_related = ("customer", "shipping_address")
    readonly_fields = ("customer", "shipping_address", "created_at")
    inlines = (OrderItemInline,)
    change_list_template = "admin/advanced_order_change_list.html"

    def has_add_permission(self, request):
        # Створення доступне лише через форму, яка викликає сервіс.
        return False

    def has_delete_permission(self, request, obj=None):
        return False
