import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/equity/ui/equity_screen.dart';
import '../features/games/game.dart';
import '../features/games/game_screen.dart';
import '../features/settings/about_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/strength/hand_strength_screen.dart';

/// Переходы без анимации — как переключение разделов в меню.
Page<void> _page(GoRouterState s, Widget child) =>
    NoTransitionPage(key: s.pageKey, child: child);

final appRouter = GoRouter(
  initialLocation: Game.holdem.path,
  routes: [
    for (final g in Game.values)
      GoRoute(
        path: g.path,
        pageBuilder: (_, s) => _page(s, switch (g) {
          Game.ofc => GameScreen(game: g),
          Game.handStrength => const HandStrengthScreen(),
          _ => EquityScreen(game: g),
        }),
      ),
    GoRoute(
      path: '/settings',
      pageBuilder: (_, s) => _page(s, const SettingsScreen()),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (_, s) => _page(s, const AboutScreen()),
    ),
  ],
);
