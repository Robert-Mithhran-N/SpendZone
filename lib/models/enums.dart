import 'package:flutter/material.dart';

/// All application enums in one file for V1 simplicity.

// ── Transaction Type ──
enum TransactionType {
  credit,
  debit;

  String get label {
    switch (this) {
      case TransactionType.credit:
        return 'Income';
      case TransactionType.debit:
        return 'Expense';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.credit:
        return Icons.arrow_downward_rounded;
      case TransactionType.debit:
        return Icons.arrow_upward_rounded;
    }
  }
}

// ── Category ──
enum Category {
  food,
  transport,
  fuel,
  shopping,
  entertainment,
  bills,
  health,
  education,
  travel,
  salary,
  investment,
  others;

  String get label {
    switch (this) {
      case Category.food:
        return 'Food';
      case Category.transport:
        return 'Transport';
      case Category.fuel:
        return 'Fuel';
      case Category.shopping:
        return 'Shopping';
      case Category.entertainment:
        return 'Entertainment';
      case Category.bills:
        return 'Bills';
      case Category.health:
        return 'Health';
      case Category.education:
        return 'Education';
      case Category.travel:
        return 'Travel';
      case Category.salary:
        return 'Salary';
      case Category.investment:
        return 'Investment';
      case Category.others:
        return 'Others';
    }
  }

  IconData get icon {
    switch (this) {
      case Category.food:
        return Icons.restaurant_rounded;
      case Category.transport:
        return Icons.directions_car_rounded;
      case Category.fuel:
        return Icons.local_gas_station_rounded;
      case Category.shopping:
        return Icons.shopping_bag_rounded;
      case Category.entertainment:
        return Icons.movie_rounded;
      case Category.bills:
        return Icons.receipt_long_rounded;
      case Category.health:
        return Icons.health_and_safety_rounded;
      case Category.education:
        return Icons.school_rounded;
      case Category.travel:
        return Icons.flight_rounded;
      case Category.salary:
        return Icons.account_balance_wallet_rounded;
      case Category.investment:
        return Icons.trending_up_rounded;
      case Category.others:
        return Icons.more_horiz_rounded;
    }
  }

  static Category fromString(String value) {
    return Category.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => Category.others,
    );
  }
}

// ── UPI App ──
enum UpiApp {
  googlePay,
  phonePe,
  paytm,
  amazonPay,
  bhim,
  whatsAppPay,
  unknown;

  String get label {
    switch (this) {
      case UpiApp.googlePay:
        return 'Google Pay';
      case UpiApp.phonePe:
        return 'PhonePe';
      case UpiApp.paytm:
        return 'Paytm';
      case UpiApp.amazonPay:
        return 'Amazon Pay';
      case UpiApp.bhim:
        return 'BHIM';
      case UpiApp.whatsAppPay:
        return 'WhatsApp Pay';
      case UpiApp.unknown:
        return 'Unknown';
    }
  }

  IconData get icon {
    switch (this) {
      case UpiApp.googlePay:
        return Icons.g_mobiledata_rounded;
      case UpiApp.phonePe:
        return Icons.phone_android_rounded;
      case UpiApp.paytm:
        return Icons.payment_rounded;
      case UpiApp.amazonPay:
        return Icons.shopping_cart_rounded;
      case UpiApp.bhim:
        return Icons.account_balance_rounded;
      case UpiApp.whatsAppPay:
        return Icons.chat_rounded;
      case UpiApp.unknown:
        return Icons.help_outline_rounded;
    }
  }

  static UpiApp fromString(String? value) {
    if (value == null) return UpiApp.unknown;
    final lower = value.toLowerCase();
    if (lower.contains('google') || lower.contains('gpay')) {
      return UpiApp.googlePay;
    }
    if (lower.contains('phonepe')) return UpiApp.phonePe;
    if (lower.contains('paytm')) return UpiApp.paytm;
    if (lower.contains('amazon')) return UpiApp.amazonPay;
    if (lower.contains('bhim')) return UpiApp.bhim;
    if (lower.contains('whatsapp')) return UpiApp.whatsAppPay;
    return UpiApp.unknown;
  }
}

// ── Transaction Source ──
enum TransactionSource {
  sms,
  notification,
  manual,
  imported;

  String get label {
    switch (this) {
      case TransactionSource.sms:
        return 'SMS';
      case TransactionSource.notification:
        return 'Notification';
      case TransactionSource.manual:
        return 'Manual';
      case TransactionSource.imported:
        return 'Imported';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionSource.sms:
        return Icons.sms_rounded;
      case TransactionSource.notification:
        return Icons.notifications_rounded;
      case TransactionSource.manual:
        return Icons.edit_rounded;
      case TransactionSource.imported:
        return Icons.file_download_rounded;
    }
  }
}
