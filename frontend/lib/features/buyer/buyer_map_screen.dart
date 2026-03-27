import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../shared/models/models.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/seller_card.dart';
import '../../shared/widgets/nature_scaffold.dart';

class BuyerMapScreen extends ConsumerStatefulWidget {
  const BuyerMapScreen({super.key});

  @override
  ConsumerState<BuyerMapScreen> createState() => _BuyerMapScreenState();
}

class _BuyerMapScreenState extends ConsumerState<BuyerMapScreen> {
  static const LatLng _defaultCenter = LatLng(42.6977, 23.3219);

  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  GoogleMapController? _mapController;
  int _lastFitMarkerCount = -1;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _lastFitMarkerCount = -1;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fitCameraToMarkers(List<_MapMarker> markers) {
    if (_mapController == null || markers.isEmpty) return;
    if (markers.length == _lastFitMarkerCount) return;
    _lastFitMarkerCount = markers.length;

    if (markers.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(markers.first.position, 8.5),
      );
      return;
    }

    double minLat = markers.first.position.latitude;
    double maxLat = minLat;
    double minLng = markers.first.position.longitude;
    double maxLng = minLng;
    for (final m in markers) {
      final p = m.position;
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }
    final pad = 0.35;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - pad, minLng - pad),
          northeast: LatLng(maxLat + pad, maxLng + pad),
        ),
        56,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sellersAsync = ref.watch(mapSellersProvider);
    final listingsAsync = ref.watch(activeListingsProvider);
    final currentUserId = ref.watch(authStateProvider).value?.uid;

    final listings = listingsAsync.maybeWhen(
      data: (l) => l,
      orElse: () => <Listing>[],
    );

    final markers = sellersAsync.maybeWhen(
      data: (sellers) => _markersFromFirestoreSellers(
        sellers,
        listings: listings,
        currentUserId: currentUserId,
        search: _searchQuery,
        category: _selectedCategory,
      ),
      orElse: () => <_MapMarker>[],
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitCameraToMarkers(markers);
    });

    LatLng center = _defaultCenter;
    if (markers.isNotEmpty) {
      center = markers.first.position;
    }

    return NatureScaffold(
      safeArea: false,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: center,
              zoom: markers.length <= 1 ? 7.5 : 6.2,
            ),
            onMapCreated: (c) {
              _mapController = c;
              _lastFitMarkerCount = -1;
              _fitCameraToMarkers(markers);
            },
            markers: markers
                .map(
                  (m) => Marker(
                    markerId: MarkerId(m.sellerId),
                    position: m.position,
                    onTap: () => _showSellerSheet(context, m),
                    infoWindow: InfoWindow(
                      title: m.sellerName,
                      snippet: '${m.city} · ★ ${m.rating.toStringAsFixed(1)}',
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                  ),
                )
                .toSet(),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),

          if (sellersAsync.isLoading)
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: LinearProgressIndicator(minHeight: 3, color: AppTheme.accentGreen),
            ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: glassDecoration(),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Търси продавачи наблизо...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                  prefixIcon: const Icon(Icons.search, size: 22, color: Colors.white70),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 72,
            left: 20,
            right: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryChip(
                    label: 'Всички',
                    selected: _selectedCategory == null,
                    onTap: () => setState(() {
                      _selectedCategory = null;
                      _lastFitMarkerCount = -1;
                    }),
                  ),
                  ...AppConstants.productCategories.take(12).map(
                        (c) => _CategoryChip(
                          label: c,
                          selected: _selectedCategory == c,
                          onTap: () => setState(() {
                            _selectedCategory = c;
                            _lastFitMarkerCount = -1;
                          }),
                        ),
                      ),
                ],
              ),
            ),
          ),

          if (markers.isEmpty &&
              sellersAsync.hasValue &&
              !(sellersAsync.isLoading))
            Positioned(
              left: 20,
              right: 20,
              bottom: 100,
              child: Material(
                color: AppTheme.cardSurface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    (sellersAsync.value ?? []).isEmpty
                        ? 'Все още няма продавачи в картата. Проверете колекцията sellers във Firebase.'
                        : 'Няма продавачи по този филтър или градовете не са в списъка за карта. '
                            'Добавете mainCity или разширейте resolveCityForMap в constants.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                  ),
                ),
              ),
            ),

          if (sellersAsync.hasError)
            Positioned(
              left: 20,
              right: 20,
              bottom: 100,
              child: Material(
                color: AppTheme.cardSurface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Продавачите не се заредиха от Firebase: ${sellersAsync.error}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSellerSheet(BuildContext context, _MapMarker marker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2B1A).withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            SellerCard(
              name: marker.sellerName,
              rating: marker.rating,
              city: marker.city,
              productChips: marker.products,
              onTap: () {
                Navigator.pop(ctx);
                context.push('/buyer/seller/${marker.sellerId}');
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/buyer/seller/${marker.sellerId}');
                },
                child: const Text('Към профила на продавача', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 10),
          ],
        ),
      ),
    );
  }
}

