import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/transaction_model.dart';
import 'transaction_providers.dart';

// State models for filters
class TransactionFilters {
  final String query;
  final Set<Category> categories;
  final Set<TransactionType> types;
  final DateTimeRange? dateRange;

  const TransactionFilters({
    this.query = '',
    this.categories = const {},
    this.types = const {},
    this.dateRange,
  });

  TransactionFilters copyWith({
    String? query,
    Set<Category>? categories,
    Set<TransactionType>? types,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
  }) {
    return TransactionFilters(
      query: query ?? this.query,
      categories: categories ?? this.categories,
      types: types ?? this.types,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
    );
  }
}

/// Filter state notifier provider
class FilterNotifier extends StateNotifier<TransactionFilters> {
  FilterNotifier() : super(const TransactionFilters());

  void setQuery(String q) {
    state = state.copyWith(query: q.trim());
  }

  void toggleCategory(Category category) {
    final updated = Set<Category>.from(state.categories);
    if (updated.contains(category)) {
      updated.remove(category);
    } else {
      updated.add(category);
    }
    state = state.copyWith(categories: updated);
  }

  void toggleType(TransactionType type) {
    final updated = Set<TransactionType>.from(state.types);
    if (updated.contains(type)) {
      updated.remove(type);
    } else {
      updated.add(type);
    }
    state = state.copyWith(types: updated);
  }

  void setDateRange(DateTimeRange? range) {
    if (range == null) {
      state = state.copyWith(clearDateRange: true);
    } else {
      state = state.copyWith(dateRange: range);
    }
  }

  void reset() {
    state = const TransactionFilters();
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, TransactionFilters>((ref) {
  return FilterNotifier();
});

/// Exposes the list of transactions after applying search query, category, type, and date-range filters
final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final filters = ref.watch(filterProvider);

  return transactionsAsync.when(
    data: (transactions) {
      return transactions.where((tx) {
        // 1. Search Query filter (Merchant, Reference Number)
        if (filters.query.isNotEmpty) {
          final query = filters.query.toLowerCase();
          final merchant = tx.merchant?.toLowerCase() ?? '';
          final refNum = tx.referenceNumber?.toLowerCase() ?? '';
          final amountStr = tx.amount.toString();
          if (!merchant.contains(query) && !refNum.contains(query) && !amountStr.contains(query)) {
            return false;
          }
        }

        // 2. Category filter
        if (filters.categories.isNotEmpty && !filters.categories.contains(tx.category)) {
          return false;
        }

        // 3. Transaction Type filter
        if (filters.types.isNotEmpty && !filters.types.contains(tx.type)) {
          return false;
        }

        // 4. Date Range filter
        if (filters.dateRange != null) {
          final txDate = tx.transactionDate;
          final start = filters.dateRange!.start;
          final end = filters.dateRange!.end.add(const Duration(days: 1)); // inclusive of end day
          if (txDate.isBefore(start) || txDate.isAfter(end)) {
            return false;
          }
        }

        return true;
      }).toList();
    },
    loading: () => [],
    error: (err, stack) => [],
  );
});
