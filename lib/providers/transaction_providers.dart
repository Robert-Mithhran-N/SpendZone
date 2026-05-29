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

  /// Insert high-quality mock data for testing/demonstration
  Future<void> loadMockData() async {
    state = const AsyncValue.loading();
    final now = DateTime.now();
    final list = [
      TransactionModel(
        id: _uuid.v4(),
        amount: 850,
        type: TransactionType.debit,
        category: Category.food,
        merchant: 'Swiggy',
        upiApp: UpiApp.phonePe,
        transactionDate: now,
        source: TransactionSource.sms,
        createdAt: now,
      ),
      TransactionModel(
        id: _uuid.v4(),
        amount: 45000,
        type: TransactionType.credit,
        category: Category.salary,
        merchant: 'Acme Corp Salary',
        upiApp: UpiApp.unknown,
        transactionDate: now.subtract(const Duration(days: 1)),
        source: TransactionSource.sms,
        createdAt: now,
      ),
      TransactionModel(
        id: _uuid.v4(),
        amount: 320,
        type: TransactionType.debit,
        category: Category.transport,
        merchant: 'Uber Rides',
        upiApp: UpiApp.googlePay,
        transactionDate: now.subtract(const Duration(days: 1)),
        source: TransactionSource.notification,
        createdAt: now,
      ),
      TransactionModel(
        id: _uuid.v4(),
        amount: 1200,
        type: TransactionType.debit,
        category: Category.shopping,
        merchant: 'Amazon Shopping',
        upiApp: UpiApp.amazonPay,
        transactionDate: now.subtract(const Duration(days: 2)),
        source: TransactionSource.sms,
        createdAt: now,
      ),
      TransactionModel(
        id: _uuid.v4(),
        amount: 199,
        type: TransactionType.debit,
        category: Category.entertainment,
        merchant: 'Spotify Premium',
        upiApp: UpiApp.googlePay,
        transactionDate: now.subtract(const Duration(days: 4)),
        source: TransactionSource.manual,
        createdAt: now,
      ),
      TransactionModel(
        id: _uuid.v4(),
        amount: 2500,
        type: TransactionType.debit,
        category: Category.fuel,
        merchant: 'Shell Petrol Station',
        upiApp: UpiApp.phonePe,
        transactionDate: now.subtract(const Duration(days: 5)),
        source: TransactionSource.sms,
        createdAt: now,
      ),
      TransactionModel(
        id: _uuid.v4(),
        amount: 3000,
        type: TransactionType.credit,
        category: Category.investment,
        merchant: 'Zerodha Dividend',
        upiApp: UpiApp.unknown,
        transactionDate: now.subtract(const Duration(days: 6)),
        source: TransactionSource.imported,
        createdAt: now,
      ),
      TransactionModel(
        id: _uuid.v4(),
        amount: 450,
        type: TransactionType.debit,
        category: Category.health,
        merchant: 'Apollo Pharmacy',
        upiApp: UpiApp.paytm,
        transactionDate: now.subtract(const Duration(days: 7)),
        source: TransactionSource.sms,
        createdAt: now,
      ),
    ];

    try {
      await _db.batchUpsertTransactions(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
