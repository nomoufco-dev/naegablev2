/// Definisi konstanta nama tabel dan skrip DDL SQLite untuk POS Naegable.
/// Diselaraskan dengan rancangan model data pada `docs/database.md`.
abstract final class DatabaseConstants {
  static const String databaseName = 'pos_naegable.db';
  static const int databaseVersion = 1;

  // --- Nama Tabel ---
  static const String tableStores = 'stores';
  static const String tableProfiles = 'profiles';
  static const String tableCategories = 'categories';
  static const String tableProducts = 'products';
  static const String tableProductVariants = 'product_variants';
  static const String tableDeliverySettings = 'delivery_settings';
  static const String tableOrders = 'orders';
  static const String tableOrderItems = 'order_items';
  static const String tablePayments = 'payments';
  static const String tableStockMovements = 'stock_movements';

  // --- Skrip DDL Pembuatan Tabel (SQLite Compatible) ---

  static const String createStoresTable = '''
    CREATE TABLE $tableStores (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      code TEXT UNIQUE NOT NULL,
      phone TEXT,
      address TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''';

  static const String createProfilesTable = '''
    CREATE TABLE $tableProfiles (
      id TEXT PRIMARY KEY,
      store_id TEXT NOT NULL,
      full_name TEXT NOT NULL,
      role TEXT NOT NULL,
      pin_hash TEXT,
      phone TEXT,
      avatar_url TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (store_id) REFERENCES $tableStores (id) ON DELETE RESTRICT
    );
  ''';

  static const String createCategoriesTable = '''
    CREATE TABLE $tableCategories (
      id TEXT PRIMARY KEY,
      store_id TEXT NOT NULL,
      name TEXT NOT NULL,
      slug TEXT NOT NULL,
      sort_order INTEGER NOT NULL DEFAULT 0,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (store_id) REFERENCES $tableStores (id) ON DELETE CASCADE
    );
  ''';

  static const String createProductsTable = '''
    CREATE TABLE $tableProducts (
      id TEXT PRIMARY KEY,
      store_id TEXT NOT NULL,
      category_id TEXT,
      sku TEXT UNIQUE,
      barcode TEXT,
      name TEXT NOT NULL,
      description TEXT,
      image_url TEXT,
      price REAL NOT NULL,
      cost_price REAL NOT NULL DEFAULT 0,
      track_stock INTEGER NOT NULL DEFAULT 1,
      current_stock INTEGER NOT NULL DEFAULT 0,
      minimum_stock INTEGER NOT NULL DEFAULT 5,
      is_available INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (store_id) REFERENCES $tableStores (id) ON DELETE CASCADE,
      FOREIGN KEY (category_id) REFERENCES $tableCategories (id) ON DELETE SET NULL
    );
  ''';

  static const String createProductVariantsTable = '''
    CREATE TABLE $tableProductVariants (
      id TEXT PRIMARY KEY,
      product_id TEXT NOT NULL,
      name TEXT NOT NULL,
      additional_price REAL NOT NULL DEFAULT 0,
      sku TEXT,
      stock INTEGER NOT NULL DEFAULT 0,
      is_available INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      FOREIGN KEY (product_id) REFERENCES $tableProducts (id) ON DELETE CASCADE
    );
  ''';

  static const String createDeliverySettingsTable = '''
    CREATE TABLE $tableDeliverySettings (
      id TEXT PRIMARY KEY,
      store_id TEXT UNIQUE NOT NULL,
      is_delivery_enabled INTEGER NOT NULL DEFAULT 1,
      delivery_fee_base REAL NOT NULL DEFAULT 10000.0,
      minimum_order_amount REAL NOT NULL DEFAULT 30000.0,
      max_delivery_radius_km REAL NOT NULL DEFAULT 5.0,
      updated_by TEXT,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (store_id) REFERENCES $tableStores (id) ON DELETE CASCADE
    );
  ''';

  static const String createOrdersTable = '''
    CREATE TABLE $tableOrders (
      id TEXT PRIMARY KEY,
      store_id TEXT NOT NULL,
      order_number TEXT UNIQUE NOT NULL,
      cashier_id TEXT,
      order_type TEXT NOT NULL,
      order_status TEXT NOT NULL DEFAULT 'pending',
      customer_name TEXT,
      customer_phone TEXT,
      delivery_address TEXT,
      subtotal REAL NOT NULL,
      discount_amount REAL NOT NULL DEFAULT 0,
      tax_amount REAL NOT NULL DEFAULT 0,
      delivery_fee REAL NOT NULL DEFAULT 0,
      total_amount REAL NOT NULL,
      notes TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (store_id) REFERENCES $tableStores (id) ON DELETE RESTRICT,
      FOREIGN KEY (cashier_id) REFERENCES $tableProfiles (id) ON DELETE SET NULL
    );
  ''';

  static const String createOrderItemsTable = '''
    CREATE TABLE $tableOrderItems (
      id TEXT PRIMARY KEY,
      order_id TEXT NOT NULL,
      product_id TEXT NOT NULL,
      variant_id TEXT,
      product_name TEXT NOT NULL,
      unit_price REAL NOT NULL,
      quantity INTEGER NOT NULL,
      subtotal REAL NOT NULL,
      notes TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (order_id) REFERENCES $tableOrders (id) ON DELETE CASCADE,
      FOREIGN KEY (product_id) REFERENCES $tableProducts (id) ON DELETE RESTRICT
    );
  ''';

  static const String createPaymentsTable = '''
    CREATE TABLE $tablePayments (
      id TEXT PRIMARY KEY,
      order_id TEXT NOT NULL,
      store_id TEXT NOT NULL,
      payment_method TEXT NOT NULL,
      payment_status TEXT NOT NULL DEFAULT 'paid',
      amount_tendered REAL NOT NULL,
      change_amount REAL NOT NULL DEFAULT 0,
      reference_number TEXT,
      paid_at TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (order_id) REFERENCES $tableOrders (id) ON DELETE RESTRICT,
      FOREIGN KEY (store_id) REFERENCES $tableStores (id) ON DELETE RESTRICT
    );
  ''';

  static const String createStockMovementsTable = '''
    CREATE TABLE $tableStockMovements (
      id TEXT PRIMARY KEY,
      store_id TEXT NOT NULL,
      product_id TEXT NOT NULL,
      variant_id TEXT,
      movement_type TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      previous_stock INTEGER NOT NULL,
      remaining_stock INTEGER NOT NULL,
      reference_id TEXT,
      notes TEXT,
      created_by TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (store_id) REFERENCES $tableStores (id) ON DELETE CASCADE,
      FOREIGN KEY (product_id) REFERENCES $tableProducts (id) ON DELETE CASCADE
    );
  ''';
}
