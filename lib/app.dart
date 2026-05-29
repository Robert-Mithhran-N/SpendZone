import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'routes/app_router.dart';
import 'providers/theme_provider.dart';

class SpendZoneApp extends ConsumerWidget {
  const SpendZoneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'SpendZone',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.darkTheme, // dark-first, light theme can be added in V2
      routerConfig: appRouter,
    );
  }
}
