import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/nature_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _scaleUp = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeOutBack)),
    );
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      
      User? user;
      try {
        user = await ref.read(authStateProvider.future).timeout(const Duration(seconds: 5));
      } catch (e) {
        if (mounted) context.go('/login');
        return;
      }

      final storage = ref.read(storageServiceProvider);
      
      if (user != null) {
        // User is authenticated — try to restore their session
        final lastRoute = await storage.getLastRoute();

        // If we have a valid saved route, go there directly (skipping legacy onboarding)
        if (lastRoute != null && 
            lastRoute != '/splash' && 
            lastRoute != '/login' && 
            lastRoute != '/' &&
            !lastRoute.contains('onboarding')) {
          if (mounted) context.go(lastRoute);
          return;
        }

        // No saved route — try to determine role from profile
        dynamic profileAsync;
        try {
          profileAsync = await ref.read(userProfileProvider.future).timeout(const Duration(seconds: 5));
        } catch (e) {
          // Backend may be down — try Firestore directly for the role
          try {
            final doc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get()
                .timeout(const Duration(seconds: 3));
            final role = doc.data()?['role'] as String?;
            if (mounted) {
              if (role == 'seller') {
                context.go('/seller/dashboard');
              } else if (role == 'buyer') {
                context.go('/buyer/home');
              } else {
                context.go('/login');
              }
            }
          } catch (_) {
            if (mounted) context.go('/login');
          }
          return;
        }

        final role = profileAsync?['role'] as String?;
        if (mounted) {
          if (role == 'seller') {
            context.go('/seller/dashboard');
          } else if (role == 'buyer') {
            context.go('/buyer/home');
          } else {
            context.go('/login');
          }
        }
      } else {
        if (mounted) context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NatureScaffold(
      blur: 0.0,
      overlayOpacity: 0.25,
      safeArea: false,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeIn.value,
              child: Transform.scale(
                scale: _scaleUp.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glow behind logo
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryGreen.withValues(alpha: 0.4),
                      AppTheme.primaryGreen.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    radius: 0.8,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 56,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'AgriSell',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                ),
                child: const Text(
                  AppConstants.tagline,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentGreen,
                    letterSpacing: 0.5,
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

/// A simplified AnimatedBuilder since the built-in one requires a Listenable.
class AnimatedBuilder extends StatelessWidget {
  final Widget? child;
  final TransitionBuilder builder;
  final Listenable animation;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: animation,
      builder: builder,
      child: child,
    );
  }
}
