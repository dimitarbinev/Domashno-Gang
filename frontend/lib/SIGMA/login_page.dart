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

  bool _loading = false;

  // ✅ IMPORTANT — use your REAL endpoint
  final String backendUrl =
      'https://jamie-subsatirical-abbreviatedly.ngrok-free.dev/auth/me';

  Future<void> _login() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _loading = true);

    try {
      // 🔐 1. Firebase login
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      // 🎫 2. Get ID token
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) throw Exception("Failed to get ID token");

      // 🌐 3. Call backend
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: {
          "Authorization": "Bearer $idToken",
          "Content-Type": "application/json",
        },
      );

      if (!mounted) return;

      // 🚨 PROTECTION: avoid HTML crash
      if (!response.headers['content-type']!.contains('application/json')) {
        throw Exception(
          "Backend returned HTML instead of JSON.\nStatus: ${response.statusCode}\nBody: ${response.body.substring(0, 80)}",
        );
      }

      final profile = jsonDecode(response.body);

      // ✅ Success
      if (response.statusCode == 200) {
        if (profile['role'] == 'guardian') {
          Navigator.pushReplacementNamed(context, '/');
        } else {
          Navigator.pushReplacementNamed(context, '/child-home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(profile['message'] ?? 'Login failed')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Firebase login failed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'EaseFlow Login',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // EMAIL
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter email'
                            : null,
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
                        validator: (value) => value == null || value.length < 6
                            ? 'Min 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 30),

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

                      // SIGNUP
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
          ),
        ),
      ),
    );
  }
}
