# SPESIFIKASI DESAIN — "naegablé BAKEHAUS"
Aplikasi kasir/POS + manajemen toko cookies, Bahasa Indonesia.
Sumber: Figma (dibaca sebagai guest, tanpa login — nilai hex selain yang bertanda ✓ adalah estimasi visual).

## Daftar Layar (39 frame, iPhone 17 402×874)
- Splash | Login
- Kasir (varian: grid/list/cart sheet/Kelola Sistem sheet)
- Checkout (varian: Bayar Langsung / Buat Pesanan / Ongkos Kirim on/off / Jadwal Ambil)
- Pembayaran (+ modal sukses) | Pesanan Berhasil
- Daftar Pesanan (collapsed/expanded/action sheet)
- Riwayat Pesanan Terhapus | Riwayat Transaksi | Riwayat Transaksi Terhapus
- Laporan & Statistik | Daftar Produk | Tambah Produk | Ubah Produk | Detail Produk
- Kelola Kategori | Pengaturan Pengiriman

## Design System
**Palet warna:**
- Cream #FFF7EC ✓ (background utama)
- Blush #F5CBD7 ✓ (chip aktif, field login, sheet)
- Cokelat tua ±#3E2B23 (estimasi — background Splash/Login, header semua layar, tombol primer, bottom nav, teks logo)
- Putih #FFFFFF (kartu, input, teks di atas cokelat)
- Hijau ±#2E9E5B (estimasi — teks "Stock: 100", total harga)
- Pink muda (info banner)

**Tipografi:** Sans-serif rounded modern (visual mirip Plus Jakarta Sans).
Logo "naegablé" font script/kaligrafi; "BAKEHAUS" caps kecil letter-spaced.
Hierarki: judul layar ~20-22px bold putih di header; nama produk ~14-16px semibold;
harga ~16px bold; label kecil abu-abu ~12px.

**Komponen reusable:**
1. Header cokelat, judul putih tengah, tombol back panah kiri (opsional)
2. Search bar putih rounded-full + ikon kaca pembesar
3. Chip kategori pill — aktif: bg blush teks cokelat; nonaktif: putih ber-border
4. Tombol primer pill cokelat teks putih full-width sticky bawah
   ("Bayar Langsung", "Konfirmasi Pembayaran", "Simpan", "Buat Pesanan", "Cetak Struk Pesanan")
5. Tombol pink ("Login", "+")
6. Bottom nav: floating pill cokelat rounded-full, 5 ikon putih —
   keranjang, struk, tombol + lingkaran pink menonjol di tengah, dokumen, grafik
   (saat sheet terbuka, + berubah jadi X)
7. Bottom sheet "Kelola Sistem": sheet blush rounded-atas, judul + tombol X,
   4 menu (Daftar Produk, Detail, Kategori, Pengiriman) — ikon lingkaran putih + label + chevron kanan
8. Toggle switch iOS-style
9. Info banner pink rounded: "Riwayat pesanan masih dapat dilihat hingga 3 bulan terakhir."
10. Modal sukses: kartu putih rounded-2xl, lingkaran centang hijau,
    tombol "Batal" (outline) + "OK" (cokelat)

## Deskripsi per Layar
- **Splash:** Full-screen cokelat, logo script cream "naegablé" tengah + "BAKEHAUS" caps kecil di bawahnya.
- **Login:** Background cokelat; kartu putih rounded-3xl (lebih sempit dari layar, sudut atas sangat membulat)
  berisi logo, field Username & Password (bg blush, rounded-full, placeholder),
  link "Forgot Password?" rata kanan, tombol "Login" pink rounded-full.
- **Kasir:** Header cokelat "Kasir" + ikon keranjang; search bar putih; chip kategori horizontal
  (ikon list, "Soft Cookies", "Dubai Chewy Cookie" aktif pink, "Fudgy Brownies"); judul seksi;
  kartu produk: (grid) foto rounded + nama + "Stock: 100" hijau + "Rp28.000" bold + tombol pill cokelat
  "add to chart", atau (list) foto kiri + info kanan + stepper "− 2 +".
  Cart bar pink mengambang "2 Items Rp56.000 Checkout (1)"; bottom nav cokelat.
