import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _idr = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(int amount) => _idr.format(amount);

  /// Compact label for calendar cells, e.g. 380000 -> "380k"
  static String compact(int amount) {
    if (amount >= 1000000) {
      final m = amount / 1000000;
      return m == m.roundToDouble()
          ? '${m.toInt()}jt'
          : '${m.toStringAsFixed(1)}jt';
    }
    if (amount >= 1000) {
      final k = amount / 1000;
      return k == k.roundToDouble()
          ? '${k.toInt()}k'
          : '${k.toStringAsFixed(1)}k';
    }
    return amount.toString();
  }

  /// Parse digits from formatted or raw input string.
  static int? parseInput(String text) {
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  /// Format while user types (digits only, with Rp prefix).
  static String formatInput(String raw) {
    final amount = parseInput(raw);
    if (amount == null) return '';
    return format(amount);
  }
}
