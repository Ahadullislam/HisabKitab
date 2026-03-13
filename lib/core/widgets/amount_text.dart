import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat('#,##,##0.00', 'en_IN');

  static String format(double amount) =>
      '${AppStrings.currency}${_formatter.format(amount)}';

  static String formatCompact(double amount) {
    if (amount >= 100000) {
      return '${AppStrings.currency}${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${AppStrings.currency}${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }

  static String formatSigned(double amount, {bool isIncome = false}) {
    final prefix = isIncome ? '+' : '-';
    return '$prefix${format(amount.abs())}';
  }
}