import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:spend_zone/database/app_database.dart';
import 'package:spend_zone/models/enums.dart';
import 'package:spend_zone/models/transaction_model.dart';

void main() {
  group('AppDatabase local SQL integration tests', () {
    late AppDatabase database;

    setUp(() {
      // Use in-memory SQLite for high-speed automated testing
      database = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('Should insert and retrieve transaction successfully', () async {
      final tx = TransactionModel(
        id: 'tx-1',
        amount: 2500,
        type: TransactionType.debit,
        category: Category.shopping,
        merchant: 'Zara Clothing',
        upiApp: UpiApp.googlePay,
        referenceNumber: '123456789012',
        source: TransactionSource.sms,
        transactionDate: DateTime(2026, 5, 29, 10, 30),
        createdAt: DateTime.now(),
      );

      await database.upsertTransaction(tx);
      final list = await database.getAllTransactions();

      expect(list.length, 1);
      expect(list[0].id, 'tx-1');
      expect(list[0].merchant, 'Zara Clothing');
      expect(list[0].amount, 2500.0);
    });

    test('Should delete transaction successfully', () async {
      final tx = TransactionModel(
        id: 'tx-delete',
        amount: 500,
        type: TransactionType.debit,
        category: Category.food,
        merchant: 'Zomato',
        upiApp: UpiApp.phonePe,
        source: TransactionSource.manual,
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await database.upsertTransaction(tx);
      var list = await database.getAllTransactions();
      expect(list.length, 1);

      await database.deleteTransaction('tx-delete');
      list = await database.getAllTransactions();
      expect(list.isEmpty, true);
    });

    test('Should filter transactions in date range', () async {
      final tx1 = TransactionModel(
        id: 'tx-range-1',
        amount: 100,
        type: TransactionType.debit,
        category: Category.others,
        source: TransactionSource.manual,
        transactionDate: DateTime(2026, 5, 10),
        createdAt: DateTime.now(),
      );

      final tx2 = TransactionModel(
        id: 'tx-range-2',
        amount: 200,
        type: TransactionType.debit,
        category: Category.others,
        source: TransactionSource.manual,
        transactionDate: DateTime(2026, 5, 20),
        createdAt: DateTime.now(),
      );

      await database.batchUpsertTransactions([tx1, tx2]);

      final filtered = await database.getTransactionsInRange(
        DateTime(2026, 5, 15),
        DateTime(2026, 5, 25),
      );

      expect(filtered.length, 1);
      expect(filtered[0].id, 'tx-range-2');
    });
  });
}
