import 'package:intl/intl.dart';
import 'package:penyaluran_app/app/utils/date_formatter.dart';

class DateTimeHelper {
  /// Mengkonversi DateTime dari UTC ke timezone lokal
  static DateTime toLocalDateTime(DateTime utcDateTime) {
    return utcDateTime.toLocal();
  }

  /// Format tanggal ke format Indonesia (dd MMM yyyy)
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Belum ditentukan';

    // Pastikan tanggal dalam timezone lokal
    final localDateTime = toLocalDateTime(dateTime);
    return DateFormatter.formatDate(localDateTime, format: 'dd MMM yyyy');
  }

  /// Format waktu ke format 24 jam (HH:mm)
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Belum ditentukan';

    // Pastikan waktu dalam timezone lokal
    final localDateTime = toLocalDateTime(dateTime);
    return DateFormatter.formatTime(localDateTime);
  }

  /// Format tanggal dan waktu (dd MMM yyyy HH:mm)
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Belum ditentukan';

    // Pastikan tanggal dan waktu dalam timezone lokal
    final localDateTime = toLocalDateTime(dateTime);
    return DateFormatter.formatDateTime(localDateTime,
        format: 'dd MMM yyyy HH:mm');
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
}
