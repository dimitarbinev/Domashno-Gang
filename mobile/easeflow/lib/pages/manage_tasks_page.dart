import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/task_model.dart';

class ManageTasksPage extends StatefulWidget {
  const ManageTasksPage({super.key});

  @override
  State<ManageTasksPage> createState() => _ManageTasksPageState();
}

class _ManageTasksPageState extends State<ManageTasksPage> {
  List<TaskModel> _tasks = [];
  bool _loading = true;

  // 🔥 Your backend endpoints
  final String backendGetTasks =
      'https://jamie-subsatirical-abbreviatedly.ngrok-free.dev/tasks/get_tasks';
  final String backendCreateTask =
      'https://jamie-subsatirical-abbreviatedly.ngrok-free.dev/tasks/create_task';

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

Future<String> _getIdToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("User not logged in");

  final idToken = await user.getIdToken();
  if (idToken == null) throw Exception("Failed to get Firebase ID token");

  return idToken; // ✅ guaranteed non-null
}

  Future<void> _fetchTasks() async {
    setState(() => _loading = true);
    try {
      final idToken = await _getIdToken();

      final response = await http.get(
        Uri.parse(backendGetTasks),
        headers: {
          "Authorization": "Bearer $idToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Backend error ${response.statusCode}: ${response.body}");
      }

      final dynamic data = jsonDecode(response.body);
      List<TaskModel> loadedTasks = [];

      if (data is List) {
        loadedTasks = data
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['tasks'] is List) {
        loadedTasks = (data['tasks'] as List)
            .map((e) => TaskModel.fromJson(e))
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to load tasks: $e')));
      }
    }
  }

  Future<void> _createTask(String title, String childUid) async {
    if (title.trim().isEmpty || childUid.trim().isEmpty) return;

    try {
      final idToken = await _getIdToken();

      final response = await http.post(
        Uri.parse(backendCreateTask),
        headers: {
          "Authorization": "Bearer $idToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'title': title.trim(),
          'childUid': childUid.trim(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to create task: ${response.body}");
      }

      final taskJson = jsonDecode(response.body);
      final newTask = TaskModel.fromJson(taskJson);

      setState(() => _tasks.add(newTask));
    } catch (e) {
      debugPrint('Create task error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to create task: $e')));
      }
    }
  }

  Future<void> _showCreateTaskDialog() async {
    final titleController = TextEditingController();
    final childUidController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: childUidController,
              decoration: const InputDecoration(labelText: 'Child ID'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _createTask(titleController.text, childUidController.text);
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Tasks')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTaskDialog,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text('No tasks yet'))
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (_, index) {
                    final task = _tasks[index];
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(task.title),
                        subtitle: Text('Child: ${task.childUid ?? ""}'),
                        trailing: Checkbox(
                          value: task.completed,
                          onChanged: (val) {
                            setState(() {
                              task.completed = val ?? false;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}