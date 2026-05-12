import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PreppyScaffold(
      title: 'Sign in',
      body: Center(child: Text('Login screen scaffold')),
    );
  }
}
