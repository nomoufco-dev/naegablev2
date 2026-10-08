import 'package:flutter/widgets.dart';
import '../core/database/sqlite_service.dart';

/// Service bootstrap untuk inisialisasi asynchronous sebelum `runApp()`.
abstract final class AppBootstrap {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Mempersiapkan database SQLite lokal dan skema tabel awal
    try {
      final sqliteService = SqliteService();
      await sqliteService.database;
    } catch (e) {
      debugPrint('Bootstrap Database Init Warning: $e');
    }
  }
}
