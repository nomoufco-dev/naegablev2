import 'package:intl/intl.dart';

/// Helper terpusat untuk memformat tanggal dan waktu transaksi POS.
abstract final class DateFormatter {
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'id_ID');

  static const List<String> _monthNamesShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  /// Memeriksa apakah tanggal berada dalam rentang 3 bulan terakhir dari [now].
  static bool isWithin3Months(DateTime date, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    int year = reference.year;
    int month = reference.month - 3;
    if (month <= 0) {
      month += 12;
      year -= 1;
    }
    int day = reference.day;
    int maxDays = DateTime(year, month + 1, 0).day;
    if (day > maxDays) {
      day = maxDays;
    }
    final cutoff = DateTime(
      year,
      month,
      day,
      reference.hour,
      reference.minute,
      reference.second,
      reference.millisecond,
      reference.microsecond,
    );
    return !date.isBefore(cutoff);
  }

  /// Format sesuai desain daftar pesanan: "02 Okt 2026 11:00"
  static String formatOrderDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = _monthNamesShort[(dt.month - 1).clamp(0, 11)];
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d $m $y $h:$min';
  }

  /// Contoh: "24 Sep 2026, 14:30"
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Contoh: "24 September 2026"
  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  /// Contoh: "14:30"
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }
}
