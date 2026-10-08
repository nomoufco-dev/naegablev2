import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/domain/entities/product_entity.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../pos/presentation/controllers/pos_controller.dart';
import 'product_form_screen.dart';

/// Layar Daftar Produk Naegablé Bakehaus sesuai spesifikasi Figma (DESIGN_SPEC_FIGMA.md):
/// Kartu produk: foto kiri, nama, "Beli Rp14.000 / Jual Rp28.000 / Stok: 99",
/// tombol "Ubah" cokelat + menu ⋮; tombol bawah "Tambah Produk Baru".
class ProductManagementScreen extends ConsumerStatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ConsumerState<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends ConsumerState<ProductManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchFilter = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToForm([ProductEntity? existingProduct]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(existingProduct: existingProduct),
      ),
    );
  }

  void _showOverflowMenu(BuildContext context, ProductEntity product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (bottomSheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36.0,
                  height: 4.0,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCDCDC),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  title: const Text('Ubah Produk', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.of(bottomSheetCtx).pop();
                    _navigateToForm(product);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.danger),
                  title: const Text('Hapus Produk', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
                  onTap: () {
                    Navigator.of(bottomSheetCtx).pop();
                    _confirmDelete(product);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(ProductEntity product) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text('Hapus Produk', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Yakin ingin menghapus produk "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.surfaceWhite,
              ),
              onPressed: () async {
                final repo = ref.read(productRepositoryProvider);
                await repo.deleteProduct(product.id);
                ref.invalidate(productsListProvider);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsListProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Daftar Produk'),
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
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() => _searchFilter = val.toLowerCase());
                },
                decoration: InputDecoration(
                  hintText: 'Cari produk bakery...',
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

            // Product List
            Expanded(
              child: productsAsync.when(
                data: (products) {
                  final filtered = products.where((p) {
                    return p.name.toLowerCase().contains(_searchFilter);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada produk yang cocok.', style: TextStyle(color: AppColors.textSecondary)),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10.0),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final costPriceFormatted = CurrencyFormatter.format(item.costPrice);
                      final sellPriceFormatted = CurrencyFormatter.format(item.price);

                      return Container(
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
                            // Foto Kiri
                            Container(
                              width: 52.0,
                              height: 52.0,
                              decoration: BoxDecoration(
                                color: AppColors.cream,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: const Icon(Icons.bakery_dining, color: AppColors.primary, size: 28.0),
                            ),
                            const SizedBox(width: 12.0),

                            // Info Nama & "Beli Rp14.000 / Jual Rp28.000 / Stok: 99"
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.noir,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'Beli $costPriceFormatted / Jual $sellPriceFormatted / Stok: ${item.currentStock}',
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Tombol "Ubah" Cokelat + Menu ⋮
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _navigateToForm(item),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.surfaceWhite,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                  child: const Text(
                                    'Ubah',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_vert, size: 20.0, color: AppColors.primary),
                                  onPressed: () => _showOverflowMenu(context, item),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),

            // Tombol Sticky Bawah: "Tambah Produk Baru"
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8.0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToForm(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surfaceWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 20.0),
                  label: const Text(
                    'Tambah Produk Baru',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.surfaceWhite,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
