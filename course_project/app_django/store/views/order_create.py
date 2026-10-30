from django.contrib import messages
from django.contrib.admin.views.decorators import staff_member_required
from django.contrib.auth.decorators import permission_required
from django.core.exceptions import ValidationError
from django.shortcuts import redirect, render
from django.views.decorators.http import require_http_methods

from store.forms.order import OrderForm, OrderItemFormSet
from store.services.create_order import create_order


@staff_member_required
@permission_required("store.add_order", raise_exception=True)
@require_http_methods(["GET", "POST"])
def order_create(request):
    data = request.POST if request.method == "POST" else None
    form = OrderForm(data)
    formset = OrderItemFormSet(data, prefix="items")
    if request.method == "POST":
        form_valid = form.is_valid()
        items_valid = formset.is_valid()
        if form_valid and items_valid:
            try:
                order = create_order(
                    customer_id=form.cleaned_data["customer"].pk,
                    address_id=form.cleaned_data["shipping_address"].pk,
                    items=[
                        (item["product"].pk, item["quantity"])
                        for item in formset.cleaned_data
                        if item
                    ],
                )
            except ValidationError as error:
                form.add_error(None, error)
            else:
                messages.success(request, f"Створено замовлення №{order.pk}.")
                return redirect("store:order_create")
    return render(
        request, "store/order_create.html", {"form": form, "formset": formset}
    )
