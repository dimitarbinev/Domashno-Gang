import 'package:flutter/material.dart';

class PersonInfoPage extends StatelessWidget {
  const PersonInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Person Info')),
      body: const Center(child: Text('Person information page')),
    );
  }
}