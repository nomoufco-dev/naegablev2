# Desain Model Data PostgreSQL / Supabase: POS Naegable

Dokumen ini mendefinisikan skema basis data relasional ter-normalisasi untuk aplikasi **Naegablé Bakehaus POS** menggunakan PostgreSQL / Supabase.

> **Catatan Penting:** Dokumen ini merupakan SPESIFIKASI ARSITEKTUR DATA SAJA. Tidak ada file migrasi SQL atau tabel yang dibuat di tahap ini.

---

## 1. Diagram Relasi Entitas (ER Diagram Overview)

```
[stores]
   │
   ├──< [profiles] ──< (user_roles)
   │
   ├──< [categories] ──< [products] ──< [product_variants]
   │                         │                 │
   │                         └──┬──────────────┘
   │                            │
   ├──< [delivery_settings]     ├──< [stock_movements]
   │                            │
   └──< [orders] ───────────────┼──< [order_items]
           │
           └──< [payments]
```

---

## 2. Definisi Skema Tabel

### 2.1 Tabel `stores` (Toko / Cabang)
Menyimpan informasi outlet atau cabang toko roti.
- `id` (UUID, Primary Key, default `gen_random_uuid()`)
- `name` (VARCHAR(100), NOT NULL) — contoh: "Naegablé Bakehaus Central"
- `code` (VARCHAR(20), UNIQUE, NOT NULL) — contoh: "NGB-01"
- `phone` (VARCHAR(20), NULL)
- `address` (TEXT, NULL)
- `is_active` (BOOLEAN, default `true`, NOT NULL)
- `created_at` (TIMESTAMPTZ, default `now()`, NOT NULL)
- `updated_at` (TIMESTAMPTZ, default `now()`, NOT NULL)

### 2.2 Tabel `profiles` (Pengguna / Kasir / Staf)
Menyambung dengan tabel autentikasi Supabase `auth.users`.
- `id` (UUID, Primary Key, Foreign Key -> `auth.users(id)` ON DELETE CASCADE)
- `store_id` (UUID, Foreign Key -> `stores(id)` ON DELETE RESTRICT, NOT NULL)
- `full_name` (VARCHAR(100), NOT NULL)
- `role` (VARCHAR(20), NOT NULL) — Nilai: `'owner'`, `'manager'`, `'cashier'`
- `pin_hash` (VARCHAR(255), NULL) — Untuk fitur login cepat PIN 6 digit kasir
- `phone` (VARCHAR(20), NULL)
- `avatar_url` (TEXT, NULL)
- `is_active` (BOOLEAN, default `true`, NOT NULL)
- `created_at` (TIMESTAMPTZ, default `now()`, NOT NULL)
- `updated_at` (TIMESTAMPTZ, default `now()`, NOT NULL)
- **Index:** `idx_profiles_store_id` on (`store_id`)

### 2.3 Tabel `categories` (Kategori Produk)
Menyimpan kategori produk bakery (misal: Sourdough, Pastry, Croissant, Beverage).
- `id` (UUID, Primary Key, default `gen_random_uuid()`)
- `store_id` (UUID, Foreign Key -> `stores(id)` ON DELETE CASCADE, NOT NULL)
- `name` (VARCHAR(50), NOT NULL)
- `slug` (VARCHAR(60), NOT NULL)
- `sort_order` (INTEGER, default `0`, NOT NULL)
- `is_active` (BOOLEAN, default `true`, NOT NULL)
- `created_at` (TIMESTAMPTZ, default `now()`, NOT NULL)
- `updated_at` (TIMESTAMPTZ, default `now()`, NOT NULL)
- **Constraints:** UNIQUE (`store_id`, `slug`)
- **Index:** `idx_categories_store_order` on (`store_id`, `sort_order`)

### 2.4 Tabel `products` (Katalog Produk Bakery)
Menyimpan data master roti, kue, minuman, dll.
- `id` (UUID, Primary Key, default `gen_random_uuid()`)
- `store_id` (UUID, Foreign Key -> `stores(id)` ON DELETE CASCADE, NOT NULL)
- `category_id` (UUID, Foreign Key -> `categories(id)` ON DELETE SET NULL, NULL)
- `sku` (VARCHAR(50), NULL) — Kode unik stok barang
- `barcode` (VARCHAR(50), NULL) — Barcode scan jika tersedia
- `name` (VARCHAR(100), NOT NULL) — contoh: "Pain au Chocolat"
- `description` (TEXT, NULL)
- `image_url` (TEXT, NULL)
- `price` (NUMERIC(12, 2), NOT NULL, CHECK (`price >= 0`)) — Harga jual
- `cost_price` (NUMERIC(12, 2), default `0`, CHECK (`cost_price >= 0`)) — HPP
- `track_stock` (BOOLEAN, default `true`, NOT NULL) — Kelola stok atau unlimited
- `current_stock` (INTEGER, default `0`, NOT NULL)
- `minimum_stock` (INTEGER, default `5`, NOT NULL) — Threshold alert
- `is_available` (BOOLEAN, default `true`, NOT NULL) — Toggle tampil di kasir
- `created_at` (TIMESTAMPTZ, default `now()`, NOT NULL)
- `updated_at` (TIMESTAMPTZ, default `now()`, NOT NULL)
- **Constraints:** UNIQUE (`store_id`, `sku`)
- **Index:**
  * `idx_products_store_cat` on (`store_id`, `category_id`)
  * `idx_products_search` on (`store_id`, `name`)

