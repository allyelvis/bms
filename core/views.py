from rest_framework import viewsets
from .models import User, Product, Transaction, Accounting
from .serializers import UserSerializer, ProductSerializer, TransactionSerializer, AccountingSerializer

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer

class TransactionViewSet(viewsets.ModelViewSet):
    queryset = Transaction.objects.all()
    serializer_class = TransactionSerializer

class AccountingViewSet(viewsets.ModelViewSet):
    queryset = Accounting.objects.all()
    serializer_class = AccountingSerializer
