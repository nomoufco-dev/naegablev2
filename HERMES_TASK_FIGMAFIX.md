# TUGAS: Samakan Posisi & Bentuk Tombol Bayar + Menu ⋮ dengan Figma

## Konteks
Repo Flutter `/home/hatch/workspace/naegablev2`.
File: `lib/features/orders/presentation/screens/order_list_screen.dart`.
Pengguna melapor posisi dan bentuk tombol "Bayar" + menu ⋮ di kartu pesanan
tidak sesuai Figma. Berikut hasil observasi LANGSUNG dari frame Figma
"Daftar Pesanan" (kartu expanded) — jadikan ini acuan mutlak:

## Spesifikasi Figma (wajib diikuti)
1. **Tombol "Bayar"** ada di BAWAH kartu, dalam BARIS TERSENDIRI di bawah
   baris "Total" (bukan sebaris dengan teks total).
2. **Menu ⋮ SEBARIS dengan tombol "Bayar"** di baris paling bawah kartu,
   tepat di SEBELAH KANAN tombol "Bayar". BUKAN di header kartu.
   (Di header kartu yang collapsed hanya ada ikon chevron expand — tanpa ⋮.)
3. **Bentuk tombol "Bayar"**: TIDAK full-width — lebarnya ~80-85% lebar konten
   kartu (berbagi baris dengan tombol ⋮). Warna COKLAT TUA (dark chocolate,
   sekitar #5C3D2E — gunakan AppColors.primary jika sudah cocok, kalau belum
   sesuaikan). Bentuk PILL (rounded penuh/stadium). Teks "Bayar" putih,
   semibold, ukuran sedang.
4. **Bentuk tombol ⋮**: TOMBOL TERPISAH berbentuk KOTAK dengan sudut membulat
   (rounded square/squircle), background PUTIH dengan border/shadow halus,
   berisi 3 titik vertikal HITAM. Bentuknya kira-kira PERSEGI dan TINGGINYA
   SAMA dengan tinggi tombol "Bayar".
5. **Urutan vertikal kartu** (atas ke bawah):
   baris item → baris "Total Pesanan" → baris "Total" (bold) / nominal HIJAU
   bold → baris bawah: [tombol Bayar coklat lebar] [tombol kotak putih ⋮].

## Yang harus dilakukan
- Pindahkan menu ⋮ dari header kartu ke baris bawah, di kanan tombol "Bayar"
  (hapus ⋮ dari header; header hanya berisi chip, info pelanggan, chevron expand).
- Buat tombol "Bayar" berbentuk pill coklat tua, lebar ~80-85%, teks putih.
- Buat tombol ⋮ sebagai kotak putih rounded berisi titik tiga hitam,
  tinggi sama dengan tombol Bayar, menempel di kanan tombol Bayar.
- Pastikan tap tombol ⋮ membuka action sheet "Struk Pesanan"/"Batalkan Pesanan".
- Jangan ubah bagian kartu lainnya.

## Aturan
- Setelah selesai jalankan `flutter analyze`, perbaiki error jika ada.
- Jangan commit ke git.

## Laporan akhir
Ringkasan perubahan + konfirmasi sudah sesuai 5 poin spesifikasi di atas.
