import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';

class ChildHomePage extends StatelessWidget {
  const ChildHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: Center(
        child: Text(
          'Child Home Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}