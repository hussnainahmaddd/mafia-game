import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToOnboarding();
  }

  Future<void> _navigateToOnboarding() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo/app_icon.png',
              width: 150,
              height: 150,
            )
            .animate()
            .fade(duration: 800.ms)
            .scale(duration: 800.ms, curve: Curves.easeOutBack),
            const Gap(20),
            Text(
              'MAFIA',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.secondaryBright,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
            )
            .animate(delay: 500.ms) // Delay text slightly
            .fade(duration: 800.ms)
            .slideY(begin: 0.5, end: 0, duration: 800.ms, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }
}
