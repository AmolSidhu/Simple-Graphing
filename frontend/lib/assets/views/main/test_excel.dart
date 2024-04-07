import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class TestExcel extends StatefulWidget {
  const TestExcel({Key? key}) : super(key: key);

  @override
  _ExcelTestUploadState createState() => _ExcelTestUploadState();
}

class _ExcelTestUploadState extends State<TestExcel> {
  final _formKey = GlobalKey<FormState>();
  Uint8List? _selectedFile;
  String? _selectedFileName;
  late String _username = '';
  late String _email = '';
  String _statusMessage = '';

  void _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedFile = result.files.single.bytes;
        _selectedFileName = result.files.single.name;
      });
    } else {
      print('No file selected or file path is null');
    }
  }

  void _uploadFile() async {
    if (_selectedFile != null && _selectedFileName != null) {
      if (_formKey.currentState?.validate() ?? false) {
        _formKey.currentState?.save();

        var url = Uri.parse('http://127.0.0.1:8000/upload_test/');
        var request = http.MultipartRequest('POST', url);
        request.files.add(http.MultipartFile.fromBytes(
            'excelFile', _selectedFile!,
            filename: _selectedFileName));

        request.fields['username'] = _username;
        request.fields['email'] = _email;

        var response = await request.send();
        if (response.statusCode == 200) {
          setState(() {
            _statusMessage = 'Upload successful';
          });
          print('File uploaded successfully');
        } else {
          setState(() {
            _statusMessage = 'Error uploading file: ${response.reasonPhrase}';
          });
          print('Error uploading file: ${response.reasonPhrase}');
        }
      }
    } else {
      print('No file selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel Upload'),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.startsWith('Upload successful')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _username = value!;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value!;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _selectFile,
                        child: const Text('Select Excel File'),
                      ),
                      const SizedBox(height: 20),
                      if (_selectedFile != null)
                        Text('Selected File: ${_selectedFileName}'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _uploadFile,
                        child: const Text('Upload File'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
