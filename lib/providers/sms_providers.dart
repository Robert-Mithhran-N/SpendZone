import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/merchant_categorizer.dart';
import '../services/sms_parser.dart';
import '../services/sms_service.dart';
import 'database_provider.dart';

/// State of the SMS transaction scanning process
enum SmsScanStatus { idle, scanning, success, error }

class SmsScanState {
  final SmsScanStatus status;
  final int countParsed;
  final String? errorMessage;

  const SmsScanState({
    required this.status,
    required this.countParsed,
    this.errorMessage,
  });

  factory SmsScanState.initial() => const SmsScanState(status: SmsScanStatus.idle, countParsed: 0);

  SmsScanState copyWith({
    SmsScanStatus? status,
    int? countParsed,
    String? errorMessage,
  }) {
    return SmsScanState(
      status: status ?? this.status,
      countParsed: countParsed ?? this.countParsed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ── Providers ──

/// FutureProvider that loads the categorizer from assets JSON
final merchantCategorizerProvider = FutureProvider<MerchantCategorizer>((ref) async {
  return MerchantCategorizer.loadFromAssets();
});

/// Provider for SmsParser — waits for categorizer loading or falls back to an empty one
final smsParserProvider = Provider<SmsParser>((ref) {
  final categorizerAsync = ref.watch(merchantCategorizerProvider);
  final categorizer = categorizerAsync.value ?? MerchantCategorizer(rules: {});
  return SmsParser(categorizer: categorizer);
});

/// Provider for SmsService
final smsServiceProvider = Provider<SmsService>((ref) {
  final parser = ref.watch(smsParserProvider);
  return SmsService(parser: parser);
});

/// StateNotifierProvider managing SMS Scanning workflow
final smsScanProvider = StateNotifierProvider<SmsScanNotifier, SmsScanState>((ref) {
  return SmsScanNotifier(ref);
});

class SmsScanNotifier extends StateNotifier<SmsScanState> {
  final Ref _ref;

  SmsScanNotifier(this._ref) : super(SmsScanState.initial());

  SmsService get _smsService => _ref.read(smsServiceProvider);

  /// Performs inbox scan and batch inserts transactional results to DB
  Future<void> scanTransactions() async {
    if (state.status == SmsScanStatus.scanning) return;

    state = state.copyWith(status: SmsScanStatus.scanning);

    try {
      final transactions = await _smsService.scanInbox();
      
      if (transactions.isNotEmpty) {
        final db = _ref.read(databaseProvider);
        await db.batchUpsertTransactions(transactions);
      }

      state = SmsScanState(
        status: SmsScanStatus.success,
        countParsed: transactions.length,
      );
    } catch (e) {
      state = SmsScanState(
        status: SmsScanStatus.error,
        countParsed: 0,
        errorMessage: e.toString(),
      );
    }
  }

  /// Check permission status
  Future<bool> checkPermission() async {
    return _smsService.hasPermission();
  }

  /// Request permissions
  Future<bool> requestPermission() async {
    return _smsService.requestPermission();
  }
}
