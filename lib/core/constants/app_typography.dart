import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Standar tipografi resmi Naegablé Bakehaus sesuai `docs/design-system.md`.
abstract final class AppTypography {
  // --- Tipografi Merek (Brand Typography) ---

  /// Gaya teks untuk nama merek "naegablé" (Cursive / Handcrafted feel).
  static const TextStyle brandScript = TextStyle(
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w600,
    fontSize: 40,
    color: AppColors.textOnDark,
    letterSpacing: 1.0,
  );

  /// Gaya teks untuk penjelas merek "BAKEHAUS" (All-caps, wide tracking).
  static const TextStyle brandTagline = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 13,
    letterSpacing: 4.5,
    color: AppColors.accent,
  );

  // --- Tipografi Antarmuka POS (UI & Data) ---

  /// Judul utama halaman (misal: "Kasir").
  static const TextStyle headerTitle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 22,
    color: AppColors.textOnDark,
    height: 1.25,
  );

  /// Sub-judul atau header dialog/modal.
  static const TextStyle subHeader = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Nama produk pada kartu katalog.
  static const TextStyle productName = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// Label harga produk (Rp XX.XXX).
  static const TextStyle priceTag = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 13,
    color: AppColors.primary,
    height: 1.2,
  );

  /// Teks isi standar (deskripsi, detail pesanan).
  static const TextStyle bodyText = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Keterangan kecil, SKU, dan status stok.
  static const TextStyle caption = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 11,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  /// Label tombol aksi utama.
  static const TextStyle buttonLabel = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: AppColors.textOnDark,
    letterSpacing: 0.5,
  );
}
