import 'package:flutter/material.dart';

/// Skala spasi (spacing) dan sudut membulat (border radius) aplikasi POS Naegable.
/// Diturunkan dari `docs/design-system.md`.
abstract final class AppSpacing {
  // --- Skala Spasi (Padding & Margin) ---

  /// 4.0: Jarak antar ikon mikro dan badge.
  static const double xxs = 4.0;

  /// 8.0: Jarak antar elemen dalam kartu, margin kompak.
  static const double xs = 8.0;

  /// 12.0: Spasi antar kolom/baris pada grid katalog.
  static const double sm = 12.0;

  /// 16.0: Padding default konten halaman dan margin samping.
  static const double md = 16.0;

  /// 20.0: Padding kartu kontainer utama dan dialog.
  static const double lg = 20.0;

  /// 24.0: Margin bottom sheet dan header modal.
  static const double xl = 24.0;

  /// 32.0: Spasi pemisah section besar.
  static const double xxl = 32.0;

  // --- Skala Sudut Membulat (Border Radius) ---

  /// 6.0: Sudut badge diskon dan tag kecil.
  static const double radiusXs = 6.0;

  /// 10.0: Sudut input field dan tombol kecil.
  static const double radiusSm = 10.0;

  /// 16.0: Sudut kartu produk dalam grid katalog.
  static const double radiusMd = 16.0;

  /// 24.0: Sudut atas Bottom Sheet keranjang dan modal action sheet.
  static const double radiusLg = 24.0;

  /// 999.0: Bentuk kapsul penuh (Pill-shape) untuk search bar dan navigation bar.
  static const double radiusPill = 999.0;

  // --- BorderRadius Objek Siap Pakai ---
  static const BorderRadius roundedXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius roundedPill = BorderRadius.all(Radius.circular(radiusPill));
}
