import pandas as pd
import matplotlib
matplotlib.use('Agg')
from matplotlib import pyplot as plt
import seaborn as sns
import plotly.express as px

class GraphGenerator:
    def __init__(self, filename='', 
                 file_save_location='Data/', x_column='',
                 graph_title='', y_column='', serial='',
                 x_label='', y_label='',
                 image_number='', legend=False, legend_position='best',
                 image_save_location='Images/',
                 report_save_location='Reports/',
                 data_cleaning_method='Drop Null Values'):
        self.filename = filename
        self.file_save_location = file_save_location
        self.x_column = x_column
        self.graph_title = graph_title
        self.y_column = y_column
        self.x_label = x_label
        self.y_label = y_label
        self.serial = serial
        self.image_number = image_number
        self.legend = legend
        self.legend_position = legend_position
        self.image_save_location = image_save_location
        self.data_cleaning_method = data_cleaning_method
        self.report_save_location = report_save_location


    def _clean_data(self, data):
        if self.data_cleaning_method == 'Drop Null Values':
            data = data.dropna()
        elif self.data_cleaning_method == 'Median Fill':
            data = data.fillna(data.median())
        elif self.data_cleaning_method == 'Mean Fill':
            data = data.fillna(data.mean())
        return data

    def _save_image(self, plt_instance):
        plt_instance.savefig(f'{self.image_save_location}{self.serial}_{self.image_number}.png')
        plt_instance.close()
        
    def _create_report(self, data, data_report):
        if data_report == True:
            report = data.describe()
            report.to_csv(f'{self.report_save_location}{self.serial}_{self.image_number}_report.txt', sep='\t')
            
    def _create_dataframe(self):
        file_location = self.file_save_location + self.filename
        columns = [self.y_column, self.x_column]
        data = pd.read_csv(file_location, usecols=columns, encoding='utf-8')
        return data
        
    def _pie_graph(self, data):
        fig, ax = plt.subplots()
        ax.pie(data[self.y_column], labels=data[self.x_column],
            autopct='%1.1f%%',
            shadow=True, startangle=90,
            wedgeprops={"edgecolor": "black",
                        'linewidth': 2,
                        'antialiased': True})
        ax.axis('equal')
        return fig
    
    def _bar_graph(self, data):
        fig, ax = plt.subplots()
        ax.bar(data[self.x_column], data[self.y_column])
        return fig

    def _line_graph(self, data):
        fig, ax = plt.subplots()
        ax.plot(data[self.x_column], data[self.y_column])
        return fig
    
    def _scatter_graph(self, data):
        fig, ax = plt.subplots()
        ax.scatter(data[self.x_column], data[self.y_column])
        return fig
    
    def _histogram_graph(self, data):
        fig, ax = plt.subplots()
        ax.hist(data[self.y_column])
        return fig
    
    def _boxplot_graph(self, data):
        fig, ax = plt.subplots()
        ax.boxplot(data[self.y_column])
        return fig
    
    def _heatmap_graph(self, data):
        fig, ax = plt.subplots()
        sns.heatmap(data)
        return fig
    
    def _bubble_graph(self, data):
        fig = px.scatter(data, x=self.x_column, y=self.y_column, size=self.y_column)
        return fig
    
    def _area_graph(self, data):
        fig, ax = plt.subplots()
        ax.fill_between(data[self.x_column], data[self.y_column])
        return fig
    
    def _donut_graph(self, data):
        fig, ax = plt.subplots()
        ax.pie(data[self.y_column], labels=data[self.x_column],
            autopct='%1.1f%%',
            shadow=True, startangle=90,
            wedgeprops={"edgecolor": "black",
                        'linewidth': 2,
                        'antialiased': True})
        ax.axis('equal')
        inner_circle = plt.Circle((0, 0), 0.6, color='white')
        ax.add_artist(inner_circle)
        return fig
    
    def create_graph(self, graph_type, data_report=False):
        data = self._create_dataframe()
        data = self._clean_data(data)
        
        fig = None
        if graph_type == 'Pie Graph':
            fig = self._pie_graph(data)
        elif graph_type == 'Bar Graph':
            fig = self._bar_graph(data)
        elif graph_type == 'Line Graph':
            fig = self._line_graph(data)
        elif graph_type == 'Scatter Graph':
            fig = self._scatter_graph(data)
        elif graph_type == 'Histogram':
            fig = self._histogram_graph(data)
        elif graph_type == 'Boxplot':
            fig = self._boxplot_graph(data)
        elif graph_type == 'Heatmap':
            fig = self._heatmap_graph(data)
        elif graph_type == 'Bubble Graph':
            fig = self._bubble_graph(data)
        elif graph_type == 'Area Graph':
            fig = self._area_graph(data)
        elif graph_type == 'Donut Graph':
            fig = self._donut_graph(data)
        
        if isinstance(fig, plt.Figure):
            plt.title(self.graph_title)
            plt.xlabel(self.x_label)
            plt.ylabel(self.y_label)
            
            if self.legend:
                plt.legend(loc=self.legend_position)
            
            if self.image_save_location:
                plt.savefig(f'{self.image_save_location}{self.serial}_{self.image_number}.png')
            
            self._create_report(data, data_report)
                       
        plt.close()
        del data
