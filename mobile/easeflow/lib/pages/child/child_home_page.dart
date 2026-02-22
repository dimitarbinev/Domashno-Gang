import 'package:flutter/material.dart';
import '../../widgets/child_scaffold.dart';

class ChildHomePage extends StatelessWidget {
  const ChildHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChildScaffold(
      title: 'EaseFlow',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Large circular TASKS button (icon + label inside)
              Center(
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/child-tasks'),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                      backgroundColor: const Color.fromARGB(186, 142, 249, 35),
                      foregroundColor: Colors.black,
                      elevation: 8,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.assignment, size: 72),
                        SizedBox(height: 12),
                        Text(
                          'TASKS',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const SizedBox(height: 24),

              // Large circular EMERGENCY button (icon + label inside)
              Center(
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Emergency'),
                          content: const Text('Emergency action triggered.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                      backgroundColor: const Color.fromARGB(255, 192, 56, 56),
                      foregroundColor: Colors.white,
                      elevation: 8,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.warning, size: 72),
                        SizedBox(height: 12),
                        Text(
                          'EMERGENCY',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}