import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/enums.dart';
import '../models/transaction_model.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_helpers.dart';
import 'glass_card.dart';

class RecentTransactions extends StatelessWidget {
  final List<TransactionModel> transactions;
  final VoidCallback? onViewAllTap;
  final Function(TransactionModel)? onTransactionTap;

  const RecentTransactions({
    super.key,
    required this.transactions,
    this.onViewAllTap,
    this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT TRANSACTIONS',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
              if (transactions.isNotEmpty)
                TextButton(
                  onPressed: onViewAllTap,
                  child: Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 40,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No recent transactions',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length > 5 ? 5 : transactions.length,
              separatorBuilder: (context, index) => const Divider(
                height: 24,
                color: AppColors.divider,
              ),
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final categoryColor = AppColors.categoryColors[transaction.category.name] ??
                    AppColors.categoryColors['others']!;
                final isDebit = transaction.type == TransactionType.debit;

                return GestureDetector(
                  onTap: () => onTransactionTap?.call(transaction),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      // Category Icon Badge
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: categoryColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          transaction.category.icon,
                          color: categoryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Merchant and details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.merchant ?? 'Unknown Merchant',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  DateHelpers.relativeDate(transaction.transactionDate),
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                if (transaction.upiApp != null && transaction.upiApp != UpiApp.unknown) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 3,
                                    height: 3,
                                    decoration: const BoxDecoration(
                                      color: AppColors.textTertiary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    transaction.upiApp!.label,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isDebit ? '-' : '+'}${CurrencyFormatter.format(transaction.amount)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isDebit ? AppColors.expense : AppColors.income,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          // Source badge
                          Row(
                            children: [
                              Icon(
                                transaction.source.icon,
                                size: 10,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                transaction.source.label,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.textTertiary,
                                      fontSize: 10,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
