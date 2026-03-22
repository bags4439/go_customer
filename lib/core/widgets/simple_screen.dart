import 'package:flutter/material.dart';

class SimpleScreen extends StatelessWidget {
  final String title;
  final Widget? body;

  const SimpleScreen({super.key, required this.title, this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body ?? Center(child: Text(title)),
    );
  }
}

