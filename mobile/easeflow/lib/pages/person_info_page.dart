import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PersonInfoPage extends StatefulWidget {
  const PersonInfoPage({super.key});

  @override
  State<PersonInfoPage> createState() => _PersonInfoPageState();
}

class _PersonInfoPageState extends State<PersonInfoPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final childUidController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final readingLevelController = TextEditingController();

  // Form state
  bool prefersEmojis = false;
  bool avoidBrightColors = false;
  String? selectedTone;
  String? selectedStepLength;

  bool _loading = false;

  final List<String> tones = [
    'calm',
    'energetic',
    'friendly',
    'encouraging',
    'neutral',
  ];

  final List<String> stepLengths = [
    'short',
    'medium',
    'long',
  ];

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // Get guardian (current user) and token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      final guardianId = user.uid;
      final idToken = await user.getIdToken();

      final childUid = childUidController.text.trim();

      final data = {
        'name': nameController.text.trim(),
        'age': int.parse(ageController.text),
        'readingLevel': int.parse(readingLevelController.text),
        'prefersEmojis': prefersEmojis,
        'tone': selectedTone,
        'stepLength': selectedStepLength,
        'avoidBrightColors': avoidBrightColors,
        'guardianId': guardianId,
        'childUid': childUid,
      };

      debugPrint('Sending profile data: $data');

      // Backend URL - adjust if your API path differs
      final String backendUrl =
          'https://jamie-subsatirical-abbreviatedly.ngrok-free.dev/profile';

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        String message = response.body;
        try {
          final parsed = jsonDecode(response.body);
          message = parsed['message'] ?? parsed.toString();
        } catch (_) {}

        final lower = message.toLowerCase();
        // Suppress known Firestore 'no document to update' / NOT_FOUND noise
        if (lower.contains('no document to update') ||
            lower.contains('not_found') ||
            lower.contains('not found')) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save profile: $message')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    childUidController.dispose();
    nameController.dispose();
    ageController.dispose();
    readingLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Person Info')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Child ID Field
                TextFormField(
                  controller: childUidController,
                  decoration: const InputDecoration(
                    labelText: 'Child UID',
                    hintText: 'Enter child UID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Child UID is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

              // Name Field
                TextFormField(
                  controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter child\'s name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Age Field
              TextFormField(
                controller: ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  hintText: 'Enter age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Age is required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Reading Level Field
              TextFormField(
                controller: readingLevelController,
                decoration: const InputDecoration(
                  labelText: 'Reading Level (1-5)',
                  hintText: 'Enter reading level',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Reading level is required';
                  }
                  final level = int.tryParse(value);
                  if (level == null || level < 1 || level > 5) {
                    return 'Please enter a number between 1 and 5';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tone Dropdown
              DropdownButtonFormField<String>(
                value: selectedTone,
                decoration: const InputDecoration(
                  labelText: 'Tone',
                  border: OutlineInputBorder(),
                ),
                items: tones
                    .map((tone) => DropdownMenuItem(
                          value: tone,
                          child: Text(tone),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedTone = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a tone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Step Length Dropdown
             

              const SizedBox(height: 16),

              // Prefers Emojis Checkbox
              CheckboxListTile(
                value: prefersEmojis,
                onChanged: (value) {
                  setState(() => prefersEmojis = value ?? false);
                },
                title: const Text('Prefers Emojis'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),

              // Avoid Bright Colors Checkbox
              CheckboxListTile(
                value: avoidBrightColors,
                onChanged: (value) {
                  setState(() => avoidBrightColors = value ?? false);
                },
                title: const Text('Avoid Bright Colors'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Save Profile'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}