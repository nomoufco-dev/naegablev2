# UI Specification: POS Naegablé Bakehaus

Document Version: 1.0.0
Author: Lead Flutter Engineer + UI/UX Reverse Engineer
Status: Approved for Implementation

---

## 1. SCREEN_ID: SCREEN_SPLASH
- **SCREEN_NAME**: Splash Screen
- **PURPOSE**: Layar pembuka (cold-start) menampilkan identitas visual brand artisanal bakery "naegablé BAKEHAUS" sambil mempersiapkan inisialisasi database SQLite dan state lokal.
- **CANVAS**: Mobile Portrait (360x800 – 430x932), Background Solid Deep Espresso Brown (`#442F2A`).
- **LAYOUT**: Centered single unit, full-bleed safe area layout, rasio proporsi vertikal ~48% optical center.
- **COMPONENTS**:
  - `brand_logo_wordmark`: Tulisan kaligrafi "naegablé" warna Blush Pink (`#F5CBD7`), ukuran font 44px.
  - `brand_logo_tagline`: Tulisan all-caps "BAKEHAUS" warna Blush Pink (`#F5CBD7`), ukuran font 14px, letter-spacing 4.5.
  - `loading_indicator`: Indikator pemuatan halus warna Blush Pink saat warm-up SQLite berjalan.
- **TYPOGRAPHY**:
  - Wordmark: Cursive / Calligraphic Serif style (italic, w600, 44px).
  - Subtitle: Geometric Sans-serif uppercase (w700, 14px, letter-spacing: 4.5).
- **COLORS**:
  - Background: `#442F2A` (Grey Brown).
  - Brand Mark: `#F5CBD7` (Blush).
- **SPACING**:
  - Gap antara wordmark dan tagline: 6px.
  - Padding: 0px full screen.
- **ASSETS**:
  - `assets/splash/SPLASH.png`
  - `assets/splash/splash_bg.png`
  - `assets/branding/logo_blush.png`
- **INTERACTION**:
  - Transisi otomatis setelah 2 detik atau setelah database SQLite siap.
  - Tap di layar mempercepat transisi langsung ke `/pos`.
- **NAVIGATION**: Otomatis berpindah rute ke `/pos` (Main POS Screen).
- **STATE**: Inisialisasi service & seeding database SQLite lokal.
- **FLUTTER_MAPPING**: `SplashScreen` widget di `lib/features/splash/presentation/screens/splash_screen.dart`.
- **UNCERTAINTIES**: Tidak ada.

---

## 2. SCREEN_ID: SCREEN_POS_KASIR
- **SCREEN_NAME**: Home - Kasir Page (`HOME - KASIR PAGE.png`)
- **PURPOSE**: Layar operasional kasir utama untuk memilih produk bakery berdasarkan kategori, mencari menu secara instan, mengubah mode tampilan (grid 3-kolom vs 2-kolom), menambah item ke keranjang belanja, melihat ringkasan order aktif, serta memicu checkout.
- **CANVAS**: Mobile Portrait, Background Cream (`#FFF7EC`) dengan header Grey Brown (`#442F2A`).
- **LAYOUT**:
  - Bagian Atas: App Bar solid Grey Brown dengan judul tengah "Kasir", search bar kapsul dengan ikon lup di kanan, dan tombol keranjang di kanan.
  - Bagian Sub-Header: Strip toolbar latar abu-abu/cream lembut (`#F0E8E1`), tombol toggle layout grid/list di sisi kiri, dan deretan chip filter kategori horizontal yang dapat digeser.
  - Bagian Tengah: Header seksi produk ("Daftar Menu") dan Grid Katalog Produk responsif (3-kolom compact atau 2-kolom kartu detail).
  - Bagian Bawah: Bottom Sheet keranjang belanja warna putih bersih (`#FFFFFF`) dengan sudut atas membulat besar (radius 24px) yang menampilkan ringkasan item & tombol Bayar.
  - Bagian Paling Bawah: Floating Bottom Navigation Bar kapsul mengambang warna Grey Brown (`#442F2A`) dengan lekukan notch dan tombol tengah FAB Pink (`+`).
