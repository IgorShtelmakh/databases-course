from django.contrib.admin.views.decorators import staff_member_required
from django.contrib.auth.decorators import permission_required
from django.shortcuts import render
from django.views.decorators.http import require_GET
from django.views.decorators.cache import never_cache

from store.forms.report import ReportForm
from store.queries.order_report import order_report as query_order_report


@staff_member_required
@permission_required("store.view_order", raise_exception=True)
@never_cache
@require_GET
def order_report(request):
    form = ReportForm(request.GET if request.GET else {"min_total": "0"})
    valid = form.is_valid()
    rows = query_order_report(form.cleaned_data["min_total"]) if valid else []
    return render(
        request,
        "store/order_report.html",
        {"form": form, "rows": rows},
        status=200 if valid else 400,
    )
