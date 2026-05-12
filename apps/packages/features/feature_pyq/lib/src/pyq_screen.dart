import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class PyqScreen extends StatelessWidget {
  const PyqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PreppyScaffold(
      title: 'PYQ',
      body: Center(child: Text('PYQ scaffold')),
    );
  }
}
