from decimal import Decimal
from django import forms


class ReportForm(forms.Form):
    min_total = forms.DecimalField(
        label="Мінімальна сума, грн",
        min_value=Decimal("0"),
        max_digits=12,
        decimal_places=2,
        initial=Decimal("0"),
    )
