import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PreppyScaffold(
      title: 'Practice',
      body: Center(child: Text('Practice scaffold')),
    );
  }
}
