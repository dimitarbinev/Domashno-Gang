// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'pages/auth/login_page.dart';
import 'pages/auth/signup_page.dart';
import 'pages/home_page.dart';
import 'pages/child/child_home_page.dart';
import 'pages/child/child_tasks_page.dart';
import 'pages/create_task_page.dart';
import 'pages/manage_tasks_page.dart';
import 'pages/person_info_page.dart';
import 'pages/settings_page.dart';
import 'models/task_model.dart'; // make sure this exists

// 📝 Global in-memory list for testing
final List<TaskModel> tasks = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully!");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark, // 🔥 IMPORTANT
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
          ),
        ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => SignupPage(),

        // Parent home
        '/': (context) => HomePage(),

        // Child pages
        '/child-home': (context) => ChildHomePage(),
        '/child-tasks': (context) => const ChildTasksPage(),

        // Parent task pages
        '/create-task': (context) => CreateTaskPage(tasks: tasks),
        '/manage-tasks': (context) => ManageTasksPage(),

        '/person-info': (context) => PersonInfoPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}