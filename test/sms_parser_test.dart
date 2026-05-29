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
        'zomato': 'food',
        'uber': 'transport',
        'shell': 'fuel',
        'amazon': 'shopping',
        'netflix': 'entertainment',
        'apollo': 'health',
      });
      parser = SmsParser(categorizer: categorizer);
    });

    // ── Basic Parsing ──

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

    // ── Indian Bank Specific Tests ──

    test('SBI: Should parse SBI debit SMS', () {
      const smsText =
          'Dear SBI Customer, your A/C X1234 debited Rs 2500.00 on 29-05-26. Transfer to JOHN DOE. UPI Ref 412345678901.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.amount, 2500.0);
      expect(tx.type, TransactionType.debit);
    });

    test('HDFC: Should parse HDFC credit SMS', () {
      const smsText =
          'HDFC Bank: Rs 45000.00 credited to a/c XX1234 on 01-05-2026. NEFT Ref AXRHDFC12345678.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 1));
      expect(tx, isNotNull);
      expect(tx!.amount, 45000.0);
      expect(tx.type, TransactionType.credit);
    });

    test('ICICI: Should parse ICICI debit SMS', () {
      const smsText =
          'ICICI Bank Acct XX1234 debited Rs. 1,250.50. IMPS to JANE. Ref 312345678901. Avl Bal Rs 15000.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.amount, 1250.50);
      expect(tx.type, TransactionType.debit);
    });

    test('Axis: Should parse Axis Bank debit SMS', () {
      const smsText =
          'INR 899.00 spent on Axis Bank Card XX1234 at Amazon on 29-05-2026. Ref 512345678901.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.amount, 899.0);
      expect(tx.type, TransactionType.debit);
      expect(tx.category, Category.shopping);
    });

    test('Kotak: Should parse Kotak debit SMS', () {
      const smsText =
          'Rs 3500.00 debited from A/c XX1234 via Kotak. Transfer to MERCHANT. UPI Ref 712345678901.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.amount, 3500.0);
      expect(tx.type, TransactionType.debit);
    });

    test('PNB: Should parse PNB credit SMS', () {
      const smsText =
          'PNB: Rs.25,000.00 credited to Ac XX1234 on 28May26. Ref 812345678901. Avl Bal Rs 50000.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 28));
      expect(tx, isNotNull);
      expect(tx!.amount, 25000.0);
      expect(tx.type, TransactionType.credit);
    });

    test('Canara: Should parse Canara Bank debit SMS', () {
      const smsText =
          'Your Canara Bank A/c XX1234 debited for Rs 750.00 on 29May2026. Transfer to SHOP. Ref 912345678901.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.amount, 750.0);
      expect(tx.type, TransactionType.debit);
    });

    test('Federal Bank: Should parse Federal Bank SMS', () {
      const smsText =
          'Federal Bank: Rs 1500.00 paid to MERCHANT via UPI from XX1234. Ref 112345678901.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.amount, 1500.0);
      expect(tx.type, TransactionType.debit);
    });

    test('IDFC: Should parse IDFC First Bank SMS', () {
      const smsText =
          'IDFC FIRST Bank: Rs. 2000 debited from A/c XX1234. Paid to SHOP. UPI Ref 212345678901.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.amount, 2000.0);
      expect(tx.type, TransactionType.debit);
    });

    test('Union Bank: Should parse Union Bank SMS', () {
      const smsText =
          'Dear Customer, INR 500 has been debited from your Union Bank a/c XX1234. Ref 312345678901.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.amount, 500.0);
      expect(tx.type, TransactionType.debit);
    });

    // ── UPI App Tests ──

    test('Should detect Google Pay', () {
      const smsText = 'Rs 200.00 paid to SHOP via GPay. UPI Ref 123456789012.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.upiApp, UpiApp.googlePay);
    });

    test('Should detect PhonePe', () {
      const smsText = 'Sent Rs 300.00 to SHOP via PhonePe. UPI Ref 123456789012.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.upiApp, UpiApp.phonePe);
    });

    test('Should detect Paytm', () {
      const smsText = 'Rs 150.00 paid to SHOP via Paytm. UPI Ref 123456789012.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.upiApp, UpiApp.paytm);
    });

    test('Should detect Amazon Pay', () {
      const smsText = 'Rs 450.00 paid to SHOP via Amazon Pay. UPI Ref 123456789012.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.upiApp, UpiApp.amazonPay);
    });

    test('Should detect BHIM', () {
      const smsText = 'Rs 100.00 sent to SHOP via BHIM. UPI Ref 123456789012.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.upiApp, UpiApp.bhim);
    });

    test('Should detect WhatsApp Pay', () {
      const smsText = 'Rs 600.00 sent to SHOP via WhatsApp. UPI Ref 123456789012.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.upiApp, UpiApp.whatsAppPay);
    });

    // ── Edge Cases ──

    test('Should handle amounts with commas', () {
      const smsText = 'Rs 1,25,000.00 credited to your account. Ref 123456789012.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.amount, 125000.0);
    });

    test('Should handle amount without decimal places', () {
      const smsText = 'Rs 500 debited from your account. Ref 123456789012.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.amount, 500.0);
    });

    test('Should handle INR prefix', () {
      const smsText = 'INR 750.50 spent at Shell Petrol on 29-05-2026.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.amount, 750.50);
    });

    test('Should classify refund as credit even with debit keywords', () {
      const smsText = 'Refund of Rs 500.00 has been credited to your a/c XX1234. Ref 123456789012.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.type, TransactionType.credit);
    });

    test('Should classify cashback as credit', () {
      const smsText = 'Cashback of Rs 50.00 has been credited to your a/c. Paid via UPI.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.type, TransactionType.credit);
    });

    test('Should return null for messages with no amount', () {
      const smsText = 'Your account has been debited. Please check your balance.';
      final tx = parser.parse(smsText, DateTime.now());
      expect(tx, isNull);
    });

    test('Should handle missing reference number gracefully', () {
      const smsText = 'Rs 200.00 debited from your a/c XX1234. Transfer to SHOP.';
      final tx = parser.parse(smsText, DateTime(2026, 5, 29));
      expect(tx, isNotNull);
      expect(tx!.referenceNumber, isNull);
    });
  });
}
