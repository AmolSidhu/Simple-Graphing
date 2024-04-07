import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/assets/static/static.dart';
import 'package:frontend/assets/views/tabbar_functions/graph_output.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsState {}

class _SettingsPageState extends State<Settings> {
  final _formKey = GlobalKey<FormState>();

  final _storage = const FlutterSecureStorage();
  String _selectedXColumn = '';
  String _selectedYColumn = '';
  String? _graphTitle = '';
  String? _graphXLabel = '';
  String? _graphYLabel = '';
  String? _selectedGraphType = '';
  int? _xAxisTilt = 0;
  int? _yAxisTilt = 0;
  bool _showLegend = false;
  String _selectedLegendPosition = '';
  bool _showGridlines = false;
  bool _showDataReport = false;
  String _selectedDataCleaningMethod = '';
  String token = '';
  String serial = '';
  String lastImage = '';

  List<String> _columns = [];
  List<String> _graphs = [];
  List<String> _legendPositions = [];
  List<String> _dataCleaningMethods = [];

  Future<void> _fetchSettingsData() async {
    token = (await _storage.read(key: 'token')) ?? '';
    serial = (await _storage.read(key: 'serial')) ?? '';
    lastImage = (await _storage.read(key: 'image_number')) ?? '';
    final response = await http.get(
      Uri.parse('${server}v1/send_settings_data/$serial/$lastImage/'),
      headers: {
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _columns = List<String>.from(jsonData['columns']).toSet().toList();
        _graphs = List<String>.from(jsonData['graphs']).toSet().toList();
        _legendPositions =
            List<String>.from(jsonData['legend']).toSet().toList();
        _dataCleaningMethods =
            List<String>.from(jsonData['data']).toSet().toList();

        if (_columns.isNotEmpty) {
          _selectedXColumn = _columns[0];
          _selectedYColumn = _columns[1];
        }
      });
    } else {
      throw Exception('Failed to load settings data');
    }
    if (_graphs.isNotEmpty) {
      _selectedGraphType = _graphs[0];
    } else {
      throw Exception('Failed to load graph types');
    }
    if (_legendPositions.isNotEmpty) {
      _selectedLegendPosition = _legendPositions[0];
    } else {
      throw Exception('Failed to load legend positions');
    }
    if (_dataCleaningMethods.isNotEmpty) {
      _selectedDataCleaningMethod = _dataCleaningMethods[0];
    } else {
      throw Exception('Failed to load data cleaning methods');
    }
  }

  Future<void> _sendSettingsData() async {
    final Map<String, dynamic> requestData = {
      'serial': serial,
      'x_column': _selectedXColumn,
      'y_column': _selectedYColumn,
      'graph_title': _graphTitle,
      'graph_x_label': _graphXLabel,
      'graph_y_label': _graphYLabel,
      'graph_type': _selectedGraphType,
      'x_axis_tilt': _xAxisTilt,
      'y_axis_tilt': _yAxisTilt,
      'show_legend': _showLegend,
      'legend_position': _selectedLegendPosition,
      'show_gridlines': _showGridlines,
      'show_data_report': _showDataReport,
      'data_cleaning_method': _selectedDataCleaningMethod,
    };

    final response = await http.patch(
      Uri.parse('${server}v1/recieve_settings_data/$serial/$lastImage/'),
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      print('Settings data sent successfully');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const GraphOutput(),
        ),
      );
    } else {
      print('Failed to send settings data');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSettingsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedXColumn,
                  items: _columns.map((String column) {
                    return DropdownMenuItem<String>(
                      value: column,
                      child: Text(column),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedXColumn = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'X Column'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an X Column';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedYColumn,
                  items: _columns.map((String column) {
                    return DropdownMenuItem<String>(
                      value: column,
                      child: Text(column),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYColumn = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Y Column'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a Y Column';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Graph Title'),
                  onChanged: (value) {
                    setState(() {
                      _graphTitle = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Graph Title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Graph X Label'),
                  onChanged: (value) {
                    setState(() {
                      _graphXLabel = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Graph X Label';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Graph Y Label'),
                  onChanged: (value) {
                    setState(() {
                      _graphYLabel = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Graph Y Label';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedGraphType,
                  items: _graphs.map((String graph) {
                    return DropdownMenuItem<String>(
                      value: graph,
                      child: Text(graph),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      if (_graphs.contains(value)) {
                        _selectedGraphType = value!;
                      } else {
                        print(
                            'Error: Selected Graph Type does not exist in the list');
                      }
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Graph Type'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a Graph Type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'X Axis Tilt (°)',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _xAxisTilt = int.tryParse(value) ?? 0;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter X Axis Tilt';
                          }
                          final tilt = int.tryParse(value);
                          if (tilt == null || tilt < -90 || tilt > 90) {
                            return 'Please enter a valid value between -90 and 90';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Y Axis Tilt (°)',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _yAxisTilt = int.tryParse(value) ?? 0;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Y Axis Tilt';
                          }
                          final tilt = int.tryParse(value);
                          if (tilt == null || tilt < -90 || tilt > 90) {
                            return 'Please enter a valid value between -90 and 90';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Show Legend'),
                    Switch(
                      value: _showLegend,
                      onChanged: (value) {
                        setState(() {
                          _showLegend = value;
                        });
                      },
                    ),
                  ],
                ),
                if (_showLegend)
                  DropdownButtonFormField<String>(
                    value: _selectedLegendPosition,
                    items: _legendPositions.map((String position) {
                      return DropdownMenuItem<String>(
                        value: position,
                        child: Text(position),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLegendPosition = value!;
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: 'Legend Position'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a Legend Position';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Show Gridlines'),
                    Switch(
                      value: _showGridlines,
                      onChanged: (value) {
                        setState(() {
                          _showGridlines = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Show Data Report'),
                    Switch(
                      value: _showDataReport,
                      onChanged: (value) {
                        setState(() {
                          _showDataReport = value;
                        });
                      },
                    ),
                  ],
                ),
                if (_showDataReport)
                  DropdownButtonFormField<String>(
                    value: _selectedDataCleaningMethod,
                    items: _dataCleaningMethods.map((String method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDataCleaningMethod = value!;
                      });
                    },
                    decoration: const InputDecoration(
                        labelText: 'Data Cleaning Method'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a Data Cleaning Method';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sendSettingsData,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
