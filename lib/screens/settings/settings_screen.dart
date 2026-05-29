import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../providers/sms_providers.dart';
import '../../providers/transaction_providers.dart';
import '../../providers/database_provider.dart';
import '../../models/transaction_model.dart';
import '../../widgets/glass_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _smsPermissionGranted = false;
  final String _appVersion = '1.0.0 (V1 MVP)';

  @override
  void initState() {
    super.initState();
    _checkPermissionsStatus();
  }

  Future<void> _checkPermissionsStatus() async {
    final status = await Permission.sms.isGranted;
    if (mounted) {
      setState(() {
        _smsPermissionGranted = status;
      });
    }
  }

  Future<void> _requestSmsPermission() async {
    final granted = await ref.read(smsScanProvider.notifier).requestPermission();
    setState(() {
      _smsPermissionGranted = granted;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted ? 'SMS Permission Granted!' : 'SMS Permission Denied.',
          ),
        ),
      );
    }
  }

  Future<void> _exportData() async {
    try {
      final transactions = await ref.read(transactionListProvider.future);
      if (transactions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No transactions to export.')),
          );
        }
        return;
      }

      final jsonList = transactions.map((t) => t.toJson()).toList();
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/spendzone_backup.json');
      await tempFile.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        subject: 'SpendZone Backup',
        text: 'Here is your local SpendZone financial backup file.',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _restoreData() async {
    final textController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restore Backup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Paste the JSON content from your backup file below to restore your transactions.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 6,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                decoration: const InputDecoration(
                  hintText: '[ { "id": "...", "amount": 100, ... } ]',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final input = textController.text.trim();
                if (input.isEmpty) return;

                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                try {
                  final List<dynamic> jsonList = json.decode(input);
                  final transactions = jsonList
                      .map((jsonItem) => TransactionModel.fromJson(
                          jsonItem as Map<String, dynamic>))
                      .toList();

                  for (final tx in transactions) {
                    await ref.read(databaseProvider).upsertTransaction(tx);
                  }

                  // Force a build refresh of the list provider
                  ref.invalidate(transactionListProvider);

                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Successfully restored ${transactions.length} transactions!',
                      ),
                      backgroundColor: AppColors.income,
                    ),
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Invalid backup JSON: $e'),
                      backgroundColor: AppColors.expense,
                    ),
                  );
                }
              },
              child: const Text('Restore', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy is our absolute priority. SpendZone is designed offline-first.',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              SizedBox(height: 12),
              Text(
                '• No financial data is sent to external servers.\n'
                '• All SMS parsing happens 100% locally on your device.\n'
                '• Database backups are stored locally and only shared when you choose to export them.\n'
                '• We do not collect analytics, logs, or personal identifiers.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }



  void _clearDatabase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all scanned and manual transactions. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Delete Everything', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(transactionListProvider.notifier).clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All financial records cleared.'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Preferences
            _sectionHeader('PREFERENCES'),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('CRED inspired dark layout styling'),
                    trailing: Switch(
                      value: isDark,
                      onChanged: (val) => themeNotifier.toggleTheme(),
                      activeTrackColor: AppColors.primary,
                    ),
                    leading: const Icon(Icons.dark_mode_rounded, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section: Permissions
            _sectionHeader('PERMISSIONS'),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('SMS Reader Permission'),
                    subtitle: Text(
                      _smsPermissionGranted
                          ? 'Granted — Scanning SMS'
                          : 'Denied — Manual entry only',
                      style: TextStyle(
                        color: _smsPermissionGranted ? AppColors.income : AppColors.expense,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    leading: const Icon(Icons.sms_rounded, color: AppColors.primary),
                    onTap: _requestSmsPermission,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section: Backup & Restore
            _sectionHeader('DATA MANAGEMENT'),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Export Local Data'),
                    subtitle: const Text('Backup transactions as local JSON'),
                    leading: const Icon(Icons.upload_rounded, color: AppColors.primary),
                    onTap: _exportData,
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Restore Backup'),
                    subtitle: const Text('Restore transactions from JSON string'),
                    leading: const Icon(Icons.download_rounded, color: AppColors.primary),
                    onTap: _restoreData,
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Clear All Database Records'),
                    subtitle: const Text('Permanently delete local SQLite records'),
                    leading: const Icon(Icons.delete_forever_rounded, color: AppColors.expense),
                    onTap: _clearDatabase,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section: App info
            _sectionHeader('LEGAL & ABOUT'),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Privacy Policy'),
                    subtitle: const Text('We keep your finance data local and private'),
                    leading: const Icon(Icons.lock_rounded, color: AppColors.primary),
                    onTap: _showPrivacyPolicy,
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('SpendZone Version'),
                    subtitle: Text(_appVersion),
                    leading: const Icon(Icons.info_rounded, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