/// Pins from Firestore `sellers` (+ optional listing-based category filter & product chips).
List<_MapMarker> _markersFromFirestoreSellers(
  List<Seller> sellers, {
  required List<Listing> listings,
  String? currentUserId,
  required String search,
  String? category,
}) {
  /// When category is set and we have listing data: only these sellers. Empty set = no matches.
  Set<String>? sellerIdsForCategory;
  if (category != null && category.isNotEmpty) {
    if (listings.isEmpty) {
      sellerIdsForCategory = null;
    } else {
      sellerIdsForCategory = listings
          .where((l) => l.productCategory == category)
          .map((l) => l.sellerId)
          .toSet();
    }
  }

  final filtered = sellers.where((s) {
    if (currentUserId != null && s.id == currentUserId) return false;
    if (sellerIdsForCategory != null) {
      if (sellerIdsForCategory.isEmpty) return false;
      if (!sellerIdsForCategory.contains(s.id)) return false;
    }
    if (search.trim().isNotEmpty) {
      final q = search.toLowerCase();
      final cityResolved = AppConstants.resolveCityForMap(s.mainCity) ?? s.mainCity;
      if (!s.name.toLowerCase().contains(q) && !cityResolved.toLowerCase().contains(q)) {
        return false;
      }
    }
    return true;
  }).toList();

  final cityGroups = <String, List<Seller>>{};
  for (final s in filtered) {
    final city = AppConstants.resolveCityForMap(s.mainCity);
    if (city == null) continue;
    cityGroups.putIfAbsent(city, () => []).add(s);
  }

  List<String> productChipsForSeller(String sellerId) {
    final names = listings
        .where((l) => l.sellerId == sellerId)
        .map((l) => l.productName)
        .toSet()
        .take(6)
        .toList();
    if (names.isEmpty) return const ['Натисни за профил'];
    return names;
  }

  final out = <_MapMarker>[];
  for (final entry in cityGroups.entries) {
    final city = entry.key;
    final list = entry.value;
    final coords = AppConstants.cityLocations[city];
    if (coords == null) continue;

    final base = LatLng(coords.lat, coords.lng);
    for (var i = 0; i < list.length; i++) {
      final s = list[i];
      final pos = list.length <= 1
          ? base
          : LatLng(
              base.latitude + 0.004 * math.cos(2 * math.pi * i / list.length),
              base.longitude + 0.004 * math.sin(2 * math.pi * i / list.length),
            );
      out.add(_MapMarker(
        position: pos,
        sellerId: s.id,
        sellerName: s.name.trim().isEmpty ? 'Продавач' : s.name.trim(),
        city: city,
        rating: s.rating,
        products: productChipsForSeller(s.id),
      ));
    }
  }
  return out;
}

class _MapMarker {
  final LatLng position;
  final String sellerId, sellerName, city;
  final double rating;
  final List<String> products;

  const _MapMarker({
    required this.position,
    required this.sellerId,
    required this.sellerName,
    required this.city,
    required this.rating,
    required this.products,
  });
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppTheme.accentGreen : Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            border: Border.all(
              color: selected
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
