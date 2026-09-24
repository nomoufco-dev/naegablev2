# Arsitektur Aplikasi POS Naegable

Dokumen ini mendefinisikan standar arsitektur dan struktur kode untuk aplikasi Point of Sale (POS) **Naegablé Bakehaus**. Arsitektur ini dirancang untuk memastikan skalabilitas, maintainability, pemisahan tanggung jawab (separation of concerns), serta kemudahan pengujian.

---

## 1. Prinsip Utama Arsitektur

1. **Feature-First Organization**
   Kode dikelompokkan berdasarkan modul fitur (domain bisnis), bukan berdasarkan jenis file (seperti menumpuk semua screen dalam satu folder screens/).
2. **Pemisahan Lapisan (Layered Separation)**
   Setiap modul fitur dibagi secara tegas menjadi tiga lapisan:
   - **Presentation Layer**: UI Widgets, Screens, dan ViewState / Controllers.
   - **Domain / Business Logic Layer**: Entities, Value Objects, dan UseCases / Business Rules (independen dari framework UI).
   - **Data Layer**: Data Models (DTO), Data Sources (Supabase Client, Local Storage), dan Implementasi Repositories.
3. **No Database in UI Rule**
   Widget UI dilarang keras memanggil Supabase Client, query SQL, atau REST API secara langsung. Seluruh interaksi data wajib melalui Repository atau Controller/Notifier.
4. **Minimal Entry Point (`main.dart`)**
   File `main.dart` hanya bertugas melakukan bootstrapping environment, inisialisasi dependency dasar (Supabase, local cache, error logging), dan menjalankan root widget (`App`).
5. **Single Responsibility & Ukuran File Terkendali**
   Setiap file Dart dianjurkan berukuran di bawah 250–300 baris. Komponen UI kompleks wajib dipecah menjadi widget modular kecil yang dapat digunakan kembali.

---

## 2. Struktur Direktori Proyek (`lib/`)

```
lib/
├── app/
│   ├── app.dart                       # Root MaterialApp, konfigurasi tema & router
│   ├── app_router.dart                # Deklarasi rute aplikasi (GoRouter)
│   └── app_bootstrap.dart             # Inisialisasi service async sebelum runApp()
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Token warna resmi dari design system
│   │   ├── app_typography.dart        # Token tipografi (Bakehaus script & sans-serif)
│   │   ├── app_spacing.dart           # Token margin, padding, & border radius
│   │   └── app_assets.dart            # Path string aset gambar, ikon, & logo
│   ├── theme/
│   │   └── app_theme.dart             # Konfigurasi ThemeData (Light & Brand Theme)
│   ├── network/
│   │   ├── supabase_client.dart       # Wrapper Supabase Client instance (Anon Key only)
│   │   └── network_exceptions.dart    # Mapping error jaringan & database
│   ├── storage/
│   │   └── local_storage_service.dart # Abstraksi penyimpanan lokal (SharedPreferences / Cache)
│   ├── utils/
│   │   ├── currency_formatter.dart    # Format Rupiah (IDR) presisi
│   │   ├── date_formatter.dart        # Format tanggal & waktu POS
│   │   └── validator.dart             # Validasi input form
│   └── widgets/                       # Komponen UI bersama (Shared Reusable Widgets)
│       ├── custom_app_bar.dart
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── custom_bottom_nav_bar.dart # Notched navigation bar sesuai desain
│       ├── custom_modal_bottom_sheet.dart
│       ├── loading_indicator.dart
│       └── error_view.dart
├── features/
│   ├── splash/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── splash_screen.dart
│   │   │   └── controllers/
│   │   │       └── splash_controller.dart
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_profile_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_profile.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── pin_login_screen.dart
│   │       ├── controllers/
│   │       │   └── auth_controller.dart
│   │       └── widgets/
│   │           └── pin_keypad.dart
│   ├── pos/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── product_remote_datasource.dart
│   │   │   │   └── category_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── product_model.dart
│   │   │   │   ├── category_model.dart
│   │   │   │   └── cart_item_model.dart
│   │   │   └── repositories/
│   │   │       └── pos_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── product.dart
│   │   │   │   ├── category.dart
│   │   │   │   └── cart_item.dart
│   │   │   └── repositories/
│   │   │       └── pos_repository.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── pos_screen.dart    # Tampilan HOME - KASIR PAGE.png
│   │       ├── controllers/
│   │       │   ├── catalog_controller.dart
│   │       │   └── cart_controller.dart
│   │       └── widgets/
│   │           ├── pos_header.dart
│   │           ├── pos_search_bar.dart
│   │           ├── category_filter_bar.dart
│   │           ├── product_grid.dart
│   │           ├── product_card.dart
│   │           ├── bottom_cart_sheet.dart
│   │           └── quick_action_fab.dart
│   ├── management/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── management_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── delivery_settings_model.dart
│   │   │   └── repositories/
│   │   │       └── management_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── delivery_settings.dart
│   │   │   └── repositories/
│   │   │       └── management_repository.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── product_list_screen.dart
│   │       │   ├── category_list_screen.dart
│   │       │   └── delivery_settings_screen.dart
│   │       ├── controllers/
│   │       │   ├── product_crud_controller.dart
│   │       │   ├── category_crud_controller.dart
│   │       │   └── delivery_toggle_controller.dart
│   │       └── widgets/
│   │           ├── quick_management_modal.dart # Desain modal pink
│   │           ├── product_form_dialog.dart
│   │           ├── category_form_dialog.dart
│   │           └── delivery_status_card.dart
│   ├── checkout/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── order_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── order_model.dart
│   │   │   │   └── payment_model.dart
│   │   │   └── repositories/
│   │   │       └── order_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── order.dart
│   │   │   │   └── payment.dart
│   │   │   └── repositories/
│   │   │       └── order_repository.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── checkout_screen.dart
│   │       │   └── payment_success_screen.dart
│   │       ├── controllers/
│   │       │   └── checkout_controller.dart
│   │       └── widgets/
│   │           ├── payment_method_selector.dart
│   │           ├── cash_calculator_keypad.dart
│   │           └── receipt_preview_dialog.dart
│   └── orders/
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── screens/
│           │   ├── active_orders_screen.dart
│           │   └── order_history_screen.dart
│           └── controllers/
│               └── order_history_controller.dart
└── main.dart                          # Entrypoint aplikasi (ultra-ringkas)
```

