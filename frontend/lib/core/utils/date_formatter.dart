import 'package:intl/intl.dart';

class DateFormatter {
  static const List<String> monthNamesIndonesian = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  static const List<String> monthNamesShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  /// Returns "Maret 2025"
  static String formatMonthYear(int month, int year) {
    if (month < 1 || month > 12) return '$year';
    return '${monthNamesIndonesian[month - 1]} $year';
  }

  /// Returns relative date or short formatted date:
  /// e.g. "Hari ini", "Kemarin", "12 Mar 2025", "10 Mar 2025"
  static String formatRelativeOrDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final itemDate = DateTime(date.year, date.month, date.day);

      final diff = today.difference(itemDate).inDays;
      if (diff == 0) {
        return 'Hari ini';
      } else if (diff == 1) {
        return 'Kemarin';
      } else {
        final monthShort = monthNamesShort[date.month - 1];
        if (date.year == now.year) {
          return '${date.day} $monthShort';
        }
        return '${date.day} $monthShort ${date.year}';
      }
    } catch (_) {
      return dateStr;
    }
  }

  /// Formats date to "12 Maret 2025"
  static String formatFullDate(DateTime date) {
    final month = monthNamesIndonesian[date.month - 1];
    return '${date.day} $month ${date.year}';
  }

  /// Formats DateTime to API date string "YYYY-MM-DD"
  static String toApiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