- **Checkout:** Back + judul "Checkout"; kartu putih "Metode Pemesanan" berisi dua pill toggle
  "Bayar Langsung" (aktif cokelat) / "Buat Pesanan"; baris "Ongkos Kirim" + toggle
  (saat on: field alamat + ongkos Rp30.000); kartu "Rincian Pesanan": item
  "Dubai Chewy Cookie Rp28.000 X 2 → Rp56.000", "Total Pesanan Rp56.000", "Total Rp56.000" hijau;
  tombol bawah cokelat ("Bayar Langsung"/"Buat Pesanan");
  varian Buat Pesanan menambah field Nama Pelanggan, toggle "Jadwal Ambil", picker "Pilih Tanggal"/"Pilih Waktu".
- **Pembayaran:** "Total Pembayaran Rp56.000" hijau besar; field "Nama Pelanggan" (opsional);
  pill "Tunai"/"QRIS"; field "Jumlah Uang" (Rp58.000), "Kembalian" (Rp0);
  tombol cepat "Rp50.000"/"Rp100.000"; tombol "Konfirmasi Pembayaran".
  Modal sukses: "Pembayaran Rp56.000" + teks konfirmasi + tombol Batal/OK.
- **Pesanan Berhasil:** Lingkaran centang hijau besar, "Pesanan Berhasil Ditambahkan",
  kartu info pelanggan ("Gaby" + alamat), tombol "Cetak Struk Pesanan" cokelat.
- **Daftar Pesanan:** Header + search + ikon trash; kartu pesanan expandable: chip pink "Pesanan Baru",
  nama pelanggan, "TRX20261002-001" + ikon copy, "02 Okt 2026 11:00 - Antrian 01",
  "Jadwal Pengambilan: ...", rincian item, total hijau, tombol "Bayar" cokelat +
  menu overflow (⋮) → action sheet "Struk Pesanan"/"Batalkan Pesanan".
- **Riwayat Pesanan Terhapus & Riwayat Transaksi Terhapus:** Back + judul; banner info pink;
  kartu collapsed ("Dihapus: 02 Okt 2026 19:00", chip "Pesanan Baru", nama, TRX) /
  expanded (rincian + total hijau).
- **Riwayat Transaksi:** Search + ikon trash; kartu transaksi expandable (tanggal, nama, TRX + copy, "Rp56.000" bold).
- **Laporan & Statistik:** Hero card cokelat rounded: "Total Pendapatan Toko" (pink kecil),
  "Rp64.000" (putih besar), "1 Transaksi Berhasil - 2 Produk Terjual";
  dua kartu statik "Total Transaksi: 2" & "Rata-rata Order: Rp64.000";
  seksi "Distribusi Produk Terjual" dengan baris produk + progress bar pink
  ("Dubai Chewy Cookie 2 pcs", "Classic OG Soft Cookies 1 pcs").
- **Daftar Produk:** Kartu produk: foto kiri, nama, "Beli Rp14.000 / Jual Rp28.000 / Stok: 99",
  tombol "Ubah" cokelat + menu ⋮; tombol bawah "Tambah Produk Baru".
- **Tambah/Ubah Produk:** Form: Nama Produk, Harga Beli & Harga Jual berdampingan (prefix "Rp0"),
  Stok, Kategori (dropdown "Contoh: Soft Cookies"), Gambar (tombol "Kamera"/"Galeri"),
  Deskripsi Produk (textarea); tombol "Simpan" cokelat.
- **Detail Produk:** Chip statistik ("2 Terjual" dll), search, kartu produk dengan toggle "Aktif",
  seksi "Nonaktif" dengan toggle.
- **Kelola Kategori:** Empty state "Belum ada kategori" + tombol "Tambah Kategori" cokelat.
- **Pengaturan Pengiriman:** Daftar metode (Delivery Order/DO, Cash on Delivery/COD, Self Pick-Up)
  masing-masing dengan toggle on/off.

## Catatan implementasi Flutter
- Pola umum: Scaffold bg cream/putih, AppBar/header custom cokelat rounded-bawah,
  konten kartu putih rounded-2xl dengan margin ±16, tombol bawah sticky full-width dengan padding.
- Radius umum: kartu ~16-24px, pill/chip/input ~full (30px+), bottom nav pill mengambang.
