import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/nature_scaffold.dart';

class BuyerProfileScreen extends ConsumerWidget {
  const BuyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NatureScaffold(
      appBar: AppBar(
        title: const Text('Моят профил'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar with glass effect
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 16),
            ref.watch(currentBuyerProvider).when(
              data: (buyer) => Column(
                children: [
                  Text(
                    buyer?.name ?? 'Купувач',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppTheme.accentGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        buyer?.preferredCity ?? 'Неизвестен',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, _) => const Text('Грешка при зареждане', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 28),

            // Stats with glass decoration
            Row(
              children: [
                Expanded(child: _StatCard(label: 'Поръчки', value: '12', icon: Icons.shopping_bag_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'Отзиви', value: '8', icon: Icons.rate_review_outlined)),
                const SizedBox(width: 12),
                Expanded(
                  child: ref.watch(savedSellersProvider).when(
                    data: (ids) => _StatCard(label: 'Запазени', value: ids.length.toString(), icon: Icons.favorite_outline),
                    loading: () => _StatCard(label: 'Запазени', value: '...', icon: Icons.favorite_outline),
                    error: (_, _) => _StatCard(label: 'Запазени', value: '0', icon: Icons.favorite_outline),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Menu items with glass effect
            Container(
              decoration: glassDecoration(radius: AppTheme.radiusLarge),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _MenuItem(icon: Icons.favorite_outline, label: 'Запазени продавачи', onTap: () => context.push('/buyer/saved-sellers')),
                  const Divider(height: 1, indent: 56, endIndent: 20, color: Colors.white10),
                  _MenuItem(icon: Icons.settings_outlined, label: 'Настройки', onTap: () => context.push('/seller/settings')),
                  const Divider(height: 1, indent: 56, endIndent: 20, color: Colors.white10),
                  _MenuItem(
                    icon: Icons.storefront_outlined,
                    label: 'Превключи към продавач',
                    onTap: () async {
                      try {
                        await ref.read(authServiceProvider).switchRole('seller');
                        if (context.mounted) {
                          context.go('/seller/dashboard');
                        }
                      } catch (e) {
                        debugPrint('Error switching role: $e');
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 20, color: Colors.white10),
                  _MenuItem(
                    icon: Icons.logout,
                    label: 'Изход',
                    isDanger: true,
                    onTap: () async {
                      await ref.read(authServiceProvider).signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: glassDecoration(),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.accentGreen, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: glassDecoration(),
        child: Row(
          children: [
            Icon(icon, size: 22, color: isDanger ? AppTheme.statusCancelled : AppTheme.accentGreen),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500,
              color: isDanger ? AppTheme.statusCancelled : AppTheme.textPrimary,
            ))),
            const Icon(Icons.chevron_right, size: 20, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
