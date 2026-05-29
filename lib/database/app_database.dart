import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/transactions_table.dart';
import '../models/enums.dart';
import '../models/transaction_model.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [TransactionsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  // ── Mapping Helpers ──
  TransactionModel _mapToModel(TransactionsTableData data) {
    return TransactionModel(
      id: data.id,
      amount: data.amount,
      type: TransactionType.values.byName(data.type),
      category: Category.values.byName(data.category),
      merchant: data.merchant,
      upiApp: data.upiApp != null ? UpiApp.values.byName(data.upiApp!) : null,
      referenceNumber: data.referenceNumber,
      source: TransactionSource.values.byName(data.source),
      transactionDate: data.transactionDate,
      createdAt: data.createdAt,
      rawSmsBody: data.rawSmsBody,
    );
  }

  TransactionsTableCompanion _mapToCompanion(TransactionModel model) {
    return TransactionsTableCompanion(
      id: Value(model.id),
      amount: Value(model.amount),
      type: Value(model.type.name),
      category: Value(model.category.name),
      merchant: Value(model.merchant),
      upiApp: Value(model.upiApp?.name),
      referenceNumber: Value(model.referenceNumber),
      source: Value(model.source.name),
      transactionDate: Value(model.transactionDate),
      createdAt: Value(model.createdAt),
      rawSmsBody: Value(model.rawSmsBody),
    );
  }

  // ── Database Operations ──

  /// Insert or replace transaction
  Future<void> upsertTransaction(TransactionModel transaction) async {
    await into(transactionsTable).insertOnConflictUpdate(_mapToCompanion(transaction));
  }

  /// Batch insert transactions
  Future<void> batchUpsertTransactions(List<TransactionModel> transactions) async {
    await batch((batch) {
      batch.insertAll(
        transactionsTable,
        transactions.map(_mapToCompanion).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  /// Delete transaction by ID
  Future<int> deleteTransaction(String id) {
    return (delete(transactionsTable)..where((t) => t.id.equals(id))).go();
  }

  /// Query all transactions, sorted by transactionDate descending
  Future<List<TransactionModel>> getAllTransactions() async {
    final query = select(transactionsTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)
      ]);
    final results = await query.get();
    return results.map(_mapToModel).toList();
  }

  /// Watch all transactions for reactive updates
  Stream<List<TransactionModel>> watchAllTransactions() {
    final query = select(transactionsTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)
      ]);
    return query.watch().map((list) => list.map(_mapToModel).toList());
  }

  /// Query transactions within a specific date range
  Future<List<TransactionModel>> getTransactionsInRange(DateTime start, DateTime end) async {
    final query = select(transactionsTable)
      ..where((t) => t.transactionDate.isBetweenValues(start, end))
      ..orderBy([
        (t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)
      ]);
    final results = await query.get();
    return results.map(_mapToModel).toList();
  }

  /// Watch transactions within a specific date range
  Stream<List<TransactionModel>> watchTransactionsInRange(DateTime start, DateTime end) {
    final query = select(transactionsTable)
      ..where((t) => t.transactionDate.isBetweenValues(start, end))
      ..orderBy([
        (t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)
      ]);
    return query.watch().map((list) => list.map(_mapToModel).toList());
  }

  /// Clear all database contents (useful for testing/resetting data)
  Future<void> clearAllData() async {
    await delete(transactionsTable).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'spendzone.db'));
    return NativeDatabase.createInBackground(file);
  });
}
