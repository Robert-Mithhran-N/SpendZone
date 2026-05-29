import 'package:intl/intl.dart';

/// Currency formatting utilities for Indian Rupee.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _formatterWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Format amount as ₹1,23,456
  static String format(double amount) {
    if (amount == amount.roundToDouble()) {
      return _formatter.format(amount);
    }
    return _formatterWithDecimals.format(amount);
  }

  /// Format compact: ₹1.2L, ₹50K, etc.
  static String formatCompact(double amount) {
    if (amount.abs() >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount.abs() >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount.abs() >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }

  /// Format without symbol: 1,23,456
  static String formatWithoutSymbol(double amount) {
    final formatted = format(amount);
    return formatted.replaceFirst('₹', '').trim();
  }
}
