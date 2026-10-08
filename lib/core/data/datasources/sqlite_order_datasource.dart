import 'package:sqflite/sqflite.dart';
import '../../database/database_constants.dart';
import '../../database/sqlite_service.dart';

/// Data source untuk menangani query tabel orders dan order_items di SQLite.
class SqliteOrderDatasource {
  SqliteOrderDatasource(this._sqliteService);

  final SqliteService _sqliteService;

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final db = await _sqliteService.database;
    return db.query(
      DatabaseConstants.tableOrders,
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> fetchOrderById(String id) async {
    final db = await _sqliteService.database;
    final results = await db.query(
      DatabaseConstants.tableOrders,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> fetchOrderItems(String orderId) async {
    final db = await _sqliteService.database;
    return db.query(
      DatabaseConstants.tableOrderItems,
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> insertCompleteOrder({
    required Map<String, dynamic> orderRow,
    required List<Map<String, dynamic>> itemRows,
    Map<String, dynamic>? paymentRow,
  }) async {
    final db = await _sqliteService.database;
    await db.transaction((txn) async {
      // 1. Simpan order
      await txn.insert(
        DatabaseConstants.tableOrders,
        orderRow,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Simpan order items & kurangi stok produk
      for (final item in itemRows) {
        await txn.insert(
          DatabaseConstants.tableOrderItems,
          item,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        final productId = item['product_id'] as String;
        final qty = item['quantity'] as int;

        // Potong stok produk
        await txn.rawUpdate(
          '''
          UPDATE ${DatabaseConstants.tableProducts}
          SET current_stock = CASE 
            WHEN current_stock >= ? THEN current_stock - ? 
            ELSE 0 
          END,
          updated_at = ?
          WHERE id = ?
          ''',
          [qty, qty, DateTime.now().toIso8601String(), productId],
        );
      }

      // 3. Simpan payment record jika ada
      if (paymentRow != null) {
        await txn.insert(
          DatabaseConstants.tablePayments,
          paymentRow,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> updateOrderStatus(String id, String status) async {
    final db = await _sqliteService.database;
    await db.transaction((txn) async {
      await txn.update(
        DatabaseConstants.tableOrders,
        {
          'order_status': status,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      if (status == 'cancelled') {
        final items = await txn.query(
          DatabaseConstants.tableOrderItems,
          where: 'order_id = ?',
          whereArgs: [id],
        );
        for (final item in items) {
          final productId = item['product_id'] as String;
          final qty = item['quantity'] as int;
          await txn.rawUpdate(
            '''
            UPDATE ${DatabaseConstants.tableProducts}
            SET current_stock = current_stock + ?,
                updated_at = ?
            WHERE id = ?
            ''',
            [qty, DateTime.now().toIso8601String(), productId],
          );
        }
      }
    });
  }

  Future<void> deleteOrder(String id) async {
    final db = await _sqliteService.database;
    await db.transaction((txn) async {
      await txn.delete(
        DatabaseConstants.tableOrderItems,
        where: 'order_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        DatabaseConstants.tableOrders,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}
