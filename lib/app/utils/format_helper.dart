import 'package:intl/intl.dart';

/// Kelas pembantu untuk manipulasi tanggal dan waktu
///
/// Kelas ini berisi fungsi-fungsi untuk memformat dan memanipulasi
/// tanggal dan waktu.
class DateTimeHelper {
  /// Mengkonversi DateTime dari UTC ke timezone lokal
  static DateTime toLocalDateTime(DateTime utcDateTime) {
    return utcDateTime.toLocal();
  }

  /// Format tanggal ke format Indonesia (dd MMM yyyy)
  ///
  /// [dateTime] adalah DateTime yang akan diformat
  /// [format] adalah format yang digunakan
  /// [locale] adalah locale yang digunakan
  /// [defaultValue] adalah nilai default jika dateTime null
  static String formatDate(
    DateTime? dateTime, {
    String format = 'dd MMM yyyy',
    String locale = 'id_ID',
    String defaultValue = 'Belum ditentukan',
  }) {
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
  ///
  /// [dateTime] adalah DateTime yang akan diformat
  /// [format] adalah format yang digunakan
  /// [locale] adalah locale yang digunakan
  /// [defaultValue] adalah nilai default jika dateTime null
  static String formatTime(
    DateTime? dateTime, {
    String format = 'HH:mm',
    String locale = 'id_ID',
    String defaultValue = 'Belum ditentukan',
  }) {
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
  ///
  /// [dateTime] adalah DateTime yang akan diformat
  /// [format] adalah format yang digunakan
  /// [locale] adalah locale yang digunakan
  /// [defaultValue] adalah nilai default jika dateTime null
  static String formatDateTime(
    DateTime? dateTime, {
    String format = 'dd MMM yyyy HH:mm',
    String locale = 'id_ID',
    String defaultValue = 'Belum ditentukan',
  }) {
    if (dateTime == null) return defaultValue;

    // Pastikan tanggal dan waktu dalam timezone lokal
    final localDateTime = toLocalDateTime(dateTime);
    try {
      return DateFormat(format, locale).format(localDateTime);
    } catch (e) {
      print('Error formatting date time: $e');
      return localDateTime.toString(); // Fallback to basic format
    }
  }

  /// Format tanggal relatif (hari ini, kemarin, dll)
  ///
  /// [dateTime] adalah DateTime yang akan diformat
  /// [locale] adalah locale yang digunakan
  /// [defaultValue] adalah nilai default jika dateTime null
  static String formatRelativeDate(
    DateTime? dateTime, {
    String locale = 'id_ID',
    String defaultValue = 'Belum ditentukan',
  }) {
    if (dateTime == null) return defaultValue;

    // Pastikan tanggal dalam timezone lokal
    final localDateTime = toLocalDateTime(dateTime);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final aDate =
        DateTime(localDateTime.year, localDateTime.month, localDateTime.day);

    if (aDate == today) {
      return 'Hari ini, ${formatTime(localDateTime)}';
    } else if (aDate == yesterday) {
      return 'Kemarin, ${formatTime(localDateTime)}';
    } else if (aDate == tomorrow) {
      return 'Besok, ${formatTime(localDateTime)}';
    } else {
      return formatDateTime(localDateTime);
    }
  }

  /// Mendapatkan nama hari dari DateTime
  ///
  /// [dateTime] adalah DateTime yang akan diambil nama harinya
  /// [locale] adalah locale yang digunakan
  /// [defaultValue] adalah nilai default jika dateTime null
  static String getDayName(
    DateTime? dateTime, {
    String locale = 'id_ID',
    String defaultValue = 'Belum ditentukan',
  }) {
    if (dateTime == null) return defaultValue;

    // Pastikan tanggal dalam timezone lokal
    final localDateTime = toLocalDateTime(dateTime);
    try {
      return DateFormat('EEEE', locale).format(localDateTime);
    } catch (e) {
      print('Error getting day name: $e');
      return ''; // Fallback to empty string
    }
  }

  /// Mendapatkan nama bulan dari DateTime
  ///
  /// [dateTime] adalah DateTime yang akan diambil nama bulannya
  /// [locale] adalah locale yang digunakan
  /// [defaultValue] adalah nilai default jika dateTime null
  static String getMonthName(
    DateTime? dateTime, {
    String locale = 'id_ID',
    String defaultValue = 'Belum ditentukan',
  }) {
    if (dateTime == null) return defaultValue;

    // Pastikan tanggal dalam timezone lokal
    final localDateTime = toLocalDateTime(dateTime);
    try {
      return DateFormat('MMMM', locale).format(localDateTime);
    } catch (e) {
      print('Error getting month name: $e');
      return ''; // Fallback to empty string
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

  /// Format nilai ke dalam format mata uang Rupiah
  ///
  /// [value] adalah nilai yang akan diformat
  /// [symbol] adalah simbol mata uang (default: 'Rp')
  /// [decimalDigits] adalah jumlah digit desimal yang ditampilkan
  /// [defaultValue] adalah nilai default jika value null
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
      print('Error formatting currency: $e');
      // Fallback ke format manual
      return '$symbol ${value.toStringAsFixed(decimalDigits).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';
    }
  }
}
