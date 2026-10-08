# TUGAS: Selaraskan Ikon dengan Desain Figma

## Konteks
Repo Flutter `/home/hatch/workspace/naegablev2` (package `pos_naegable`).
Sumber kebenaran ikon: `DESIGN_SPEC_FIGMA.md`.
Baca juga `docs/design-system.md` jika ada bagian tentang ikon.

## Masalah
Ikon di aplikasi belum sesuai dengan Figma. Periksa dan perbaiki SEMUA ikon berikut:

### 1. Bottom Nav (`lib/core/widgets/custom_bottom_nav_bar.dart`) — PRIORITAS
Figma: 5 ikon putih di pill cokelat melayang = **keranjang, struk, [+ pink di tengah], dokumen, grafik**.
Saat ini: storefront, layers, +, history, chart.
Perbaiki menjadi:
- Index 0 (Kasir): `Icons.shopping_cart_outlined` (keranjang)
- Index 1 (Struk/Daftar Pesanan): `Icons.receipt_outlined` (struk)
- Tengah: FAB + lingkaran pink (sudah benar, jangan diubah)
- Index 2 (Dokumen): `Icons.description_outlined` (dokumen)
- Index 3 (Laporan): `Icons.bar_chart_outlined` (grafik — sudah benar)
Pastikan tooltip/label navigasi tetap masuk akal dengan ikon barunya.

### 2. Ikon lain yang harus dicek di seluruh `lib/`:
- Search bar: harus ikon kaca pembesar (`Icons.search`) — perbaiki jika beda
- Tombol back: panah kiri (`Icons.arrow_back_ios_new` atau `Icons.arrow_back`) — samakan di semua layar
- Ikon copy di nomor TRX (Daftar Pesanan, Riwayat): `Icons.copy_outlined` atau `Icons.content_copy_outlined`
- Menu overflow (⋮): `Icons.more_vert` — sudah benar, pertahankan
- Ikon trash/hapus: `Icons.delete_outline` — sudah benar, pertahankan
- Toggle Aktif/Nonaktif produk: gunakan switch iOS-style (CupertinoSwitch) sesuai Figma
- Tombol Kamera/Galeri di form produk: `Icons.camera_alt_outlined` dan `Icons.photo_library_outlined`
- Ikon kategori di chip filter: `Icons.list` atau `Icons.format_list_bulleted`
- Ikon centang sukses: `Icons.check_circle` hijau — sudah benar, pertahankan
- Empty state Kategori: ikon yang ramah (mis. `Icons.category_outlined`)

### 3. Aturan
- Hanya ganti ikon — jangan ubah layout, warna, atau logika.
- Konsisten: satu makna = satu ikon di semua layar (mis. keranjang selalu `shopping_cart_outlined`).
- Setelah selesai jalankan `flutter analyze`, perbaiki error jika ada.
- Jangan commit ke git.

## Laporan akhir
Daftar file yang diubah dan ikon apa yang diganti (sebelum → sesudah).