### 2.5 Tabel `product_variants` (Varian & Opsi Produk)
Menyimpan varian produk (misal: Ukuran slice/whole, tingkat gula, topping).
- `id` (UUID, Primary Key, default `gen_random_uuid()`)
- `product_id` (UUID, Foreign Key -> `products(id)` ON DELETE CASCADE, NOT NULL)
- `name` (VARCHAR(50), NOT NULL) — contoh: "Whole Loaf", "Slice", "Less Sweet"
- `additional_price` (NUMERIC(12, 2), default `0`, NOT NULL)
- `sku` (VARCHAR(50), NULL)
- `stock` (INTEGER, default `0`, NOT NULL)
- `is_available` (BOOLEAN, default `true`, NOT NULL)
- `created_at` (TIMESTAMPTZ, default `now()`, NOT NULL)
- **Index:** `idx_variants_product` on (`product_id`)

### 2.6 Tabel `delivery_settings` (Konfigurasi Pengiriman Toko)
Menyimpan status dan aturan layanan delivery (sesuai tombol switch pada desain UI).
- `id` (UUID, Primary Key, default `gen_random_uuid()`)
- `store_id` (UUID, UNIQUE, Foreign Key -> `stores(id)` ON DELETE CASCADE, NOT NULL)
- `is_delivery_enabled` (BOOLEAN, default `true`, NOT NULL) — Status ON/OFF
- `delivery_fee_base` (NUMERIC(12, 2), default `10000.00`, NOT NULL)
- `minimum_order_amount` (NUMERIC(12, 2), default `30000.00`, NOT NULL)
- `free_delivery_threshold` (NUMERIC(12, 2), NULL)
- `max_delivery_radius_km` (NUMERIC(5, 2), default `5.00`, NOT NULL)
- `updated_by` (UUID, Foreign Key -> `profiles(id)` ON DELETE SET NULL, NULL)
- `updated_at` (TIMESTAMPTZ, default `now()`, NOT NULL)

### 2.7 Tabel `orders` (Transaksi Kasir / Pesanan)
Menyimpan nota atau transaksi utama POS.
- `id` (UUID, Primary Key, default `gen_random_uuid()`)
- `store_id` (UUID, Foreign Key -> `stores(id)` ON DELETE RESTRICT, NOT NULL)
- `order_number` (VARCHAR(30), NOT NULL) — Format: `NGB-YYYYMMDD-XXXX`
- `cashier_id` (UUID, Foreign Key -> `profiles(id)` ON DELETE SET NULL, NULL)
- `order_type` (VARCHAR(20), NOT NULL) — Nilai: `'dine_in'`, `'takeaway'`, `'delivery'`
- `order_status` (VARCHAR(20), default `'pending'`, NOT NULL)
  — Nilai: `'pending'`, `'processing'`, `'ready'`, `'completed'`, `'cancelled'`
- `customer_name` (VARCHAR(100), NULL)
- `customer_phone` (VARCHAR(20), NULL)
- `delivery_address` (TEXT, NULL)
- `subtotal` (NUMERIC(12, 2), NOT NULL, CHECK (`subtotal >= 0`))
- `discount_amount` (NUMERIC(12, 2), default `0`, NOT NULL)
- `tax_amount` (NUMERIC(12, 2), default `0`, NOT NULL)
- `delivery_fee` (NUMERIC(12, 2), default `0`, NOT NULL)
- `total_amount` (NUMERIC(12, 2), NOT NULL, CHECK (`total_amount >= 0`))
- `notes` (TEXT, NULL)
- `created_at` (TIMESTAMPTZ, default `now()`, NOT NULL)
- `updated_at` (TIMESTAMPTZ, default `now()`, NOT NULL)
- **Constraints:** UNIQUE (`store_id`, `order_number`)
- **Index:**
  * `idx_orders_store_date` on (`store_id`, `created_at` DESC)
  * `idx_orders_status` on (`store_id`, `order_status`)

