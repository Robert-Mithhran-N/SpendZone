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
  /// Returns a list of parsed transaction models.
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
      for (final msg in messages) {
        if (msg.body != null && msg.date != null) {
          final tx = parser.parse(msg.body!, msg.date!);
          if (tx != null) {
            parsedTransactions.add(tx);
          }
        }
      }

      return parsedTransactions;
    } catch (_) {
      // Return empty if platform call fails (e.g. on emulators or non-Android devices)
      return [];
    }
  }
}
