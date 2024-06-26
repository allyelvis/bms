from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'users', views.UserViewSet)
router.register(r'products', views.ProductViewSet)
router.register(r'transactions', views.TransactionViewSet)
router.register(r'accounting', views.AccountingViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
