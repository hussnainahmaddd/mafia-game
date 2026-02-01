import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../onboarding/presentation/onboarding_page.dart'; // Reuse animated background

class LobbyPage extends StatelessWidget {
  final String lobbyId;

  const LobbyPage({super.key, required this.lobbyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('GATHERING SUSPECTS', style: TextStyle(fontFamily: 'BlackOpsOne')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background text texture (Subtle)
          const Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: AnimatedAvatarBackground(),
            ),
          ),
          
          // Vignette
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Gap(20),
                // Room Code "Case File" Header
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C1B1B), // Dark brownish/red
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'CASE FILE NO.',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary.withOpacity(0.7),
                              letterSpacing: 3.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Gap(4),
                      Text(
                        lobbyId.split('-').last, // Show just the ID part if long
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontFamily: 'BlackOpsOne',
                              letterSpacing: 4.0,
                            ),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: -0.5, end: 0, duration: 600.ms, curve: Curves.easeOutBack),

                const Gap(30),

                // Players Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 6, // Simulated slots
                    itemBuilder: (context, index) {
                      // Simulating: First 3 joined, others empty
                      final isJoined = index < 3;
                      return _PlayerDossierCard(
                         index: index, 
                         isJoined: isJoined,
                         isReady: index == 0, // Host is ready
                      ).animate().fade(delay: (100 * index).ms).scale();
                    },
                  ),
                ),

                // Start Game Action
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2), // Sharp, brutalist
                        ),
                        elevation: 10,
                        shadowColor: AppColors.secondary.withOpacity(0.5),
                      ),
                      onPressed: () {
                        // Simulate Game Start -> Go to Role Reveal
                        context.push('/game/reveal/$lobbyId');
                      },
                      child: const Text(
                        'INITIATE INVESTIGATION',
                        style: TextStyle(
                          fontFamily: 'BlackOpsOne',
                          fontSize: 18,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ).animate().slideY(begin: 1.0, end: 0, delay: 800.ms, curve: Curves.easeOut),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerDossierCard extends StatelessWidget {
  final int index;
  final bool isJoined;
  final bool isReady;

  const _PlayerDossierCard({
    required this.index,
    required this.isJoined,
    required this.isReady,
  });

  @override
  Widget build(BuildContext context) {
    if (!isJoined) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1), style: BorderStyle.none),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, size: 40, color: Colors.white.withOpacity(0.2)),
              const Gap(8),
              Text(
                'WAITING...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontFamily: 'BlackOpsOne',
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Dark dossier color
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo attached with "Paperclip"
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/avatars/unknown.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Name Label
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.white.withOpacity(0.05),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'PLAYER ${index + 1}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'SUSPECT',
                        style: TextStyle(
                          color: AppColors.secondaryBright,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Paperclip visual (Simulated)
        Positioned(
          top: -10,
          right: 20,
          child: Transform.rotate(
            angle: -0.2, // Tilted paperclip
            child: Container(
              width: 15,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
