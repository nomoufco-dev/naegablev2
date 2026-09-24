# Panduan & Aturan Pengembangan (Development Rules)

Dokumen ini berisi kumpulan instruksi ketat (*strict guidelines*) untuk seluruh proses pengembangan aplikasi **POS Naegablé**, khususnya saat menggunakan AI Coding Assistant / Automated Agents. Setiap kontributor wajib mematuhi aturan berikut demi menjaga kebersihan, stabilitas, dan keamanan kode.

---

## 1. Aturan Struktur & Batasan Ukuran File

1. **Dilarang Membuat File yang Tidak Diperlukan**
   - Jangan membuat file sampel, file duplikat, file backup manual (misal: `main_old.dart`, `test2.dart`), atau file placeholder kosong.
   - Buat file hanya jika memang direncanakan dalam arsitektur resmi (`docs/architecture.md`).
2. **Dilarang Membuat File Raksasa (No Giant Files)**
   - Setiap file Dart dibatasi maksimal **250–300 baris kode**.
   - Jika suatu widget atau controller membengkak melampaui batas ini, wajib dipecah menjadi sub-komponen terpisah di direktori `widgets/` atau controller modular.
3. **File `main.dart` Wajib Minimal**
   - `main.dart` dilarang memuat UI logic, tema langsung, atau logika navigasi.
   - Hanya boleh berisi `runApp()` dan pemanggilan inisialisasi asynchronous `AppBootstrap.init()`.

---

## 2. Aturan Design System & Styling

1. **Dilarang Melakukan Hardcode Warna (No Hardcoded Hex Colors)**
   - Dilarang menulis `Color(0xFF442F2A)` atau `Colors.brown` di dalam widget.
   - Seluruh warna WAJIB menggunakan konstanta resmi dari `AppColors` (misal: `AppColors.primary`, `AppColors.accent`, `AppColors.cream`, `AppColors.noir`).
2. **Dilarang Melakukan Hardcode Tipografi & Spacing**
   - Gunakan `AppTypography` untuk gaya teks, ukuran, dan ketebalan font.
   - Gunakan `AppSpacing` untuk padding, margin, dan border radius (hindari angka acak seperti `padding: EdgeInsets.all(17.3)`).
3. **Format Mata Uang Terpusat**
   - Tampilan nominal harga dilarang menggunakan string manual (seperti `'Rp ' + price.toString()`).
   - Selalu gunakan helper `CurrencyFormatter.format(amount)` agar seragam dengan format Rupiah baku (contoh: `Rp 25.000`).

---

## 3. Aturan Arsitektur Data & Keamanan

1. **Dilarang Meletakkan Query Database Langsung di Widget UI**
   - Widget Flutter dilarang memanggil `Supabase.instance.client` atau melakukan query tabel langsung di dalam method `build()` atau event callback widget.
   - Seluruh akses data WAJIB melalui **Repository** dan diarahkan melalui **Controller / Notifier**.
2. **Dilarang Menanam Kunci Rahasia / Service-Role Key**
   - Klien Flutter hanya boleh memegang **Supabase Anon Public Key**.
   - Dilarang keras memasukkan **Supabase Service-Role Key** ke dalam kode aplikasi, repositori Git, atau konfigurasi mobile client.
   - Akses data dibatasi ketat menggunakan **Row Level Security (RLS)** berbasis token login user.
3. **Dilarang Hardcode Data di UI (Mock Data Rules)**
   - Jangan menempelkan array data statis langsung di dalam class UI Widget.
   - Gunakan Model (`ProductModel`, `CategoryModel`) dan Repository yang mengembalikan data tiruan (mock) atau data remote agar mudah beralih tanpa mengubah struktur widget.

---

## 4. Disiplin Modifikasi Kode (Scope Discipline)

1. **Fokus Pada Fitur yang Ditugaskan (No Unrelated Edits)**
   - Saat mengerjakan satu fitur (misalnya Splash Screen), dilarang mengedit atau mengubah file fitur lain (seperti modul Checkout atau Cart).
   - Jangan melakukan refactoring liar atau reformatting file yang tidak relevan dengan tugas aktif.
2. **Hindari Duplikasi Logika Bisnis (DRY - Don't Repeat Yourself)**
   - Perhitungan diskon, pajak, total keranjang, dan status ketersediaan stok harus berada di Domain/Controller, tidak disalin-tempel antar layar.

---

## 5. Standar Verifikasi & Pelaporan

Setiap kali menyelesaikan suatu tugas implementasi atau perbaikan:
1. **Wajib Menjalankan Analyzer:**
   - Eksekusi `flutter analyze` dan pastikan **nol issues (0 errors, 0 warnings)**.
2. **Wajib Menjalankan Pengujian:**
   - Eksekusi `flutter test` dan pastikan seluruh unit test / widget test terkait berstatus **Passed**.
3. **Transparansi Perubahan File:**
   - Berikan laporan eksplisit mengenai file apa saja yang dibuat atau dimodifikasi beserta tujuannya.
4. **Berhenti dan Tunggu Persetujuan Pengguna:**
   - Jangan melanjutkan ke tahap implementasi berikutnya sebelum pengguna mereview dan memberikan instruksi untuk melanjutkan.
