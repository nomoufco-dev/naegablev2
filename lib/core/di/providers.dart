import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/sqlite_category_datasource.dart';
import '../data/datasources/sqlite_delivery_datasource.dart';
import '../data/datasources/sqlite_order_datasource.dart';
import '../data/datasources/sqlite_product_datasource.dart';
import '../data/repositories/sqlite_category_repository.dart';
import '../data/repositories/sqlite_delivery_repository.dart';
import '../data/repositories/sqlite_order_repository.dart';
import '../data/repositories/sqlite_product_repository.dart';
import '../database/sqlite_service.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/delivery_settings_repository.dart';
import '../domain/repositories/order_repository.dart';
import '../domain/repositories/product_repository.dart';

// --- Database & Infrastructure Provider ---

final sqliteServiceProvider = Provider<SqliteService>((ref) {
  final service = SqliteService();
  ref.onDispose(() => service.close());
  return service;
});

// --- SQLite Data Sources ---

final sqliteProductDatasourceProvider = Provider<SqliteProductDatasource>((ref) {
  return SqliteProductDatasource(ref.watch(sqliteServiceProvider));
});

final sqliteCategoryDatasourceProvider = Provider<SqliteCategoryDatasource>((ref) {
  return SqliteCategoryDatasource(ref.watch(sqliteServiceProvider));
});

final sqliteDeliveryDatasourceProvider = Provider<SqliteDeliveryDatasource>((ref) {
  return SqliteDeliveryDatasource(ref.watch(sqliteServiceProvider));
});

final sqliteOrderDatasourceProvider = Provider<SqliteOrderDatasource>((ref) {
  return SqliteOrderDatasource(ref.watch(sqliteServiceProvider));
});

// --- Public Repository Providers (Interface-bound) ---
// Seluruh UI dan Controller HANYA boleh mengonsumsi provider interface ini.
// Saat migrasi ke Supabase, cukup ganti implementasi di bawah ini tanpa menyentuh UI.

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return SqliteProductRepository(ref.watch(sqliteProductDatasourceProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return SqliteCategoryRepository(ref.watch(sqliteCategoryDatasourceProvider));
});

final deliverySettingsRepositoryProvider = Provider<DeliverySettingsRepository>((ref) {
  return SqliteDeliveryRepository(ref.watch(sqliteDeliveryDatasourceProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return SqliteOrderRepository(ref.watch(sqliteOrderDatasourceProvider));
});
