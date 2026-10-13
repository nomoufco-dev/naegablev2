import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/domain/entities/product_entity.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../pos/presentation/controllers/pos_controller.dart';

/// Layar Detail Produk Naegablé Bakehaus sesuai spesifikasi Figma (DESIGN_SPEC_FIGMA.md):
/// Chip statistik ("2 Terjual" dll), search, kartu produk dengan toggle "Aktif",
/// seksi "Nonaktif" dengan toggle.
class ProductDetailManagementScreen extends ConsumerStatefulWidget {
  const ProductDetailManagementScreen({super.key});

  @override
  ConsumerState<ProductDetailManagementScreen> createState() => _ProductDetailManagementScreenState();
}

class _ProductDetailManagementScreenState extends ConsumerState<ProductDetailManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchFilter = '';
  // 0 = Semua, 1 = Aktif, 2 = Nonaktif (sesuai tab Figma)
  int _selectedTab = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleProductAvailability(ProductEntity product) async {
    final updated = product.copyWith(isAvailable: !product.isAvailable);
    final repo = ref.read(productRepositoryProvider);
    await repo.saveProduct(updated);
    ref.invalidate(productsListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsListProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceWhite,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18.0),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/pos');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar sesuai Figma
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() => _searchFilter = val.toLowerCase());
                },
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 13.0),
                  suffixIcon: const Icon(Icons.search, color: AppColors.noir),
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9999),
                    borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9999),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9999),
                    borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                  ),
                ),
              ),
            ),

            // Tab chip Semua / Aktif / Nonaktif sesuai Figma
            productsAsync.when(
              data: (products) {
                final filtered = products.where((p) => p.name.toLowerCase().contains(_searchFilter)).toList();
                final activeCount = filtered.where((p) => p.isAvailable).length;
                final inactiveCount = filtered.where((p) => !p.isAvailable).length;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                  child: Row(
                    children: [
                      _buildTabChip('Semua', filtered.length, 0),
                      const SizedBox(width: 8.0),
                      _buildTabChip('Aktif', activeCount, 1),
                      const SizedBox(width: 8.0),
                      _buildTabChip('Nonaktif', inactiveCount, 2),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),

            // Daftar produk
            Expanded(
              child: productsAsync.when(
                data: (products) {
                  final filtered = products.where((p) => p.name.toLowerCase().contains(_searchFilter)).toList();
                  final activeProducts = filtered.where((p) => p.isAvailable).toList();
                  final inactiveProducts = filtered.where((p) => !p.isAvailable).toList();

                  final showActive = _selectedTab == 0 || _selectedTab == 1;
                  final showInactive = _selectedTab == 0 || _selectedTab == 2;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showActive) ...[
                          const Text(
                            'Aktif',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.noir,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          if (activeProducts.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('Tidak ada produk aktif.', style: TextStyle(color: AppColors.textSecondary)),
                            )
                          else
                            ...activeProducts.map((p) => _buildProductDetailCard(p)),
                          const SizedBox(height: 16.0),
                        ],
                        if (showInactive) ...[
                          const Text(
                            'Nonaktif',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.noir,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          if (inactiveProducts.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('Tidak ada produk nonaktif.', style: TextStyle(color: AppColors.textSecondary)),
                            )
                          else
                            ...inactiveProducts.map((p) => _buildProductDetailCard(p)),
                        ],
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chip tab filter sesuai Figma: hitungan + label, aktif = cokelat.
  Widget _buildTabChip(String label, int count, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.surfaceWhite : AppColors.noir,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.0,
                  color: isSelected ? AppColors.surfaceWhite : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Kartu produk sesuai Figma: gambar + info di atas, baris "Aktif"/toggle di bawah kanan.
  Widget _buildProductDetailCard(ProductEntity product) {
    final isActive = product.isAvailable;
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFEAE5E0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Gambar Produk
              Container(
                width: 52.0,
                height: 52.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3EE),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Icon(Icons.bakery_dining, color: AppColors.primary, size: 28.0),
              ),
              const SizedBox(width: 12.0),
              // Info multi-baris sesuai Figma
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.noir,
                      ),
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      'Beli ${CurrencyFormatter.format(product.costPrice)}',
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.noir,
                      ),
                    ),
                    Text(
                      'Jual ${CurrencyFormatter.format(product.price)}',
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.noir,
                      ),
                    ),
                    Text(
                      'Stok ${product.currentStock}',
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          // Baris status + toggle di kanan bawah sesuai Figma
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                isActive ? 'Aktif' : 'Nonaktif',
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.noir,
                ),
              ),
              const SizedBox(width: 8.0),
              Transform.scale(
                scale: 0.85,
                child: CupertinoSwitch(
                  value: isActive,
                  activeTrackColor: AppColors.primary,
                  onChanged: (_) => _toggleProductAvailability(product),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
