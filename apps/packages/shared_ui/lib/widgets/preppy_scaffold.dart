import 'package:flutter/material.dart';

/// Lightweight wrapper around [Scaffold] so feature screens have a uniform
/// app bar without re-importing the same widgets everywhere.
class PreppyScaffold extends StatelessWidget {
  const PreppyScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(title: Text(title), actions: actions),
        body: body,
      ),
    );
  }
}
