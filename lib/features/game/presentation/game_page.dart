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

          // DAY START (Sunrise)
          if (gameState.phase == GamePhase.dayStart)
             _buildInfoScreen('MORNING ARRIVES', 'assets/images/phases/day_sunrise.png', Colors.orangeAccent),

          // DAY RESULTS (Who Died?)
          if (gameState.phase == GamePhase.dayResults)
            _buildLobbyView(gameState),

          // DAY DISCUSSION (Chat)
          if (gameState.phase == GamePhase.dayDiscussion)
             _buildDayChat(gameState),

          // DAY VOTE
          if (gameState.phase == GamePhase.dayVote)
             _buildVotingView(gameState),

          // MAFIA CHAT OVERLAY
          if (gameState.phase == GamePhase.mafiaChat)
             if (isMafia) _buildMafiaChat(gameState)
             else _buildInfoScreen('TOWN SLEEPS', 'assets/images/phases/town_sleeping.png', Colors.blueGrey),

          // INITIAL LOBBY VIEW
          if (gameState.phase == GamePhase.initialLobby)
             _buildLobbyView(gameState),

          // MAFIA KILL VOTE GRID
          if (gameState.phase == GamePhase.mafiaVote)
             if (isMafia) _buildActionGrid(
               title: 'ELIMINATE TARGET', 
               color: Colors.red, 
               actionLabel: 'KILL',
               onAction: (id) {}, 
             )
             else _buildInfoScreen('MAFIA IS HUNTING', 'assets/images/phases/mafia_killing.png', Colors.redAccent),

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
               _buildInfoScreen('DOCTOR IS WORKING', 'assets/images/phases/doctor_working.png', Colors.green),

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
               _buildInfoScreen('DETECTIVE IS INVESTIGATING', 'assets/images/phases/detective_working.png', Colors.blue),

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
                child: Builder(
                  builder: (context) {
                    final minutes = (gameState.timer / 60).floor();
                    final seconds = gameState.timer % 60;
                    return Text(
                      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontFamily: 'BlackOpsOne', color: AppColors.accent, fontSize: 20),
                    );
                  }
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayChat(GameState state) {
    return Positioned.fill(
      child: Container(
        color: AppColors.primary, // Clean background
        child: SafeArea(
          child: Column(
            children: [
              const Gap(60), // Clear the timer
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'TOWN MEETING',
                  style: TextStyle(
                      fontFamily: 'BlackOpsOne', color: Colors.orange[200], fontSize: 28, shadows: [Shadow(color: Colors.orange, blurRadius: 10)]),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length, // Should ideally be separate day messages list
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.1),
                           borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          state.messages[index],
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
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
                          hintText: 'Share your thoughts...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          fillColor: Colors.black.withOpacity(0.5),
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const Gap(10),
                    Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          if (_chatController.text.isNotEmpty) {
                            // Ideally use user's name/role if revealed, or just Player X
                            ref.read(gameProvider.notifier).addMessage('Me: ${_chatController.text}');
                            _chatController.clear();
                          }
                        },
                      ),
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
    bool isDayResults = state.phase == GamePhase.dayResults;
    String title = 'THE TOWN GATHERS';
    String subtitle = 'Get to know your neighbors...';

    if (isDayResults) {
      title = state.lastKilledId != null ? 'TRAGEDY STRIKES!' : 'PEACEFUL NIGHT';
      subtitle = state.lastKilledId != null ? 'Someone was found dead this morning.' : 'The doctor saved the day (or the Mafia slept).';
    }

    return Positioned.fill(
      child: Container(
        color: AppColors.primary, // Neutral background
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            children: [
              const Gap(40),
              Text(
                title,
                style: const TextStyle(
                    fontFamily: 'BlackOpsOne', color: AppColors.textPrimary, fontSize: 28),
              ),
               const Gap(10),
               Text(
                subtitle,
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
                    final isDead = state.deadPlayerIds.contains(index);
                    
                    return Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDead ? Colors.red.withOpacity(0.6) : AppColors.highlight.withOpacity(0.3),
                                    width: isDead ? 2 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: ColorFiltered(
                                    colorFilter: isDead 
                                        ? const ColorFilter.mode(Colors.grey, BlendMode.saturation) 
                                        : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                                    child: Image.asset(
                                      'assets/images/avatars/unknown.png', // Ideally this is the player's actual avatar
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                              ),
                              if (isDead)
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withOpacity(0.4),
                                    child: Center(
                                      child: Transform.rotate(
                                        angle: -0.2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.red, width: 2),
                                            borderRadius: BorderRadius.circular(4),
                                            color: Colors.black.withOpacity(0.5)
                                          ),
                                          child: const Text(
                                            'ELIMINATED',
                                            style: TextStyle(
                                              fontFamily: 'BlackOpsOne',
                                              color: Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Gap(5),
                        Text(
                          'Player ${index + 1}', 
                          style: TextStyle(
                            color: isDead ? Colors.red[200] : Colors.white, 
                            fontSize: 12, 
                            decoration: isDead ? TextDecoration.lineThrough : null,
                            decorationColor: Colors.red,
                          )
                        ),
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

  Widget _buildInfoScreen(String title, String imagePath, Color color) {
    return Positioned.fill(
      child: Container(
        color: Colors.black, // darker background for illustration
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            // Text Content
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.5), width: 2),
                  boxShadow: [
                     BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 15, spreadRadius: 5),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'BlackOpsOne', 
                          color: color, 
                          fontSize: 32, 
                          height: 1.1,
                          shadows: [
                            BoxShadow(color: color.withOpacity(0.8), blurRadius: 20),
                          ]),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fadeIn(duration: 1000.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0)),
                  ],
                ),
              ),
            ),
          ],
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
              const Gap(60), // Avoid Timer Overlap
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


  Widget _buildVotingView(GameState state) {
    print('*** BUILDING VOTING VIEW ***');
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF2C1F1F), // Dark courthouse/room bg
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            children: [
              const Gap(60),
              const Text(
                'CAST YOUR VOTE',
                style: TextStyle(
                    fontFamily: 'BlackOpsOne', color: Colors.redAccent, fontSize: 28, letterSpacing: 1.5),
              ),
               const Gap(10),
               Text(
                'Who do you suspect?',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              const Gap(30),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.65, // Tall for posters
                  ),
                  itemCount: 9, 
                  itemBuilder: (context, index) {
                    final isDead = state.deadPlayerIds.contains(index);
                    if (isDead) return const SizedBox.shrink(); // Hide dead players or show distinct style? Let's hide or dim.

                    // For now, simulate local selection state with a ValueNotifier or just use a local variable?
                    // Since it's stateless here, we depend on provider/callback. 
                    // But we don't have a 'selectedVoteId' in GameState yet? 
                    // The generic grid used 'selectedId', but GameState doesn't track user's vote selection persistantly in UI?
                    // Actually _buildActionGrid passed 'onAction'.
                    // Let's assume we just fire the action. We might need local state for visual feedback if GameState doesn't update immediately.
                    // For UI demo, I'll use a Stateful wrapper or just simulating click effect.
                    
                    return _VotingCard(
                      index: index, 
                      onVote: (id) {
                         // Implement vote logic later, for now just print or no-op visual
                      }
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

// ... existing code ...

class _VotingCard extends StatefulWidget {
  final int index;
  final Function(int) onVote;
  const _VotingCard({required this.index, required this.onVote});

  @override
  State<_VotingCard> createState() => _VotingCardState();
}

class _VotingCardState extends State<_VotingCard> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected;
        });
        if (_isSelected) widget.onVote(widget.index);
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4E1C1), // Paper/parchment color
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 5, offset: const Offset(2, 2))
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                const Text('WANTED', style: TextStyle(fontFamily: 'BlackOpsOne', color: Colors.black87, fontSize: 12)),
                const Gap(4),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      color: Colors.grey[300],
                      image: const DecorationImage(
                        image: AssetImage('assets/images/avatars/unknown.png'),
                        fit: BoxFit.cover,
                      )
                    ),
                  ),
                ),
                const Gap(4),
                Text('Player ${widget.index + 1}', style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 10)),
              ],
            ),
          ),
          if (_isSelected)
            Positioned.fill(
              child: Center(
                child: Transform.rotate(
                  angle: -0.2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'VOTE',
                      style: TextStyle(
                        fontFamily: 'BlackOpsOne',
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
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
