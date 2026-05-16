import 'package:auth/feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard'), actions: [
        
      ],),
      body: Column(
        children: [
          Center(child: Text('Dashboard scaffold')),
          LogoutButton(
            label: 'Sign out',
            style: LogoutButtonStyle.text,
            onSignedOut: () {
              context.go('/login');
            },
          ),
          ElevatedButton(
            onPressed: () {
              context.push('/status');
            },
            child: Text('Status'),
          ),
        ],
      ),
    );
  }
}
