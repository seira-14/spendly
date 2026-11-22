import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Formats a number to "Rp 2.450.000"
  static String format(num? amount) {
    if (amount == null) return 'Rp 0';
    return _formatter.format(amount);
  }

  /// Formats an expense transaction amount to "-Rp 150.000"
  static String formatExpense(num? amount) {
    if (amount == null) return '-Rp 0';
    return '-${_formatter.format(amount)}';
  }

  /// Formats compact for charts e.g. "2.4M", "500K", "150rb"
  static String formatCompact(num? amount) {
    if (amount == null || amount == 0) return '0';
    if (amount >= 1000000) {
      final val = (amount / 1000000).toStringAsFixed(1);
      return '${val.replaceAll('.0', '')}jt';
    } else if (amount >= 1000) {
      final val = (amount / 1000).toStringAsFixed(0);
      return '${val}rb';
    }
    return amount.toString();
  }

  /// Parse user input string like "150.000" or "Rp 150.000" to double
  static double parse(String input) {
    final clean = input.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(clean) ?? 0.0;
  }
}
