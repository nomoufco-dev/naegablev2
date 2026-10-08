# TUGAS: Navigasi Ikon Struk → Daftar Pesanan

## Konteks
Repo Flutter `/home/hatch/workspace/naegablev2` (package `pos_naegable`).
Sumber desain: `DESIGN_SPEC_FIGMA.md` — bottom nav Figma: keranjang, struk, [+], dokumen, grafik.

## Masalah
Di `lib/features/pos/presentation/screens/pos_screen.dart`, `CustomBottomNavBar.onItemSelected`
hanya mengubah `_currentTabIndex` (state lokal) tanpa navigasi ke mana pun.
Akibatnya ikon struk (index 1) tidak membuka apa-apa.

## Yang harus dilakukan
1. Ikon **struk (index 1)** di bottom nav harus navigasi ke **Daftar Pesanan** (`/orders`
   di GoRouter — layar `order_list_screen.dart`, yaitu daftar PO/pesanan seperti di Figma).
2. Gunakan `context.go('/orders')` (GoRouter) agar konsisten dengan routing aplikasi.
3. Pastikan tombol back dari `/orders` kembali ke `/pos` dengan benar.
4. Jika ada tab lain yang seharusnya navigasi (dokumen → ? grafik → `/reports`?), sesuaikan
   dengan Figma: grafik → Laporan & Statistik (`/reports`). Untuk dokumen, jika Figma tidak
   jelas, arahkan ke `/orders` juga atau biarkan tab lokal — tulis keputusanmu di laporan.
5. Jangan ubah tampilan/visual bottom nav — hanya perilaku navigasinya.

## Aturan
- Ikuti pola GoRouter yang sudah ada di `lib/app/app_router.dart`.
- Jangan merusak navigasi yang sudah jalan (checkout, payment, dll).
- Setelah selesai jalankan `flutter analyze`, perbaiki error jika ada.
- Jangan commit ke git.

## Laporan akhir
File yang diubah dan perilaku navigasi tiap ikon bottom nav setelah perbaikan.
