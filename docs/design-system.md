# Design System & Visual Specification: Naegablé Bakehaus

Dokumen ini merupakan panduan spesifikasi desain antarmuka (UI/UX) resmi untuk aplikasi **POS Naegablé**. Seluruh token dan spesifikasi diturunkan langsung dari aset desain resmi di `/mnt/d/ai-company/design/pos_naegable`.

---

## 1. Palet Warna (Color Palette)

Berdasarkan `design-system/COLOR PALLETE.png`, identitas visual Naegablé mengusung tema *warm artisanal bakery* dengan empat warna utama:

| Token | Nama Desain | Nilai Hex | Peran & Penggunaan |
| :--- | :--- | :--- | :--- |
| `primary` | **Grey Brown** | `#442F2A` | Warna utama identitas brand. Digunakan untuk background splash screen, header/app bar, container bottom navigation bar, dan teks kontras tinggi di atas latar terang. |
| `accent` | **Blush** | `#F5CBD7` | Warna aksen lembut. Digunakan untuk FAB (+), background modal menu manajemen (action sheet), badge jumlah pesanan, dan elemen interaktif yang butuh sorotan. |
| `background` | **Cream** | `#FFF7EC` | Warna dasar kanvas aplikasi (Scaffold background), latar kartu produk, dan input fields. Memberikan kesan hangat dan ramah di mata dibanding putih polos. |
| `contrast` | **Noir** | `#070D0D` | Hitam pekat netral untuk teks berbobot tebal, batas garis (*border* tegas), dan ikon kontras tinggi. |

### Warna Semantik & Pembantu (Auxiliary Tokens)
| Token | Nilai Hex | Penggunaan |
| :--- | :--- | :--- |
| `surfaceWhite` | `#FFFFFF` | Latar kartu modal, lingkaran ikon pada action sheet, dialog input. |
| `textPrimary` | `#070D0D` | Warna teks utama di atas background Cream atau White. |
| `textSecondary`| `#6B5C57` | Warna teks pendukung, label SKU, dan tanggal riwayat transaksi. |
| `textOnDark`   | `#FFF7EC` | Teks warna Cream untuk keterbacaan di atas background Grey Brown. |
| `borderLight`  | `#E8DCD0` | Garis pembatas kartu produk dan separator list. |
| `success`      | `#2E7D32` | Status delivery aktif (ON), transaksi berhasil, stok aman. |
| `warning`      | `#ED6C02` | Peringatan stok menipis (low stock). |
| `danger`       | `#D32F2F` | Status delivery non-aktif (OFF), produk habis, hapus data. |

---

## 2. Tipografi (Typography)

Sistem tipografi memadukan dua karakter kontras yang mencerminkan *artisanal patisserie*:

### 2.1 Brand Typography (Identitas Toko)
1. **Script Wordmark ("naegablé")**
   - **Gaya:** Cursive / modern calligraphy tulisan tangan lembut dengan aksen tirus (*é*).
   - **Karakter:** All-lowercase, mengalir ramah, sedikit miring ke atas (*upward slant*).
   - **Penggunaan:** Layar Splash Screen, Header Nota Transaksi, dan Brand Banner.
2. **Descriptor Sans ("BAKEHAUS")**
   - **Gaya:** Geometric Sans-Serif modern (contoh: *Montserrat* / *Plus Jakarta Sans*).
   - **Karakter:** All-caps, bobot *Bold/SemiBold*, dengan jarak antarkarakter lebar (*wide letter-spacing / tracking: 0.25–0.30*).
   - **Penggunaan:** Sub-judul di bawah kata "naegablé".

### 2.2 UI & POS Typography (Keterbacaan Operasional Kasir)
Menggunakan keluarga huruf Sans-Serif modern (seperti *Plus Jakarta Sans* atau *Inter*) demi keterbacaan cepat kasir:

| Nama Gaya | Ukuran | Bobot (Weight) | Spasi Baris | Penggunaan |
| :--- | :--- | :--- | :--- | :--- |
| `Header Title` | 24px | Bold (700) | 30px | Judul header "Kasir", Splash title |
| `Sub-header` | 18px | SemiBold (600) | 24px | Judul modal dialog, total checkout |
| `Product Name` | 13px | SemiBold (600) | 16px | Nama produk pada kartu grid |
| `Price Tag` | 13px | Bold (700) | 16px | Harga produk (Rp XX.XXX) |
| `Body Text` | 14px | Regular (400) | 20px | Deskripsi produk, detail pesanan |
| `Caption / SKU`| 11px | Medium (500) | 14px | Kode SKU, status stok, kategori chip |
| `Button Label` | 14px | SemiBold (600) | 18px | Teks tombol aksi, label menu modal |

---

## 3. Sistem Jarak (Spacing Scale)

Sistem layout menggunakan modular scale berbasis kelipatan 4px:
- `spacing-xxs` : 4px  (Jarak ikon dan badge)
- `spacing-xs`  : 8px  (Padding internal kartu produk kecil, spasi baris)
- `spacing-sm`  : 12px (Jarak antar item dalam grid produk)
- `spacing-md`  : 16px (Padding standar halaman / margin layar kiri-kanan)
- `spacing-lg`  : 20px (Padding kartu utama, gap section)
- `spacing-xl`  : 24px (Padding header modal, margin bottom sheet)
- `spacing-xxl` : 32px (Margin top splash screen)

---

## 4. Sistem Sudut Membulat (Border Radius Scale)

