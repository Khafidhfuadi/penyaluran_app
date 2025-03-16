import 'package:intl/intl.dart';

class DateTimeHelper {
  /// Mengkonversi DateTime dari UTC ke timezone lokal
  static DateTime toLocalDateTime(DateTime utcDateTime) {
    return utcDateTime.toLocal();
  }

  /// Format tanggal ke format Indonesia (dd MMM yyyy)
  static String formatDate(DateTime? dateTime,
      {String format = 'dd MMM yyyy',
      String locale = 'id_ID',
      String defaultValue = 'Belum ditentukan'}) {
    if (dateTime == null) return defaultValue;

    // Pastikan tanggal dalam timezone lokal
    final localDateTime = toLocalDateTime(dateTime);
    try {
      return DateFormat(format, locale).format(localDateTime);
    } catch (e) {
      print('Error formatting date: $e');
      return localDateTime.toString().split(' ')[0]; // Fallback to basic format
    }
  }

  /// Format waktu ke format 24 jam (HH:mm)
  static String formatTime(DateTime? dateTime,
      {String format = 'HH:mm',
      String locale = 'id_ID',
      String defaultValue = 'Belum ditentukan'}) {
    if (dateTime == null) return defaultValue;

    // Pastikan waktu dalam timezone lokal
    final localDateTime = toLocalDateTime(dateTime);
    try {
      return DateFormat(format, locale).format(localDateTime);
    } catch (e) {
      print('Error formatting time: $e');
      return localDateTime
          .toString()
          .split(' ')[1]
          .substring(0, 5); // Fallback to basic format
    }
  }

  /// Format tanggal dan waktu (dd MMM yyyy HH:mm)
  static String formatDateTime(DateTime? dateTime,
      {String format = 'dd MMM yyyy HH:mm',
      String locale = 'id_ID',
      String defaultValue = 'Belum ditentukan'}) {
    if (dateTime == null) return defaultValue;

    // Pastikan tanggal dan waktu dalam timezone lokal
    final localDateTime = toLocalDateTime(dateTime);
    try {
      return DateFormat(format, locale).format(localDateTime);
    } catch (e) {
      print('Error formatting date time: $e');
      return localDateTime.toString().split('.')[0]; // Fallback to basic format
    }
  }

  /// Format tanggal lengkap dalam bahasa Indonesia (Senin, 01 Januari 2023)
  static String formatDateIndonesian(DateTime? dateTime) {
    if (dateTime == null) return 'Belum ditentukan';

    // Pastikan tanggal dalam timezone lokal
    final localDateTime = toLocalDateTime(dateTime);

    final List<String> namaBulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    final List<String> namaHari = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ];

    final String hari = namaHari[localDateTime.weekday % 7];
    final String tanggal = localDateTime.day.toString().padLeft(2, '0');
    final String bulan = namaBulan[localDateTime.month - 1];
    final String tahun = localDateTime.year.toString();

    return '$hari, $tanggal $bulan $tahun';
  }

  /// Format angka dengan pemisah ribuan
  static String formatNumber(num? number,
      {String locale = 'id_ID', String defaultValue = '0'}) {
    if (number == null) return defaultValue;
    try {
      return NumberFormat("#,##0.##", locale).format(number);
    } catch (e) {
      print('Error formatting number: $e');
      return number.toString(); // Fallback to basic format
    }
  }

  /// Format tanggal dan waktu dengan jam (dd MMMM yyyy HH:mm)
  static String formatDateTimeWithHour(DateTime? dateTime) {
    if (dateTime == null) return 'Belum ditentukan';
    final localDateTime = toLocalDateTime(dateTime);
    return DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(localDateTime);
  }
}
