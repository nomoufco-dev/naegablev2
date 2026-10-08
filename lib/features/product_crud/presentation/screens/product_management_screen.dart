import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/domain/entities/product_entity.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'package:pos_naegable/features/pos/presentation/controllers/pos_controller.dart';

/// Layar CRUD Kelola Produk Bakery Naegablé.
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

  void _openProductFormDialog([ProductEntity? existingProduct]) {
    final nameController = TextEditingController(text: existingProduct?.name ?? '');
    final priceController = TextEditingController(
      text: existingProduct != null ? existingProduct.price.toStringAsFixed(0) : '',
    );
    final stockController = TextEditingController(
      text: existingProduct != null ? existingProduct.currentStock.toString() : '20',
    );
    String? selectedCategoryId = existingProduct?.categoryId;
    bool isAvailable = existingProduct?.isAvailable ?? true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, child) {
            final categoriesAsync = ref.watch(categoriesListProvider);
            final categories = categoriesAsync.value ?? [];
            if (selectedCategoryId == null && categories.isNotEmpty) {
              selectedCategoryId = categories.first.id;
            }

            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  backgroundColor: AppColors.surfaceWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                  title: Text(
                    existingProduct == null ? 'Tambah Produk Bakery' : 'Edit Produk Bakery',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Produk',
                            hintText: 'Misal: Chocolate Croissant',
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        DropdownButtonFormField<String>(
                          initialValue: selectedCategoryId,
                          decoration: const InputDecoration(labelText: 'Kategori'),
                          items: categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat.id,
                              child: Text(cat.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setDialogState(() => selectedCategoryId = val);
                          },
                        ),
                        const SizedBox(height: 12.0),
                        TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Harga Jual (Rp)',
                            hintText: 'Misal: 25000',
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        TextField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Jumlah Stok',
                            hintText: 'Misal: 15',
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        SwitchListTile.adaptive(
                          title: const Text('Status Tersedia', style: TextStyle(fontSize: 13.0)),
                          value: isAvailable,
                          activeThumbColor: AppColors.success,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            setDialogState(() => isAvailable = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnDark,
                      ),
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final price = double.tryParse(priceController.text.trim()) ?? 0.0;
                        final stock = int.tryParse(stockController.text.trim()) ?? 0;

                        if (name.isEmpty || price <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nama dan harga valid wajib diisi!')),
                          );
                          return;
                        }

                        final now = DateTime.now();
                        final product = ProductEntity(
                          id: existingProduct?.id ?? 'prod-${now.millisecondsSinceEpoch}',
                          storeId: 'store-main-001',
                          name: name,
                          price: price,
                          categoryId: selectedCategoryId,
                          sku: existingProduct?.sku ?? 'NGB-${now.millisecondsSinceEpoch.toString().substring(8)}',
                          currentStock: stock,
                          isAvailable: isAvailable,
                          createdAt: existingProduct?.createdAt ?? now,
                          updatedAt: now,
                        );

                        final repo = ref.read(productRepositoryProvider);
                        await repo.saveProduct(product);
                        ref.invalidate(productsListProvider);

                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                );
              },
            );
          },
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Master Produk'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnDark,
        actions: [
          IconButton(
            onPressed: () => _openProductFormDialog(),
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Produk',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchFilter = val.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Cari dalam daftar produk...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                fillColor: AppColors.surfaceWhite,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color(0xFFE2DDD7)),
                ),
              ),
            ),
          ),

          // Daftar Produk List
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final filtered = products.where((p) {
                  return p.name.toLowerCase().contains(_searchFilter);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada produk yang cocok.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8.0),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: const Color(0xFFE2DDD7)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44.0,
                            height: 44.0,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Icon(Icons.bakery_dining, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.noir,
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  '${CurrencyFormatter.format(item.price)} • Stok: ${item.currentStock}',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _openProductFormDialog(item),
                            icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20.0),
                            tooltip: 'Edit Produk',
                          ),
                          IconButton(
                            onPressed: () => _confirmDelete(item),
                            icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20.0),
                            tooltip: 'Hapus Produk',
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openProductFormDialog(),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primary,
        tooltip: 'Tambah Produk Baru',
        child: const Icon(Icons.add, size: 28.0),
      ),
    );
  }
}
