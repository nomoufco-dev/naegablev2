import '../entities/category_entity.dart';

/// Kontrak abstraksi repositori kategori produk.
abstract interface class CategoryRepository {
  /// Mengambil semua kategori aktif yang terurut berdasarkan `sort_order`.
  Future<List<CategoryEntity>> getCategories();

  /// Mengambil satu kategori berdasarkan ID.
  Future<CategoryEntity?> getCategoryById(String id);

  /// Menyimpan kategori baru atau memperbarui yang ada.
  Future<void> saveCategory(CategoryEntity category);

  /// Menghapus kategori berdasarkan ID.
  Future<void> deleteCategory(String id);
}
