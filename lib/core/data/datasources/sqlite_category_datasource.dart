import 'package:sqflite/sqflite.dart';
import '../../database/database_constants.dart';
import '../../database/sqlite_service.dart';

/// Data source terisolasi untuk operasi tabel kategori pada SQLite.
class SqliteCategoryDatasource {
  SqliteCategoryDatasource(this._sqliteService);

  final SqliteService _sqliteService;

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final db = await _sqliteService.database;
    return db.query(
      DatabaseConstants.tableCategories,
      where: 'is_active = 1',
      orderBy: 'sort_order ASC, name ASC',
    );
  }

  Future<Map<String, dynamic>?> fetchCategoryById(String id) async {
    final db = await _sqliteService.database;
    final results = await db.query(
      DatabaseConstants.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> insertOrUpdateCategory(Map<String, dynamic> data) async {
    final db = await _sqliteService.database;
    await db.insert(
      DatabaseConstants.tableCategories,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await _sqliteService.database;
    await db.delete(
      DatabaseConstants.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
