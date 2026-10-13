import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/domain/entities/category_entity.dart';
import 'package:pos_naegable/features/pos/presentation/controllers/pos_controller.dart';

/// Layar CRUD Kelola Kategori Menu Naegablé.
class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  void _openCategoryForm(BuildContext context, WidgetRef ref, [CategoryEntity? existing]) {
    final nameController = TextEditingController(text: existing?.name ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text(
            existing == null ? 'Tambah Kategori' : 'Edit Kategori',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Kategori',
              hintText: 'Misal: Artisan Loaf',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnDark,
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final now = DateTime.now();
                final slug = name.toLowerCase().replaceAll(RegExp(r'\s+'), '-');
                final category = CategoryEntity(
                  id: existing?.id ?? 'cat-${now.millisecondsSinceEpoch}',
                  storeId: 'store-main-001',
                  name: name,
                  slug: slug,
                  createdAt: existing?.createdAt ?? now,
                  updatedAt: now,
                );

                final repo = ref.read(categoryRepositoryProvider);
                await repo.saveCategory(category);
                ref.invalidate(categoriesListProvider);
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
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, CategoryEntity category) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text('Hapus Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Yakin ingin menghapus kategori "${category.name}"?'),
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
                final repo = ref.read(categoryRepositoryProvider);
                await repo.deleteCategory(category.id);
                ref.invalidate(categoriesListProvider);
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
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesListProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnDark,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18.0),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    // Empty state sesuai Figma: teks abu-abu terpusat
                    return const Center(
                      child: Text(
                        'Belum ada kategori',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8.0),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: const Color(0xFFE2DDD7)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36.0,
                              height: 36.0,
                              decoration: BoxDecoration(
                                color: AppColors.blush,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Icon(Icons.category_outlined, color: AppColors.primary, size: 20.0),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.noir,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _openCategoryForm(context, ref, cat),
                              icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20.0),
                            ),
                            IconButton(
                              onPressed: () => _confirmDelete(context, ref, cat),
                              icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20.0),
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

            // Tombol "Tambah Kategori" cokelat di bawah sesuai Figma
            Container(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () => _openCategoryForm(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surfaceWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: const Text(
                    'Tambah Kategori',
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
