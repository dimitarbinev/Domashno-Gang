import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme.dart';
import '../../shared/widgets/seller_card.dart';
import '../../shared/widgets/nature_scaffold.dart';

class BuyerMapScreen extends StatefulWidget {
  const BuyerMapScreen({super.key});

  @override
  State<BuyerMapScreen> createState() => _BuyerMapScreenState();
}

class _BuyerMapScreenState extends State<BuyerMapScreen> {
  static const LatLng _center = LatLng(42.6977, 23.3219); // Sofia

  @override
  Widget build(BuildContext context) {
    return NatureScaffold(
      safeArea: false,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _center,
              zoom: 6.5,
            ),
            markers: _markers.map((m) {
              return Marker(
                markerId: MarkerId(m.sellerId),
                position: m.position,
                infoWindow: InfoWindow(
                  title: m.sellerName,
                  snippet: '${m.city} · ★ ${m.rating}',
                  onTap: () => _showSellerSheet(context, m),
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              );
            }).toSet(),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),

          // Top search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: glassDecoration(),
              child: TextField(
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

          // Filter chips
          Positioned(
            top: MediaQuery.of(context).padding.top + 72,
            left: 20,
            right: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Всички', 'Зеленчуци', 'Плодове', 'Млечни']
                    .map(
                      (c) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: c == 'Всички' ? AppTheme.accentGreen : Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                          border: Border.all(
                            color: c == 'Всички'
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          c,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                    .toList(),
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
          color: const Color(0xFF1A2B1A).withValues(alpha: 0.95), // Dark green-tinted background
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
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
                context.go('/buyer/seller/${marker.sellerId}');
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
                  context.go('/buyer/seller/${marker.sellerId}');
                },
                child: const Text('Виж всички обяви', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 10),
          ],
        ),
      ),
    );
  }
}

class _MapMarker {
  final LatLng position;
  final String sellerId, sellerName, city;
  final double rating;
  final List<String> products;

  const _MapMarker({
    required this.position,
    required this.sellerId, required this.sellerName,
    required this.city, required this.rating,
    required this.products,
  });
}

const _markers = [
  _MapMarker(position: LatLng(42.6977, 23.3219), sellerId: 's1', sellerName: 'Ivan Petrov', city: 'Sofia', rating: 4.7, products: ['Tomatoes', 'Peppers']),
  _MapMarker(position: LatLng(42.1354, 24.7453), sellerId: 's2', sellerName: 'Maria Georgieva', city: 'Plovdiv', rating: 4.5, products: ['Apples', 'Pears']),
  _MapMarker(position: LatLng(43.2141, 27.9147), sellerId: 's3', sellerName: 'Todor Stoyanov', city: 'Varna', rating: 4.9, products: ['Honey']),
  _MapMarker(position: LatLng(42.5048, 27.4626), sellerId: 's4', sellerName: 'Elena Nikolova', city: 'Burgas', rating: 4.3, products: ['Carrots', 'Potatoes']),
];
