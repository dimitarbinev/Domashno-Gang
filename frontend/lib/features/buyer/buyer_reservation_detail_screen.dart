import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../shared/models/models.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/status_chip.dart';

class BuyerReservationDetailScreen extends ConsumerWidget {
  final String reservationId;
  const BuyerReservationDetailScreen({super.key, required this.reservationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(myReservationsProvider);

    return reservationsAsync.when(
      data: (reservations) {
        final reservation = reservations.cast<Reservation?>().firstWhere(
              (r) => r?.id == reservationId,
              orElse: () => null,
            );

        if (reservation == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go('/buyer/reservations'),
              ),
              title: const Text('Reservation Details'),
            ),
            body: const Center(child: Text('Reservation not found')),
          );
        }

        final canCancel = reservation.status == 'pending';

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go('/buyer/reservations'),
            ),
            title: const Text('Reservation Details'),
            actions: [
              StatusChip(status: reservation.status),
              const SizedBox(width: 16),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Info Card
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
                        child: const Icon(Icons.shopping_basket_outlined,
                            color: AppTheme.accentGreen, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reservation.productName ?? 'Product',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary)),
                            const SizedBox(height: 4),
                            Text(reservation.city ?? 'Local',
                                style: const TextStyle(
                                    fontSize: 14, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Details Grid
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: glassDecoration(),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.scale_outlined,
                        label: 'Quantity',
                        value: '${reservation.quantity.toStringAsFixed(0)} kg',
                      ),
                      const Divider(height: 32, color: Colors.white10),
                      _DetailRow(
                        icon: Icons.payments_outlined,
                        label: 'Price per kg',
                        value: '${(reservation.pricePerKg ?? 0).toStringAsFixed(2)} лв',
                      ),
                      const Divider(height: 32, color: Colors.white10),
                      _DetailRow(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Deposit Paid',
                        value: '${reservation.deposit.toStringAsFixed(2)} лв',
                      ),
                      const Divider(height: 32, color: Colors.white10),
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Created On',
                        value: DateFormat('MMM d, yyyy').format(reservation.createdAt),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Availability Range
                const Text('Collection Window',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: glassDecoration(),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range_rounded, color: AppTheme.accentGreen),
                      const SizedBox(width: 16),
                      Text(
                        '${DateFormat('MMM d').format(reservation.startDate)} - ${DateFormat('MMM d, yyyy').format(reservation.endDate)}',
                        style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Cancel Button
                if (canCancel)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => _showCancelDialog(context, ref, reservation.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.statusCancelled.withValues(alpha: 0.1),
                        foregroundColor: AppTheme.statusCancelled,
                        elevation: 0,
                        side: const BorderSide(color: AppTheme.statusCancelled, width: 1),
                      ),
                      child: const Text('Cancel Reservation',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, String reservationId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        title: const Text('Cancel Reservation?', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Are you sure you want to cancel this reservation? This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Wait, no', style: TextStyle(color: AppTheme.textTertiary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              try {
                await ref.read(productServiceProvider).cancelReservation(reservationId);
                ref.invalidate(myReservationsProvider);
                if (context.mounted) {
                  context.go('/buyer/reservations');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reservation cancelled successfully')),
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
            child: const Text('Yes, Cancel', style: TextStyle(color: AppTheme.statusCancelled)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.accentGreen),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      ],
    );
  }
}
