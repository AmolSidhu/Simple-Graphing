import 'dart:convert';
import 'dart:typed_data';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/assets/static/static.dart';

class Output extends StatefulWidget {
  const Output({Key? key}) : super(key: key);

  @override
  _OutputState createState() => _OutputState();
}

class _OutputState extends State<Output> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Uint8List? imageData;
  String? reportData;

  @override
  void initState() {
    super.initState();
    fetchGraph();
  }

  Future<void> fetchGraph() async {
    try {
      final token = await _storage.read(key: 'token');
      final serial = await _storage.read(key: 'serial');
      final imageNumberString = await _storage.read(key: 'image_number');
      final imageNumber = int.parse(imageNumberString ?? '');

      final response = await http.get(
        Uri.parse('${server}v1/send_graph/$serial/$imageNumber/'),
        headers: {
          'Authorization': token!,
        },
      );

      if (response.statusCode == 200) {
        final String? contentType = response.headers['content-type'];
        if (contentType != null) {
          if (contentType.contains('image')) {
            setState(() {
              imageData = response.bodyBytes;
            });
          } else if (contentType.contains('text')) {
            setState(() {
              reportData = response.body;
            });
          } else if (contentType.contains('application/json')) {
            final responseData = json.decode(response.body);
            if (responseData['message'] == 'Graph retrieved successfully') {
              final imageBytes = base64.decode(responseData['image']);
              setState(() {
                imageData = imageBytes;
                if (responseData.containsKey('report')) {
                  reportData = responseData['report'];
                }
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to retrieve graph'),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to retrieve graph'),
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to retrieve graph: ${response.reasonPhrase}'),
          ),
        );
      }
    } catch (e) {}
  }

  void downloadReport() {
    final bytes = base64.decode(reportData!);
    final blob = Blob([bytes]);
    final url = Url.createObjectUrlFromBlob(blob);
    AnchorElement(href: url)
      ..setAttribute("download", "report.txt")
      ..click();
    Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graph Output'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imageData != null)
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: Image.memory(
                    imageData!,
                    fit: BoxFit.contain,
                  ),
                ),
              const SizedBox(height: 20),
              if (reportData != null)
                ElevatedButton(
                  onPressed: downloadReport,
                  child: const Text('Download Report'),
                ),
              if (reportData == null && imageData == null)
                const Text('No data available'),
            ],
          ),
        ),
      ),
    );
  }
}
