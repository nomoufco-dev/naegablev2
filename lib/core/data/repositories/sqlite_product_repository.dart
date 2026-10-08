import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/sqlite_product_datasource.dart';

/// Implementasi ProductRepository berbasis database lokal SQLite.
/// Komponen UI & State controller hanya berinteraksi melalui interface ProductRepository,
/// sehingga repositori ini nantinya dapat dengan mudah digantikan oleh SupabaseProductRepository.
class SqliteProductRepository implements ProductRepository {
  SqliteProductRepository(this._datasource);

  final SqliteProductDatasource _datasource;

  @override
  Future<List<ProductEntity>> getProducts({
    String? categoryId,
    String? searchQuery,
  }) async {
    final rows = await _datasource.fetchProducts(
      categoryId: categoryId,
      searchQuery: searchQuery,
    );
    return rows.map(_mapRowToEntity).toList();
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    final row = await _datasource.fetchProductById(id);
    return row != null ? _mapRowToEntity(row) : null;
  }

  @override
  Future<void> saveProduct(ProductEntity product) async {
    await _datasource.insertOrUpdateProduct(_mapEntityToRow(product));
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _datasource.deleteProduct(id);
  }

  @override
  Future<void> updateStock(String id, int quantityDelta) async {
    await _datasource.adjustStock(id, quantityDelta);
  }

  ProductEntity _mapRowToEntity(Map<String, dynamic> row) {
    return ProductEntity(
      id: row['id'] as String,
      storeId: row['store_id'] as String,
      categoryId: row['category_id'] as String?,
      sku: row['sku'] as String?,
      barcode: row['barcode'] as String?,
      name: row['name'] as String,
      description: row['description'] as String?,
      imageUrl: row['image_url'] as String?,
      price: (row['price'] as num).toDouble(),
      costPrice: (row['cost_price'] as num?)?.toDouble() ?? 0.0,
      trackStock: (row['track_stock'] as int?) == 1,
      currentStock: row['current_stock'] as int? ?? 0,
      minimumStock: row['minimum_stock'] as int? ?? 5,
      isAvailable: (row['is_available'] as int?) == 1,
      createdAt: row['created_at'] != null ? DateTime.tryParse(row['created_at'] as String) : null,
      updatedAt: row['updated_at'] != null ? DateTime.tryParse(row['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> _mapEntityToRow(ProductEntity entity) {
    final now = DateTime.now().toIso8601String();
    return {
      'id': entity.id,
      'store_id': entity.storeId,
      'category_id': entity.categoryId,
      'sku': entity.sku,
      'barcode': entity.barcode,
      'name': entity.name,
      'description': entity.description,
      'image_url': entity.imageUrl,
      'price': entity.price,
      'cost_price': entity.costPrice,
      'track_stock': entity.trackStock ? 1 : 0,
      'current_stock': entity.currentStock,
      'minimum_stock': entity.minimumStock,
      'is_available': entity.isAvailable ? 1 : 0,
      'created_at': entity.createdAt?.toIso8601String() ?? now,
      'updated_at': now,
    };
  }
}
