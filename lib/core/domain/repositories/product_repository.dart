import '../entities/product_entity.dart';

/// Kontrak abstraksi repositori produk.
/// Didesain agar independen dari backend (dapat menggunakan SQLite lokal sekarang,
/// dan dapat digantikan dengan Supabase di kemudian hari tanpa mengubah UI/Domain).
abstract interface class ProductRepository {
  /// Mengambil semua produk, dengan filter opsional berdasarkan kategori atau pencarian nama.
  Future<List<ProductEntity>> getProducts({
    String? categoryId,
    String? searchQuery,
  });

  /// Mengambil detail satu produk berdasarkan ID uniknya.
  Future<ProductEntity?> getProductById(String id);

  /// Menyimpan produk baru atau memperbarui produk yang sudah ada.
  Future<void> saveProduct(ProductEntity product);

  /// Menghapus produk berdasarkan ID.
  Future<void> deleteProduct(String id);

  /// Memperbarui jumlah stok produk secara atomik (penambahan/pengurangan).
  Future<void> updateStock(String id, int quantityDelta);
}
