import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChildScaffold extends StatelessWidget {
  final Widget body;
  final String title;

  const ChildScaffold({
    super.key,
    required this.body,
    this.title = 'EaseFlow',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // background gradient for a more fluent look
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5AB61), Color(0xFF2B2F2F)],
            stops: [0.0, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Custom curved header
            PreferredSize(
              preferredSize: const Size.fromHeight(160),
              child: LayoutBuilder(builder: (context, constraints) {
                final width = constraints.maxWidth;
                return Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E5A2C), Color(0xFFB37337)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(width, 120),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Back button if possible
                          if (Navigator.canPop(context))
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              color: Colors.white,
                              onPressed: () => Navigator.of(context).pop(),
                            )
                          else
                            const SizedBox(width: 48),

                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],
                            ),
                          ),

                          // logout icon (small but available)
                          IconButton(
                            icon: const Icon(Icons.logout),
                            color: Colors.white,
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();

                              if (context.mounted) {
                                Navigator.of(context)
                                    .pushNamedAndRemoveUntil(
                                  '/login',
                                  (route) => false,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            // Body placed below the curved header, allow it to scroll if needed
            Expanded(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}