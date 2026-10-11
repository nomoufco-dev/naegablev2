import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/database/sqlite_service.dart';

/// Service bootstrap untuk inisialisasi asynchronous sebelum `runApp()`.
abstract final class AppBootstrap {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Full-screen edge-to-edge: hilangkan bar hitam sistem di bawah,
    // aplikasi menggambar hingga tepi layar.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // Header aplikasi cokelat tua → ikon status bar putih
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      // Konten bawah terang → ikon nav bar gelap
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    // Mempersiapkan database SQLite lokal dan skema tabel awal
    try {
      final sqliteService = SqliteService();
      await sqliteService.database;
    } catch (e) {
      debugPrint('Bootstrap Database Init Warning: $e');
    }
  }
}
