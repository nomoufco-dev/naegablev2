# Tugas Hermes — Perbaikan Riwayat Pesanan Terhapus (naegablev2)

Repo: `~/workspace/naegablev2`, branch `main`, package `pos_naegable`.
Bekerja di direktori repo. Bahasa UI: Indonesia.

## Permintaan Rahmana (3 hal, JANGAN ubah hal lain)

### 1. Pesanan yang dibatalkan masuk ke TOMBOL SAMPAH
- Saat ini `TransactionHistoryScreen` (`lib/features/history/presentation/screens/transaction_history_screen.dart`)
  punya tab "Pesanan Dibatalkan" yang menampilkan order berstatus `cancelled`.
- UBAH: hapus tab "Pesanan Dibatalkan" — tab "Pesanan" hanya menampilkan order yang TIDAK cancelled.
- Order yang dibatalkan (status `cancelled`) HARUS muncul di layar tempat sampah rute `/deleted-orders`
  (`DeletedHistoryScreen`, mode orders). Tombol sampah yang membuka `/deleted-orders` biarkan seperti sekarang.
- HAPUS logika mock di `DeletedHistoryScreen`: filter `orders.indexOf(o) % 2 == 1` harus dibuang —
  hanya tampilkan order yang benar-benar berstatus `cancelled` (atau benar-benar dihapus, sesuai skema data).

### 2. Riwayat terhapus kedaluwarsa 3 bulan
- Banner "Riwayat pesanan masih dapat dilihat hingga 3 bulan terakhir." sudah ada — pertahankan.
- Implementasikan aturannya: item yang umurnya lebih dari 3 bulan (pakai `createdAt`; kalau ada
  kolom waktu hapus/`updatedAt` yang lebih tepat, pakai itu — konsisten dengan skema sqlite yang ada)
  tidak boleh tampil di `DeletedHistoryScreen`. Pilih implementasi yang paling konsisten dengan
  arsitektur repo (filter saat query ATAU hapus permanen dari sqlite saat kedaluwarsa — putuskan
  yang paling bersih, jangan dua-duanya setengah).
- Tulis unit test untuk logika kedaluwarsa 3 bulan ini (batas tepat 3 bulan, lewat 1 hari, dsb).

### 3. Samakan visual dengan PANEL LOGIN
- Layar "Riwayat Pesanan Terhapus" saat ini (AppBar standar + background cream) dinilai
  "jauh dari kata mirip" dengan layar Login.
- Selaraskan dengan `LoginScreen` (`lib/features/auth/presentation/screens/login_screen.dart`):
  nuansa header/background cokelat `AppColors.primary`, kartu putih rounded besar
  (`borderRadius` ~28 seperti kartu login), aksen blush `#F5CBD7`, tombol pill `rounded-full`,
  tipografi konsisten dengan design system di `lib/core/constants/`.
- Hanya visual — JANGAN ubah struktur data, alur, atau fungsi. Banner info pink 3 bulan tetap ada.

## Batasan
- Jangan mengubah layout, warna, teks, atau logika di luar 3 hal di atas.
- Jangan commit file `HERMES_TASK*.md` (abaikan file-file itu).
- Ikuti pola Riverpod + sqlite yang sudah ada di repo. Jangan menambah dependency baru.

## Selesai
- Jalankan `flutter analyze` — harus 0 error.
- Jalankan `flutter test` — semua harus lulus.
- Commit lokal di branch `main` dengan pesan jelas. JANGAN push ke remote.
- Laporkan ringkas: file yang diubah, hasil analyze, hasil test.
