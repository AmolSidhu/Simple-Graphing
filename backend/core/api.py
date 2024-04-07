from django.http import JsonResponse
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.exceptions import AuthenticationFailed
from secrets import token_hex
from django.core.files.base import ContentFile
from django.core.files.storage import default_storage
import pandas as pd
import logging
import jwt
import base64

from .graph_class import GraphGenerator

from .models import Credentials, DataFile, GraphModel

logger = logging.getLogger(__name__)

@api_view(['POST'])
def upload(request):
    try:
        if request.method == 'POST':
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'message': 'Invalid or missing Authorization header'},
                                    status=status.HTTP_401_UNAUTHORIZED)
            try:
                payload = jwt.decode(token, 'SECRET_KEY', algorithms=['HS256'])
            except jwt.ExpiredSignatureError:
                raise AuthenticationFailed('Unauthenticated')
            user = Credentials.objects.get(username=payload['username'], email=payload['email'])
            if not user:
                return JsonResponse({'message': 'Username is required'},
                                    status=status.HTTP_400_BAD_REQUEST)
            file = request.FILES.get('excelFile')
            if not file:
                return JsonResponse({'message': 'No file provided'}, status=400)
            file_extension = file.name.split('.')[-1]
            if file_extension != 'csv':
                return JsonResponse({'message': 'Invalid file type'}, status=400)
            serial = token_hex(5) + '_' + token_hex(10) + '_' + token_hex(5)
            path = default_storage.save(f'Data/{serial}.{file_extension}', ContentFile(file.read()))
            DataFile.objects.create(
                file_serial=serial,
                file_name=f'{serial}{file_extension}',
                uploaded_by=user,
                initial_file_name= request.data['file_name']
            )
            datafile = DataFile.objects.get(file_serial=serial)
            GraphModel.objects.create(
                username=user,
                file_name=datafile,
                image_number=1,
            )
            response_data = {
                'msg': f'File uploaded successfully and saved at {path}',
                'serial': serial,
                'image_number': '1'
            }
            return JsonResponse(response_data, status=200)
    except Credentials.DoesNotExist:
        return JsonResponse({'message': 'User does not exist'},
                            status=status.HTTP_404_NOT_FOUND)
    except jwt.InvalidTokenError:
        return JsonResponse({'message': 'Invalid token'}, status=status.HTTP_401_UNAUTHORIZED)
    except Exception as e:
        logging.error(f"Error during file upload: {str(e)}")
        return JsonResponse({'message': 'Internal server error'},
                            status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['PATCH'])
def graph_type(request):
    try:
        if request.method == 'PATCH':
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'message': 'Invalid or missing Authorization header'},
                                    status=status.HTTP_401_UNAUTHORIZED)
            try:
                payload = jwt.decode(token, 'SECRET_KEY', algorithms=['HS256'])
            except jwt.ExpiredSignatureError:
                raise AuthenticationFailed('Unauthenticated')
            current_graph = GraphModel.objects.get(username=payload['username'],
                                                   file_name=request.data['serial'],
                                                   image_number=request.data['image_number'])
            if not current_graph:
                return JsonResponse({'message': 'Graph does not exist'},
                                    status=status.HTTP_404_NOT_FOUND)
            current_graphs = ['Pie Graph', 'Bar Graph', 'Line Graph',
                              'Scatter Graph', 'Histogram Graph', 'Box Plot Graph',
                              'Heat Map Graph', 'Bubble Graph', 'Area Graph', 'Donut Graph']
            if request.data['graph_type'] not in current_graphs:
                return JsonResponse({'message': 'Invalid graph type'},
                                    status=status.HTTP_400_BAD_REQUEST)
            current_graph.graph_type = request.data['graph_type']
            current_graph.save()
            return JsonResponse({'message': 'Graph type updated successfully'},
                                status=status.HTTP_200_OK)
    except Exception as e:
        logging.error(f"Error during graph type selection: {str(e)}")
        return JsonResponse({'message': 'Internal server error'},
                            status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
def send_settings_data(request, serial, image_number):
    try:
        if request.method == 'GET':
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'message': 'Invalid or missing Authorization header'},
                                    status=status.HTTP_401_UNAUTHORIZED)
            try:
                payload = jwt.decode(token, 'SECRET_KEY', algorithms=['HS256'])
            except jwt.ExpiredSignatureError:
                raise AuthenticationFailed('Unauthenticated')
            user = Credentials.objects.get(username=payload['username'], email=payload['email'])
            file = DataFile.objects.get(file_serial=serial)
            if not user:
                return JsonResponse({'message': 'User does not exist'},
                                    status=status.HTTP_404_NOT_FOUND)
            current_graph = GraphModel.objects.get(username=user,
                                                   file_name=file,
                                                   image_number=image_number)
            if not current_graph:
                return JsonResponse({'message': 'Graph does not exist'},
                                    status=status.HTTP_404_NOT_FOUND)
            file = f'Data/{serial}.csv'
            data = pd.read_csv(file)
            columns = data.columns.tolist()
            current_graphs = ['Pie Graph', 'Bar Graph', 'Line Graph',
                              'Scatter Graph', 'Histogram', 'Boxplot',
                              'Heat Map', 'Bubble Graph', 'Area Graph', 'Donut Graph']
            legend_positions = ['best', 'upper right', 'upper left', 'lower left', 'lower right',
                                'right', 'center left', 'center right',
                                'lower center', 'upper center', 'center']
            data_cleaning = ['Drop Null Values', 'Median Fill', 'Mean Fill']
            return JsonResponse({'columns': columns,
                                 'graphs': current_graphs,
                                 'legend': legend_positions,
                                 'data': data_cleaning},
                                status=status.HTTP_200_OK)
    except Exception as e:
        logging.error(f"Error during pie graph column selection: {str(e)}")
        return JsonResponse({'message': 'Internal server error'},
                            status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['PATCH'])
