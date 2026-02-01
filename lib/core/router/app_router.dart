import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/lobby/presentation/lobby_page.dart';
import '../../features/game/presentation/game_page.dart';
import '../../features/create_game/presentation/create_game_page.dart';
import '../../features/create_game/presentation/custom_game_page.dart';
import '../../features/game/presentation/role_reveal_page.dart';
import '../../features/premium/presentation/premium_page.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/create-game',
      builder: (context, state) => const CreateGamePage(),
      routes: [
        GoRoute(
          path: 'custom',
          builder: (context, state) => const CustomGamePage(),
        ),
      ],
    ),
    GoRoute(
      path: '/lobby/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'unknown';
        return LobbyPage(lobbyId: id);
      },
    ),
    GoRoute(
      path: '/game/reveal/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'unknown';
        return RoleRevealPage(gameId: id);
      },
    ),
    GoRoute(
      path: '/game/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'unknown';
        return GamePage(gameId: id);
      },
    ),
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumPage(),
    ),
  ],
);
