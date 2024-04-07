import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:frontend/assets/views/main/settings.dart';

import 'package:frontend/assets/static/static.dart';

class ExcelUpload extends StatefulWidget {
  const ExcelUpload({Key? key}) : super(key: key);

  @override
  _ExcelUploadState createState() => _ExcelUploadState();
}

class _ExcelUploadState extends State<ExcelUpload> {
  final _formKey = GlobalKey<FormState>();
  Uint8List? _selectedFile;
  String? _selectedFileName;
  late String _fileName = '';
  String _statusMessage = '';
  late String token;
  late String selectedCleaningMethod = 'Drop Null Value';

  final storage = const FlutterSecureStorage();

  void _selectFile() async {
    try {
      token = (await storage.read(key: 'token'))!;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _selectedFile = result.files.single.bytes;
          _selectedFileName = result.files.single.name;
        });
      } else {
        if (kDebugMode) {
          print('No file selected');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error selecting file: $e');
      }
    }
  }

  Future<void> _uploadFile(BuildContext context) async {
    if (_selectedFile != null && _selectedFileName != null) {
      if (_formKey.currentState?.validate() ?? false) {
        _formKey.currentState?.save();

        final url = Uri.parse('${server}v1/upload/');
        final request = http.MultipartRequest('POST', url);

        request.headers['Content-Type'] = 'application/json';
        request.headers['Authorization'] = token;

        request.files.add(http.MultipartFile.fromBytes(
          'excelFile',
          _selectedFile!,
          filename: _selectedFileName,
        ));

        request.fields['file_name'] = _fileName;
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          final String serialToken = responseData['serial'];
          final String imageNumberToken = responseData['image_number'];

          await storage.write(key: 'serial', value: serialToken);
          await storage.write(key: 'image_number', value: imageNumberToken);

          setState(() {
            _statusMessage = 'Upload successful';
          });
          if (kDebugMode) {
            print('File uploaded successfully');
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Settings(),
            ),
          );
        } else {
          setState(() {
            _statusMessage = 'Error uploading file: ${response.reasonPhrase}';
          });
          if (kDebugMode) {
            print('Error uploading file: ${response.reasonPhrase}');
          }
        }
      }
    } else {
      if (kDebugMode) {
        print('No file selected');
      }
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
                          labelText: 'Project Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _fileName = value!;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _selectFile(),
                        child: const Text('Select CSV File'),
                      ),
                      const SizedBox(height: 20),
                      if (_selectedFile != null)
                        Text('Selected File: $_selectedFileName'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _uploadFile(context),
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
