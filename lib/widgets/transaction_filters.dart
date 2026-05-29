import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../theme/app_colors.dart';
import '../providers/search_providers.dart';

class TransactionFiltersSheet extends ConsumerWidget {
  const TransactionFiltersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filterProvider);
    final filterNotifier = ref.read(filterProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    filterNotifier.reset();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Spends direction type
            Text(
              'TRANSACTION TYPE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: TransactionType.values.map((type) {
                final isSelected = filters.types.contains(type);
                return FilterChip(
                  label: Text(type.label),
                  selected: isSelected,
                  onSelected: (_) => filterNotifier.toggleType(type),
                  selectedColor: AppColors.primaryContainer,
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Categories
            Text(
              'CATEGORIES',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Category.values.map((cat) {
                final isSelected = filters.categories.contains(cat);
                return FilterChip(
                  label: Text(cat.label),
                  selected: isSelected,
                  onSelected: (_) => filterNotifier.toggleCategory(cat),
                  selectedColor: AppColors.primaryContainer,
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Quick Date Ranges
            Text(
              'QUICK RANGE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                _QuickDateChip(
                  label: 'Today',
                  onTap: () {
                    final today = DateTime.now();
                    filterNotifier.setDateRange(DateTimeRange(start: today, end: today));
                  },
                ),
                _QuickDateChip(
                  label: 'This Week',
                  onTap: () {
                    final now = DateTime.now();
                    final start = now.subtract(Duration(days: now.weekday - 1));
                    filterNotifier.setDateRange(DateTimeRange(start: start, end: now));
                  },
                ),
                _QuickDateChip(
                  label: 'This Month',
                  onTap: () {
                    final now = DateTime.now();
                    final start = DateTime(now.year, now.month, 1);
                    filterNotifier.setDateRange(DateTimeRange(start: start, end: now));
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _QuickDateChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickDateChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.surfaceVariant,
      side: const BorderSide(color: AppColors.border),
    );
  }
}
