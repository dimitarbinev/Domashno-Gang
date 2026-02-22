// pages/child_tasks_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/task_model.dart';

class ChildTasksPage extends StatefulWidget {
  const ChildTasksPage({super.key});

  @override
  State<ChildTasksPage> createState() => _ChildTasksPageState();
}

class _ChildTasksPageState extends State<ChildTasksPage> {
  bool _loading = true;
  List<TaskModel> _tasks = [];

  final String backendUrl =
      'https://jamie-subsatirical-abbreviatedly.ngrok-free.dev/tasks/get_tasks';

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");
      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse(backendUrl),
        headers: {
          "Authorization": "Bearer $idToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            "Backend error (${response.statusCode}): ${response.body}");
      }

      final dynamic data = jsonDecode(response.body);

      List<TaskModel> loadedTasks = [];

      if (data is List) {
        loadedTasks = data
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['tasks'] is List) {
        loadedTasks = (data['tasks'] as List)
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      setState(() {
        _tasks = loadedTasks;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Fetch tasks error: $e');
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load tasks: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Tasks')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text('No tasks yet'))
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (_, index) {
                    final task = _tasks[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                          task.title,
                          style: const TextStyle(fontSize: 20),
                        ),
                        subtitle: Text(task.childUid ?? ''),
                        trailing: Icon(
                          task.completed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color:
                              task.completed ? Colors.green : Colors.grey,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}