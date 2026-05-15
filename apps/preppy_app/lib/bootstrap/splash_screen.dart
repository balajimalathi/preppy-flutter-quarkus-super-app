import 'package:flutter/material.dart';

/// Shown while [authProvider] hydrates; [GoRouter] redirect moves the user on.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
