import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../models/enums.dart';
import '../../models/transaction_model.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_helpers.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/transaction_filters.dart';
import '../../providers/search_providers.dart';
import '../../providers/transaction_providers.dart';
import '../../providers/sms_providers.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  @override
  Widget build(BuildContext context) {
    final filteredTransactions = ref.watch(filteredTransactionsProvider);
    final filters = ref.watch(filterProvider);
    final searchNotifier = ref.read(filterProvider.notifier);
    final smsScanState = ref.watch(smsScanProvider);

    // Group transactions by date
    final Map<String, List<TransactionModel>> groupedTransactions = {};
    for (final tx in filteredTransactions) {
      final key = DateHelpers.relativeDate(tx.transactionDate);
      if (groupedTransactions[key] == null) {
        groupedTransactions[key] = [];
      }
      groupedTransactions[key]!.add(tx);
    }

    final hasFiltersApplied = filters.categories.isNotEmpty ||
        filters.types.isNotEmpty ||
        filters.dateRange != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Transaction',
            onPressed: () => _showAddTransactionSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(smsScanProvider.notifier).scanTransactions(),
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: Column(
          children: [
            // Search Bar & Filter Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomSearchBar(
                onChanged: (val) => searchNotifier.setQuery(val),
                hasFiltersApplied: hasFiltersApplied,
                onFilterTap: () => _showFiltersSheet(context),
              ),
            ),

            // SMS Scanning Alert State
            if (smsScanState.status == SmsScanStatus.scanning)
              const LinearProgressIndicator(color: AppColors.primary, backgroundColor: AppColors.surfaceVariant),

            // List of Transactions
            Expanded(
              child: filteredTransactions.isEmpty
                  ? EmptyState(
                      icon: hasFiltersApplied ? Icons.search_off_rounded : Icons.receipt_long_rounded,
                      title: hasFiltersApplied ? 'No matching transactions' : 'No transactions recorded',
                      description: hasFiltersApplied
                          ? 'Try resetting the filters or modifying your search query.'
                          : 'Transactions will appear automatically when you receive bank SMS, or you can add one manually.',
                      actionLabel: hasFiltersApplied ? 'Reset Filters' : 'Add Transaction',
                      onActionTap: hasFiltersApplied
                          ? () => searchNotifier.reset()
                          : () => _showAddTransactionSheet(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: groupedTransactions.length,
                      itemBuilder: (context, groupIndex) {
                        final dateGroup = groupedTransactions.keys.elementAt(groupIndex);
                        final dateTxs = groupedTransactions[dateGroup]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date header
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
                              child: Text(
                                dateGroup.toUpperCase(),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.textTertiary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                              ),
                            ),
                            // List of items inside that group
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: dateTxs.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final tx = dateTxs[index];
                                return TransactionTile(
                                  transaction: tx,
                                  onDelete: () {
                                    ref.read(transactionListProvider.notifier).removeTransaction(tx.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Deleted transaction at ${tx.merchant}'),
                                        action: SnackBarAction(
                                          label: 'Undo',
                                          textColor: AppColors.income,
                                          onPressed: () {
                                            ref.read(transactionListProvider.notifier).updateTransaction(tx);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  onTap: () => _showTransactionDetails(context, tx),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFiltersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TransactionFiltersSheet(),
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddTransactionSheet(),
    );
  }

  void _showTransactionDetails(BuildContext context, TransactionModel tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tx.merchant ?? 'Transaction details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'Amount', value: CurrencyFormatter.format(tx.amount), highlightColor: tx.type == TransactionType.debit ? AppColors.expense : AppColors.income),
            _DetailRow(label: 'Type', value: tx.type.label),
            _DetailRow(label: 'Category', value: tx.category.label),
            _DetailRow(label: 'Source', value: tx.source.label),
            _DetailRow(label: 'Date & Time', value: DateHelpers.formatFull(tx.transactionDate)),
            if (tx.referenceNumber != null)
              _DetailRow(label: 'Ref Number', value: tx.referenceNumber!),
            if (tx.upiApp != null && tx.upiApp != UpiApp.unknown)
              _DetailRow(label: 'UPI App', value: tx.upiApp!.label),
            if (tx.rawSmsBody != null) ...[
              const SizedBox(height: 12),
              const Text('RAW SMS MESSAGE', style: TextStyle(fontSize: 10, color: AppColors.textTertiary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
                child: Text(tx.rawSmsBody!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'monospace')),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? highlightColor;

  const _DetailRow({required this.label, required this.value, this.highlightColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: TextStyle(color: highlightColor ?? AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _AddTransactionSheet extends ConsumerStatefulWidget {
  const _AddTransactionSheet();

  @override
  ConsumerState<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<_AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  double _amount = 0;
  String _merchant = '';
  TransactionType _type = TransactionType.debit;
  Category _category = Category.others;
  UpiApp _upiApp = UpiApp.unknown;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Transaction',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Amount
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  prefixIcon: Icon(Icons.currency_rupee_rounded),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter amount';
                  final amt = double.tryParse(val);
                  if (amt == null || amt <= 0) return 'Enter valid amount';
                  return null;
                },
                onSaved: (val) => _amount = double.parse(val!),
              ),
              const SizedBox(height: 16),

              // Merchant
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Payee / Merchant',
                  prefixIcon: Icon(Icons.storefront_rounded),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter payee or merchant';
                  return null;
                },
                onSaved: (val) => _merchant = val!,
              ),
              const SizedBox(height: 16),

              // Debit/Credit Segment Selector
              Text('TYPE', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: TransactionType.values.map((type) {
                  final isSelected = _type == type;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: OutlinedButton(
                        onPressed: () => setState(() => _type = type),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected ? AppColors.primaryContainer : Colors.transparent,
                          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(type.label, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<Category>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                dropdownColor: AppColors.surface,
                items: Category.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.label, style: const TextStyle(color: AppColors.textPrimary)),
                  );
                }).toList(),
                onChanged: (cat) => setState(() => _category = cat!),
              ),
              const SizedBox(height: 16),

              // UPI App dropdown
              DropdownButtonFormField<UpiApp>(
                initialValue: _upiApp,
                decoration: const InputDecoration(
                  labelText: 'UPI App used (Optional)',
                  prefixIcon: Icon(Icons.payment_rounded),
                ),
                dropdownColor: AppColors.surface,
                items: UpiApp.values.map((app) {
                  return DropdownMenuItem(
                    value: app,
                    child: Text(app.label, style: const TextStyle(color: AppColors.textPrimary)),
                  );
                }).toList(),
                onChanged: (app) => setState(() => _upiApp = app!),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      ref.read(transactionListProvider.notifier).addManualTransaction(
                            amount: _amount,
                            type: _type,
                            category: _category,
                            merchant: _merchant,
                            upiApp: _upiApp,
                            transactionDate: DateTime.now(),
                          );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaction added successfully!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save Transaction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
