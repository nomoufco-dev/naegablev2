# Spesifikasi Fitur: POS Naegable

Dokumen ini mendefinisikan seluruh modul fungsional (fitur), alur pengguna (*user flow*), serta tanggung jawab sistem dalam aplikasi **POS Naegablé Bakehaus**.

---

## 1. Daftar Modul Fitur

Aplikasi terbagi menjadi 8 modul fitur utama:
1. **Modul Splash & Autentikasi Kasir**
2. **Modul POS & Katalog Produk (Home - Kasir)**
3. **Modul Keranjang & Panel Transaksi Aktif**
4. **Modul Quick Action Modal (Menu Manajemen Cepat)**
5. **Modul CRUD Produk & Kategori**
6. **Modul Pengaturan Layanan Delivery (ON / OFF)**
7. **Modul Pembayaran & Checkout (Kasir Terminal)**
8. **Modul Riwayat Pesanan & Laporan Ringkas**

---

## 2. Rincian & Tanggung Jawab Modul Fitur

### 2.1 Modul Splash & Autentikasi Kasir
- **Tanggung Jawab:**
  * Menampilkan identitas visual Naegablé Bakehaus sesuai `SPLASH.png`.
  * Memeriksa keberadaan token sesi login kasir yang tersimpan secara lokal.
  * Menampilkan dialog/layar PIN 6-digit untuk pergantian shift kasir secara cepat dan aman.
- **Alur Kerja:**
  1. Aplikasi dibuka -> Tampil SplashScreen (background Grey Brown `#442F2A`, logo cursive "naegablé BAKEHAUS").
  2. Inisialisasi service async & cache produk (durasi 1.5–2 detik).
  3. Jika sesi aktif -> Navigasi langsung ke `PosScreen`.
  4. Jika belum login atau terkunci -> Tampilkan keypad input PIN kasir.

### 2.2 Modul POS & Katalog Produk (`HOME - KASIR PAGE.png`)
- **Tanggung Jawab:**
  * Menampilkan katalog roti, kue, dan minuman dalam format Grid 3 Kolom yang responsif.
  * Menyediakan kolom pencarian instan (*real-time search*) berdasarkan nama produk atau SKU.
  * Menyediakan baris filter kategori horizontal (misal: "Semua", "Sourdough", "Croissant", "Cakes", "Beverages").
  * Menampilkan status ketersediaan dan indikator stok pada tiap kartu produk.
- **Interaksi Pengguna:**
  * Mengetuk kartu produk menambahkan 1 item ke keranjang aktif.
  * Jika produk memiliki varian, muncul *quick variant selector modal*.
  * Kartu produk menampilkan badge kecil kuantitas jika item tersebut sudah ada di keranjang aktif.

### 2.3 Modul Keranjang & Panel Transaksi Aktif (Bottom Cart Sheet)
- **Tanggung Jawab:**
  * Mengelola state pesanan aktif saat ini (daftar item, varian, kuantitas, catatan).
  * Menghitung subtotal secara otomatis dan akurat.
  * Menyediakan dua mode tampilan:
    - **Collapsed (Bilah Bawah):** Menampilkan ringkasan singkat jumlah item, total harga, dan tombol aksi "Bayar".
    - **Expanded (Bottom Sheet Penuh):** Menampilkan daftar rinci pesanan, tombol penambah `+` dan pengurang `-` kuantitas, tombol hapus item, serta field catatan per-item.

### 2.4 Modul Quick Action Modal (`CRUD PRODUCT KATEGORY DELIVERY ON OF.png`)
- **Tanggung Jawab:**
  * Modal navigasi cepat yang dipicu saat kasir/manajer menekan tombol tengah FAB pink (`+`).
  * Tampil sebagai bottom sheet berwarna Blush Pink (`#F5CBD7`) dengan 4 opsi kapsul:
    1. **Kelola Produk:** Membuka daftar master produk & form tambah produk baru.
    2. **Kelola Kategori:** Membuka dialog pengelolaan kategori (tambah/edit/hapus kategori).
    3. **Kelola Varian:** Membuka pengaturan opsi dan varian harga.
    4. **Layanan Delivery (Ikon Truk):** Membuka kontrol status delivery atau melakukan toggle cepat status operasional pengiriman (ON / OFF).
  * Tombol dismiss silang (**X**) bulat putih di bagian bawah notch untuk menutup modal kembali ke kasir.

### 2.5 Modul CRUD Produk & Kategori
- **Tanggung Jawab:**
  * **Tambah / Edit Produk:**
    * Input nama produk bakery, harga jual, harga modal (HPP).
    * Pilih kategori induk dari dropdown/chips.
    * Input stok awal dan batas minimum peringatan stok habis.
    * Pilihan gambar (URL gambar atau pemilihan dari galeri aset).
    * Toggle ketersediaan produk (Tersedia / Habis).
  * **Hapus Produk:** Dilengkapi konfirmasi dialog untuk mencegah kehilangan data.
  * **Kelola Kategori:** Menambah kategori baru dan mengatur urutan tampilan filter bar kasir.

### 2.6 Modul Pengaturan Layanan Delivery (ON / OFF)
- **Tanggung Jawab:**
  * Mengendalikan status operasional pesanan delivery toko secara real-time.
  * Ketika status **ON**:
    - Kasir dapat memilih opsi "Delivery" pada tipe pesanan.
    - Formulir memasukkan nama pelanggan, nomor telepon, alamat antar, dan kalkulasi otomatis ongkos kirim.
  * Ketika status **OFF**:
    - Opsi pesanan delivery dinonaktifkan di kasir, mencegah pesanan antar masuk saat kurir tidak tersedia atau cuaca buruk.
    - Menampilkan indikator peringatan visual di header jika mode delivery sedang mati.

### 2.7 Modul Pembayaran & Checkout (Kasir Terminal)
- **Tanggung Jawab:**
  * Menyajikan opsi metode pembayaran:
    1. **Tunai (Cash):** Dilengkapi tombol nominal cepat (Uang Pas, Rp 50.000, Rp 100.000, Rp 200.000) dan kalkulator kembalian otomatis.
    2. **QRIS:** Menampilkan QRIS statis/dinamis untuk dipindai oleh pelanggan.
    3. **Kartu Debit / EDC:** Input nomor referensi struk mesin EDC.
  * Mengunci transaksi dan memotong stok produk secara otomatis begitu pembayaran sukses.
  * Menampilkan layar struk / tanda terima sukses dengan opsi cetak nota via printer thermal Bluetooth atau bagikan via WhatsApp.

### 2.8 Modul Riwayat Pesanan & Laporan Ringkas (History & Orders)
- **Tanggung Jawab:**
  * Tab Pesanan Berjalan (Bills): Menampung pesanan yang di-hold (simpan sementara) saat pelanggan masih memilih tambahan kue.
  * Tab Riwayat (History): Menampilkan daftar transaksi yang telah selesai berdasarkan tanggal dan filter kasir.
  * Tab Laporan (Reports): Ringkasan total omzet harian, jumlah pesanan, dan metode pembayaran terpopuler.
