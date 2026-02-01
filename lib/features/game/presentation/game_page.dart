import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/game_state.dart';
import 'providers/game_provider.dart';

class GamePage extends ConsumerStatefulWidget {
  final String gameId;

  const GamePage({super.key, required this.gameId});

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start the game loop when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).startGameLoop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final isMafia = gameState.userRole == PlayerRole.mafia || gameState.userRole == PlayerRole.godfather;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Base Game UI (Day/Night Indicator)
          Center(
             child: Text(
               'PHASE: ${gameState.phase.name.toUpperCase()}', 
               style: TextStyle(color: Colors.white.withOpacity(0.1)),
             ), 
          ),

          // NIGHT ANIMATION OVERLAY
          if (gameState.phase == GamePhase.nightStart)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.nightlight_round, size: 80, color: AppColors.secondary),
                      const Gap(20),
                      Text(
                        'NIGHT FALLS',
                        style: TextStyle(
                            fontFamily: 'BlackOpsOne', color: AppColors.secondary, fontSize: 32),
                      ).animate().fadeIn(duration: 1000.ms).slideY(),
                    ],
                  ),
                ),
              ),
            ),

          // MAFIA CHAT OVERLAY
          if (gameState.phase == GamePhase.mafiaChat)
             if (isMafia) _buildMafiaChat(gameState)
             else _buildInfoScreen('TOWN SLEEPS', Icons.nightlight_round, Colors.blueGrey),

          // INITIAL LOBBY VIEW
          if (gameState.phase == GamePhase.initialLobby)
             _buildLobbyView(gameState),

          // LOBBY VIEW (Day)
          if (gameState.phase == GamePhase.day)
             _buildLobbyView(gameState),

          // MAFIA KILL VOTE GRID
          if (gameState.phase == GamePhase.mafiaVote)
             if (isMafia) _buildActionGrid(
               title: 'ELIMINATE TARGET', 
               color: Colors.red, 
               actionLabel: 'KILL',
               onAction: (id) {}, 
             )
             else _buildInfoScreen('MAFIA IS HUNTING', Icons.warning_amber_rounded, Colors.redAccent),

          // DOCTOR SAVE GRID
          if (gameState.phase == GamePhase.doctorAction)
            if (gameState.userRole == PlayerRole.doctor)
               _buildActionGrid(
                 title: 'SELECT SOMEONE TO SAVE', 
                 color: Colors.green, 
                 actionLabel: 'SAVE',
                 selectedId: gameState.doctorTargetId,
                 onAction: (id) => ref.read(gameProvider.notifier).healPlayer(id),
               )
            else 
               _buildInfoScreen('DOCTOR IS WORKING', Icons.medical_services, Colors.green),

  // DETECTIVE INVESTIGATE GRID
          if (gameState.phase == GamePhase.detectiveAction)
            if (gameState.userRole == PlayerRole.detective)
               _buildDetectiveGrid(
                 title: 'SELECT SUSPECT TO CHECK', 
                 color: Colors.blue, 
                 // If we have a result, we pass it to the specific card via the grid builder logic below
                 targetId: gameState.detectiveTargetId,
                 resultText: gameState.investigationResult,
                 onAction: (id) {
                   if (gameState.detectiveTargetId == null) {
                      ref.read(gameProvider.notifier).investigatePlayer(id);
                   }
                 },
               )
            else 
               _buildInfoScreen('DETECTIVE IS INVESTIGATING', Icons.search, Colors.blue),

          // Global Timer Indicator
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.secondary),
                ),
                child: Text(
                  '00:${gameState.timer.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      fontFamily: 'BlackOpsOne', color: AppColors.accent, fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectiveGrid({
    required String title, 
    required Color color, 
    required Function(int) onAction,
    int? targetId,
    String? resultText,
  }) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.95),
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            children: [
              const Gap(50), 
              Text(
                title,
                style: TextStyle(
                    fontFamily: 'BlackOpsOne', color: color, fontSize: 24),
              ),
              const Gap(20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.65, // Taller for cards
                  ),
                  itemCount: 9, 
                  itemBuilder: (context, index) {
                    final isRevealed = (targetId == index && resultText != null);
                    // Determine card type based on result if revealed
                    // For simulation: Player 3 and 7 are Mafia.
                    final isMafia = (index == 2 || index == 6); 
                    final cardImage = isMafia ? 'assets/images/avatars/mafia.png' : 'assets/images/avatars/villager.png';
                    final roleName = isMafia ? 'MAFIA' : 'CIVILIAN';

                    return DetectiveFlipCard(
                      index: index,
                      isRevealed: isRevealed,
                      frontImage: cardImage,
                      roleName: roleName,
                      onTap: () => onAction(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLobbyView(GameState state) {
    bool isDay = state.phase == GamePhase.day;
    return Positioned.fill(
      child: Container(
        color: AppColors.primary, // Day/Neutral background
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            children: [
              const Gap(40),
              Text(
                isDay ? 'DAY 1' : 'THE TOWN GATHERS',
                style: const TextStyle(
                    fontFamily: 'BlackOpsOne', color: AppColors.textPrimary, fontSize: 28),
              ),
               const Gap(10),
               Text(
                isDay ? 'Discuss and vote to eliminate a suspect.' : 'Get to know your neighbors...',
                style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
              ),
              const Gap(30),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.75, // Taller for portraits
                  ),
                  itemCount: 9, 
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.highlight.withOpacity(0.3)),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/avatars/unknown.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const Gap(5),
                        Text('Player ${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
// ... existing methods ...



  Widget _buildMafiaChat(GameState state) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'MAFIA MEETING',
                  style: TextStyle(
                      fontFamily: 'BlackOpsOne', color: Colors.blueGrey[200], fontSize: 24),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        state.messages[index],
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Discuss strategy...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          fillColor: Colors.white.withOpacity(0.1),
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const Gap(10),
                    IconButton(
                      icon: const Icon(Icons.send, color: AppColors.secondary),
                      onPressed: () {
                        if (_chatController.text.isNotEmpty) {
                          ref.read(gameProvider.notifier).addMessage('Godfather: ${_chatController.text}');
                          _chatController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoScreen(String title, IconData icon, Color color) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 80, color: color.withOpacity(0.5)),
              const Gap(20),
              Text(
                title,
                style: TextStyle(
                    fontFamily: 'BlackOpsOne', color: color, fontSize: 32),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fadeIn(duration: 1000.ms).then().fadeOut(duration: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionGrid({
    required String title, 
    required Color color, 
    required String actionLabel,
    required Function(int) onAction,
    int? selectedId,
    String? resultText,
  }) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.95),
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            children: [
              const Gap(50), // Avoid Timer Overlap
              Text(
                title,
                style: TextStyle(
                    fontFamily: 'BlackOpsOne', color: color, fontSize: 24),
              ),
              const Gap(20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 9, // Example count
                  itemBuilder: (context, index) {
                    final isSelected = selectedId == index;
                    // Special coloring for Result
                    final resultColor = (resultText == 'MAFIA' && isSelected) ? Colors.red : (resultText == 'INNOCENT' && isSelected) ? Colors.green : color;
                    
                    return GestureDetector(
                      onTap: () => onAction(index),
                      child: Column(
                        children: [
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/avatars/unknown.png'),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                  color: isSelected ? resultColor : Colors.grey.withOpacity(0.3),
                                  width: isSelected ? 4 : 1,
                                ),
                                boxShadow: isSelected ? [BoxShadow(color: resultColor, blurRadius: 15)] : [],
                              ),
                            ),
                          ),
                          const Gap(5),
                          Text('Player ${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          const Gap(5),
                           ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? resultColor : color.withOpacity(0.2),
                                side: BorderSide(color: resultColor),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () => onAction(index),
                              child: Text(
                                (isSelected && resultText != null) ? resultText : (isSelected ? 'SELECTED' : actionLabel), 
                                style: TextStyle(
                                  color: isSelected ? Colors.white : color, 
                                  fontSize: 10,
                                  fontWeight: (isSelected && resultText != null) ? FontWeight.bold : FontWeight.normal,
                                )
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetectiveFlipCard extends StatefulWidget {
  final int index;
  final bool isRevealed;
  final String frontImage;
  final String roleName;
  final VoidCallback onTap;

  const DetectiveFlipCard({
    super.key,
    required this.index,
    required this.isRevealed,
    required this.frontImage,
    required this.roleName,
    required this.onTap,
  });

  @override
  State<DetectiveFlipCard> createState() => _DetectiveFlipCardState();
}

class _DetectiveFlipCardState extends State<DetectiveFlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _controller, curve: Curves.easeInOutBack));
    
    if (widget.isRevealed) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(DetectiveFlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRevealed && !oldWidget.isRevealed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isRevealed ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * 3.14159;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);
          
          final isBackVisible = angle >= 1.57;

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: isBackVisible 
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(3.14159), 
                  child: _buildRoleSide()
                )
              : _buildAvatarSide(),
          );
        },
      ),
    );
  }

  Widget _buildAvatarSide() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 5, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/avatars/unknown.png',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          const Gap(5),
          const Text(
            'TAP TO CHECK',
            style: TextStyle(fontFamily: 'BlackOpsOne', color: Colors.blueAccent, fontSize: 10),
          ),
          const Gap(5),
          Text(
            'Player ${widget.index + 1}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const Gap(5),
        ],
      ),
    );
  }

  Widget _buildRoleSide() {
    final isMafia = widget.roleName == 'MAFIA';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isMafia ? Colors.red : Colors.green, width: 3),
        boxShadow: [
          BoxShadow(
              color: (isMafia ? Colors.red : Colors.green).withOpacity(0.6),
              blurRadius: 15,
              spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                widget.frontImage,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          const Gap(5),
          Text(
            widget.roleName,
            style: TextStyle(
              fontFamily: 'BlackOpsOne', 
              color: isMafia ? Colors.red : Colors.green, 
              fontSize: 14
            ),
          ),
          const Gap(8),
        ],
      ),
    );
  }
}