def recieve_settings_data(request, serial, image_number):
    try:
        if request.method == 'PATCH':
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'message': 'Invalid or missing Authorization header'},
                                    status=status.HTTP_401_UNAUTHORIZED)
            try:
                payload = jwt.decode(token, 'SECRET_KEY', algorithms=['HS256'])
            except jwt.ExpiredSignatureError:
                raise AuthenticationFailed('Unauthenticated')
            user = Credentials.objects.get(username=payload['username'], email=payload['email'])
            if not user:
                return JsonResponse({'message': 'User does not exist'},
                                    status=status.HTTP_404_NOT_FOUND)
            file = DataFile.objects.get(file_serial=serial, uploaded_by=user)
            if not file:
                return JsonResponse({'message': 'File does not exist'},
                                    status=status.HTTP_404_NOT_FOUND)
            current_graph = GraphModel.objects.get(username=user,
                                                   file_name=file,
                                                   image_number=image_number)
            if not current_graph:
                return JsonResponse({'message': 'Graph does not exist'},
                                    status=status.HTTP_404_NOT_FOUND)
            current_graph.x_column = request.data['x_column']
            current_graph.y_column = request.data['y_column']
            current_graph.graph_title = request.data['graph_title']
            current_graph.graph_x_label = request.data['graph_x_label']
            current_graph.graph_y_label = request.data['graph_y_label']
            current_graph.x_axis_tilt = request.data['x_axis_tilt']
            current_graph.y_axis_tilt = request.data['y_axis_tilt']
            current_graph.legend = request.data['show_legend']
            current_graph.legend_position = request.data['legend_position']
            current_graph.grid_lines = request.data['show_gridlines']
            # not yet implemented
            #current_graph.trendline = 'empty'
            # not yet implemented
            #current_graph.line_of_best_fit = 'empty'
            # not yet implemented
            #current_graph.r_squared = 'empty'
            current_graph.data_report = request.data['show_data_report']
            # not yet implemented
            #current_graph.data_depth = 'empty'
            current_graph.data_cleaning_method = request.data['data_cleaning_method']
            current_graph.save()
            graph_gen = GraphGenerator(
                filename=f'{serial}.csv',
                x_column=request.data['x_column'],
                y_column=request.data['y_column'],
                graph_title=request.data['graph_title'],
                serial=serial,
                image_number=image_number,
                legend=request.data['show_legend'],
                legend_position=request.data['legend_position'],
                data_cleaning_method=request.data['data_cleaning_method'],
                x_label=request.data['graph_x_label'],
                y_label=request.data['graph_y_label'],
            )  
            graph_gen.create_graph(graph_type=request.data['graph_type'],
                                   data_report=request.data['show_data_report'])
            return JsonResponse({'message': 'Graph settings updated successfully'},
                                status=status.HTTP_200_OK)
    except Exception as e:
        logging.error(f"Error during graph settings update: {str(e)}")
        return JsonResponse({'message': 'Internal server error'},
                            status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
def send_graph(request, serial, image_number):
    try:
        if request.method == 'GET':
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'message': 'Invalid or missing Authorization header'},
                                    status=status.HTTP_401_UNAUTHORIZED)
            try:
                payload = jwt.decode(token, 'SECRET_KEY', algorithms=['HS256'])
            except jwt.ExpiredSignatureError:
                raise AuthenticationFailed('Unauthenticated')
            user = Credentials.objects.get(username=payload['username'], email=payload['email'])
            if not user:
                return JsonResponse({'message': 'User does not exist'},
                                    status=status.HTTP_404_NOT_FOUND)
            file = DataFile.objects.get(file_serial=serial, uploaded_by=user)
            current_graph = GraphModel.objects.get(username=user,
                                                   file_name=file,
                                                   image_number=image_number)
            if not current_graph:
                return JsonResponse({'message': 'Graph does not exist'},
                                    status=status.HTTP_404_NOT_FOUND)
            image_path = f'Images/{serial}_{image_number}.png'
            with open(image_path, 'rb') as image_file:
                image_data = base64.b64encode(image_file.read()).decode('ascii')
            report_data = None
            if current_graph.data_report:
                report_path = f'Reports/{serial}_{image_number}_report.txt'
                with open(report_path, 'rb') as report_file:
                    report_data = base64.b64encode(report_file.read()).decode('ascii')
            response_data = {'message': 'Graph retrieved successfully',
                             'image': image_data}
            if report_data:
                response_data['report'] = report_data
            return JsonResponse(response_data, status=status.HTTP_200_OK)
    except Exception as e:
        logging.error(f"Error during graph retrieval: {str(e)}")
        return JsonResponse({'message': 'Internal server error'},
                            status=status.HTTP_500_INTERNAL_SERVER_ERROR)
