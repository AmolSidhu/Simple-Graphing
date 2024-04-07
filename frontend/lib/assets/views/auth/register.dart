import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/assets/static/static.dart';
import 'package:frontend/assets/views/auth/login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  late String _username, _email, _password;

  Future<void> _register() async {
    var url = Uri.parse('${server}v1/register/');
    var response = await http.post(url, body: {
      'username': _username,
      'email': _email,
      'password': _password,
    });

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(labelText: 'Username'),
            onSaved: (value) => _username = value!,
            validator: (value) =>
                value!.isEmpty ? 'Username is required' : null,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Email'),
            onSaved: (value) => _email = value!,
            validator: (value) => value!.isEmpty ? 'Email is required' : null,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            onSaved: (value) => _password = value!,
            validator: (value) =>
                value!.isEmpty ? 'Password is required' : null,
          ),
          ElevatedButton(
            child: const Text('Register'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                _register();
              }
            },
          ),
        ],
      ),
    );
  }
}
