import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final guardianIdController = TextEditingController();

  String role = 'parent'; // parent or child

  void _signup() {
    if (_formKey.currentState!.validate()) {
      // Collect data
      final displayName = displayNameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text;
      final guardianId = role == 'child' ? guardianIdController.text.trim() : null;

      // print('Signup Info:');
      // print('Display Name: $displayName');
      // print('Email: $email');
      // print('Password: $password');
      // print('Role: $role');
      // if (guardianId != null) print('Guardian ID: $guardianId');

      // Navigate to proper home
      if (role == 'parent') {
        Navigator.pushReplacementNamed(context, '/');
      } else {
        Navigator.pushReplacementNamed(context, '/child-home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView( // scroll if keyboard appears
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),

                  // DISPLAY NAME
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter display name' : null,
                  ),
                  const SizedBox(height: 20),

                  // EMAIL
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter email' : null,
                  ),
                  const SizedBox(height: 20),

                  // PASSWORD
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.length < 6 ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 20),

                  // CONFIRM PASSWORD
                  TextFormField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value != passwordController.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // ROLE
                  DropdownButtonFormField<String>(
                    value: role,
                    items: const [
                      DropdownMenuItem(value: 'parent', child: Text('Parent')),
                      DropdownMenuItem(value: 'child', child: Text('Child')),
                    ],
                    onChanged: (value) => setState(() => role = value!),
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // GUARDIAN ID (only for child)
                  if (role == 'child')
                    TextFormField(
                      controller: guardianIdController,
                      decoration: const InputDecoration(
                        labelText: 'Guardian ID',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => role == 'child' && value!.isEmpty
                          ? 'Enter guardian ID'
                          : null,
                    ),
                  if (role == 'child') const SizedBox(height: 20),

                  // SIGNUP BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _signup,
                      child: const Text('Create Account'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}