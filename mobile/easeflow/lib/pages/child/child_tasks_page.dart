// pages/child_tasks_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


import '../../models/task_model.dart';
import '../../widgets/child_scaffold.dart';

class ChildTasksPage extends StatefulWidget {
  const ChildTasksPage({super.key});

  @override
  State<ChildTasksPage> createState() => _ChildTasksPageState();
}

class _ChildTasksPageState extends State<ChildTasksPage> {
  bool _loading = true;
  List<TaskModel> _tasks = [];
  // track which items are expanded
  final Set<int> _expanded = {};

  final String baseUrl=
      'https://jamie-subsatirical-abbreviatedly.ngrok-free.dev/tasks';

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
        final childUid = user.uid; // <-- define childUid here

        final response = await http.get(
          Uri.parse('$baseUrl/child/$childUid'), // <-- use childUid
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
    return ChildScaffold(
      title: 'Your Tasks',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.task_alt, size: 80, color: Colors.white70),
                      SizedBox(height: 12),
                      Text(
                        'No tasks yet',
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  itemCount: _tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, index) {
                    final task = _tasks[index];

                    final bgGradient = task.completed
                        ? const LinearGradient(
                            colors: [Color(0xFFB7EFC5), Color(0xFF8EE5A1)])
                        : const LinearGradient(
                            colors: [Color(0xFFFAF3C2), Color(0xFFF9D976)]);

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // toggle completed locally for quick feedback
                            setState(() {
                              _tasks[index].completed = !_tasks[index].completed;
                            });
                          },
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: bgGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // icon column (no expand here)
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 6,
                                          offset: const Offset(0, 4),
                                        )
                                      ],
                                    ),
                                    child: Icon(
                                      task.completed ? Icons.check : Icons.assignment_turned_in,
                                      size: 36,
                                      color: task.completed ? Colors.green : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 18),

                                  // Large title + small subtitle
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          task.completed
                                              ? 'Completed'
                                              : 'Tap to mark complete',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // trailing big status icon + expand button below it
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                                          color: task.completed ? Colors.green : Colors.grey,
                                          size: 38,
                                        ),
                                        const SizedBox(height: 6),
                                        // expand / collapse button placed under status icon
                                        IconButton(
                                          icon: Icon(
                                            _expanded.contains(index) ? Icons.expand_less : Icons.expand_more,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (_expanded.contains(index)) {
                                                _expanded.remove(index);
                                              } else {
                                                _expanded.add(index);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Animated description area
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: _expanded.contains(index)
                              ? Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const SizedBox(
                                    height: 72,
                                    child: Text(
                                      '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}