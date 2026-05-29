import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/enums.dart';

class MerchantCategorizer {
  final Map<String, String> rules;

  MerchantCategorizer({required this.rules});

  /// Categorize merchant payee string using rules map
  Category categorize(String merchantName) {
    final name = merchantName.toLowerCase();
    
    // Find matching rule
    for (final entry in rules.entries) {
      if (name.contains(entry.key.toLowerCase())) {
        return Category.fromString(entry.value);
      }
    }

    // Default Fallbacks for unlisted merchants based on keyword hints
    if (name.contains('paytm') || name.contains('bill') || name.contains('electricity') || name.contains('recharge')) {
      return Category.bills;
    }
    if (name.contains('restaurant') || name.contains('cafe') || name.contains('hotel') || name.contains('dhaba')) {
      return Category.food;
    }
    if (name.contains('petrol') || name.contains('fuel') || name.contains('cng')) {
      return Category.fuel;
    }
    if (name.contains('hospital') || name.contains('pharmacy') || name.contains('medical') || name.contains('clinic')) {
      return Category.health;
    }
    if (name.contains('uber') || name.contains('ola') || name.contains('cab') || name.contains('auto')) {
      return Category.transport;
    }

    return Category.others;
  }

  /// Factory creator to load from assets file
  static Future<MerchantCategorizer> loadFromAssets() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/merchant_rules.json');
      final Map<String, dynamic> rawMap = json.decode(jsonStr);
      final rules = rawMap.map((key, value) => MapEntry(key, value.toString()));
      return MerchantCategorizer(rules: rules);
    } catch (_) {
      // Fallback empty if asset fails to load (e.g. in tests)
      return MerchantCategorizer(rules: {});
    }
  }
}
