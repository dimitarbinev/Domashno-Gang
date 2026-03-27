import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../shared/widgets/listing_card.dart';
import '../../shared/widgets/nature_scaffold.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/providers.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  String? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) {
      return const NatureScaffold(body: Center(child: Text('Моля, влезте в профила си', style: TextStyle(color: Colors.white))));
    }

    final listingsAsync = ref.watch(sellerListingsProvider(user.uid));

    return NatureScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Моите обяви',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  IconButton(
                    onPressed: () => context.go('/seller/create-listing'),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _FilterChip(label: 'Всички', isSelected: _filterStatus == null, onTap: () => setState(() => _filterStatus = null)),
                  _FilterChip(label: 'Активни', isSelected: _filterStatus == 'active', onTap: () => setState(() => _filterStatus = 'active')),
                  _FilterChip(label: 'Достигнат', isSelected: _filterStatus == 'threshold_reached', onTap: () => setState(() => _filterStatus = 'threshold_reached')),
                  _FilterChip(label: 'Потвърдени', isSelected: _filterStatus == 'confirmed', onTap: () => setState(() => _filterStatus = 'confirmed')),
                  _FilterChip(label: 'Отменени', isSelected: _filterStatus == 'cancelled', onTap: () => setState(() => _filterStatus = 'cancelled')),
                  _FilterChip(label: 'Завършени', isSelected: _filterStatus == 'completed', onTap: () => setState(() => _filterStatus = 'completed')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: listingsAsync.when(
                data: (listings) {
                  final filtered = _filterStatus == null
                      ? listings
                      : listings.where((l) => l.status == _filterStatus).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.list_alt_rounded, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          Text('Няма намерени обяви', 
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => ListingCard(
                      listing: filtered[i],
                      showSellerInfo: false,
                      onTap: () => context.go('/seller/listing/${filtered[i].id}'),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGreen)),
                error: (err, _) => Center(child: Text('Грешка: $err', style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          border: Border.all(color: isSelected ? AppTheme.primaryGreen : Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: Colors.white,
        )),
      ),
    );
  }
}
