import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/domain/entities/product_entity.dart';
import '../../../pos/presentation/controllers/pos_controller.dart';

/// Layar / Form Form Tambah & Ubah Produk Naegablé Bakehaus sesuai spesifikasi Figma (DESIGN_SPEC_FIGMA.md):
/// Nama Produk, Harga Beli & Harga Jual berdampingan (prefix "Rp0"), Stok,
/// Kategori dropdown, Gambar (tombol "Kamera"/"Galeri"), Deskripsi Produk (textarea),
/// tombol "Simpan" cokelat sticky bottom.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({
    super.key,
    this.existingProduct,
  });

  final ProductEntity? existingProduct;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descriptionController;

  String? _selectedCategoryId;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _nameController = TextEditingController(text: p?.name ?? '');
    _costPriceController = TextEditingController(text: p != null ? p.costPrice.toInt().toString() : '0');
    _priceController = TextEditingController(text: p != null ? p.price.toInt().toString() : '0');
    _stockController = TextEditingController(text: p != null ? p.currentStock.toString() : '100');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _selectedCategoryId = p?.categoryId;
    _isAvailable = p?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costPriceController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final costPrice = double.tryParse(_costPriceController.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    final description = _descriptionController.text.trim();

    if (name.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama produk dan harga jual valid wajib diisi!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final product = ProductEntity(
      id: widget.existingProduct?.id ?? 'prod-${now.millisecondsSinceEpoch}',
      storeId: 'store-main-001',
      name: name,
      price: price,
      costPrice: costPrice,
      categoryId: _selectedCategoryId,
      sku: widget.existingProduct?.sku ?? 'NGB-${now.millisecondsSinceEpoch.toString().substring(8)}',
      currentStock: stock,
      description: description.isNotEmpty ? description : null,
      isAvailable: _isAvailable,
      createdAt: widget.existingProduct?.createdAt ?? now,
      updatedAt: now,
    );

    final repo = ref.read(productRepositoryProvider);
    await repo.saveProduct(product);
    ref.invalidate(productsListProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Produk "${product.name}" berhasil disimpan!'),
        backgroundColor: AppColors.primary,
      ),
    );

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/products');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesListProvider);
    final categories = categoriesAsync.value ?? [];
    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    final isEdit = widget.existingProduct != null;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Produk' : 'Tambah Produk Baru'),
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
              context.go('/products');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form Card Container
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 8.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Nama Produk
                          const Text(
                            'Nama Produk',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.noir,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'Contoh: Dubai Chewy Cookie',
                              filled: true,
                              fillColor: AppColors.cream,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),

                          // 2. Harga Beli & Harga Jual Berdampingan (Prefix Rp0)
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Harga Beli',
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.noir,
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),
                                    TextField(
                                      controller: _costPriceController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        prefixText: 'Rp0 ',
                                        prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                        filled: true,
                                        fillColor: AppColors.cream,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Harga Jual',
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.noir,
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),
                                    TextField(
                                      controller: _priceController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        prefixText: 'Rp0 ',
                                        prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                        filled: true,
                                        fillColor: AppColors.cream,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),

                          // 3. Stok Produk
                          const Text(
                            'Stok Produk',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.noir,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          TextField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '100',
                              filled: true,
                              fillColor: AppColors.cream,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),

                          // 4. Kategori Dropdown
                          const Text(
                            'Kategori',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.noir,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategoryId,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.cream,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat.id,
                                child: Text(cat.name, style: const TextStyle(fontSize: 13.5)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedCategoryId = val);
                            },
                          ),
                          const SizedBox(height: 16.0),

                          // 5. Gambar (Tombol Kamera & Galeri)
                          const Text(
                            'Gambar Produk',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.noir,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.primary, width: 1.2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Membuka Kamera...')),
                                    );
                                  },
                                  icon: const Icon(Icons.camera_alt_outlined, size: 18.0, color: AppColors.primary),
                                  label: const Text(
                                    'Kamera',
                                    style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.primary, width: 1.2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Membuka Galeri...')),
                                    );
                                  },
                                  icon: const Icon(Icons.photo_library_outlined, size: 18.0, color: AppColors.primary),
                                  label: const Text(
                                    'Galeri',
                                    style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),

                          // 6. Deskripsi Produk Textarea
                          const Text(
                            'Deskripsi Produk',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.noir,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Tuliskan deskripsi produk bakery...',
                              filled: true,
                              fillColor: AppColors.cream,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tombol "Simpan" Cokelat Sticky Bottom
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
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surfaceWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
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
