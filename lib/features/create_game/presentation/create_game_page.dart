import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class CreateGamePage extends StatelessWidget {
  const CreateGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('SELECT GAME MODE', style: TextStyle(fontFamily: 'BlackOpsOne')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, 
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7, // Taller cards (height > width)
                children: [
                  _GameModeCard(
                    title: 'CLASSIC MAFIA',
                    description: '2 Mafia, 1 Detective, 1 Doctor. The original experience.',
                    imagePath: 'assets/images/avatars/mafia.png',
                    color: AppColors.secondary,
                    onTap: () {
                      context.push('/lobby/CLASSIC-${DateTime.now().millisecond}');
                    },
                  ),
                  _GameModeCard(
                    title: 'CHAOS MODE',
                    description: 'Includes Serial Killer, Joker, and Granny with Gun.',
                    imagePath: 'assets/images/avatars/joker.png',
                    color: Colors.purple,
                    onTap: () {
                      context.push('/lobby/CHAOS-${DateTime.now().millisecond}');
                    },
                  ),
                  _GameModeCard(
                    title: 'THE SYNDICATE',
                    description: 'Godfather leads the Mafia. Vigilante joins the Town.',
                    imagePath: 'assets/images/avatars/godfather.png',
                    color: const Color(0xFFD4AF37), // Gold
                    textColor: Colors.black,
                    onTap: () {
                      context.push('/lobby/SYNDICATE-${DateTime.now().millisecond}');
                    },
                  ),
                  _GameModeCard(
                    title: 'CUSTOM LOBBY',
                    description: 'Build your own setup. Choose any roles you want.',
                    imagePath: 'assets/images/avatars/mayor.png', // Placeholder
                    color: AppColors.highlight,
                    onTap: () {
                      context.push('/create-game/custom');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameModeCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _GameModeCard({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.color,
    this.textColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.primaryDark.withOpacity(0.9),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'BlackOpsOne',
                        color: color,
                        fontSize: 16,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.2,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }
}
