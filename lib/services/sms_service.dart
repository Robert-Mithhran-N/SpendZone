import 'dart:developer' as developer;
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/transaction_model.dart';
import 'sms_parser.dart';

class SmsService {
  final SmsQuery _smsQuery = SmsQuery();
  final SmsParser parser;

  SmsService({required this.parser});

  /// Request SMS read permissions
  Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  /// Check current SMS read permission status
  Future<bool> hasPermission() async {
    return Permission.sms.isGranted;
  }

  /// Read SMS inbox and parse transactional messages.
  /// Returns a deduplicated list of parsed transaction models.
  Future<List<TransactionModel>> scanInbox() async {
    final hasPerm = await hasPermission();
    if (!hasPerm) {
      final granted = await requestPermission();
      if (!granted) return [];
    }

    try {
      final messages = await _smsQuery.querySms(
        kinds: [SmsQueryKind.inbox],
      );

      final List<TransactionModel> parsedTransactions = [];
      final Set<String> deduplicationKeys = {};

      for (final msg in messages) {
        if (msg.body != null && msg.date != null) {
          final tx = parser.parse(msg.body!, msg.date!);
          if (tx != null) {
            // Generate deduplication key from amount + date (truncated to minute) + reference
            final dedupKey = _generateDedupKey(tx);
            if (!deduplicationKeys.contains(dedupKey)) {
              deduplicationKeys.add(dedupKey);
              parsedTransactions.add(tx);
            }
          }
        }
      }

      return parsedTransactions;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to query SMS messages from content provider',
        name: 'SmsService',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Generate a deduplication key based on amount, date (to minute precision), and reference number.
  /// This prevents the same SMS from creating duplicate transactions on re-scan.
  String _generateDedupKey(TransactionModel tx) {
    final dateKey = '${tx.transactionDate.year}-${tx.transactionDate.month}-${tx.transactionDate.day}-${tx.transactionDate.hour}-${tx.transactionDate.minute}';
    final refKey = tx.referenceNumber ?? '';
    return '${tx.amount}|$dateKey|$refKey|${tx.type.name}';
  }
}
