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

    test('Should check if transaction exists', () async {
      final date = DateTime(2026, 5, 29, 10, 30);
      final tx = TransactionModel(
        id: 'tx-exists-test',
        amount: 350.0,
        type: TransactionType.debit,
        category: Category.bills,
        referenceNumber: 'REF123',
        source: TransactionSource.sms,
        transactionDate: date,
        createdAt: DateTime.now(),
      );

      await database.upsertTransaction(tx);

      final exists = await database.transactionExists(350.0, date, 'REF123');
      expect(exists, true);

      final nonExistentAmount = await database.transactionExists(450.0, date, 'REF123');
      expect(nonExistentAmount, false);

      final nonExistentRef = await database.transactionExists(350.0, date, 'REF999');
      expect(nonExistentRef, false);

      final nonExistentDate = await database.transactionExists(350.0, DateTime(2026, 5, 28), 'REF123');
      expect(nonExistentDate, false);
    });

    test('Should skip duplicates on batch insertion', () async {
      final date = DateTime(2026, 5, 29, 12, 00);
      final tx1 = TransactionModel(
        id: 'tx-orig',
        amount: 99.0,
        type: TransactionType.debit,
        category: Category.food,
        referenceNumber: 'REF99',
        source: TransactionSource.sms,
        transactionDate: date,
        createdAt: DateTime.now(),
      );

      await database.upsertTransaction(tx1);

      final tx2 = TransactionModel(
        id: 'tx-dup',
        amount: 99.0,
        type: TransactionType.debit,
        category: Category.food,
        referenceNumber: 'REF99',
        source: TransactionSource.sms,
        transactionDate: date,
        createdAt: DateTime.now(),
      );

      final tx3 = TransactionModel(
        id: 'tx-new',
        amount: 150.0,
        type: TransactionType.debit,
        category: Category.shopping,
        referenceNumber: 'REF150',
        source: TransactionSource.sms,
        transactionDate: date,
        createdAt: DateTime.now(),
      );

      await database.batchUpsertTransactions([tx2, tx3]);

      final all = await database.getAllTransactions();
      // tx2 (duplicate) should be skipped, so we should only have tx1 and tx3 in db
      expect(all.length, 2);
      final ids = all.map((t) => t.id).toList();
      expect(ids, contains('tx-orig'));
      expect(ids, contains('tx-new'));
      expect(ids, isNot(contains('tx-dup')));
    });

    test('Should upsert idempotently (same ID updates instead of duplicating)', () async {
      final tx = TransactionModel(
        id: 'tx-idempotent',
        amount: 120.0,
        type: TransactionType.debit,
        category: Category.others,
        source: TransactionSource.manual,
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await database.upsertTransaction(tx);
      var list = await database.getAllTransactions();
      expect(list.length, 1);
      expect(list[0].amount, 120.0);

      final updatedTx = tx.copyWith(amount: 150.0);
      await database.upsertTransaction(updatedTx);
      list = await database.getAllTransactions();
      expect(list.length, 1);
      expect(list[0].amount, 150.0);
    });

    test('Should clear database on clearAllData', () async {
      final tx = TransactionModel(
        id: 'tx-clear',
        amount: 50.0,
        type: TransactionType.debit,
        category: Category.others,
        source: TransactionSource.manual,
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await database.upsertTransaction(tx);
      var list = await database.getAllTransactions();
      expect(list.length, 1);

      await database.clearAllData();
      list = await database.getAllTransactions();
      expect(list.isEmpty, true);
    });
  });
}