Aplikasi Naegablé mengedepankan bentuk tumpul ramah (*soft rounded aesthetic*):
- `radius-xs`   : 6px   (Badge diskon, tag indikator kecil)
- `radius-sm`   : 10px  (Field form, opsi varian produk)
- `radius-md`   : 16px  (Kartu produk dalam grid katalog)
- `radius-lg`   : 24px  (Sudut atas Bottom Sheet keranjang & Dialog Form)
- `radius-pill` : 999px (Search bar, Floating Bottom Nav, Action Row modal pink, FAB)

---

## 5. Spesifikasi Komponen Utama (Component Specifications)

### 5.1 Header Kasir & Search Bar (`screens/HOME - KASIR PAGE.png`)
- **Container:** Background `Grey Brown` (`#442F2A`), padding vertikal 16px, horizontal 16px.
- **Judul:** Teks "Kasir" di posisi tengah, warna `Cream` (`#FFF7EC`), ukuran 22px SemiBold.
- **Search Bar:**
  * Bentuk: Kapsul memanjang (*pill-shaped* `radius-pill`).
  * Latar: Abu-abu muda / Cream (`#F0E8E1`).
  * Ikon: Kaca pembesar di ujung kanan warna `#442F2A`.
  * Placeholder: "Cari produk bakery..." warna `#7A6A65`.
- **Tombol Keranjang (Atas Kanan):**
  * Ikon troli belanja warna `Cream`, dilengkapi badge merah muda jika ada item aktif.

### 5.2 Katalog Produk Grid (3 Kolom)
- **Susunan:** GridView 3 kolom dengan `crossAxisSpacing: 10px` dan `mainAxisSpacing: 10px`.
- **Kartu Produk (`ProductCard`):**
  * Dimensi: Rasio aspect ~0.85 (persegi dengan sudut membulat 14px).
  * Latar: `Surface White` atau `Cream` terang dengan border halus `#E8DCD0`.
  * Konten Kartu:
    1. Area gambar produk di bagian atas (placeholder atau URL gambar bakery).
    2. Nama produk di bawah gambar (maksimal 2 baris, ukuran 12px SemiBold).
    3. Label harga tebal (misal: "Rp 18.000").
    4. Indikator kuantitas jika sudah ada di keranjang (badge angka bulat di pojok kartu).

### 5.3 Notched Floating Bottom Navigation Bar
- **Bentuk:** Bilah mengambang berbentuk kapsul memanjang (*floating pill*) berwarna `Grey Brown` (`#442F2A`).
- **Fitur Khusus:** Terdapat cekungan melengkung (*cutout notch*) di bagian tengah atas untuk menampung tombol FAB.
- **Ikon Navigasi (4 Tab):**
  1. Ikon Keranjang / POS (Aktif)
  2. Ikon Pesanan Berjalan (Bills / Open Orders)
  3. Ikon Riwayat Transaksi (History)
  4. Ikon Laporan Penjualan (Reports)
- **Warna Ikon:** `Cream` (`#FFF7EC`) dengan opacity 60% saat non-aktif, 100% saat aktif.

### 5.4 Floating Action Button (FAB Central)
- **Bentuk:** Lingkaran sempurna (`radius: 56px`).
- **Posisi:** Melayang di dalam notch navigasi bawah.
- **Warna:** Background `Blush Pink` (`#F5CBD7`), Ikon `+` warna `Grey Brown` (`#442F2A`).
- **Interaksi:** Membuka Quick Management Action Sheet atau pesanan manual.

### 5.5 Bottom Cart Sheet (Panel Keranjang Bawah)
- **Latar:** Putih bersih (`#FFFFFF`) dengan sudut atas membulat besar (`24px`).
- **State Ringkas (Collapsed):**
  * Menampilkan total item ("3 Item"), ringkasan subtotal ("Rp 75.000"), dan tombol aksi "Bayar" / "Review".
- **State Luas (Expanded):**
  * Daftar pesanan aktif lengkap dengan tombol kurangi `-`, jumlah, dan tambah `+`.

### 5.6 Quick Management Modal / Action Sheet (`features/CRUD PRODUCT KATEGORY DELIVERY ON OF.png`)
- **Latar Belakang Modal:** Warna penuh `Blush Pink` (`#F5CBD7`) dengan sudut atas melengkung anggun.
- **Header Modal:** Bar putih horizontal sebagai penanda judul menu manajemen.
- **4 Baris Opsi Kapsul (Pill-shaped Rows):**
  * Bentuk: Kapsul panjang warna pink pucat (`#FCEEF2`).
  * Sisi Kiri: Lingkaran putih bersih sebagai tempat ikon:
    1. Row 1: Ikon Produk -> Navigasi ke CRUD Produk.
    2. Row 2: Ikon Kategori -> Navigasi ke CRUD Kategori.
    3. Row 3: Ikon Varian / Opsi Tambahan.
    4. Row 4: Ikon Truk Pengiriman (*Delivery Truck*) -> Pengaturan Delivery ON/OFF.
  * Sisi Kanan: Panah chevron `>` warna `#442F2A`.
- **Tombol Tutup (Dismiss Button):**
  * Tombol bulat putih dengan ikon silang (**X**) tebal di bagian bawah tengah, bersinggungan langsung dengan lekukan bar navigasi.

### 5.7 Delivery Switch Component
- **Status ON:** Background toggle `Success Green` (`#2E7D32`), label "Delivery Aktif".
- **Status OFF:** Background toggle `Grey Brown` / `Danger Red`, label "Delivery Non-Aktif".
