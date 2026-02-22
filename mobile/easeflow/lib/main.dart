// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';

import 'pages/auth/login_page.dart';
import 'pages/auth/signup_page.dart';
import 'pages/home_page.dart';
import 'pages/child/child_home_page.dart';
import 'pages/child/child_tasks_page.dart';
import 'pages/create_task_page.dart';
import 'pages/manage_tasks_page.dart';
import 'pages/person_info_page.dart';
import 'pages/settings_page.dart';
import 'models/task_model.dart';

// 🧠 Global in-memory list (temporary until full backend)
final List<TaskModel> tasks = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 MUST be first
  await dotenv.load(fileName: ".env");

  // 🔥 THEN Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🌙 FORCE DARK MODE
      themeMode: ThemeMode.dark,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
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

        // 👨‍👩‍👧 Parent home
        '/': (context) => HomePage(),

        // 🧒 Child pages
        '/child-home': (context) => ChildHomePage(),
        '/child-tasks': (context) => const ChildTasksPage(),

        // 🧾 Task pages
        '/create-task': (context) => CreateTaskPage(tasks: tasks),
        '/manage-tasks': (context) => ManageTasksPage(),

        '/person-info': (context) => PersonInfoPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}