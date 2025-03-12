import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime? date,
      {String format = 'dd MMMM yyyy',
      String locale = 'id_ID',
      String defaultValue = '-'}) {
    if (date == null) return defaultValue;
    try {
      return DateFormat(format, locale).format(date);
    } catch (e) {
      print('Error formatting date: $e');
      return date.toString().split(' ')[0]; // Fallback to basic format
    }
  }

  static String formatTime(DateTime? time,
      {String format = 'HH:mm',
      String locale = 'id_ID',
      String defaultValue = '-'}) {
    if (time == null) return defaultValue;
    try {
      return DateFormat(format, locale).format(time);
    } catch (e) {
      print('Error formatting time: $e');
      return time
          .toString()
          .split(' ')[1]
          .substring(0, 5); // Fallback to basic format
    }
  }

  static String formatDateTime(DateTime? dateTime,
      {String format = 'dd MMMM yyyy HH:mm',
      String locale = 'id_ID',
      String defaultValue = '-'}) {
    if (dateTime == null) return defaultValue;
    try {
      return DateFormat(format, locale).format(dateTime);
    } catch (e) {
      print('Error formatting date time: $e');
      return dateTime.toString().split('.')[0]; // Fallback to basic format
    }
  }

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

  static String formatDateTimeWithHour(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(dateTime);
  }
}
