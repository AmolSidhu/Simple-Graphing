from django.db import models
from django.contrib.auth.models import AbstractUser

class Credentials(AbstractUser):
    email = models.EmailField(unique=True, max_length=100)
    username = models.CharField(max_length=100, unique=True)
    password = models.CharField(max_length=100)
    date_joined = models.DateTimeField(auto_now_add=True)
    last_updated = models.DateTimeField(auto_now=True)
    first_name = models.CharField(max_length=100, default='')
    last_name = models.CharField(max_length=100, default='')
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)
    
    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email', 'password']
    
    def __str__(self):
        return self.username
    
class DataFile(models.Model):
    file_serial = models.CharField(max_length=100, unique=True)
    initial_file_name = models.CharField(max_length=100)
    file_name = models.CharField(max_length=100, unique=True)
    uploaded_by = models.ForeignKey(Credentials, on_delete=models.CASCADE, to_field='username')
    uploaded_at = models.DateTimeField(auto_now_add=True)
    last_accessed = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return self.uploaded_by.username, self.file_name

class GraphModel(models.Model):
    username = models.ForeignKey(Credentials, on_delete=models.CASCADE, to_field='username')
    file_name = models.ForeignKey(DataFile, on_delete=models.CASCADE, to_field='file_name')
    image_number = models.IntegerField()
    x_column = models.CharField(max_length=100)
    use_x_column_for_plot = models.BooleanField(default=False)
    x_column_data_type = models.CharField(max_length=100)
    x_axis_tilt = models.CharField(max_length=100)
    y_column = models.CharField(max_length=100)
    y_axis_tilt = models.CharField(max_length=100)
    graph_type = models.CharField(max_length=100)
    graph_title = models.CharField(max_length=100)
    graph_x_label = models.CharField(max_length=100)
    graph_y_label = models.CharField(max_length=100)
    data_agg_column_1 = models.CharField(max_length=100)
    data_agg_column_2 = models.CharField(max_length=100)
    grid_lines = models.BooleanField(default=False)
    bins = models.IntegerField(default=1)
    trendline = models.BooleanField(default=False)
    legend = models.BooleanField(default=False)
    legend_position = models.CharField(max_length=100)
    line_of_best_fit = models.BooleanField(default=False)
    r_squared = models.BooleanField(default=False)
    data_report = models.BooleanField(default=False)
    data_depth = models.CharField(max_length=100)
    data_cleaning_method = models.CharField(max_length=100, default='Drop Null Values')
    