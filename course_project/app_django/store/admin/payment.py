from django.contrib import admin
from store.models import Payment


@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ("id", "order", "amount", "status", "created_at")
    search_fields = ("order__customer__full_name",)
    list_filter = ("status",)
    list_select_related = ("order",)
