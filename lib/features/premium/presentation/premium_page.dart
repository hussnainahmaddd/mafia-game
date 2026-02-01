import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Darker base
      body: Stack(
        children: [
           // 1. Background Texture (Godfather Overlay)
           Positioned.fill(
             child: Opacity(
               opacity: 0.2,
               child: Image.asset(
                 'assets/images/avatars/godfather.png',
                 fit: BoxFit.cover,
                 alignment: Alignment.topCenter,
               ),
             ),
           ),
           
           // 2. Gradient Vignette
           Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.9),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                        onPressed: () => context.pop(),
                      ),
                      const Text(
                        'MEMBERSHIP',
                        style: TextStyle(
                          color: Colors.white30,
                          letterSpacing: 4.0,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 40), // Balance
                    ],
                  ),
                ),

                const Gap(10),
                
                // Cinematic Title
                Column(
                  children: [
                    const Text(
                      'JOIN THE FAMILY',
                      style: TextStyle(
                        fontFamily: 'BlackOpsOne',
                        fontSize: 36,
                        color: AppColors.accent,
                        shadows: [
                          BoxShadow(color: AppColors.secondary, blurRadius: 20, spreadRadius: 5),
                        ],
                        letterSpacing: 2.0,
                      ),
                    ).animate().fadeIn().slideY(begin: -0.5, end: 0),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.secondary.withOpacity(0.1),
                      ),
                      child: const Text(
                        'ELEVATE YOUR STATUS',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                  ],
                ),

                const Gap(30),

                // Packages
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildTierCard(
                        title: 'SOLDIER',
                        subtitle: 'WEEKLY TRIBUTE',
                        price: '\$1.99',
                        period: '/ week',
                        features: ['No Ads', 'Bronze Badge'],
                        color: const Color(0xFFCD7F32), // Bronze
                        delay: 300,
                      ),
                      const Gap(24),
                      _buildTierCard(
                        title: 'CAPO',
                        subtitle: 'MONTHLY LOYALTY',
                        price: '\$4.99',
                        period: '/ month',
                        features: ['No Ads', 'Silver Badge', 'Priority Queue', 'Save 40%'],
                        color: const Color(0xFFAAAAAA), // Silver 
                        isPopular: true,
                        delay: 400,
                      ),
                      const Gap(24),
                      _buildTierCard(
                        title: 'GODFATHER',
                        subtitle: 'YEARLY REIGN',
                        price: '\$39.99',
                        period: '/ year',
                        features: ['All Features', 'Gold Badge', 'Exclusive "Don" Screen', 'Save 70%'],
                        color: AppColors.accent, // Gold
                        isBestValue: true,
                        delay: 500,
                      ),
                      const Gap(40),
                    ],
                  ),
                ),

                // Footer
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'RESTORE PURCHASES',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                      letterSpacing: 1.5,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const Gap(10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard({
    required String title,
    required String subtitle,
    required String price,
    required String period,
    required List<String> features,
    required Color color,
    int delay = 0,
    bool isPopular = false,
    bool isBestValue = false,
  }) {
    final borderColor = isPopular || isBestValue ? color : Colors.white.withOpacity(0.1);
    
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24), // Extra top padding for badges
          decoration: BoxDecoration(
            color: const Color(0xFF151515), // Deep dark grey
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: (isPopular || isBestValue) ? 2 : 1),
            boxShadow: [
              if (isPopular || isBestValue)
                BoxShadow(color: color.withOpacity(0.15), blurRadius: 20, spreadRadius: 0),
              const BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'BlackOpsOne',
                          color: color,
                          fontSize: 24,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        period,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(16),
              Divider(color: Colors.white.withOpacity(0.1)),
              const Gap(16),
              ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: color, size: 18),
                    const Gap(12),
                    Text(
                      f, 
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        letterSpacing: 0.5,
                      )
                    ),
                  ],
                ),
              )),
              const Gap(20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), // Sharper
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {},
                child: const Text(
                  'CLAIM OFFER',
                  style: TextStyle(
                    fontFamily: 'BlackOpsOne',
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Stamps
        if (isPopular)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 5)],
              ),
              child: const Text(
                'MOST WANTED',
                style: TextStyle(
                  fontFamily: 'BlackOpsOne',
                  color: Colors.white,
                  fontSize: 10,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          
        if (isBestValue)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 5)],
              ),
              child: const Text(
                'BEST VALUE',
                style: TextStyle(
                  fontFamily: 'BlackOpsOne',
                  color: Colors.black,
                  fontSize: 10,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
      ],
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutQuart);
  }
}
