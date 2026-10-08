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
      backgroundColor: AppColors.cream,
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
            // Section 1: Chip Statistik
            Container(
              color: AppColors.surfaceWhite,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatChip('2 Terjual', Icons.local_fire_department_outlined),
                    const SizedBox(width: 8.0),
                    _buildStatChip('6 Total Produk', Icons.inventory_2_outlined),
                    const SizedBox(width: 8.0),
                    _buildStatChip('Stok Melimpah', Icons.check_circle_outline),
                  ],
                ),
              ),
            ),
            const Divider(height: 1.0, color: Color(0xFFEAE5E0)),

            // Section 2: Search Bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() => _searchFilter = val.toLowerCase());
                },
                decoration: InputDecoration(
                  hintText: 'Cari detail produk...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9999),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Section 3: Lists (Aktif vs Nonaktif)
            Expanded(
              child: productsAsync.when(
                data: (products) {
                  final filtered = products.where((p) => p.name.toLowerCase().contains(_searchFilter)).toList();
                  final activeProducts = filtered.where((p) => p.isAvailable).toList();
                  final inactiveProducts = filtered.where((p) => !p.isAvailable).toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Seksi Produk Aktif
                        const Text(
                          'Produk Aktif',
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
                          ...activeProducts.map((p) => _buildProductDetailCard(p, true)),

                        const SizedBox(height: 20.0),

                        // Seksi Produk Nonaktif
                        const Text(
                          'Nonaktif',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        if (inactiveProducts.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('Tidak ada produk nonaktif.', style: TextStyle(color: AppColors.textSecondary)),
                          )
                        else
                          ...inactiveProducts.map((p) => _buildProductDetailCard(p, false)),
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

  Widget _buildStatChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.0, color: AppColors.primary),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailCard(ProductEntity product, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gambar Produk / Icon
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Icon(Icons.bakery_dining, color: AppColors.primary, size: 26.0),
          ),
          const SizedBox(width: 12.0),

          // Detail Produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: isActive ? AppColors.noir : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  '${CurrencyFormatter.format(product.price)} • Stok: ${product.currentStock}',
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Toggle Status Aktif / Nonaktif
          Column(
            children: [
              Text(
                isActive ? 'Aktif' : 'Nonaktif',
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  color: isActive ? const Color(0xFF2E9E5B) : AppColors.textSecondary,
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: CupertinoSwitch(
                  value: product.isAvailable,
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
