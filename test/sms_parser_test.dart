import 'package:flutter_test/flutter_test.dart';
import 'package:spend_zone/models/enums.dart';
import 'package:spend_zone/services/merchant_categorizer.dart';
import 'package:spend_zone/services/sms_parser.dart';

void main() {
  group('SmsParser Tests', () {
    late SmsParser parser;
    late MerchantCategorizer categorizer;

    setUp(() {
      categorizer = MerchantCategorizer(rules: {
        'swiggy': 'food',
        'uber': 'transport',
        'shell': 'fuel',
      });
      parser = SmsParser(categorizer: categorizer);
    });

    test('Should parse typical debit SMS correctly', () {
      const smsText =
          'Your A/C XXXXX12345 debited by Rs. 250.00 for payment to Swiggy on 29-05-2026. Ref No: 612345678901.';
      final date = DateTime(2026, 5, 29);
      final tx = parser.parse(smsText, date);

      expect(tx, isNotNull);
      expect(tx!.amount, 250.0);
      expect(tx.type, TransactionType.debit);
      expect(tx.category, Category.food);
      expect(tx.merchant, 'Swiggy');
      expect(tx.referenceNumber, '612345678901');
      expect(tx.source, TransactionSource.sms);
    });

    test('Should parse typical credit SMS correctly', () {
      const smsText =
          'Dear Customer, your a/c X1234 is credited with Rs. 15,000.00 on 28/05/2026. Ref 987654321012.';
      final date = DateTime(2026, 5, 28);
      final tx = parser.parse(smsText, date);

      expect(tx, isNotNull);
      expect(tx!.amount, 15000.0);
      expect(tx.type, TransactionType.credit);
      expect(tx.referenceNumber, '987654321012');
    });

    test('Should parse UPI VPA handles and extract UPI brand', () {
      const smsText =
          'Sent Rs. 500.00 to merchant@ybl via PhonePe. UPI Ref: 123456789012.';
      final date = DateTime(2026, 5, 29);
      final tx = parser.parse(smsText, date);

      expect(tx, isNotNull);
      expect(tx!.amount, 500.0);
      expect(tx.type, TransactionType.debit);
      expect(tx.merchant, 'Merchant');
      expect(tx.upiApp, UpiApp.phonePe);
      expect(tx.referenceNumber, '123456789012');
    });

    test('Should return null for non-transactional SMS messages', () {
      const smsText =
          'Your one-time password (OTP) is 782910. Do not share this with anyone for safety.';
      final date = DateTime.now();
      final tx = parser.parse(smsText, date);

      expect(tx, isNull);
    });
  });
}
