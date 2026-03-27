import 'dart:ui';
import 'package:flutter/material.dart';


class NatureScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool extendBodyBehindAppBar;
  final bool safeArea;
  final double blur;
  final double overlayOpacity;

  const NatureScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.extendBodyBehindAppBar = true,
    this.safeArea = true,
    this.blur = 8.0,
    this.overlayOpacity = 0.42,
  });

  @override
  Widget build(BuildContext context) {
    Widget currentBody = body;
    if (safeArea) {
      currentBody = SafeArea(child: currentBody);
    }

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar != null 
        ? Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E2E1E).withValues(alpha: 0.85),
              border: const Border(top: BorderSide(color: Color(0x2066BB6A))),
            ),
            child: bottomNavigationBar,
          )
        : null,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Optional Blur
          if (blur > 0)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(color: Colors.transparent),
              ),
            ),
          // Gradient Overlay for Readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: overlayOpacity),
                    Colors.black.withValues(alpha: overlayOpacity * 0.4),
                    Colors.black.withValues(alpha: overlayOpacity * 1.2),
                  ],
                ),
              ),
            ),
          ),
          // Content
          currentBody,
        ],
      ),
    );
  }
}
