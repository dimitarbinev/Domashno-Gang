import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../shared/providers/providers.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/nature_scaffold.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _priceController = TextEditingController();
  Product? _selectedProduct;
  String? _selectedCity;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _pickDate(bool isStart) async {
    final now = DateTime.now();
    final initialDate = isStart 
        ? now.add(const Duration(days: 1))
        : (_startDate?.add(const Duration(days: 1)) ?? now.add(const Duration(days: 2)));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
      builder: (ctx, child) => Theme(
        data: AppTheme.darkTheme.copyWith(
          colorScheme: AppTheme.darkTheme.colorScheme.copyWith(
            primary: AppTheme.primaryGreen,
            surface: AppTheme.cardSurface,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
          if (_endDate != null && _endDate!.isBefore(date)) {
            _endDate = date.add(const Duration(days: 1));
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _handleCreate() async {
    if (_selectedProduct == null ||
        _selectedCity == null ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Моля, попълнете всички полета')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(productServiceProvider).confirmListing(
            productId: _selectedProduct!.id,
            city: _selectedCity!,
            startDate: _startDate!,
            endDate: _endDate!,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Обявата е създадена успешно')),
        );
        context.go('/seller/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Неуспешно създаване: ${e.toString()}')),
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
    final productsAsync = ref.watch(sellerProductsProvider);

    return NatureScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.go('/seller/dashboard'),
        ),
        title: const Text('Създай обява'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: glassDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFieldLabel('Избери продукт'),
              productsAsync.when(
                data: (products) => DropdownButtonFormField<Product>(
                  initialValue: _selectedProduct,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Продукт').copyWith(
                    prefixIcon: const Icon(Icons.eco, size: 20, color: AppTheme.accentGreen),
                  ),
                  dropdownColor: Colors.black87,
                  items: products
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.name, style: const TextStyle(color: Colors.white))))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedProduct = v;
                      if (v != null) {
                        _priceController.text = v.pricePerKg.toStringAsFixed(2);
                      }
                    });
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Грешка при зареждане: $err',
                    style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 18),

              _buildFieldLabel('Град'),
              DropdownButtonFormField<String>(
                initialValue: _selectedCity,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Избери град').copyWith(
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: AppTheme.accentGreen),
                ),
                dropdownColor: Colors.black87,
                items: AppConstants.cities
                    .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white))))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCity = v),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Начална дата'),
                        GestureDetector(
                          onTap: () => _pickDate(true),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18, color: AppTheme.accentGreen),
                                const SizedBox(width: 12),
                                Text(
                                  _startDate != null
                                      ? DateFormat('MMM d, y').format(_startDate!)
                                      : 'Начало',
                                  style: TextStyle(
                                    color: _startDate != null
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.3),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Крайна дата'),
                        GestureDetector(
                          onTap: () => _pickDate(false),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18, color: AppTheme.accentGreen),
                                const SizedBox(width: 12),
                                Text(
                                  _endDate != null
                                      ? DateFormat('MMM d, y').format(_endDate!)
                                      : 'Край',
                                  style: TextStyle(
                                    color: _endDate != null
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.3),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
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
                      : const Text('Създай обява',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.accentGreen, width: 1),
      ),
    );
  }
}
