import 'package:flutter/material.dart';

import 'package:frontend/assets/views/auth/login.dart';
import 'package:frontend/assets/views/auth/register.dart';

class NotLogged extends StatefulWidget {
  const NotLogged({super.key});

  @override
  State<NotLogged> createState() => _TabBarState();
}

class _TabBarState extends State<NotLogged> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.backup_table),
            ),
            Tab(
              icon: Icon(Icons.info),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          Center(
            child: Login(),
          ),
          Center(
            child: Register(),
          ),
        ],
      ),
    );
  }
}
