import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'database_constants.dart';

/// Service infrastruktur untuk mengelola siklus hidup koneksi SQLite lokal.
/// Seluruh akses query dibatasi di lapisan datasource/repository,
/// TIDAK BOLEH diakses langsung oleh UI widget.
class SqliteService {
  // ignore: prefer_initializing_formals
  SqliteService({Database? database}) : _database = database;

  Database? _database;

  /// Mengambil instance database aktif, atau menginisialisasinya jika belum dibuka.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, DatabaseConstants.databaseName);

    return openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // 1. Buat Tabel-tabel
    batch.execute(DatabaseConstants.createStoresTable);
    batch.execute(DatabaseConstants.createProfilesTable);
    batch.execute(DatabaseConstants.createCategoriesTable);
    batch.execute(DatabaseConstants.createProductsTable);
    batch.execute(DatabaseConstants.createProductVariantsTable);
    batch.execute(DatabaseConstants.createDeliverySettingsTable);
    batch.execute(DatabaseConstants.createOrdersTable);
    batch.execute(DatabaseConstants.createOrderItemsTable);
    batch.execute(DatabaseConstants.createPaymentsTable);
    batch.execute(DatabaseConstants.createStockMovementsTable);

    // 2. Data Awal (Seed Data)
    final now = DateTime.now().toIso8601String();
    const defaultStoreId = 'store-main-001';

    // Store
    batch.insert(DatabaseConstants.tableStores, {
      'id': defaultStoreId,
      'name': 'Naegablé Bakehaus',
      'code': 'NGB-01',
      'phone': '081234567890',
      'address': 'Jl. Artisan Bakery No. 12',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });

    // Default Profile
    batch.insert(DatabaseConstants.tableProfiles, {
      'id': 'profile-admin-001',
      'store_id': defaultStoreId,
      'full_name': 'Kasir Utama',
      'role': 'cashier',
      'pin_hash': '123456',
      'phone': '081234567890',
      'avatar_url': null,
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });

    // Default Delivery Settings
    batch.insert(DatabaseConstants.tableDeliverySettings, {
      'id': 'delivery-setting-001',
      'store_id': defaultStoreId,
      'is_delivery_enabled': 1,
      'delivery_fee_base': 10000.0,
      'minimum_order_amount': 30000.0,
      'max_delivery_radius_km': 5.0,
      'updated_by': 'profile-admin-001',
      'updated_at': now,
    });

    // Default Categories sesuai HOME - KASIR PAGE TIPE 1 & 2
    final categories = [
      {'id': 'cat-01', 'name': 'Soft Cookies', 'slug': 'soft-cookies', 'sort_order': 1},
      {'id': 'cat-02', 'name': 'Dubai Chewy Cookie', 'slug': 'dubai-chewy-cookie', 'sort_order': 2},
      {'id': 'cat-03', 'name': 'Fudgy Brownies', 'slug': 'fudgy-brownies', 'sort_order': 3},
      {'id': 'cat-04', 'name': 'Croissant & Pastry', 'slug': 'croissant-pastry', 'sort_order': 4},
      {'id': 'cat-05', 'name': 'Artisan Coffee', 'slug': 'artisan-coffee', 'sort_order': 5},
    ];

    for (final cat in categories) {
      batch.insert(DatabaseConstants.tableCategories, {
        'id': cat['id'],
        'store_id': defaultStoreId,
        'name': cat['name'],
        'slug': cat['slug'],
        'sort_order': cat['sort_order'],
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      });
    }

    // Default Starter Products sesuai Desain & Mockup Resmi
    final products = [
      {
        'id': 'prod-01',
        'category_id': 'cat-02',
        'sku': 'NGB-DC-001',
        'name': 'Dubai Chewy Cookie',
        'price': 28000.0,
        'current_stock': 100,
        'image_url': 'assets/branding/dubai_chewy_cookie.png',
      },
      {
        'id': 'prod-02',
        'category_id': 'cat-01',
        'sku': 'NGB-SC-001',
        'name': 'Soft Cookies Classic',
        'price': 25000.0,
        'current_stock': 80,
        'image_url': 'assets/branding/dubai_chewy_cookie.png',
      },
      {
        'id': 'prod-03',
        'category_id': 'cat-03',
        'sku': 'NGB-FB-001',
        'name': 'Fudgy Brownies Slice',
        'price': 30000.0,
        'current_stock': 50,
        'image_url': 'assets/branding/dubai_chewy_cookie.png',
      },
      {
        'id': 'prod-04',
        'category_id': 'cat-04',
        'sku': 'NGB-CR-001',
        'name': 'Butter Croissant',
        'price': 22000.0,
        'current_stock': 25,
        'image_url': null,
      },
      {
        'id': 'prod-05',
        'category_id': 'cat-04',
        'sku': 'NGB-CR-002',
        'name': 'Pain au Chocolat',
        'price': 26000.0,
        'current_stock': 20,
        'image_url': null,
      },
      {
        'id': 'prod-06',
        'category_id': 'cat-05',
        'sku': 'NGB-CF-001',
        'name': 'Caffe Latte',
        'price': 28000.0,
        'current_stock': 50,
        'image_url': null,
      },
    ];

    for (final prod in products) {
      batch.insert(DatabaseConstants.tableProducts, {
        'id': prod['id'],
        'store_id': defaultStoreId,
        'category_id': prod['category_id'],
        'sku': prod['sku'],
        'barcode': null,
        'name': prod['name'],
        'description': null,
        'image_url': prod['image_url'],
        'price': prod['price'],
        'cost_price': (prod['price'] as double) * 0.5,
        'track_stock': 1,
        'current_stock': prod['current_stock'],
        'minimum_stock': 5,
        'is_available': 1,
        'created_at': now,
        'updated_at': now,
      });
    }

    await batch.commit(noResult: true);
  }

  /// Menutup koneksi database.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
