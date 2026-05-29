import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import 'glass_card.dart';
import 'animated_counter.dart';

class BalanceCard extends StatelessWidget {
  final double income;
  final double expense;
  final VoidCallback? onTap;

  const BalanceCard({
    super.key,
    required this.income,
    required this.expense,
    this.onTap,
  });

  double get netBalance => income - expense;

  @override
  Widget build(BuildContext context) {
    final isNegative = netBalance < 0;

    return GlassCard(
      onTap: onTap,
      gradientColors: [
        AppColors.primaryContainer.withValues(alpha: 0.3),
        AppColors.surface.withValues(alpha: 0.95),
      ],
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NET BALANCE',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isNegative
                      ? AppColors.expenseSurface
                      : AppColors.incomeSurface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: (isNegative ? AppColors.expense : AppColors.income)
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isNegative
                          ? Icons.trending_down_rounded
                          : Icons.trending_up_rounded,
                      color: isNegative ? AppColors.expense : AppColors.income,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isNegative ? 'Deficit' : 'Surplus',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isNegative ? AppColors.expense : AppColors.income,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedCounter(
            value: netBalance,
            prefix: '₹',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_circle_down_rounded,
                      color: AppColors.income,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Income',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                        ),
                        AnimatedCounter(
                          value: income,
                          prefix: '₹',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 32,
                width: 1,
                color: AppColors.divider,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Expense',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                        ),
                        AnimatedCounter(
                          value: expense,
                          prefix: '₹',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_circle_up_rounded,
                      color: AppColors.expense,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 400.ms);
  }
}
