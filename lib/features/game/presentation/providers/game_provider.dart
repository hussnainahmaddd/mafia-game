import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/game_state.dart';

final gameProvider = NotifierProvider<GameNotifier, GameState>(GameNotifier.new);

class GameNotifier extends Notifier<GameState> {
  Timer? _timer;

  @override
  GameState build() {
    return const GameState();
  }

  void startGameLoop() {
    // 1. Initial Lobby (Show players for 10s)
    state = state.copyWith(phase: GamePhase.initialLobby, timer: 10);
    _startCountdown(() {
      startNightPhase();
    });
  }

  void startNightPhase() {
    // 2. Night Start Animation (Simulate 3s intro)
    state = state.copyWith(phase: GamePhase.nightStart, timer: 3);
    _startCountdown(() {
      // 3. Mafia Chat (10s)
      startMafiaChat();
    });
  }

  void startMafiaChat() {
    state = state.copyWith(phase: GamePhase.mafiaChat, timer: 10, messages: []);
    _startCountdown(() {
      // 3. Mafia Vote (5s)
      startMafiaVote();
    });
  }

  void startMafiaVote() {
    state = state.copyWith(phase: GamePhase.mafiaVote, timer: 5);
    _startCountdown(() {
      // 4. Doctor Action (5s)
      startDoctorAction();
    });
  }

  void startDoctorAction() {
    state = state.copyWith(phase: GamePhase.doctorAction, timer: 15);
    _startCountdown(() {
      startDetectiveAction();
    });
  }

  void startDetectiveAction() {
    state = state.copyWith(phase: GamePhase.detectiveAction, timer: 15, investigationResult: null, detectiveTargetId: null);
    _startCountdown(() {
      // 5. Day Phase
      state = state.copyWith(phase: GamePhase.day, timer: 0);
    });
  }

  void _startCountdown(VoidCallback onDone) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timer > 0) {
        state = state.copyWith(timer: state.timer - 1);
      } else {
        timer.cancel();
        onDone();
      }
    });
  }

  void addMessage(String msg) {
    state = state.copyWith(messages: [...state.messages, msg]);
  }

  void healPlayer(int id) {
    state = state.copyWith(doctorTargetId: id);
  }

  void investigatePlayer(int id) {
    // Correct logic: Check if player is mafia.
    // Since we don't have a real player map yet, we will simulate: 
    // Player 3 and 7 are Mafia for testing.
    final isMafia = (id == 2 || id == 6); // 0-indexed: Player 3, Player 7
    state = state.copyWith(
      detectiveTargetId: id,
      investigationResult: isMafia ? 'MAFIA' : 'INNOCENT',
    );
  }
}
