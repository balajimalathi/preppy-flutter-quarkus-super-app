import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Column(
        children: [
          Center(child: Text('Dashboard scaffold')),
          ElevatedButton(
            onPressed: () {
              context.go('/status');
            },
            child: Text('Status'),
          ),
        ],
      ),
    );
  }
}
