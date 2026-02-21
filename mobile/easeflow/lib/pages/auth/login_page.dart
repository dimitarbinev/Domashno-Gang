import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String role = 'parent'; // default role selector (optional)

  bool _loading = false;

  // Replace with your backend endpoint
  final String backendUrl = 'https://your-backend.com/api/verify-token';

Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);

  try {
    // 1️⃣ Sign in with Firebase
    final userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text);

    // 2️⃣ Get ID token from Firebase
    final idToken = await userCredential.user!.getIdToken();

    // 3️⃣ Send ID token to backend for verification
    final response = await http.post(
      Uri.parse(backendUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    final result = jsonDecode(response.body);

    // ✅ Check if widget is still mounted before using context
    if (!mounted) return;

    if (response.statusCode == 200 && result['role'] != null) {
      if (result['role'] == 'parent') {
        Navigator.pushReplacementNamed(context, '/');
      } else {
        Navigator.pushReplacementNamed(context, '/child-home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Login failed')),
      );
    }
  } on FirebaseAuthException catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Login failed')),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An error occurred')),
    );
  } finally {
  if (mounted) {
    setState(() => _loading = false);
  }
}
}

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _login,
                          child: const Text('Login'),
                        ),
                ),
                const SizedBox(height: 16),

                // GO TO SIGNUP
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
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