### 2.8 Tabel `order_items` (Rincian Item Pesanan)
Menyimpan setiap produk yang dipesan dalam transaksi.
- `id` (UUID, Primary Key, default `gen_random_uuid()`)
- `order_id` (UUID, Foreign Key -> `orders(id)` ON DELETE CASCADE, NOT NULL)
- `product_id` (UUID, Foreign Key -> `products(id)` ON DELETE RESTRICT, NOT NULL)
- `variant_id` (UUID, Foreign Key -> `product_variants(id)` ON DELETE SET NULL, NULL)
- `product_name` (VARCHAR(100), NOT NULL) — Snapshot nama saat transaksi
- `unit_price` (NUMERIC(12, 2), NOT NULL) — Snapshot harga saat transaksi
- `quantity` (INTEGER, NOT NULL, CHECK (`quantity > 0`))
- `subtotal` (NUMERIC(12, 2), NOT NULL)
- `notes` (VARCHAR(150), NULL) — Catatan item (misal: "potong 4")
- `created_at` (TIMESTAMPTZ, default `now()`, NOT NULL)
- **Index:** `idx_order_items_order` on (`order_id`)

### 2.9 Tabel `payments` (Pembayaran Transaksi)
Menyimpan riwayat pelunasan transaksi.
- `id` (UUID, Primary Key, default `gen_random_uuid()`)
- `order_id` (UUID, Foreign Key -> `orders(id)` ON DELETE RESTRICT, NOT NULL)
- `store_id` (UUID, Foreign Key -> `stores(id)` ON DELETE RESTRICT, NOT NULL)
- `payment_method` (VARCHAR(20), NOT NULL) — Nilai: `'cash'`, `'qris'`, `'debit'`, `'credit'`, `'transfer'`
- `payment_status` (VARCHAR(20), default `'paid'`, NOT NULL) — Nilai: `'pending'`, `'paid'`, `'failed'`, `'refunded'`
- `amount_tendered` (NUMERIC(12, 2), NOT NULL) — Uang yang diserahkan pembeli
- `change_amount` (NUMERIC(12, 2), default `0`, NOT NULL) — Kembalian
- `reference_number` (VARCHAR(100), NULL) — Kode transaksi QRIS / Approval EDC
- `paid_at` (TIMESTAMPTZ, default `now()`, NOT NULL)
- `created_at` (TIMESTAMPTZ, default `now()`, NOT NULL)
- **Index:** `idx_payments_order` on (`order_id`)

### 2.10 Tabel `stock_movements` (Mutasi & Log Stok)
Menyimpan riwayat keluar-masuk stok secara transparan.
- `id` (UUID, Primary Key, default `gen_random_uuid()`)
- `store_id` (UUID, Foreign Key -> `stores(id)` ON DELETE CASCADE, NOT NULL)
- `product_id` (UUID, Foreign Key -> `products(id)` ON DELETE CASCADE, NOT NULL)
- `variant_id` (UUID, Foreign Key -> `product_variants(id)` ON DELETE CASCADE, NULL)
- `movement_type` (VARCHAR(20), NOT NULL) — Nilai: `'sale'`, `'restock'`, `'waste'`, `'adjustment'`, `'return'`
- `quantity` (INTEGER, NOT NULL) — Nilai minus untuk pengurangan, positif untuk penambahan
- `previous_stock` (INTEGER, NOT NULL)
- `remaining_stock` (INTEGER, NOT NULL)
- `reference_id` (UUID, NULL) — Dapat mereferensikan `order_id`
- `notes` (TEXT, NULL)
- `created_by` (UUID, Foreign Key -> `profiles(id)` ON DELETE SET NULL, NULL)
- `created_at` (TIMESTAMPTZ, default `now()`, NOT NULL)
- **Index:** `idx_stock_product_date` on (`product_id`, `created_at` DESC)

---

## 3. Strategi Row Level Security (RLS) & Akses Kontrol

Untuk melindungi data antar cabang dan membatasi hak akses role:
1. **Multi-Tenant Isolation:**
   - Semua query difilter berdasarkan `store_id` yang sesuai dengan `profiles.store_id` pengguna yang sedang login (`auth.uid()`).
2. **Aturan Hak Akses:**
   - `owner`: Akses penuh (SELECT, INSERT, UPDATE, DELETE) pada semua tabel di tokonya.
   - `manager`: Akses penuh pada produk, kategori, stok, delivery setting, dan order; tidak dapat menghapus profil user lain.
   - `cashier`:
     * SELECT pada `categories`, `products`, `product_variants`, `delivery_settings`.
     * INSERT & SELECT pada `orders`, `order_items`, `payments`, `stock_movements`.
     * UPDATE hanya pada status pesanan berjalan yang ditangani kasir bersangkutan.
     * Tidak memiliki hak akses DELETE pada tabel mana pun.
3. **Public Access:** Dilarang. Tidak ada data POS yang dapat diakses secara anonim tanpa JWT auth.