- **COMPONENTS**:
  - `header_app_bar`: Tinggi 110-120px dengan judul "Kasir", action cart icon dengan notification badge kuantitas item.
  - `search_input_pill`: Field input pencarian berbentuk kapsul, latar `#F0E8E1`, teks placeholder "Cari produk...", ikon search kaca pembesar di sisi kanan.
  - `layout_toggle_btn`: Tombol kotak di kiri sub-header dengan ikon layout split/grid `◫`.
  - `category_chips_scroll`: List horizontal chip kategori ("Semua", "Croissant & Pastry", "Sourdough & Loaf", "Sweet Cakes", "Artisan Coffee"). Chip aktif: latar Grey Brown dengan teks Cream; Chip tidak aktif: latar Cream terang dengan teks Noir.
  - `product_card_grid`: Grid kartu produk bakery. Setiap kartu memiliki foto/ilustrasi kue, nama produk, kategori, harga Rupiah, indikator ketersediaan stok, dan tombol cepat tambah `+` dengan badge kuantitas jika sudah ada di keranjang.
  - `bottom_cart_summary_sheet`: Panel keranjang putih membulat:
    - Collapsed: Menampilkan ringkasan total item ("3 Item"), total bayar ("Rp 75.000"), dan tombol "Bayar".
    - Expanded / Tap: Menampilkan daftar lengkap item dengan tombol `-` & `+`, catatan per item, dan tombol proses checkout.
  - `floating_bottom_nav_bar`: Bilah navigasi kapsul melayang dengan 4 tab:
    1. Kasir / Katalog (Ikon Store/Cart)
    2. Master Produk & Kategori (Ikon Dokumen Berkas)
    3. FAB Center (+) warna Blush Pink (`#F5CBD7`): Membuka Quick Management Action Sheet.
    4. Riwayat Transaksi (Ikon Dokumen Jam)
    5. Laporan & Statistik (Ikon Diagram Batang)
- **TYPOGRAPHY**:
  - Judul Header: 22px SemiBold putih.
  - Placeholder & Input: 14px regular.
  - Nama Produk: 12px SemiBold textPrimary.
  - Harga: 13px Bold primary.
  - Total Bayar: 16px Bold textPrimary.
- **COLORS**:
  - Header & Bottom Nav: `#442F2A` (Grey Brown).
  - Canvas: `#FFF7EC` (Cream).
  - Sub-Header & Pill Input: `#F0E8E1` (Surface Muted).
  - FAB (+): `#F5CBD7` (Blush).
  - Cart Sheet: `#FFFFFF` (Surface White).
- **SPACING**:
  - Margin sisi: 12-16px.
  - Card gap: 10px.
  - Sheet top radius: 24px.
  - Floating nav bottom margin: 16px.
- **ASSETS**:
  - `assets/design/HOME - KASIR PAGE.png`
  - `assets/branding/logo_grey_brown.png`
- **INTERACTION**:
  - Mengetik pada search bar memfilter produk secara instan tanpa delay.
  - Mengetuk chip kategori menyaring katalog produk sesuai kategori yang dipilih.
  - Mengetuk tombol toggle grid mengubah tata letak antara 3-kolom dan 2-kolom.
  - Mengetuk kartu produk atau tombol `+` menambahkan item ke keranjang dan memperbarui badge.
  - Mengetuk tombol keranjang atau panel bawah membuka rincian pesanan.
  - Mengetuk tombol FAB pink tengah (`+`) membuka Quick Management Modal.
  - Mengetuk tab navigasi bawah berpindah ke layar/view yang sesuai.
  - Mengetuk tombol "Bayar" membuka dialog/layar Checkout Pembayaran Kasir.
- **NAVIGATION**:
  - Tab 0: PosScreen (Kasir)
  - Tab 1: ProductCatalogManagementScreen (Katalog & CRUD Master)
  - FAB (+): QuickManagementModal (Action Sheet)
  - Tab 2: TransactionHistoryScreen (Riwayat Transaksi)
  - Tab 3: SalesReportScreen (Laporan Penjualan)
