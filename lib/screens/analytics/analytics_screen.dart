import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../providers/analytics_providers.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/category_pie_chart.dart';
import '../../widgets/upi_usage_chart.dart';
import '../../widgets/analytics_line_chart.dart';
import '../../widgets/analytics_bar_chart.dart';
import '../../utils/date_helpers.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final periodState = ref.watch(analyticsPeriodProvider);
    final analytics = ref.watch(analyticsModelProvider);
    final periodNotifier = ref.read(analyticsPeriodProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selector Segment Row
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: AnalyticsPeriod.values.map((p) {
                    final isSelected = periodState.period == p;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(p.label),
                        selected: isSelected,
                        onSelected: (_) {
                          if (p == AnalyticsPeriod.custom) {
                            _selectCustomDateRange(context, periodNotifier);
                          } else {
                            periodNotifier.setPeriod(p);
                          }
                        },
                        selectedColor: AppColors.primaryContainer,
                        checkmarkColor: AppColors.primary,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              
              // Display Date Range text
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  '${DateHelpers.formatFull(periodState.dateRange.start)} - ${DateHelpers.formatFull(periodState.dateRange.end)}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 16),

              // Summary Net Balance / Cash Flow card
              BalanceCard(
                income: analytics.totalIncome,
                expense: analytics.totalExpense,
              ),
              const SizedBox(height: 24),

              // Spending Trend Line Chart
              AnalyticsLineChart(
                dailySpends: analytics.dailySpends,
                dateRange: periodState.dateRange,
              ),
              const SizedBox(height: 24),

              // Weekly Spends Bar Chart
              AnalyticsBarChart(
                dailySpends: analytics.dailySpends,
                dateRange: periodState.dateRange,
              ),
              const SizedBox(height: 24),

              // Category breakdown Donut Pie Chart
              CategoryPieChart(
                categorySpends: analytics.categorySpends,
              ),
              const SizedBox(height: 24),

              // UPI app usage breakdown list
              UpiUsageChart(
                upiSpends: analytics.upiSpends,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectCustomDateRange(
      BuildContext context, AnalyticsPeriodNotifier notifier) async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      notifier.setPeriod(
        AnalyticsPeriod.custom,
        customRange: DateTimeRange(
          start: pickedRange.start,
          end: pickedRange.end,
        ),
      );
    }
  }
}
