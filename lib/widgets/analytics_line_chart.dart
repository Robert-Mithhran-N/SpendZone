import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import 'glass_card.dart';

class AnalyticsLineChart extends StatelessWidget {
  final Map<DateTime, double> dailySpends;
  final DateTimeRange dateRange;

  const AnalyticsLineChart({
    super.key,
    required this.dailySpends,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    final spots = _generateSpots();

    if (spots.isEmpty) {
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SPENDING TREND',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'No spends to display trend line',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final maxVal = dailySpends.values.fold<double>(0, (max, e) => e > max ? e : max);
    final yInterval = maxVal > 0 ? (maxVal / 4).ceilToDouble() : 1000.0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SPENDING TREND',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.divider,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: yInterval > 0 ? yInterval : 1000,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.max) return const SizedBox.shrink();
                        return Text(
                          CurrencyFormatter.formatCompact(value),
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: _calculateXInterval(),
                      getTitlesWidget: (value, meta) {
                        final date = dateRange.start.add(Duration(days: value.toInt()));
                        if (date.isAfter(dateRange.end)) return const SizedBox.shrink();
                        
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('dd MMM').format(date),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: dateRange.end.difference(dateRange.start).inDays.toDouble(),
                minY: 0,
                maxY: maxVal * 1.15,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: spots.length > 2,
                    color: AppColors.expense,
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: spots.length <= 15,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.expense,
                        strokeWidth: 1.5,
                        strokeColor: AppColors.background,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.expense.withValues(alpha: 0.18),
                          AppColors.expense.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    final List<FlSpot> spots = [];
    final days = dateRange.end.difference(dateRange.start).inDays;

    for (int i = 0; i <= days; i++) {
      final date = dateRange.start.add(Duration(days: i));
      final dayKey = DateTime(date.year, date.month, date.day);
      final amount = dailySpends[dayKey] ?? 0;
      spots.add(FlSpot(i.toDouble(), amount));
    }

    // Filter spots if all are 0
    final hasSpends = spots.any((spot) => spot.y > 0);
    if (!hasSpends) return [];

    return spots;
  }

  double _calculateXInterval() {
    final days = dateRange.end.difference(dateRange.start).inDays;
    if (days <= 7) return 1;
    if (days <= 14) return 2;
    if (days <= 31) return 5;
    return (days / 5).ceilToDouble();
  }

}
