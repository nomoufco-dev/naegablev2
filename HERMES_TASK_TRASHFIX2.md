# Tugas Hermes — Follow-up trash & Figma (naegablev2)

Repo: `~/workspace/naegablev2`, branch `main`, package `pos_naegable`.
Referensi desain: `DESIGN_SPEC_FIGMA.md` + URL Figma di dalamnya
(https://www.figma.com/design/DMKWd83xBc0feE0QwTfuMw/app). Buka Figma sebagai guest
dan bandingkan frame yang sesuai bila perlu.

## 1. BUG: tombol sampah tidak bisa ditekan [PRIORITAS]
- Di `OrderListScreen` (`lib/features/orders/presentation/screens/order_list_screen.dart`,
  rute `/orders`), tombol sampah di AppBar (`Icons.delete_outline`,
  `onPressed: () => context.push('/deleted-orders')`) dilaporkan tidak merespons saat ditekan.
- Diagnosis akar masalahnya (apakah navigasi, context, atau hal lain) dan perbaiki.
- Pastikan tap tombol sampah membuka `DeletedHistoryScreen` (mode orders) dengan benar.
- Tulis widget test yang membuktikan navigasi tombol sampah berfungsi.

## 2. Samakan dengan FIGMA (bukan dengan login page)
- Koreksi dari tugas sebelumnya: yang diminta Rahmana adalah tampilan yang mirip FIGMA.
- Bandingkan `LoginScreen` (`lib/features/auth/presentation/screens/login_screen.dart`)
  dengan frame Login di Figma, dan sesuaikan hingga mirip (layout, warna, bentuk field/tombol,
  tipografi, spacing).
- Bandingkan `DeletedHistoryScreen`
  (`lib/features/history/presentation/screens/deleted_history_screen.dart`)
  dengan frame Figma untuk layar riwayat/history pesanan, dan sesuaikan hingga mirip
  (tetap pertahankan banner "Riwayat pesanan masih dapat dilihat hingga 3 bulan terakhir."
  dan filter kedaluwarsa 3 bulan yang sudah ada).
- Acuan warna: Cream `#FFF7EC`, Blush `#F5CBD7`, primer `#442F2A`, hijau `#2E9E5B`.

## Batasan
- Jangan ubah logika bisnis: tab "Pesanan Dibatalkan" tetap dihapus, filter 3 bulan tetap jalan,
  pesanan batal tetap masuk tempat sampah.
- Jangan mengubah layar/fitur lain di luar 2 hal di atas.
- Jangan commit file `HERMES_TASK*.md` (abaikan file-file itu).
- Jangan menambah dependency baru.

## Selesai
- `flutter analyze`: 0 error.
- `flutter test`: semua lulus (termasuk test baru navigasi tombol sampah).
- Commit lokal di branch `main` dengan pesan jelas. JANGAN push ke remote.
- Laporkan ringkas: akar masalah tombol sampah + perbaikan, file yang diubah untuk Figma,
  hasil analyze & test.
