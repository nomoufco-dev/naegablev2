import 'package:intl/intl.dart';

/// Helper terpusat untuk memformat nilai mata uang Rupiah (IDR).
abstract final class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Mengonversi nilai numerik menjadi representasi string Rupiah standar.
  /// Contoh: `25000` -> `"Rp 25.000"`
  static String format(num amount) {
    return _formatter.format(amount);
  }

  /// Mengonversi string format Rupiah kembali menjadi angka.
  static num parse(String formatted) {
    final clean = formatted.replaceAll(RegExp(r'[^0-9]'), '');
    return num.tryParse(clean) ?? 0;
  }
}
