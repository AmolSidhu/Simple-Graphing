from django.http import JsonResponse
from django.db.models import Q
from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import Credentials

import hashlib
import jwt
import logging

logger = logging.getLogger(__name__)

@api_view(['POST'])
def register(request):
    try:
        if request.method == 'POST':
            existing_user = Credentials.objects.filter(Q(username=request.data['username']) | Q(email=request.data['email'])).first()
            if existing_user and existing_user.username == request.data['username']:
                response = JsonResponse({'msg': 'Username already exists'},
                                        status=status.HTTP_409_CONFLICT)
            elif existing_user and existing_user.email == request.data['email']:
                response = JsonResponse({'msg': 'Email already exists'},
                                        status=status.HTTP_409_CONFLICT)
            else:
                password = hashlib.sha256(request.data['password'].encode()).hexdigest()
                new_user = Credentials.objects.create(
                    username=request.data['username'],
                    email=request.data['email'],
                    password=password
                )
                new_user.save()
                response = JsonResponse({'msg': 'User registered successfully'},
                                        status=status.HTTP_200_OK)
            return response
    except Exception as e:
        logging.error(f"Error during registration: {str(e)}")
        return Response({'message': 'Internal server error'},
                        status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
@api_view(['POST'])
def login(request):
    try:
        if request.method == 'POST':
            try:
                user = Credentials.objects.get(username=request.data['username'])
            except Credentials.DoesNotExist:
                return JsonResponse({'msg': 'User not found'},
                                    status=status.HTTP_404_NOT_FOUND)
                
            correct_password = hashlib.sha256(request.data['password'].encode()).hexdigest() == user.password
            if not correct_password:
                return JsonResponse({'msg': 'Incorrect password'},
                                    status=status.HTTP_401_UNAUTHORIZED)
            else:
                payload = {
                    'username': user.username,
                    'email': user.email
                }
                token = jwt.encode(payload, 'SECRET_KEY', algorithm='HS256')
                response =  JsonResponse({'token': token, 'msg': 'Logged in successfully'},
                                         status=status.HTTP_200_OK)
                return response
    except Exception as e:
        logging.error(f"Error during login: {str(e)}")
        return Response({'message': 'Internal server error'},
                        status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
def logout(request):
    try:
        if request.method == 'POST':
            response = Response()
            response.delete_cookie('token')
            response['msg'] = 'Logged out successfully'
            response.status_code = status.HTTP_200_OK
            return response
    except Exception as e:
        logging.error(f"Error during logout: {str(e)}")
        return Response({'message': 'Internal server error'},
                        status=status.HTTP_500_INTERNAL_SERVER_ERROR)