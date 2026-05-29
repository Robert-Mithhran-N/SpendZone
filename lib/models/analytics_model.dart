import 'enums.dart';

class AnalyticsModel {
  final double totalIncome;
  final double totalExpense;
  final double netCashFlow;
  final Map<Category, double> categorySpends;
  final Map<UpiApp, double> upiSpends;
  final Map<DateTime, double> dailySpends;

  const AnalyticsModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.netCashFlow,
    required this.categorySpends,
    required this.upiSpends,
    required this.dailySpends,
  });

  factory AnalyticsModel.empty() {
    return const AnalyticsModel(
      totalIncome: 0,
      totalExpense: 0,
      netCashFlow: 0,
      categorySpends: {},
      upiSpends: {},
      dailySpends: {},
    );
  }
}
