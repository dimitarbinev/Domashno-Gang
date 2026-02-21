import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String role = 'parent'; // parent or child

  void _login() {
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
                  'EaseFlow Login',
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

                // ROLE SELECTOR
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
                    labelText: 'Login as',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/signup'),
                  child: const Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}