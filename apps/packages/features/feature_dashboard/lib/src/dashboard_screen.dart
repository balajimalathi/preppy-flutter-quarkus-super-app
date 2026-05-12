import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PreppyScaffold(
      title: 'Dashboard',
      body: Center(child: Text('Dashboard scaffold')),
    );
  }
}
