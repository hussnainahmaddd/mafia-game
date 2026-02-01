import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../onboarding/presentation/onboarding_page.dart'; // Reuse animated background

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // 1. Reusing the animated avatar background for consistency & dynamism
          // We apply a heavy dark overlay so it's subtle texture, not distracting
          Positioned.fill(
            child: Opacity(
              opacity: 0.3, 
              child: IgnorePointer(child: AnimatedAvatarBackground()),
            ),
          ),
          
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/images/logo/app_icon.png', width: 40, height: 40)
                          .animate().fade().scale(),
                      IconButton(
                        onPressed: () {}, 
                        icon: const Icon(Icons.settings, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  
                  const Gap(20),

                  // "Wanted" Poster Profile Card
                  _buildProfileCard(context)
                      .animate().slideY(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutBack),

                  const Spacer(),

                  // Cinematic Menu Options
                  Text(
                    'CHOOSE YOUR PATH',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.highlight,
                          letterSpacing: 3.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate().fadeIn(delay: 300.ms),
                  
                  const Gap(20),

                  _CinematicButton(
                    title: 'CREATE GAME',
                    subtitle: 'Host a new session',
                    icon: Icons.add_circle,
                    color: AppColors.secondary,
                    delay: 400.ms,
                    onTap: () => context.push('/create-game'),
                  ),
                  const Gap(16),
                  _CinematicButton(
                    title: 'JOIN GAME',
                    subtitle: 'Enter a room code',
                    icon: Icons.vpn_key,
                    color: AppColors.primaryDark,
                    borderColor: AppColors.highlight,
                    delay: 500.ms,
                    onTap: () {},
                  ),
                  const Gap(16),
                  _CinematicButton(
                    title: 'FIND MATCH',
                    subtitle: 'Join public queue',
                    icon: Icons.public,
                    color: Colors.transparent,
                    borderColor: AppColors.accent,
                    textColor: AppColors.accent,
                    delay: 600.ms,
                    onTap: () {},
                  ),
                  const Gap(16),
                  _CinematicButton(
                    title: 'PREMIUM ACCESS',
                    subtitle: 'Become The Don',
                    icon: Icons.diamond, // or star
                    color: Colors.amber.withOpacity(0.1),
                    borderColor: Colors.amber,
                    textColor: Colors.amber,
                    delay: 700.ms,
                    onTap: () => context.push('/premium'),
                  ),
                  
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2430), // Slightly lighter than bg
        borderRadius: BorderRadius.circular(2), // Sharp corners like a file
        border: Border.all(color: AppColors.highlight.withOpacity(0.2)),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accent.withOpacity(0.5), width: 2),
              image: const DecorationImage(
                image: AssetImage('assets/images/avatars/godfather.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Gap(20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DON HUSSNAIN',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'BlackOpsOne',
                        color: AppColors.textPrimary,
                        letterSpacing: 1.0,
                      ),
                ),
                const Gap(4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
                  ),
                  child: Text(
                    'LEVEL 5 BOSS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.secondaryBright,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Gap(8),
                Text(
                  'Wins: 42  |  Rank: #1',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CinematicButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color? borderColor;
  final Color? textColor;
  final VoidCallback onTap;
  final Duration delay;

  const _CinematicButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.delay,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor ?? Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            if (color != Colors.transparent)
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? Colors.white, size: 28),
            const Gap(20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'BlackOpsOne',
                      color: textColor ?? Colors.white,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: (textColor ?? Colors.white).withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: (textColor ?? Colors.white).withOpacity(0.3), size: 16),
          ],
        ),
      ),
    ).animate(delay: delay).slideX(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutQuart).fadeIn();
  }
}
