#!/bin/bash

# Update and install dependencies
sudo apt update
sudo apt install -y python3-pip python3-venv libpq-dev postgresql postgresql-contrib nginx curl nodejs npm

# Set up PostgreSQL
sudo -u postgres psql -c "CREATE DATABASE business_db;"
sudo -u postgres psql -c "CREATE USER business_user WITH PASSWORD 'password';"
sudo -u postgres psql -c "ALTER ROLE business_user SET client_encoding TO 'utf8';"
sudo -u postgres psql -c "ALTER ROLE business_user SET default_transaction_isolation TO 'read committed';"
sudo -u postgres psql -c "ALTER ROLE business_user SET timezone TO 'UTC';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE business_db TO business_user;"

# Create and activate virtual environment
python3 -m venv env
source env/bin/activate

# Install Django and other dependencies
pip install django djangorestframework psycopg2-binary

# Create Django project
django-admin startproject business_management_system backend
cd backend

# Create Django apps
python manage.py startapp core
python manage.py startapp hospital
python manage.py startapp retail
python manage.py startapp school

# Create requirements.txt
pip freeze > requirements.txt

# Populate settings.py
cat <<EOL > business_management_system/settings.py
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = 'your-secret-key'
DEBUG = True
ALLOWED_HOSTS = []

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'core',
    'hospital',
    'retail',
    'school',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'business_management_system.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'business_management_system.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'business_db',
        'USER': 'business_user',
        'PASSWORD': 'password',
        'HOST': 'localhost',
        'PORT': '',
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_L10N = True
USE_TZ = True

STATIC_URL = '/static/'
EOL

# Migrate the database
python manage.py migrate

# Create superuser
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'admin')" | python manage.py shell
