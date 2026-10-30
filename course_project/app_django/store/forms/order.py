from django import forms
from django.forms import formset_factory

from store.models import Address, Customer, Product


class OrderForm(forms.Form):
    customer = forms.ModelChoiceField(label="Клієнт", queryset=Customer.objects.all())
    shipping_address = forms.ModelChoiceField(
        label="Адреса доставки",
        queryset=Address.objects.select_related("customer"),
        help_text="Оберіть адресу саме цього клієнта.",
    )


class OrderItemForm(forms.Form):
    product = forms.ModelChoiceField(
        label="Товар", queryset=Product.objects.filter(is_active=True)
    )
    quantity = forms.IntegerField(label="Кількість", min_value=1, max_value=2147483647)


OrderItemFormSet = formset_factory(
    OrderItemForm,
    extra=2,
    min_num=1,
    validate_min=True,
    max_num=10,
    validate_max=True,
    absolute_max=10,
)
