import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'pages/auth/login_page.dart';
import 'pages/home_page.dart';
import 'pages/child/child_home_page.dart';
import 'pages/auth/signup_page.dart';
import 'pages/create_task_page.dart';
import 'pages/manage_tasks_page.dart';
import 'pages/person_info_page.dart';
import 'pages/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final Future<FirebaseApp> _firebaseInit;

  @override
  void initState() {
    super.initState();
    _firebaseInit = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _firebaseInit,
      builder: (context, snapshot) {
        // Error initializing Firebase
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'Error initializing Firebase:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        // Firebase is ready
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginPage(),
              '/signup': (context) => const SignupPage(),
              '/': (context) => const HomePage(),
              '/child-home': (context) => const ChildHomePage(),
              '/create-task': (context) => const CreateTaskPage(),
              '/manage-tasks': (context) => const ManageTasksPage(),
              '/person-info': (context) => const PersonInfoPage(),
              '/settings': (context) => const SettingsPage(),
            },
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.dark,
              ),
            ),
          );
        }

        // Loading Firebase
        return const MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}