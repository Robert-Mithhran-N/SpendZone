import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/transaction_model.dart';
import '../models/analytics_model.dart';
import '../utils/date_helpers.dart';
import 'transaction_providers.dart';

enum AnalyticsPeriod {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom;

  String get label {
    switch (this) {
      case AnalyticsPeriod.today:
        return 'Today';
      case AnalyticsPeriod.thisWeek:
        return 'This Week';
      case AnalyticsPeriod.thisMonth:
        return 'This Month';
      case AnalyticsPeriod.thisYear:
        return 'This Year';
      case AnalyticsPeriod.custom:
        return 'Custom';
    }
  }
}

class AnalyticsPeriodState {
  final AnalyticsPeriod period;
  final DateTimeRange dateRange;

  const AnalyticsPeriodState({
    required this.period,
    required this.dateRange,
  });

  AnalyticsPeriodState copyWith({
    AnalyticsPeriod? period,
    DateTimeRange? dateRange,
  }) {
    return AnalyticsPeriodState(
      period: period ?? this.period,
      dateRange: dateRange ?? this.dateRange,
    );
  }
}

class AnalyticsPeriodNotifier extends StateNotifier<AnalyticsPeriodState> {
  AnalyticsPeriodNotifier() : super(_initialState());

  static AnalyticsPeriodState _initialState() {
    final now = DateTime.now();
    return AnalyticsPeriodState(
      period: AnalyticsPeriod.thisMonth,
      dateRange: DateTimeRange(
        start: DateHelpers.startOfMonth(now),
        end: DateHelpers.endOfMonth(now),
      ),
    );
  }

  void setPeriod(AnalyticsPeriod period, {DateTimeRange? customRange}) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (period) {
      case AnalyticsPeriod.today:
        start = DateHelpers.startOfDay(now);
        end = DateHelpers.endOfDay(now);
        break;
      case AnalyticsPeriod.thisWeek:
        start = DateHelpers.startOfWeek(now);
        end = DateHelpers.endOfDay(now);
        break;
      case AnalyticsPeriod.thisMonth:
        start = DateHelpers.startOfMonth(now);
        end = DateHelpers.endOfMonth(now);
        break;
      case AnalyticsPeriod.thisYear:
        start = DateHelpers.startOfYear(now);
        end = DateHelpers.endOfYear(now);
        break;
      case AnalyticsPeriod.custom:
        if (customRange != null) {
          start = DateHelpers.startOfDay(customRange.start);
          end = DateHelpers.endOfDay(customRange.end);
        } else {
          return;
        }
        break;
    }

    state = AnalyticsPeriodState(period: period, dateRange: DateTimeRange(start: start, end: end));
  }
}

final analyticsPeriodProvider =
    StateNotifierProvider<AnalyticsPeriodNotifier, AnalyticsPeriodState>((ref) {
  return AnalyticsPeriodNotifier();
});

/// Helper function to calculate analytics from a list of transactions in a date range
AnalyticsModel calculateAnalytics(
  List<TransactionModel> transactions,
  DateTime start,
  DateTime end,
) {
  final rangeTransactions = transactions.where((tx) {
    final date = tx.transactionDate;
    return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
        date.isBefore(end.add(const Duration(seconds: 1)));
  }).toList();

  double totalIncome = 0;
  double totalExpense = 0;
  final Map<Category, double> categorySpends = {};
  final Map<UpiApp, double> upiSpends = {};
  final Map<DateTime, double> dailySpends = {};

  for (final tx in rangeTransactions) {
    final amt = tx.amount;
    if (tx.type == TransactionType.credit) {
      totalIncome += amt;
    } else {
      totalExpense += amt;
      // Accumulate category spends
      categorySpends[tx.category] = (categorySpends[tx.category] ?? 0) + amt;
      // Accumulate UPI spends
      if (tx.upiApp != null && tx.upiApp != UpiApp.unknown) {
        upiSpends[tx.upiApp!] = (upiSpends[tx.upiApp!] ?? 0) + amt;
      }
      // Accumulate daily spends
      final dayKey = DateHelpers.startOfDay(tx.transactionDate);
      dailySpends[dayKey] = (dailySpends[dayKey] ?? 0) + amt;
    }
  }

  return AnalyticsModel(
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    netCashFlow: totalIncome - totalExpense,
    categorySpends: categorySpends,
    upiSpends: upiSpends,
    dailySpends: dailySpends,
  );
}

/// Exposes calculated AnalyticsModel based on selected period dateRange and transactionList stream
final analyticsModelProvider = Provider<AnalyticsModel>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final periodState = ref.watch(analyticsPeriodProvider);
  final start = periodState.dateRange.start;
  final end = periodState.dateRange.end;

  return transactionsAsync.when(
    data: (transactions) => calculateAnalytics(transactions, start, end),
    loading: () => AnalyticsModel.empty(),
    error: (err, stack) => AnalyticsModel.empty(),
  );
});

/// Exposes calculated AnalyticsModel specifically for the current month, used by the Dashboard
final dashboardAnalyticsProvider = Provider<AnalyticsModel>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final now = DateTime.now();
  final start = DateHelpers.startOfMonth(now);
  final end = DateHelpers.endOfMonth(now);

  return transactionsAsync.when(
    data: (transactions) => calculateAnalytics(transactions, start, end),
    loading: () => AnalyticsModel.empty(),
    error: (err, stack) => AnalyticsModel.empty(),
  );
});

