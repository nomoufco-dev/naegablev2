import 'package:sqflite/sqflite.dart';
import '../../database/database_constants.dart';
import '../../database/sqlite_service.dart';

/// Data source terisolasi untuk tabel pengaturan delivery toko pada SQLite.
class SqliteDeliveryDatasource {
  SqliteDeliveryDatasource(this._sqliteService);

  final SqliteService _sqliteService;

  Future<Map<String, dynamic>?> fetchDeliverySettings() async {
    final db = await _sqliteService.database;
    final results = await db.query(
      DatabaseConstants.tableDeliverySettings,
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateDeliveryStatus(bool isEnabled) async {
    final db = await _sqliteService.database;
    await db.update(
      DatabaseConstants.tableDeliverySettings,
      {
        'is_delivery_enabled': isEnabled ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> saveDeliverySettings(Map<String, dynamic> data) async {
    final db = await _sqliteService.database;
    await db.insert(
      DatabaseConstants.tableDeliverySettings,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