- **STATE**:
  - `productListProvider`: List produk dari SQLite.
  - `categoryListProvider`: List kategori dari SQLite.
  - `selectedCategoryIdProvider`: State kategori aktif.
  - `searchQueryProvider`: Query pencarian aktif.
  - `cartStateProvider`: State keranjang belanja aktif (items, quantities, subtotal, tax).
  - `gridColumnsProvider`: 3 atau 2 kolom.
  - `deliveryModeProvider`: Status delivery ON/OFF.
- **FLUTTER_MAPPING**: `PosScreen` di `lib/features/pos/presentation/screens/pos_screen.dart` didukung widget modular.
- **UNCERTAINTIES**: Tidak ada.

---

## 3. SCREEN_ID: MODAL_FEATURE_DRAWER
- **SCREEN_NAME**: Quick Management Action Sheet (`CRUD PRODUCT KATEGORY DELIVERY ON OF.png`)
- **PURPOSE**: Modal menu manajemen cepat berlatar Blush Pink dengan lekukan bawah yang membingkai tombol close bulat putih `✕`, menyediakan akses langsung ke CRUD Produk, CRUD Kategori, Pemilihan Tipe Pesanan (Dine-in / Takeaway), dan Toggle Pengiriman Delivery ON/OFF.
- **CANVAS**: Floating Card / Modal Bottom Sheet berlatar Blush Pink (`#F5CBD7`) dengan sudut melengkung besar (radius 28px).
- **LAYOUT**:
  - Header: Bar indikator putih dan judul menu manajemen ("Menu Manajemen Kasir").
  - Daftar 4 Baris Opsi Kapsul (Pill Rows) berlatar Cream muda (`#FFFDF9`):
    - Row 1: Ikon Produk Bakery di dalam lingkaran putih + Label "Kelola Produk" + Panah Chevron `>`.
    - Row 2: Ikon Kategori di dalam lingkaran putih + Label "Kelola Kategori" + Panah Chevron `>`.
    - Row 3: Ikon Meja / Tipe Pesanan di dalam lingkaran putih + Label "Tipe Pesanan (Dine In / Takeaway)" + Badge status + Panah Chevron `>`.
    - Row 4: Ikon Truk Pengiriman (Delivery Truck) di dalam lingkaran putih + Label "Layanan Delivery" + Switch Toggle ON/OFF aktif.
  - Bagian Bawah: Cekungan notch halus membingkai tombol close bundar putih berisi ikon `✕` warna Grey Brown.
- **COMPONENTS**:
  - `modal_container`: Container Blush Pink `#F5CBD7`.
  - `action_pill_row_1`: Baris Kelola Produk.
  - `action_pill_row_2`: Baris Kelola Kategori.
  - `action_pill_row_3`: Baris Tipe Pesanan.
  - `action_pill_row_4`: Baris Delivery ON/OFF dengan Switch interaktif.
  - `close_button_fab`: Tombol lingkaran putih diameter 56px dengan ikon `Icons.close` di bagian notch bawah.
- **TYPOGRAPHY**:
  - Judul Menu: 18px SemiBold Noir.
  - Label Kapsul: 14px SemiBold Noir.
  - Status Sub-label: 11px Regular Grey Brown.
- **COLORS**:
  - Modal Background: `#F5CBD7` (Blush).
  - Pill Rows: `#FFFDF9` (Pale Cream / Soft White).
  - Icon Badges: `#FFFFFF` (White).
  - Icon & Chevron: `#442F2A` (Grey Brown).
  - Toggle Switch: `#2E7D32` (Success Green saat ON), `#BDBDBD` (saat OFF).
- **SPACING**:
  - Padding modal: 20px horizontal, 24px top, 16px bottom.
  - Jarak antar baris kapsul: 12px.
- **ASSETS**:
  - `assets/design/CRUD PRODUCT KATEGORY DELIVERY ON OF.png`
- **INTERACTION**:
  - Mengetuk Row 1: Membuka layar CRUD Produk (tambah, ubah harga/stok, hapus).
  - Mengetuk Row 2: Membuka dialog/layar CRUD Kategori (tambah kategori, ubah urutan).
  - Mengetuk Row 3: Mengubah tipe pesanan aktif antara Dine-in dan Takeaway.
  - Mengetuk/toggle Row 4: Menyalakan/mematikan mode Delivery, menyimpan langsung ke tabel `delivery_settings` SQLite dan memperbarui state POS.
  - Mengetuk tombol `✕`: Menutup modal dan kembali ke layar kasir.
