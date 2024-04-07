import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/assets/static/main_tabbar.dart';
import 'package:frontend/assets/static/login_tabbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const secureStorage = FlutterSecureStorage();

  final token = await secureStorage.read(key: 'token');

  runApp(MaterialApp(
    home: token != null ? const MainTabBar() : const NotLogged(),
  ));
}
