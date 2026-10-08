import 'package:sqflite/sqflite.dart';
import '../../database/database_constants.dart';
import '../../database/sqlite_service.dart';

/// Data source terisolasi untuk operasi tabel produk pada database SQLite.
/// Seluruh query SQL dienkapsulasi di dalam file ini dan tidak bocor ke luar.
class SqliteProductDatasource {
  SqliteProductDatasource(this._sqliteService);

  final SqliteService _sqliteService;

  Future<List<Map<String, dynamic>>> fetchProducts({
    String? categoryId,
    String? searchQuery,
  }) async {
    final db = await _sqliteService.database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (categoryId != null && categoryId.isNotEmpty) {
      whereClauses.add('category_id = ?');
      whereArgs.add(categoryId);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add('(name LIKE ? OR sku LIKE ?)');
      final term = '%${searchQuery.trim()}%';
      whereArgs.add(term);
      whereArgs.add(term);
    }

    final where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    return db.query(
      DatabaseConstants.tableProducts,
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'name ASC',
    );
  }

  Future<Map<String, dynamic>?> fetchProductById(String id) async {
    final db = await _sqliteService.database;
    final results = await db.query(
      DatabaseConstants.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> insertOrUpdateProduct(Map<String, dynamic> data) async {
    final db = await _sqliteService.database;
    await db.insert(
      DatabaseConstants.tableProducts,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteProduct(String id) async {
    final db = await _sqliteService.database;
    await db.delete(
      DatabaseConstants.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> adjustStock(String id, int quantityDelta) async {
    final db = await _sqliteService.database;
    await db.rawUpdate(
      '''
      UPDATE ${DatabaseConstants.tableProducts}
      SET current_stock = current_stock + ?, updated_at = ?
      WHERE id = ?
      ''',
      [quantityDelta, DateTime.now().toIso8601String(), id],
    );
  }
}
