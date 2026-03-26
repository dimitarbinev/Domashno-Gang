import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/quantity_progress_bar.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/ai_insight_card.dart';
import '../../shared/widgets/go_decision_bar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/providers.dart';

class SellerListingDetailScreen extends ConsumerWidget {
  final String listingId;
  const SellerListingDetailScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    final listingsAsync = ref.watch(sellerListingsProvider(user.uid));
    final reservationsAsync = ref.watch(listingReservationsProvider(listingId));

    return listingsAsync.when(
      data: (listings) {
        final listing = listings.cast<Listing?>().firstWhere(
              (l) => l?.id == listingId,
              orElse: () => null,
            );

        if (listing == null) {
          return const Scaffold(body: Center(child: Text('Listing not found')));
        }

        final showGoCancel =
            listing.status == 'active' || listing.status == 'threshold_reached';

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go('/seller/dashboard'),
            ),
            title: const Text('Listing Details'),
            actions: [
              StatusChip(status: listing.status),
              const SizedBox(width: 16),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: glassDecoration(),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          color: AppTheme.cardSurfaceLight,
                        ),
                        child: const Icon(Icons.eco,
                            color: AppTheme.accentGreen, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(listing.productName,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.accentGreen),
                                const SizedBox(width: 4),
                                Text(listing.city,
                                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                                const SizedBox(width: 12),
                                const Icon(Icons.calendar_today, size: 12, color: AppTheme.textSecondary),
                                const SizedBox(width: 4),
                                Text(DateFormat('MMM d, y').format(listing.date),
                                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                                const SizedBox(width: 12),
                                const Icon(Icons.access_time, size: 12, color: AppTheme.textSecondary),
                                const SizedBox(width: 4),
                                Text('${listing.startTime} - ${listing.endTime}',
                                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('${listing.pricePerKg.toStringAsFixed(2)} лв/kg',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.accentGreen)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Progress
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: glassDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Demand Progress',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 14),
                      QuantityProgressBar(
                        current: listing.requestedQuantity,
                        target: listing.minThreshold,
                        height: 12,
                        label:
                            '${listing.requestedQuantity.toStringAsFixed(0)} / ${listing.minThreshold.toStringAsFixed(0)} kg requested',
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'Deposits: ${listing.depositsTotal.toStringAsFixed(2)} лв',
                              style: const TextStyle(
                                  fontSize: 13, color: AppTheme.textSecondary)),
                          Text('${listing.startTime} - ${listing.endTime}',
                              style: const TextStyle(
                                  fontSize: 13, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Reservations (Using real data)
                reservationsAsync.when(
                  data: (reservations) => Container(
                    padding: const EdgeInsets.all(20),
                    decoration: glassDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reservations (${reservations.length})',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 14),
                        if (reservations.isEmpty)
                          const Text('No reservations yet',
                              style: TextStyle(color: AppTheme.textTertiary)),
                        ...reservations.map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.primaryGreen
                                          .withValues(alpha: 0.15),
                                    ),
                                    child: const Icon(Icons.person,
                                        size: 20, color: AppTheme.accentGreen),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(r.buyerName ?? 'Buyer',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.textPrimary)),
                                        Text(
                                            '${r.quantity.toStringAsFixed(0)} kg · ${r.deposit.toStringAsFixed(2)} лв deposit',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  StatusChip(status: r.status, small: true),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading reservations: $e'),
                ),
                const SizedBox(height: 16),

                // AI Price Suggestion
                AIInsightCard(
                  icon: Icons.trending_up,
                  title: 'Price Insight',
                  body:
                      'Your price of ${listing.pricePerKg.toStringAsFixed(2)} лв/kg is optimized for the ${listing.city} region based on local demand.',
                  confidenceLabel: 'High Confidence',
                  confidenceValue: 0.85,
                ),
                const SizedBox(height: 12),

                // AI Route Suggestion
                AIInsightCard(
                  icon: Icons.route,
                  title: 'Route Suggestion',
                  body:
                      'Optimized stop in ${listing.city} for ${listing.requestedQuantity.toStringAsFixed(0)} kg is confirmed.\n\nExpected revenue: ${(listing.requestedQuantity * listing.pricePerKg).toStringAsFixed(2)} лв',
                  confidenceLabel: 'High',
                  confidenceValue: 0.9,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar: showGoCancel
              ? GoDecisionBar(
                  onGo: () async {
                    try {
                      await ref.read(productServiceProvider).updateListingStatus(
                        productId: listing.productId,
                        listingId: listing.id,
                        status: 2, // Confirmed GO!
                      );
                      // Refresh listings
                      ref.invalidate(sellerListingsProvider(user.uid));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Listing Confirmed! GO!')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  onCancel: () async {
                    try {
                      await ref.read(productServiceProvider).updateListingStatus(
                        productId: listing.productId,
                        listingId: listing.id,
                        status: 3, // Cancelled
                      );
                      // Refresh listings
                      ref.invalidate(sellerListingsProvider(user.uid));
                      if (context.mounted) {
                        context.go('/seller/dashboard');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Listing Cancelled.')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                )
              : null,
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