- **NAVIGATION**: Bottom sheet dismiss / push screen CRUD.
- **STATE**: `deliverySettingsProvider` & `orderTypeProvider`.
- **FLUTTER_MAPPING**: `QuickManagementModal` di `lib/features/pos/presentation/widgets/quick_management_modal.dart`.
- **UNCERTAINTIES**: Tidak ada.

---

## 4. SCREEN_ID: SCREEN_PRODUCT_CRUD
- **SCREEN_NAME**: Kelola Produk (Master Product CRUD)
- **PURPOSE**: Layar manajemen lengkap produk toko Naegablé: melihat semua produk, mencari produk, menambah produk baru, mengedit data produk (nama, harga, kategori, stok), dan menghapus produk dengan persistensi SQLite lokal.
- **CANVAS**: Mobile Portrait, Background Cream (`#FFF7EC`).
- **LAYOUT**: App Bar Grey Brown dengan tombol kembali dan tombol Tambah `+`, daftar list card produk, dan dialog/form modal input produk.
- **COMPONENTS**:
  - `product_list_view`: Daftar kartu produk dengan rincian nama, kategori, harga Rp, sisa stok, status tersedia, tombol edit (pensil), dan tombol hapus (tempat sampah).
  - `add_product_button`: Tombol aksi tambah produk baru.
  - `product_form_dialog`: Form input validasi: Nama Produk, Kategori (Dropdown), Harga Jual, Harga Modal, Stok Awal, dan Switch Ketersediaan.
  - `delete_confirm_dialog`: Dialog konfirmasi sebelum menghapus produk dari database.
- **STATE**: Sinkronisasi penuh dengan `sqliteProductRepositoryProvider` dan state katalog kasir.

---

## 5. SCREEN_ID: SCREEN_CATEGORY_CRUD
- **SCREEN_NAME**: Kelola Kategori (Master Category CRUD)
- **PURPOSE**: Layar manajemen kategori roti/kue/minuman Naegablé: melihat daftar kategori, menambah kategori baru, mengedit nama/urutan, dan menghapus kategori.
- **COMPONENTS**: List card kategori dengan tombol tambah, edit nama, dan hapus kategori, menyimpan langsung ke SQLite.

---

## 6. SCREEN_ID: SCREEN_CHECKOUT_PAYMENT
- **SCREEN_NAME**: Terminal Pembayaran Kasir (Checkout Dialog / Screen)
- **PURPOSE**: Memproses pembayaran transaksi kasir: memilih metode pembayaran (Tunai, QRIS, Debit/EDC), input jumlah uang diterima, tombol nominal cepat uang pas, hitung kembalian otomatis, simpan transaksi ke tabel `orders` & `order_items` SQLite, potong stok produk, dan tampilkan nota bukti transaksi berhasil.
- **COMPONENTS**:
  - Ringkasan pesanan & total bayar.
  - Pilihan metode: Tunai / QRIS / Transfer.
  - Tombol nominal cepat: Uang Pas, Rp 50.000, Rp 100.000, Rp 200.000.
  - Field input uang bayar & display otomatis kembalian.
  - Tombol konfirmasi "Selesaikan Pembayaran".
  - Dialog struk/nota digital dengan detail item, tanggal, nomor order unik (`NGB-YYYYMMDD-XXXX`), dan tombol "Transaksi Baru".

---

## 7. SCREEN_ID: SCREEN_TRANSACTION_HISTORY
- **SCREEN_NAME**: Riwayat Transaksi (Tab History)
- **PURPOSE**: Melihat seluruh riwayat penjualan yang tersimpan di SQLite, melihat detail setiap nota, filter status, dan total omzet.

---

## 8. SCREEN_ID: SCREEN_REPORTS_ANALYTICS
- **SCREEN_NAME**: Laporan & Statistik Penjualan (Tab Reports)
- **PURPOSE**: Visualisasi ringkasan performa toko Naegablé Bakehaus: Total Pendapatan, Jumlah Transaksi, Rata-rata Nilai Pesanan, dan Diagram Batang distribusi penjualan produk/kategori.
