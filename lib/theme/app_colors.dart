import 'package:flutter/material.dart';

/// SpendZone color system — CRED/Jupiter inspired dark theme
class AppColors {
  AppColors._();

  // ── Background & Surface ──
  static const Color background = Color(0xFF09090F);
  static const Color surface = Color(0xFF12121F);
  static const Color surfaceVariant = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF222238);

  // ── Primary ──
  static const Color primary = Color(0xFF7C6BFF);
  static const Color primaryLight = Color(0xFF9D8FFF);
  static const Color primaryContainer = Color(0xFF2D2654);

  // ── Semantic ──
  static const Color income = Color(0xFF00E5A0);
  static const Color incomeLight = Color(0xFF33EDBA);
  static const Color incomeSurface = Color(0xFF0A2E23);
  static const Color expense = Color(0xFFFF4C6A);
  static const Color expenseLight = Color(0xFFFF7A91);
  static const Color expenseSurface = Color(0xFF2E0A14);
  static const Color warning = Color(0xFFFFB84D);
  static const Color warningSurface = Color(0xFF2E2410);

  // ── Text ──
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFF8888A0);
  static const Color textTertiary = Color(0xFF555570);

  // ── Border & Divider ──
  static const Color border = Color(0xFF252540);
  static const Color divider = Color(0xFF1A1A30);

  // ── Glass ──
  static const Color glassWhite = Color(0x14FFFFFF); // 8% white
  static const Color glassBorder = Color(0x1AFFFFFF); // 10% white

  // ── Chart palette ──
  static const List<Color> chartColors = [
    Color(0xFF7C6BFF), // primary
    Color(0xFF00E5A0), // income green
    Color(0xFFFF4C6A), // expense red
    Color(0xFFFFB84D), // warning yellow
    Color(0xFF4FC3F7), // sky blue
    Color(0xFFFF8A65), // coral
    Color(0xFFAB47BC), // purple
    Color(0xFF66BB6A), // green
    Color(0xFFEF5350), // red
    Color(0xFF42A5F5), // blue
    Color(0xFFFFA726), // orange
    Color(0xFF26C6DA), // cyan
  ];

  // ── Category colors (indexed by Category enum) ──
  static const Map<String, Color> categoryColors = {
    'food': Color(0xFFFF8A65),
    'transport': Color(0xFF4FC3F7),
    'fuel': Color(0xFFFFB84D),
    'shopping': Color(0xFFAB47BC),
    'entertainment': Color(0xFFFF4C6A),
    'bills': Color(0xFF42A5F5),
    'health': Color(0xFF66BB6A),
    'education': Color(0xFF26C6DA),
    'travel': Color(0xFF7C6BFF),
    'salary': Color(0xFF00E5A0),
    'investment': Color(0xFF00BCD4),
    'others': Color(0xFF8888A0),
  };

  // ── UPI app colors ──
  static const Map<String, Color> upiAppColors = {
    'googlePay': Color(0xFF4285F4),
    'phonePe': Color(0xFF5F259F),
    'paytm': Color(0xFF00BAF2),
    'amazonPay': Color(0xFFFF9900),
    'bhim': Color(0xFF00695C),
    'whatsAppPay': Color(0xFF25D366),
    'unknown': Color(0xFF8888A0),
  };
}
