import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/task_model.dart';

class CreateTaskPage extends StatefulWidget {
  final List<TaskModel> tasks;

  const CreateTaskPage({super.key, required this.tasks});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final titleController = TextEditingController();
  final childUidController = TextEditingController();

  bool _loading = false;

  // ✅ CHANGE THIS to your real endpoint if needed
  final String backendUrl =
      'https://jamie-subsatirical-abbreviatedly.ngrok-free.dev/tasks/';

  Future<void> _submitTask() async {
    final title = titleController.text.trim();
    final childUid = childUidController.text.trim();

    if (title.isEmpty || childUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // 🔐 1. Get Firebase token
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      if (idToken == null) {
        throw Exception("User not authenticated");
      }

      // 🌐 2. Send to backend
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          "Authorization": "Bearer $idToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "title": title,
          "childUid": childUid,
        }),
      );

      if (!mounted) return;

      // 🚨 Protect against HTML response (your old bug)
      if (!(response.headers['content-type'] ?? '')
          .contains('application/json')) {
        throw Exception(
            "Backend returned HTML instead of JSON.\nStatus: ${response.statusCode}");
      }

      final result = jsonDecode(response.body);

      // ✅ Success
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          widget.tasks.add(
            TaskModel(
              title: title,
              childUid: childUid,
            ),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created!')),
        );

        titleController.clear();
        childUidController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to create task')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Create task error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    childUidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            const SizedBox(height: 20),

            // 🔥 BUTTON WITH LOADER
            SizedBox(
              width: double.infinity,
              height: 48,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitTask,
                      child: const Text('Submit Task'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}