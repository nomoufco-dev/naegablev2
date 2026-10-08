import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/sqlite_category_datasource.dart';

/// Implementasi CategoryRepository berbasis database lokal SQLite.
class SqliteCategoryRepository implements CategoryRepository {
  SqliteCategoryRepository(this._datasource);

  final SqliteCategoryDatasource _datasource;

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final rows = await _datasource.fetchCategories();
    return rows.map(_mapRowToEntity).toList();
  }

  @override
  Future<CategoryEntity?> getCategoryById(String id) async {
    final row = await _datasource.fetchCategoryById(id);
    return row != null ? _mapRowToEntity(row) : null;
  }

  @override
  Future<void> saveCategory(CategoryEntity category) async {
    await _datasource.insertOrUpdateCategory(_mapEntityToRow(category));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _datasource.deleteCategory(id);
  }

  CategoryEntity _mapRowToEntity(Map<String, dynamic> row) {
    return CategoryEntity(
      id: row['id'] as String,
      storeId: row['store_id'] as String,
      name: row['name'] as String,
      slug: row['slug'] as String,
      sortOrder: row['sort_order'] as int? ?? 0,
      isActive: (row['is_active'] as int?) == 1,
      createdAt: row['created_at'] != null ? DateTime.tryParse(row['created_at'] as String) : null,
      updatedAt: row['updated_at'] != null ? DateTime.tryParse(row['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> _mapEntityToRow(CategoryEntity entity) {
    final now = DateTime.now().toIso8601String();
    return {
      'id': entity.id,
      'store_id': entity.storeId,
      'name': entity.name,
      'slug': entity.slug,
      'sort_order': entity.sortOrder,
      'is_active': entity.isActive ? 1 : 0,
      'created_at': entity.createdAt?.toIso8601String() ?? now,
      'updated_at': now,
    };
  }
}
