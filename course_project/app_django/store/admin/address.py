from django.contrib import admin
from store.models import Address


@admin.register(Address)
class AddressAdmin(admin.ModelAdmin):
    list_display = ("id", "customer", "city", "street", "postal_code")
    list_select_related = ("customer",)
    search_fields = ("city", "street", "customer__full_name")

    def get_readonly_fields(self, request, obj=None):
        # Адреса після створення не переходить до іншого клієнта.
        return ("customer",) if obj else ()
