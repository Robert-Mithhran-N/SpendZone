import 'package:uuid/uuid.dart';
import '../models/enums.dart';
import '../models/transaction_model.dart';
import 'sms_patterns.dart';
import 'merchant_categorizer.dart';

class SmsParser {
  final MerchantCategorizer categorizer;
  final _uuid = const Uuid();

  SmsParser({required this.categorizer});

  /// Parse a raw SMS string and return a TransactionModel, or null if not a transaction message.
  TransactionModel? parse(String smsBody, DateTime smsDate) {
    final lowerBody = smsBody.toLowerCase();

    // 1. Determine if it is a transactional message
    final isDebit = SmsPatterns.debitDetector.hasMatch(lowerBody);
    final isCredit = SmsPatterns.creditDetector.hasMatch(lowerBody);

    // If it has neither debit nor credit keywords, ignore it
    if (!isDebit && !isCredit) return null;

    // 2. Extract Amount
    final amountMatch = SmsPatterns.amountPattern.firstMatch(lowerBody);
    if (amountMatch == null) return null; // No amount found, not transactional
    
    double amount;
    try {
      final cleanAmountStr = amountMatch.group(1)!.replaceAll(',', '');
      amount = double.parse(cleanAmountStr);
    } catch (_) {
      return null; // Failed to parse amount numeric value
    }

    if (amount <= 0) return null;

    // 3. Determine Transaction Type
    // If both credit and debit keywords are found, debit takes precedence (e.g., "Rs X debited for payment to Y, a/c credited with Y")
    final type = isDebit ? TransactionType.debit : TransactionType.credit;

    // 4. Extract UPI App
    UpiApp upiApp = UpiApp.unknown;
    final upiMatch = SmsPatterns.upiAppDetector.firstMatch(lowerBody);
    if (upiMatch != null) {
      upiApp = UpiApp.fromString(upiMatch.group(1));
    }

    // 5. Extract Reference Number
    String? referenceNumber;
    final refMatch = SmsPatterns.refNoPattern.firstMatch(smsBody); // use original casing
    if (refMatch != null) {
      referenceNumber = refMatch.group(1);
    }

    // 6. Extract Merchant Name
    String? merchant;
    for (final pattern in SmsPatterns.merchantPatterns) {
      final merchantMatch = pattern.firstMatch(smsBody);
      if (merchantMatch != null) {
        var name = merchantMatch.group(1)!.trim();
        
        // Clean up common VPA artifacts
        if (name.contains('@')) {
          name = name.split('@').first;
        }

        // Strip out stop words that may have been greedily matched
        final lowerName = ' $name '.toLowerCase();
        int cutIndex = name.length;
        
        final stopWords = [
          ' on ',
          ' via ',
          ' using ',
          ' ref ',
          ' txn ',
          ' through ',
          ' a/c ',
          ' card ',
          ' to ',
          ' from ',
          ' balance ',
          ' bal ',
          ' limit ',
          ' date ',
          ' inr ',
          ' rs ',
        ];

        for (final word in stopWords) {
          final idx = lowerName.indexOf(word);
          if (idx != -1 && idx < cutIndex) {
            cutIndex = idx;
          }
        }

        name = name.substring(0, cutIndex).trim();
        
        // Clean up punctuation/trailing spaces
        name = name.replaceAll(RegExp(r'[#\*.,;:]'), '').trim();
        if (name.isNotEmpty && name.length > 1) {
          merchant = _neatMerchantName(name);
          break;
        }
      }
    }

    // Default merchant name if none matched
    if (merchant == null || merchant.isEmpty) {
      merchant = type == TransactionType.credit ? 'Self Transfer / Depositor' : 'Cash Withdrawal / Retailer';
    }

    // 7. Auto-Categorize based on merchant
    final category = categorizer.categorize(merchant);

    return TransactionModel(
      id: _uuid.v4(),
      amount: amount,
      type: type,
      category: category,
      merchant: merchant,
      upiApp: upiApp,
      referenceNumber: referenceNumber,
      source: TransactionSource.sms,
      transactionDate: smsDate,
      createdAt: DateTime.now(),
      rawSmsBody: smsBody,
    );
  }

  /// Always title-case the merchant name for premium formatting
  String _neatMerchantName(String name) {
    if (name.isEmpty) return name;
    return name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}
