#!/bin/bash

# Variables
PROJECT_NAME="business_management"
APP_NAME="core"
DB_NAME="your_database_name"
DB_USER="your_username"
DB_PASSWORD="your_password"
DB_HOST="mysql-28d68f05-allyelvis6569-cc54.a.aivencloud.com"
DB_PORT="12080"

# Create Django Project
echo "Creating Django project..."
django-admin startproject $PROJECT_NAME
cd $PROJECT_NAME

# Create Django App
echo "Creating Django app..."
django-admin startapp $APP_NAME

# Install required packages
echo "Installing Django and MySQL client..."
pip install django mysqlclient djangorestframework djangorestframework-simplejwt

# Configure settings.py for MySQL
echo "Configuring settings.py..."
cat <<EOL >> $PROJECT_NAME/settings.py

# Added for MySQL configuration
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': '$DB_NAME',
        'USER': '$DB_USER',
        'PASSWORD': '$DB_PASSWORD',
        'HOST': '$DB_HOST',
        'PORT': '$DB_PORT',
    }
}

INSTALLED_APPS += [
    'rest_framework',
    'rest_framework_simplejwt',
    '$APP_NAME',
]

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
}
EOL

# Create models
echo "Creating models in $APP_NAME/models.py..."
cat <<EOL > $APP_NAME/models.py
from django.db import models

class User(models.Model):
    username = models.CharField(max_length=50)
    password = models.CharField(max_length=255)
    role = models.CharField(max_length=10)
    created_at = models.DateTimeField(auto_now_add=True)

class Product(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    stock = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)

class Transaction(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.IntegerField()
    total = models.DecimalField(max_digits=10, decimal_places=2)
    transaction_date = models.DateTimeField(auto_now_add=True)

class Accounting(models.Model):
    transaction = models.ForeignKey(Transaction, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    type = models.CharField(max_length=10)
    created_at = models.DateTimeField(auto_now_add=True)
EOL

# Create and apply migrations
echo "Making and applying migrations..."
python manage.py makemigrations
python manage.py migrate

# Create URLs for the app
echo "Setting up URLs..."
cat <<EOL > $PROJECT_NAME/urls.py
from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/', include('$APP_NAME.urls')),
]
EOL

# Create views and serializers
echo "Setting up views and serializers..."
mkdir $APP_NAME/serializers
cat <<EOL > $APP_NAME/serializers/__init__.py
from rest_framework import serializers
from .models import User, Product, Transaction, Accounting

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = '__all__'

class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = '__all__'

class TransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transaction
        fields = '__all__'

class AccountingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Accounting
        fields = '__all__'
EOL

cat <<EOL > $APP_NAME/views.py
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
EOL

cat <<EOL > $APP_NAME/urls.py
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
EOL

# Setting up React frontend
echo "Setting up React frontend..."
npx create-react-app frontend
cd frontend
npm install axios

# Create API service
echo "Creating API service..."
mkdir src/services
cat <<EOL > src/services/api.js
import axios from 'axios';

const api = axios.create({
    baseURL: 'http://localhost:8000/api',
});

export default api;
EOL

# Create ProductList component
echo "Creating ProductList component..."
mkdir src/components
cat <<EOL > src/components/ProductList.js
import React, { useEffect, useState } from 'react';
import api from '../services/api';

function ProductList() {
    const [products, setProducts] = useState([]);

    useEffect(() => {
        api.get('/products/')
            .then(response => setProducts(response.data))
            .catch(error => console.error('Error fetching products:', error));
    }, []);

    return (
        <div>
            <h1>Products</h1>
            <ul>
                {products.map(product => (
                    <li key={product.id}>{product.name} - ${product.price}</li>
                ))}
            </ul>
        </div>
    );
}

export default ProductList;
EOL

# Final Instructions
echo "Setup complete!"
echo "To start the Django server, run:"
echo "cd $PROJECT_NAME"
echo "python manage.py runserver"
echo "To start the React app, run:"
echo "cd frontend"
echo "npm start"