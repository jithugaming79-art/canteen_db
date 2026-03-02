"""URL Configuration for canteen project."""

from django.contrib import admin
from django.urls import path, include, re_path
from django.conf import settings
from django.conf.urls.static import static
from django.views.generic import TemplateView
from django.views.static import serve

urlpatterns = [
    path('admin/', admin.site.urls),
    path('accounts/', include('allauth.urls')),
    path('', include('accounts.urls')),
    path('', include('menu.urls')),
    path('', include('orders.urls')),
    path('', include('payments.urls')),
    path('', include('chatbot.urls')),
    path('offline/', TemplateView.as_view(template_name="offline.html"), name='offline'),
]

# Serve media files (works in both dev and production)
urlpatterns += [
    re_path(r'^media/(?P<path>.*)$', serve, {'document_root': settings.MEDIA_ROOT}),
]

# Serve static files in development
if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATICFILES_DIRS[0])
