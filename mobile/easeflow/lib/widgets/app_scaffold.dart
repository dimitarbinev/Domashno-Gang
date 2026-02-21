import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;

  const AppScaffold({super.key, required this.body, this.title = 'EaseFlow'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        width: 225,
        child: ListView(
          
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 150,
              color: Colors.teal,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomLeft,
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('Create Task'),
              onTap: () {
                Navigator.of(context).pushNamed('/create-task');
              },
            ),
            ListTile(
              title: const Text('Manage Tasks'),
              onTap: () {
                Navigator.of(context).pushNamed('/manage-tasks');
              },
            ),
            ListTile(
              title: const Text('Person Info'),
              onTap: () {
                Navigator.of(context).pushNamed('/person-info');
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
          ],
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Image.asset(
                      'assets/images/easeflow.png',
                      height: 90,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, color: Colors.red, size: 100);
                      },
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Builder(
                    builder: (context) => IconButton(
                      iconSize: 46,
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.teal[800],
        ),
      ),
      body: body,
    );
  }
}