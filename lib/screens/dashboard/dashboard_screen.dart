import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../models/enums.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/income_card.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/monthly_trend_chart.dart';
import '../../widgets/category_pie_chart.dart';
import '../../widgets/upi_usage_chart.dart';
import '../../widgets/recent_transactions.dart';
import '../../widgets/empty_state.dart';
import '../../providers/transaction_providers.dart';
import '../../providers/sms_providers.dart';
import '../../providers/analytics_providers.dart';
import '../../utils/date_helpers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger an initial scan when dashboard launches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(smsScanProvider.notifier).scanTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final smsScanState = ref.watch(smsScanProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SpendZone',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ),
            Text(
              'Auto-syncing your spends',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: smsScanState.status == SmsScanStatus.scanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Sync SMS transactions',
            onPressed: smsScanState.status == SmsScanStatus.scanning
                ? null
                : () => ref.read(smsScanProvider.notifier).scanTransactions(),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(smsScanProvider.notifier).scanTransactions(),
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height - 180,
                  alignment: Alignment.center,
                  child: EmptyState(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Welcome to SpendZone',
                    description: 'No transactions found. Grant SMS permission to auto-scan your bank messages, or add transactions manually.',
                    actionLabel: 'Go to Settings',
                    onActionTap: () => context.go('/settings'),
                  ),
                ),
              );
            }

            // Retrieve current month figures via dashboardAnalyticsProvider
            final analytics = ref.watch(dashboardAnalyticsProvider);
            final monthIncome = analytics.totalIncome;
            final monthExpense = analytics.totalExpense;
            final categorySpends = analytics.categorySpends;
            final upiSpends = analytics.upiSpends;

            // Calculate Monthly Trend (Last 6 Months)
            final last6Months = DateHelpers.lastNMonths(6);
            final List<String> trendMonths = [];
            final List<double> incomeTrend = [];
            final List<double> expenseTrend = [];

            for (final mDate in last6Months) {
              trendMonths.add(DateFormat('MMM').format(mDate));
              final mStart = DateHelpers.startOfMonth(mDate);
              final mEnd = DateHelpers.endOfMonth(mDate);

              final mTxs = transactions.where((tx) =>
                  tx.transactionDate.isAfter(mStart.subtract(const Duration(seconds: 1))) &&
                  tx.transactionDate.isBefore(mEnd.add(const Duration(seconds: 1))));

              double mInc = 0;
              double mExp = 0;
              for (final tx in mTxs) {
                if (tx.type == TransactionType.credit) {
                  mInc += tx.amount;
                } else {
                  mExp += tx.amount;
                }
              }
              incomeTrend.add(mInc);
              expenseTrend.add(mExp);
            }

            // Recent Transactions
            final recentTxs = transactions.take(5).toList();

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card
                    BalanceCard(
                      income: monthIncome,
                      expense: monthExpense,
                      onTap: () => context.go('/analytics'),
                    ),
                    const SizedBox(height: 16),

                    // Income & Expense row
                    Row(
                      children: [
                        Expanded(
                          child: IncomeCard(
                            amount: monthIncome,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ExpenseCard(
                            amount: monthExpense,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Transactions
                    RecentTransactions(
                      transactions: recentTxs,
                      onViewAllTap: () => context.go('/transactions'),
                      onTransactionTap: (tx) {
                        context.go('/transactions');
                      },
                    ).animate().fadeIn(delay: 100.ms, duration: 450.ms),
                    const SizedBox(height: 24),

                    // Monthly Trend Chart
                    if (incomeTrend.any((e) => e > 0) || expenseTrend.any((e) => e > 0)) ...[
                      MonthlyTrendChart(
                        months: trendMonths,
                        incomeData: incomeTrend,
                        expenseData: expenseTrend,
                      ).animate().fadeIn(delay: 200.ms, duration: 450.ms),
                      const SizedBox(height: 24),
                    ],

                    // Spends Breakdown Pie Chart
                    CategoryPieChart(
                      categorySpends: categorySpends,
                    ).animate().fadeIn(delay: 300.ms, duration: 450.ms),
                    const SizedBox(height: 24),

                    // UPI Spends Bar Chart
                    UpiUsageChart(
                      upiSpends: upiSpends,
                    ).animate().fadeIn(delay: 400.ms, duration: 450.ms),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, stack) => Center(
            child: Text(
              'Error loading dashboard: $err',
              style: const TextStyle(color: AppColors.expense),
            ),
          ),
        ),
      ),
    );
  }
}
