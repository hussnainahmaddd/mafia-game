enum GamePhase {
  initialLobby,    // Brief look at everyone before night
  nightStart,      // Animation
  mafiaChat,       // 10s
  mafiaVote,       // 5s
  doctorAction,    // 5s
  detectiveAction, // 5s
  dayStart,        // Sunrise animation
  dayResults,      // Who died?
  dayDiscussion,   // 2 mins chat
  dayVote,         // Voting
}

enum PlayerRole {
  mafia,
  godfather,
  doctor,
  villager,
  detective,
}

class GameState {
  final GamePhase phase;
  final int timer;
  final PlayerRole userRole; // For simulation
  final List<String> messages;

  final int? doctorTargetId;
  final int? detectiveTargetId;
  final String? investigationResult; // "MAFIA" or "INNOCENT"
  
  final int? lastKilledId; // Who died last night?
  final List<int> deadPlayerIds; // List of all dead players

  const GameState({
    this.phase = GamePhase.initialLobby,
    this.timer = 0,
    this.userRole = PlayerRole.villager,
    this.messages = const [],
    this.doctorTargetId,
    this.detectiveTargetId,
    this.investigationResult,
    this.lastKilledId,
    this.deadPlayerIds = const [],
  });

  GameState copyWith({
    GamePhase? phase,
    int? timer,
    PlayerRole? userRole,
    List<String>? messages,
    int? doctorTargetId,
    int? detectiveTargetId,
    String? investigationResult,
    int? lastKilledId,
    List<int>? deadPlayerIds,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      timer: timer ?? this.timer,
      userRole: userRole ?? this.userRole,
      messages: messages ?? this.messages,
      doctorTargetId: doctorTargetId ?? this.doctorTargetId,
      detectiveTargetId: detectiveTargetId ?? this.detectiveTargetId,
      investigationResult: investigationResult ?? this.investigationResult,
      lastKilledId: lastKilledId,
      deadPlayerIds: deadPlayerIds ?? this.deadPlayerIds,
    );
  }
}
