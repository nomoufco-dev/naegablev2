# TUGAS: Implementasi Desain Figma ke Flutter

## Konteks
Kamu bekerja di repo Flutter `/home/hatch/workspace/naegablev2` (package `pos_naegable`),
aplikasi kasir/POS "naegablé BAKEHAUS" (toko cookies, Bahasa Indonesia).
Arsitektur: feature-based clean architecture. Baca dulu:
- `DESIGN_SPEC_FIGMA.md` (spesifikasi desain lengkap dari Figma — SUMBER KEBENARAN untuk UI)
- `docs/architecture.md`, `docs/development-rules.md`, `docs/design-system.md`, `docs/ui-specification.md`
- `lib/app/app_router.dart` (routing GoRouter), `lib/core/constants/app_colors.dart`

## Kondisi saat ini
Fitur yang SUDAH ADA: Splash, Kasir/POS (grid produk, cart sheet, kelola sistem sheet),
Checkout, Daftar Produk, Kelola Kategori, Riwayat Transaksi, Laporan & Statistik.

## Yang harus dikerjakan
1. **Layar Login** (belum ada): background cokelat, kartu putih rounded-3xl berisi logo,
   field Username & Password (bg blush #F5CBD7, rounded-full), link "Forgot Password?" kanan,
   tombol "Login" pink rounded-full. Route `/login`, jadikan entry setelah splash
   (splash → login → pos). Login dummy: tombol Login langsung masuk (tanpa backend auth).
2. **Layar Pembayaran** (belum ada): "Total Pembayaran" hijau besar ±#2E9E5B;
   field Nama Pelanggan (opsional); pill toggle "Tunai"/"QRIS"; field Jumlah Uang;
   hitung Kembalian otomatis; tombol cepat Rp50.000/Rp100.000; tombol "Konfirmasi Pembayaran"
   cokelat → modal sukses (kartu putih rounded-2xl, lingkaran centang hijau,
   tombol "Batal" outline + "OK" cokelat). Terhubung dari Checkout (Bayar Langsung).
3. **Layar Pesanan Berhasil** (belum ada): lingkaran centang hijau besar,
   "Pesanan Berhasil Ditambahkan", kartu info pelanggan, tombol "Cetak Struk Pesanan" cokelat.
4. **Daftar Pesanan** (belum ada): header + search + ikon trash; kartu expandable
   (chip pink "Pesanan Baru", nama pelanggan, TRX + ikon copy, tanggal & antrian,
   jadwal pengambilan, rincian item, total hijau, tombol "Bayar" cokelat,
   menu ⋮ → action sheet "Struk Pesanan"/"Batalkan Pesanan").
5. **Pengaturan Pengiriman** (belum ada): daftar metode (Delivery Order/DO, Cash on Delivery/COD,
   Self Pick-Up) masing-masing dengan toggle iOS-style on/off.
6. **Riwayat Pesanan Terhapus & Riwayat Transaksi Terhapus** (belum ada):
   banner info pink "Riwayat pesanan masih dapat dilihat hingga 3 bulan terakhir.",
   kartu collapsed/expanded.
7. **Detail Produk** (belum ada): chip statistik ("2 Terjual" dll), search,
   kartu produk dengan toggle "Aktif", seksi "Nonaktif" dengan toggle.
8. **Tambah/Ubah Produk**: pastikan form sesuai desain (Nama, Harga Beli & Jual berdampingan
   prefix "Rp0", Stok, Kategori dropdown, Gambar tombol Kamera/Galeri, Deskripsi textarea,
   tombol "Simpan" cokelat). Tambahkan jika belum lengkap.
9. **Selaraskan layar yang sudah ada** (Kasir, Checkout, Daftar Produk, Riwayat, Laporan)
   dengan DESIGN_SPEC_FIGMA.md — warna, radius, spacing, komponen harus cocok.
   Jangan ubah logika bisnis / data layer yang sudah jalan.

## Aturan
- Ikuti `docs/development-rules.md` dan pola arsitektur yang ada (feature-based, sqlite repository).
- Jangan menambah dependensi baru kecuali benar-benar perlu (diskusikan dulu di laporan).
- Semua teks Bahasa Indonesia. Format rupiah via `lib/core/utils/currency_formatter.dart`.
- Daftarkan route baru di `lib/app/app_router.dart`.
- Setelah selesai, jalankan `flutter analyze` dan perbaiki semua error/warning.
- Jangan commit ke git — cukup ubah working tree.

## Laporan akhir
Tulis ringkasan: file yang dibuat/diubah, layar yang selesai, hasil `flutter analyze`,
dan hal yang belum selesai (jika ada).
