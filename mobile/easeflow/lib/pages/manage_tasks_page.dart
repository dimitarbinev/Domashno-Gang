import 'package:flutter/material.dart';


class ManageTasksPage extends StatelessWidget {
  const ManageTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Tasks')),
      body: const Center(child: Text('Manage your tasks here')),
    );
  }
}