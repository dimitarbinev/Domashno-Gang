import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../shared/providers/map_provider.dart';
import '../../shared/providers/providers.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';

class RoutePlanningScreen extends ConsumerWidget {
  const RoutePlanningScreen({super.key});

  static const LatLng _initialCenter = LatLng(42.6977, 23.3219);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    final listingsAsync = ref.watch(sellerListingsProvider(user.uid));
    final mapState = ref.watch(mapProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Route Planning',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (mapState.isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Map ──
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  color: AppTheme.cardSurface,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06)),
                ),
                clipBehavior: Clip.antiAlias,
                child: listingsAsync.when(
                  data: (listings) {
                    return GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _initialCenter,
                        zoom: 7,
                      ),
                      markers: mapState.markers,
                      polylines: mapState.polylines,
                      myLocationEnabled: true,
                      zoomControlsEnabled: false,
                      mapType: MapType.normal,
                      onMapCreated: (controller) {
                        if (mapState.routeOptions.isEmpty) {
                          // Demo: 6 cities across Bulgaria
                          ref
                              .read(mapProvider.notifier)
                              .fetchMultiDayRoute([
                            'Pernik',
                            'Sofia',
                            'Vratsa',
                            'Shumen',
                            'Varna',
                            'Burgas',
                          ]);
                        }
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) =>
                      Center(child: Text('Error loading listings')),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Day legend ──
            if (mapState.routeOptions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    for (final opt in mapState.routeOptions) ...[
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(
                              (opt as Map)['color'] as int? ?? 0xFF2ECC71),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ден ${opt['day']}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 8),

            // ── Per-day route cards ──
            Expanded(
              flex: 2,
              child: mapState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primaryGreen))
                  : mapState.routeOptions.isEmpty
                      ? const Center(
                          child: Text('No routes found',
                              style: TextStyle(
                                  color: AppTheme.textSecondary)))
                      : ListView(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            for (final routeInfo in mapState.routeOptions)
                              _DayRouteCard(
                                  routeInfo:
                                      routeInfo as Map<String, dynamic>),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card showing analysis for one day's route
class _DayRouteCard extends StatelessWidget {
  final Map<String, dynamic> routeInfo;

  const _DayRouteCard({required this.routeInfo});

  @override
  Widget build(BuildContext context) {
    final label = routeInfo['label'] as String? ?? 'Route';
    final stops = routeInfo['ordered_stops'] as List? ?? [];
    final distKm = routeInfo['total_distance_km'] ?? 0;
    final driveTime = routeInfo['drive_time_readable'] ?? '';
    final adminMin = routeInfo['admin_time_minutes'] ?? 0;
    final totalTime = routeInfo['total_time_readable'] ?? '';
    final numStops = routeInfo['num_stops'] ?? stops.length;
    final colorValue = routeInfo['color'] as int?;
    final color =
        colorValue != null ? Color(colorValue) : AppTheme.primaryGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border:
            Border.all(color: color.withValues(alpha: 0.4), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Stop chips ──
          Wrap(
            spacing: 4,
            runSpacing: 6,
            children: stops.asMap().entries.map((e) {
              final isLast = e.key == stops.length - 1;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  if (!isLast)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(Icons.arrow_forward_ios,
                          size: 10,
                          color: color.withValues(alpha: 0.5)),
                    ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // ── Stats row ──
          Row(
            children: [
              // Distance
              const Icon(Icons.straighten,
                  size: 15, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text('$distKm km',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const SizedBox(width: 14),
              // Drive time
              const Icon(Icons.directions_car,
                  size: 15, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(driveTime,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textPrimary)),
              const SizedBox(width: 14),
              // Admin time
              const Icon(Icons.people,
                  size: 15, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text('${adminMin}м ($numStops спирки)',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 6),
          // Total time
          Row(
            children: [
              const Icon(Icons.schedule,
                  size: 15, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text('Общо: $totalTime',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}
