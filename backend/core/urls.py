"""
URL configuration for core project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path

from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

import core.auth as auth
import core.api as api


urlpatterns = [
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    path('admin/', admin.site.urls),
    
    path('v1/register/', auth.register, name='register'),
    path('v1/login/', auth.login, name='login'),
    path('v1/logout/', auth.logout, name='logout'),
    
    path('v1/upload/', api.upload, name='upload'),
    path('v1/graph_type/', api.graph_type, name='graph_type'),
    path('v1/send_settings_data/<str:serial>/<str:image_number>/', api.send_settings_data, name='send_settings_data'),
    path('v1/recieve_settings_data/<str:serial>/<str:image_number>/', api.recieve_settings_data, name='recieve_settings_data'),
    path('v1/send_graph/<str:serial>/<str:image_number>/', api.send_graph, name='send_graph'),
]
