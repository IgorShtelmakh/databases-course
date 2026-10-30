from django.core.exceptions import ValidationError
from django.db import transaction

from store.models import Address, Order, OrderItem, Product


@transaction.atomic
def create_order(*, customer_id, address_id, items):
    """Створити замовлення та позиції разом. items: список (product_id, quantity)."""

    def positive_integer(value):
        return type(value) is int and 0 < value <= 2147483647

    if not positive_integer(customer_id) or not positive_integer(address_id):
        raise ValidationError("Оберіть клієнта й адресу.")
    if not 1 <= len(items) <= 10:
        raise ValidationError("Замовлення повинно містити від 1 до 10 позицій.")
    if any(
        not positive_integer(pid) or not positive_integer(qty) for pid, qty in items
    ):
        raise ValidationError(
            "Ідентифікатор товару та кількість мають бути додатними цілими числами."
        )
    ids = [pid for pid, _ in items]
    if len(set(ids)) != len(ids):
        raise ValidationError("Товар не може повторюватися в замовленні.")

    address = (
        Address.objects.select_for_update()
        .filter(
            pk=address_id,
            customer_id=customer_id,
        )
        .first()
    )
    if address is None:
        raise ValidationError("Адреса не належить обраному клієнту.")
    # Однаковий порядок блокування зменшує ризик взаємного блокування.
    products = list(
        Product.objects.select_for_update().filter(pk__in=ids).order_by("pk")
    )
    if len(products) != len(ids) or any(not product.is_active for product in products):
        raise ValidationError("Усі товари мають існувати та бути активними.")
    by_id = {product.pk: product for product in products}
    order = Order(customer_id=customer_id, shipping_address=address)
    order.full_clean()
    order.save()
    for product_id, quantity in items:
        item = OrderItem(
            order=order,
            product=by_id[product_id],
            quantity=quantity,
            unit_price=by_id[product_id].price,
        )
        item.full_clean()
        item.save()
    return order
