#!/usr/bin/env bash
# Exit on error
set -o errexit

# Install dependencies
pip install -r requirements.txt

# Collect static files
python manage.py collectstatic --no-input

# Run database migrations
python manage.py migrate

# Create superuser if it doesn't exist
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(username='admin').exists() or User.objects.create_superuser('admin', 'admin@campusbites.com', 'admin123')" | python manage.py shell

# Create kitchen staff user if it doesn't exist
echo "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='kitchen').exists():
    u = User.objects.create_user('kitchen', 'kitchen@campusbites.com', 'kitchen123')
    u.profile.role = 'kitchen'
    u.profile.full_name = 'Kitchen Staff'
    u.profile.save()
    print('Kitchen user created')
else:
    print('Kitchen user already exists')
" | python manage.py shell

# Reset login lockouts (django-axes)
python manage.py axes_reset
