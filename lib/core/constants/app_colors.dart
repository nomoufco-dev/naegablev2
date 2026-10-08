import 'package:flutter/material.dart';

/// Palet warna resmi Naegablé Bakehaus.
/// Diturunkan langsung dari spesifikasi desain `docs/design-system.md`
/// dan aset `design-system/COLOR PALLETE.png`.
abstract final class AppColors {
  // --- Warna Utama Identitas Merek ---
  
  /// Grey Brown / Chocolate (#442F2A): Warna primer, background header, app bar, & floating bottom nav, tombol add/checkout.
  static const Color primary = Color(0xFF442F2A);
  static const Color greyBrown = Color(0xFF442F2A);

  /// Blush Pink (#F5CBD7): Warna aksen, FAB (+), chip kategori aktif, dan lingkaran expand cart preview.
  static const Color accent = Color(0xFFF5CBD7);
  static const Color blush = Color(0xFFF5CBD7);

  /// Cream (#FFF7EC): Warna aksen latar sekunder.
  static const Color cream = Color(0xFFFFF7EC);

  /// Background kanvas Scaffold putih bersih sesuai HOME - KASIR PAGE TIPE 1.
  static const Color background = Color(0xFFFFFFFF);

  /// Noir (#070D0D): Warna hitam pekat untuk teks kontras tinggi dan harga produk.
  static const Color noir = Color(0xFF070D0D);

  // --- Warna Semantik & Pembantu ---

  /// Surface White (#FFFFFF): Latar kartu produk, cart preview, modal, dan search bar.
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  /// Teks utama di atas latar terang (Hitam).
  static const Color textPrimary = Color(0xFF070D0D);

  /// Teks sekunder (keterangan, sub-label, jumlah item abu-abu #757575).
  static const Color textSecondary = Color(0xFF757575);

  /// Teks terang di atas latar gelap (Grey Brown).
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Warna garis batas / border kartu (#EAE5E0 / #E5E7EB).
  static const Color borderLight = Color(0xFFEAE5E0);

  /// Status stock indikator hijau neon/terang sesuai CARD 1 & CARD 2 (#00E626 / #00C853).
  static const Color stockGreen = Color(0xFF00C853);

  /// Status delivery aktif / sukses / stok aman.
  static const Color success = Color(0xFF2E7D32);

  /// Peringatan stok menipis (warning).
  static const Color warning = Color(0xFFED6C02);

  /// Status delivery non-aktif / bahaya / hapus data.
  static const Color danger = Color(0xFFD32F2F);

  /// Warna abu-abu halus untuk search bar & placeholder.
  static const Color surfaceMuted = Color(0xFFF5F5F5);

  /// Overlay latar belakang modal (dimmed scrim).
  static const Color scrim = Color(0x80000000);

  // --- Kompatibilitas Desain ---

  /// Warna tombol add & checkout (Deep Chocolate Brown #442F2A).
  static const Color primaryButton = Color(0xFF442F2A);

  /// Warna harga hitam pekat (#000000) sesuai CARD 1 & CARD 2.
  static const Color priceBlack = Color(0xFF000000);

  /// Backward-compatibility aliases
  static const Color primaryOrange = Color(0xFF442F2A);
  static const Color cartBarOrange = Color(0xFFFFFFFF);
  static const Color mediumOrange = Color(0xFF442F2A);
  static const Color priceOrange = Color(0xFF000000);
  static const Color addButtonOrange = Color(0xFF442F2A);
  static const Color iconInactive = Color(0xFFBDBDBD);
}
