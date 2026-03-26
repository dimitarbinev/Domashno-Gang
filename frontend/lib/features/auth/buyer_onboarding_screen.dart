import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../shared/providers/providers.dart';

class BuyerOnboardingScreen extends ConsumerStatefulWidget {
  const BuyerOnboardingScreen({super.key});

  @override
  ConsumerState<BuyerOnboardingScreen> createState() => _BuyerOnboardingScreenState();
}

class _BuyerOnboardingScreenState extends ConsumerState<BuyerOnboardingScreen> {
  final _nameController = TextEditingController();
  String? _selectedCity;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    final name = _nameController.text.trim();
    final city = _selectedCity;

    if (name.isEmpty || city == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final regData = ref.read(registrationDataProvider);
      
      await ref.read(authServiceProvider).signUp(
        name: name,
        email: regData['email']!,
        password: regData['password']!,
        role: regData['role']!,
        preferredCity: city,
      );

      if (mounted) {
        ref.read(registrationDataProvider.notifier).clear();
        context.go('/buyer/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/register'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.shopping_bag_rounded,
                size: 64,
                color: AppTheme.accentGreen,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Tell us about yourself',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: glassDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCity,
                      decoration: const InputDecoration(
                        labelText: 'Preferred City',
                        prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                      ),
                      dropdownColor: AppTheme.cardSurface,
                      items: AppConstants.cities
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCity = v),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleComplete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Start Exploring'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
