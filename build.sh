#!/usr/bin/env bash
# Exit on error
set -o errexit

# Install dependencies
pip install -r requirements.txt

# Collect static files
python manage.py collectstatic --no-input

# Run database migrations
python manage.py migrate

# Load menu data if fixture exists
if [ -f fixtures/menu_data.json ]; then
    python manage.py loaddata fixtures/menu_data.json || echo "Menu data already loaded or error"
fi

# Create superuser if it doesn't exist, and set admin role
echo "
from django.contrib.auth import get_user_model
from allauth.account.models import EmailAddress
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    u = User.objects.create_superuser('admin', 'admin@campusbites.com', 'admin123')
    u.profile.role = 'admin'
    u.profile.full_name = 'Admin'
    u.profile.save()
    EmailAddress.objects.get_or_create(user=u, email='admin@campusbites.com', defaults={'verified': True, 'primary': True})
    print('Admin user created')
else:
    u = User.objects.get(username='admin')
    if u.profile.role != 'admin':
        u.profile.role = 'admin'
        u.profile.save()
    EmailAddress.objects.get_or_create(user=u, email='admin@campusbites.com', defaults={'verified': True, 'primary': True})
    print('Admin user ready')
" | python manage.py shell

# Create kitchen staff user if it doesn't exist
echo "
from django.contrib.auth import get_user_model
from allauth.account.models import EmailAddress
User = get_user_model()
if not User.objects.filter(username='kitchen').exists():
    u = User.objects.create_user('kitchen', 'kitchen@campusbites.com', 'kitchen123')
    u.profile.role = 'kitchen'
    u.profile.full_name = 'Kitchen Staff'
    u.profile.save()
    EmailAddress.objects.get_or_create(user=u, email='kitchen@campusbites.com', defaults={'verified': True, 'primary': True})
    print('Kitchen user created')
else:
    u = User.objects.get(username='kitchen')
    EmailAddress.objects.get_or_create(user=u, email='kitchen@campusbites.com', defaults={'verified': True, 'primary': True})
    print('Kitchen user ready')
" | python manage.py shell

# Reset login lockouts (django-axes)
python manage.py axes_reset
