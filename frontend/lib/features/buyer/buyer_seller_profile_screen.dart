import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/rating_stars.dart';
import '../../shared/widgets/listing_card.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/nature_scaffold.dart';

class BuyerSellerProfileScreen extends ConsumerWidget {
  final String sellerId;
  const BuyerSellerProfileScreen({super.key, required this.sellerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(sellerProfileProvider(sellerId));

    return profileAsync.when(
      data: (data) {
        final profile = data['profile'];
        final List<dynamic> listingsData = data['listings'];
        final listings = listingsData.map((l) => Listing.fromJson(l, l['id'] ?? '')).toList();
        final List<dynamic> reviewsData = data['reviews'] ?? [];
        final reviews = reviewsData.map((r) => Review.fromJson(r, r['id'] ?? '')).toList();

        return NatureScaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.go('/buyer/home'),
            ),
            title: const Text('Профил на продавач'),
            actions: [
              Consumer(
                builder: (context, ref, child) {
                  final savedSellersAsync = ref.watch(savedSellersProvider);
                  return savedSellersAsync.when(
                    data: (ids) {
                      final isSaved = ids.contains(sellerId);
                      return IconButton(
                        icon: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          color: isSaved ? AppTheme.statusCancelled : Colors.white,
                        ),
                        onPressed: () async {
                          try {
                            await ref.read(productServiceProvider).toggleSaveSeller(sellerId);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar & info
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, 
                    gradient: AppTheme.primaryGradient,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 14),
                Text(profile['name'] ?? 'Продавач', 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RatingStars(rating: (profile['rating'] as num?)?.toDouble() ?? 0.0, size: 18),
                    const SizedBox(width: 8),
                    Text(profile['rating']?.toStringAsFixed(1) ?? '0.0', 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(width: 4),
                    Text('(${profile['reviewCount'] ?? 0} отзива)', 
                        style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.accentGreen),
                    const SizedBox(width: 4),
                    Text(profile['mainCity'] ?? 'Неизвестен', 
                        style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
                const SizedBox(height: 24),

                // Active Listings
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Активни обяви', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
                const SizedBox(height: 12),
                if (listings.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text('Няма активни обяви', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
                  )
                else
                  ...listings.map((l) => ListingCard(
                    listing: l,
                    showSellerInfo: false,
                    onTap: () => context.go('/buyer/listing/${l.id}'),
                  )),
                const SizedBox(height: 32),

                // Reviews Header & Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Отзиви', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    TextButton.icon(
                      onPressed: () => _showReviewDialog(context, ref, sellerId),
                      icon: const Icon(Icons.add_comment_outlined, size: 18, color: AppTheme.accentGreen),
                      label: const Text('Остави отзив', style: TextStyle(color: AppTheme.accentGreen)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (reviews.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text('Все още няма отзиви. Бъдете първият!', 
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
                  )
                else
                  ...reviews.map((r) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: glassDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(r.buyerName ?? 'Анонимен', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                            const Spacer(),
                            RatingStars(rating: r.rating, size: 14),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(r.comment, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7), height: 1.4)),
                      ],
                    ),
                  )),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
      loading: () => const NatureScaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => NatureScaffold(body: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white)))),
    );
  }

  void _showReviewDialog(BuildContext context, WidgetRef ref, String sellerId) {
    double selectedRating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.cardSurface.withValues(alpha: 0.95),
          title: const Text('Оцени продавача', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Какво е вашето впечатление?', 
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: AppTheme.accentGreen,
                      size: 32,
                    ),
                    onPressed: () => setState(() => selectedRating = index + 1.0),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Споделете мнението си...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Отказ', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  await ref.read(productServiceProvider).submitReview(
                        sellerId: sellerId,
                        rating: selectedRating,
                        comment: commentController.text,
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                  ref.invalidate(sellerProfileProvider(sellerId));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Отзивът е изпратен успешно!')),
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
              child: const Text('Изпрати'),
            ),
          ],
        ),
      ),
    );
  }
}
