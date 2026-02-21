import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: Center(
        child: Text(
          'Welcome to EasyFlow!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}