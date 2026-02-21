import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/create_task_page.dart';
import 'pages/manage_tasks_page.dart';
import 'pages/person_info_page.dart';
import 'pages/settings_page.dart';

import 'pages/auth/login_page.dart';
import 'pages/auth/signup_page.dart';
import 'pages/child/child_home_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
            routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),

        '/': (context) => HomePage(), // parent home (your current one)
        '/child-home': (context) => ChildHomePage(),

        '/create-task': (context) => CreateTaskPage(),
        '/manage-tasks': (context) => ManageTasksPage(),
        '/person-info': (context) => PersonInfoPage(),
        '/settings': (context) => SettingsPage(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}