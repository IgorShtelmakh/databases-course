from django.urls import path
from store.views.order_create import order_create
from store.views.order_report import order_report

app_name = "store"
urlpatterns = [
    path("orders/new/", order_create, name="order_create"),
    path("reports/orders/", order_report, name="order_report"),
]
