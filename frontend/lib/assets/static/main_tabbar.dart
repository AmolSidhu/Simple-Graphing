import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/assets/views/tabbar_functions/analysis.dart';
import 'package:frontend/assets/views/tabbar_functions/graph_settings.dart';
import 'package:frontend/assets/views/tabbar_functions/graph_output.dart';
import 'package:frontend/assets/static/login_tabbar.dart';
import 'package:frontend/assets/static/static.dart';

class MainTabBar extends StatefulWidget {
  const MainTabBar({super.key});

  @override
  State<MainTabBar> createState() => _TabBarState();
}

class _TabBarState extends State<MainTabBar> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');

    if (token == null) {
      print('Token not found in secure storage');
      return;
    }

    final url = Uri.parse('${server}v1/logout/');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      await storage.delete(key: 'token');
      print('Token deleted from secure storage');

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NotLogged()));
    } else {
      print('Logout failed with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test App'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.backup_table),
            ),
            Tab(
              icon: Icon(Icons.info),
            ),
            Tab(
              icon: Icon(Icons.vertical_align_bottom),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          Center(
            child: Analysis(),
          ),
          Center(
            child: GraphSettings(),
          ),
          Center(
            child: GraphOutput(),
          ),
        ],
      ),
    );
  }
}
