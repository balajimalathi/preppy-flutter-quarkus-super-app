import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class IngestionScreen extends StatelessWidget {
  const IngestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PreppyScaffold(
      title: 'Uploads',
      body: Center(child: Text('Ingestion scaffold')),
    );
  }
}
