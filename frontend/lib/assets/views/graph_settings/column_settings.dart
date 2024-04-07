import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/assets/static/static.dart';

class ColumnForm extends StatefulWidget {
  const ColumnForm({Key? key}) : super(key: key);

  @override
  _ColumnFormState createState() => _ColumnFormState();
}

class _ColumnFormState extends State<ColumnForm> {
  final storage = const FlutterSecureStorage();
  List<String> columns = [];
  String? selectedXColumn;
  String? selectedYColumn;
  String useXColumnForPlot = 'Yes';
  String xColumnDataType = '';
  String token = '';
  String serial = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      token = (await storage.read(key: 'token'))!;
      print('*********************************************');
      print('Token: $token');
      serial = (await storage.read(key: 'serial'))!;

      final response = await http.get(
        Uri.parse('${server}v1/send_columns/$serial/'),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          columns = json.decode(response.body)['columns'].cast<String>();
          if (selectedXColumn == null && columns.isNotEmpty) {
            selectedXColumn = columns[0];
          }
          if (selectedYColumn == null && columns.length > 1) {
            selectedYColumn = columns[1];
          }
        });
      } else {
        throw Exception('Failed to load columns');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> sendData() async {
    final Map<String, dynamic> requestData = {
      'serial': serial,
      'x_column': selectedXColumn,
      'y_column': selectedYColumn,
      'use_x_column_for_plot': useXColumnForPlot,
      'x_column_data_type': xColumnDataType,
      'graph_type': 'your_graph_type_here',
    };

    final response = await http.post(
      Uri.parse('${server}v1/recieve_columns/$serial/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['message'] == 'Graph data saved successfully') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Graph data saved successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save graph data'),
          ),
        );
      }
    } else {
      throw Exception('Failed to save graph data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Column Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDropdown(
              label: 'Select X Column',
              value: selectedXColumn,
              items: columns,
              onChanged: (value) {
                setState(() {
                  selectedXColumn = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            _buildDropdown(
              label: 'Select Y Column',
              value: selectedYColumn,
              items: columns,
              onChanged: (value) {
                setState(() {
                  selectedYColumn = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('Use X Column for Plot:'),
                  const SizedBox(width: 8.0),
                  DropdownButton(
                    value: useXColumnForPlot,
                    items: ['Yes', 'No'].map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        useXColumnForPlot = value as String;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'X Column Data Type'),
              onChanged: (value) {
                setState(() {
                  xColumnDataType = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: sendData,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        DropdownButtonFormField(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
