import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class SyllabusScreen extends StatelessWidget {
  const SyllabusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PreppyScaffold(
      title: 'Syllabus',
      body: Center(child: Text('Syllabus scaffold')),
    );
  }
}
