import 'package:intl/intl.dart';

/// Kelas pembantu untuk manipulasi tanggal dan waktu
class DateHelper {
  /// Format tanggal ke format Indonesia (dd MMM yyyy)
  static String formatDate(
    DateTime? dateTime, {
    String format = 'dd MMM yyyy',
    String locale = 'id_ID',
    String defaultValue = 'Belum ditentukan',
  }) {
    if (dateTime == null) return defaultValue;
    try {
      return DateFormat(format, locale).format(dateTime.toLocal());
    } catch (e) {
      return dateTime.toString().split(' ')[0];
    }
  }

  /// Format nilai ke dalam format mata uang Rupiah
  static String formatRupiah(
    num? value, {
    String symbol = 'Rp',
    int decimalDigits = 0,
    String defaultValue = 'Rp 0',
  }) {
    if (value == null) return defaultValue;
    try {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: '$symbol ',
        decimalDigits: decimalDigits,
      );
      return formatter.format(value);
    } catch (e) {
      // Format manual
      return '$symbol ${value.toStringAsFixed(decimalDigits).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';
    }
  }
}
