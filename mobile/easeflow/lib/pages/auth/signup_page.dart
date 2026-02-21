import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  String role = 'parent';

  void _signup() {
    if (_formKey.currentState!.validate()) {
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 40),

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

                // CONFIRM
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value != passwordController.text
                          ? 'Passwords do not match'
                          : null,
                ),

                const SizedBox(height: 20),

                // ROLE
                DropdownButtonFormField<String>(
                  value: role,
                  items: const [
                    DropdownMenuItem(
                        value: 'parent', child: Text('Parent')),
                    DropdownMenuItem(
                        value: 'child', child: Text('Child')),
                  ],
                  onChanged: (value) => setState(() => role = value!),
                  decoration: const InputDecoration(
                    labelText: 'Register as',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

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
                  onPressed: () =>
                      Navigator.pop(context),
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}