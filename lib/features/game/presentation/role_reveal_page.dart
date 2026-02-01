import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class RoleRevealPage extends StatefulWidget {
  final String gameId;

  const RoleRevealPage({super.key, required this.gameId});

  @override
  State<RoleRevealPage> createState() => _RoleRevealPageState();
}

class _RoleRevealPageState extends State<RoleRevealPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;
  bool _isRevealed = false;
  
  // Timer for auto-start
  late Timer _gameStartTimer;
  int _secondsRemaining = 10;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    _animation.addListener(() {
      if (_animation.value >= 0.5 && _isFront) {
        setState(() {
          _isFront = false;
        });
      } else if (_animation.value < 0.5 && !_isFront) {
        setState(() {
          _isFront = true;
        });
      }
    });

    // Start 10s countdown
    _gameStartTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        if (mounted) {
           context.pushReplacement('/game/${widget.gameId}');
        }
      }
    });
  }

  void _flipCard() {
    if (_isRevealed) {
      _controller.reverse();
      setState(() {
        _isRevealed = false;
      });
    } else {
      _controller.forward();
      setState(() {
        _isRevealed = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _gameStartTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for cinematic feel
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Ambience
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.5),
                    Colors.black,
                  ],
                  radius: 1.5,
                ),
              ),
            ),
          ),

          // Instructions / Title
          Align(
            alignment: const Alignment(0, -0.85), // Higher up to make room
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isRevealed
                      ? const Text(
                          'MY ROLE',
                          key: ValueKey('revealed'),
                          style: TextStyle(
                            fontFamily: 'BlackOpsOne',
                            color: AppColors.accent,
                            fontSize: 36,
                            letterSpacing: 3.0,
                            shadows: [
                              Shadow(color: AppColors.secondary, blurRadius: 20),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          key: const ValueKey('hidden'),
                          children: [
                            Text(
                              'YOUR FATE AWAITS',
                              style: TextStyle(
                                fontFamily: 'BlackOpsOne',
                                color: AppColors.textPrimary.withOpacity(0.8),
                                fontSize: 24,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              'Tap to reveal',
                              style: TextStyle(
                                color: AppColors.textSecondary.withOpacity(0.5),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),
                const Gap(10),
                // Timer Countdown
                Text(
                  'Game starts in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontFamily: 'Courier', 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Card Stack Effect (Visual depth)
          if (!_isRevealed) ...[
            _buildCardBackPlaceholder(scale: 0.9, yOffset: 20, opacity: 0.3),
            _buildCardBackPlaceholder(scale: 0.95, yOffset: 10, opacity: 0.6),
          ],

          // The Main Interactive Card
          GestureDetector(
            onTap: _flipCard,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final angle = _animation.value * pi;
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateY(angle);
                
                return Transform(
                  transform: transform,
                  alignment: Alignment.center,
                  child: _isFront ? _buildCardBack() : _buildCardFront(), 
                );
              },
            ),
          ),
          
          // Continue Button (Appears after reveal - Optional now since timer is auto)
          if (_isRevealed)
             Positioned(
              bottom: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () => context.pushReplacement('/game/${widget.gameId}'),
                child: const Text(
                  'ENTER NOW',
                  style: TextStyle(fontFamily: 'BlackOpsOne', color: Colors.white),
                ),
              ).animate().fadeIn(delay: 1000.ms).slideY(begin: 1.0, end: 0),
            ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      width: 280,
      height: 450, // Increased height
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.highlight.withOpacity(0.3), width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: Stack(
        children: [
          // Pattern
          Opacity(
            opacity: 0.1,
            child: Center(
              child: Image.asset('assets/images/logo/app_icon.png', fit: BoxFit.cover),
            ),
          ),
          // Center Logo
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo/app_icon.png', width: 100),
                const Gap(20),
                Text(
                  'MAFIA',
                  style: TextStyle(
                    fontFamily: 'BlackOpsOne',
                    fontSize: 30,
                    color: AppColors.textPrimary.withOpacity(0.8),
                    letterSpacing: 5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi), 
      child: Container(
        width: 280,
        height: 450, // Increased height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             BoxShadow(color: AppColors.secondary.withOpacity(0.5), blurRadius: 30, spreadRadius: 5),
          ],
        ),
        child: Column(
          children: [
            // Role Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  'assets/images/avatars/detective.png', // Simulated Role
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            // Role Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'YOU ARE THE',
                      style: TextStyle(
                        fontFamily: 'BlackOpsOne',
                        fontSize: 12,
                        color: Colors.grey,
                        letterSpacing: 2,
                      ),
                    ),
                    const Gap(5),
                    const Text(
                      'DETECTIVE',
                      style: TextStyle(
                        fontFamily: 'BlackOpsOne',
                        fontSize: 32,
                        color: Colors.blue,
                      ),
                    ),
                    const Gap(10),
                    const Text(
                      'Find the Mafia. Protect the town. Trust no one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBackPlaceholder({required double scale, required double yOffset, required double opacity}) {
    return Transform.translate(
      offset: Offset(0, yOffset),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 280,
            height: 450, // Increased height
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
          ),
        ),
      ),
    );
  }
}
