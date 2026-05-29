import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      if (mounted) {
        if (onboardingCompleted) {
          context.go('/dashboard');
        } else {
          context.go('/onboarding');
        }
      }
    } catch (_) {
      if (mounted) {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    Color(0xFF5B4FCF),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 40,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 48,
                color: Colors.white,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            // App name
            Text(
              'SpendZone',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0, duration: 500.ms),
            const SizedBox(height: 8),
            Text(
              'Your money, your insights',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}
