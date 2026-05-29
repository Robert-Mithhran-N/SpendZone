import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../models/enums.dart';
import '../models/transaction_model.dart';
import 'database_provider.dart';

/// Provider that exposes a stream of all transactions in the database
final transactionsStreamProvider = StreamProvider<List<TransactionModel>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllTransactions();
});

/// AsyncNotifier provider managing transaction operations (CRUD)
final transactionListProvider =
    AsyncNotifierProvider<TransactionListNotifier, List<TransactionModel>>(() {
  return TransactionListNotifier();
});

class TransactionListNotifier extends AsyncNotifier<List<TransactionModel>> {
  AppDatabase get _db => ref.read(databaseProvider);
  final _uuid = const Uuid();

  @override
  FutureOr<List<TransactionModel>> build() async {
    // Keep it reactive: watch the database stream
    final stream = _db.watchAllTransactions();
    final controller = StreamController<List<TransactionModel>>();
    
    final subscription = stream.listen((event) {
      state = AsyncValue.data(event);
      controller.add(event);
    }, onError: (err, stack) {
      state = AsyncValue.error(err, stack);
    });

    ref.onDispose(() {
      subscription.cancel();
      controller.close();
    });

    return _db.getAllTransactions();
  }

  /// Add a manual transaction
  Future<void> addManualTransaction({
    required double amount,
    required TransactionType type,
    required Category category,
    String? merchant,
    UpiApp? upiApp,
    String? referenceNumber,
    required DateTime transactionDate,
  }) async {
    state = const AsyncValue.loading();
    final model = TransactionModel(
      id: _uuid.v4(),
      amount: amount,
      type: type,
      category: category,
      merchant: merchant,
      upiApp: upiApp,
      referenceNumber: referenceNumber,
      source: TransactionSource.manual,
      transactionDate: transactionDate,
      createdAt: DateTime.now(),
    );

    try {
      await _db.upsertTransaction(model);
      // State is automatically updated because we are listening to watchAllTransactions
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update an existing transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    state = const AsyncValue.loading();
    try {
      await _db.upsertTransaction(transaction);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete a transaction by ID
  Future<void> removeTransaction(String id) async {
    state = const AsyncValue.loading();
    try {
      await _db.deleteTransaction(id);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Clear all database records
  Future<void> clearAll() async {
    state = const AsyncValue.loading();
    try {
      await _db.clearAllData();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

}