---

## 3. Rencana Pola State Management

Aplikasi POS membutuhkan manajemen status reaktif untuk:
1. Keranjang belanja (*Cart state*: item, diskon, kuantitas, subtotal).
2. Filter katalog (*Active category, search query, stock status*).
3. Pengaturan operasional (*Delivery status ON/OFF*).
4. Sesi pengguna kasir (*Cashier profile & current branch*).

Pilihan standar arsitektur:
- Gunakan **Flutter Riverpod** (atau **Bloc / Cubit**) untuk memisahkan business logic dari widget rendering.
- State immutable diproduksi oleh `StateNotifier` / `Notifier` dan dikonsumsi widget via reactive listener (`ref.watch` atau `BlocBuilder`).
- State tidak disimpan di dalam `StatefulWidget` kecuali untuk status murni UI lokal (misalnya status animasi atau controller form input text).

---

## 4. Lapisan Akses Data & Supabase Integration

### Flow Akses Data
```
[UI Widget]
    │ (1. User Event: misal Klik Tambah Produk)
    ▼
[Controller / Notifier]
    │ (2. Memanggil UseCase / Repository)
    ▼
[Repository Contract]
    │ (3. Implementasi Repository)
    ▼
[Remote DataSource (SupabaseClient)] ◄──► [Local Cache / Storage]
    │ (4. Eksekusi query dengan RLS)
    ▼
[PostgreSQL Database / Supabase]
```

### Aturan Supabase Client
1. Inisialisasi `SupabaseClient` dibungkus dalam singleton/provider terpusat (`core/network/supabase_client.dart`).
2. Kunci yang digunakan pada client Flutter HANYA **Anon Public Key**. Kunci **Service-Role Key** DILARANG KERAS dimasukkan ke dalam kode Flutter.
3. Hak akses data diamankan melalui **Row Level Security (RLS)** berbasis JWT token user yang login.
4. Setiap operasi jaringan wajib memiliki penanganan timeout, konektivitas terputus, dan pemetaan error ramah pengguna (*user-friendly error message*).

---

## 5. Strategi Reusable UI Components

Untuk menghindari duplikasi styling antar layar:
- Semua tombol utama menggunakan `CustomButton` yang mewarisi warna `#442f2a` (Primary) atau `#f5cbd7` (Accent/FAB).
- Seluruh input text (seperti Search bar dan form dialog) menggunakan `CustomTextField` dengan rounded border seragam (radius 12–24px).
- Bottom sheet menggunakan wrapper standar `CustomModalBottomSheet` yang mendukung header, drag handle, dan background styling yang konsisten.
- Formatter mata uang (`CurrencyFormatter`) wajib digunakan untuk seluruh tampilan harga (contoh: `Rp 25.000`), tidak boleh melakukan formatting manual dengan string concatenation.

---

## 6. Pola File `main.dart` Minimal

File `main.dart` harus dijaga agar tetap bersih:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi environment & service melalui bootstrap
  await AppBootstrap.init();
  
  runApp(const PosNaegableApp());
}
```
Seluruh konfigurasi router, tema Material, dan provider root diletakkan pada `lib/app/app.dart`.
